/**
 * @description Apex class responsible for creating or merging Apex Triggers on specified objects based on Automation Hub records. It uses the Metadata API to deploy trigger code asynchronously.
 * @author Roopan Thangam
 * @since 2026-02-20
 */
public with sharing class AutomationHubTriggerCreator {

    private static final String API_VERSION = '61.0';

    public static void fetchConfigs(Map<Id, Notification_Config__c> notificationConfigMap) {
        List<Notification_Config__c> triggerConfigs = new List<Notification_Config__c>();
        for (Notification_Config__c config : notificationConfigMap.values()) {
            if (config.Do_you_want_to_create_a_trigger__c == true) {
                triggerConfigs.add(config);
            }
        }
        if (!triggerConfigs.isEmpty()) {
            createTriggers(triggerConfigs);
        }
    }

    private static void createTriggers(List<Notification_Config__c> triggerConfigs) {
        String rawNs    = Utility.nameSpace();
        String nsPrefix = String.isNotBlank(rawNs) ? rawNs.removeEnd('__') + '.' : '';

        for (Notification_Config__c config : triggerConfigs) {
            String triggerName   = config.Trigger_Name__c;
            String objectApiName = config.Object_Name__c;

            if (String.isBlank(triggerName) || String.isBlank(objectApiName)) {
                System.debug(LoggingLevel.WARN, 'Skipping config ' + config.Id + ': missing Trigger_Name__c or Object_Name__c');
                continue;
            }

            // Hand off to @future — callouts are not allowed in trigger context
            deployTriggerAsync(triggerName, objectApiName, nsPrefix);
            System.debug(LoggingLevel.INFO, 'Trigger deployment enqueued for: ' + triggerName + ' on ' + objectApiName);
        }
    }

    // ─── Async Deploy (@future) ──────────────────────────────────────────────────

    @future(callout=true)
    private static void deployTriggerAsync(String triggerName, String objectApiName, String nsPrefix) {
        deployTriggerLogic(triggerName, objectApiName, nsPrefix);
    }

    @TestVisible
    private static void deployTriggerLogic(String triggerName, String objectApiName, String nsPrefix) {
        MetadataService.MetadataPort service = createService();

        // Determine effective trigger name and body — query by object, not by trigger name
        String effectiveTriggerName = triggerName;
        String triggerBody;

        try {
            Map<String, String> existing = readExistingTrigger(service, objectApiName);
            if (existing != null) {
                effectiveTriggerName = existing.get('name'); // use the real existing trigger name
                triggerBody = mergeWithExistingBody(existing.get('body'), objectApiName, nsPrefix);
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Could not read existing trigger, creating fresh: ' + e.getMessage());
        }

        if (String.isBlank(triggerBody)) {
            triggerBody = getNewTriggerBody(triggerName, objectApiName, nsPrefix);
        }

        String zipBase64 = buildTriggerZip(effectiveTriggerName, triggerBody);
        if(!Test.isRunningTest()) {
			MetadataServiceHelper.AsyncResult result = service.deploy(zipBase64, getDeployOptions());
            System.debug(LoggingLevel.INFO, 'Deploy job ID: ' + result.id);
        }
    }

    /**
     * Queries the Tooling API for an existing ApexTrigger on the given object (TableEnumOrId).
     * Returns a Map with 'name' and 'body' of the first trigger found, or null if none exists.
     */
    private static Map<String, String> readExistingTrigger(MetadataService.MetadataPort service, String objectApiName) {
        String baseUrl  = URL.getOrgDomainUrl().toExternalForm();
        String endpoint = baseUrl + '/services/data/v' + API_VERSION + '/tooling/query?q='
            + EncodingUtil.urlEncode(
                'SELECT Name, Body FROM ApexTrigger WHERE TableEnumOrId = \'' + objectApiName + '\' AND Status = \'Active\' LIMIT 1',
                'UTF-8'
              );

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer ' + service.SessionHeader.sessionId);
        req.setHeader('Content-Type', 'application/json');

        HttpResponse res = new Http().send(req);
        if (res.getStatusCode() != 200) {
            throw new CalloutException('Tooling API query failed: ' + res.getBody());
        }

        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        List<Object> records = (List<Object>) responseMap.get('records');

        if (records == null || records.isEmpty()) {
            return null; // No existing trigger on this object
        }

        Map<String, Object> record  = (Map<String, Object>) records[0];
        Map<String, String>  result = new Map<String, String>();
        result.put('name', (String) record.get('Name'));
        result.put('body', (String) record.get('Body'));
        return result;
    }

    /**
     * Merges notification logic into an existing trigger body:
     *  1. Adds any missing events (after insert / after update / after delete) to the declaration.
     *  2. Appends the NotificationHelper block before the last closing brace (if not already present).
     */
    @TestVisible
    private static String mergeWithExistingBody(String existingBody, String objectApiName, String nsPrefix) {
        existingBody = ensureEvents(existingBody);

        if (!existingBody.containsIgnoreCase('NotificationHelper')) {
            String logicBlock = getNotificationLogicBlock(nsPrefix);
            Integer lastBrace = existingBody.lastIndexOf('}');
            if (lastBrace >= 0) {
                existingBody = existingBody.substring(0, lastBrace)
                    + logicBlock + '\n}';
            }
        }
        return existingBody;
    }

    /**
     * Ensures the trigger declaration includes after insert, after update, and after delete.
     * Appends any missing events to the existing event list.
     */
    private static String ensureEvents(String body) {
        // Match the trigger declaration's event list: trigger Foo on Bar (...)
        Pattern declarationPattern = Pattern.compile('(?i)(trigger\\s+\\w+\\s+on\\s+\\w+\\s*\\()([^)]*)(\\))');
        Matcher m = declarationPattern.matcher(body);
        if (!m.find()) {
            return body;
        }

        String existingEvents = m.group(2);
        List<String> requiredEvents = new List<String>{ 'after insert', 'after update', 'after delete' };
        List<String> toAdd = new List<String>();

        for (String ev : requiredEvents) {
            if (!existingEvents.containsIgnoreCase(ev)) {
                toAdd.add(ev);
            }
        }

        if (toAdd.isEmpty()) {
            return body;
        }

        String updatedDeclaration = m.group(1) + existingEvents.trim() + ', ' + String.join(toAdd, ', ') + m.group(3);
        return body.replace(m.group(0), updatedDeclaration);
    }

    // ─── Trigger Body Builders ────────────────────────────────────────────────────

    private static String getNewTriggerBody(String triggerName, String objectApiName, String nsPrefix) {
        return 'trigger ' + triggerName + ' on ' + objectApiName + ' (after insert, after update, after delete) {\n'
            + getNotificationLogicBlock(nsPrefix) + '\n'
            + '}';
    }

    private static String getNotificationLogicBlock(String nsPrefix) {
        return '    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {\n'
            + '        ' + nsPrefix + 'NotificationHelper.decisionProcess(Trigger.new, Trigger.oldMap);\n'
            + '    } else if (Trigger.isAfter && Trigger.isDelete) {\n'
            + '        ' + nsPrefix + 'NotificationHelper.handleDelete(Trigger.new);\n'
            + '    }';
    }

    // ─── ZIP Builder ────────────────────────────────────────────────────────────────

    private static String buildTriggerZip(String triggerName, String triggerBody) {
        Zippex sampleZip = new Zippex();
        sampleZip.addFile('package.xml',                                       Blob.valueOf(getPackageXml(triggerName)), null);
        sampleZip.addFile('triggers/' + triggerName + '.trigger-meta.xml',     Blob.valueOf(getTriggerMetadata()),       null);
        sampleZip.addFile('triggers/' + triggerName + '.trigger',              Blob.valueOf(triggerBody),                null);
        return EncodingUtil.base64Encode(sampleZip.getZipArchive());
    }

    // ─── Metadata Helpers ─────────────────────────────────────────────────────────

    private static MetadataService.MetadataPort createService() {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataServiceHelper.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    private static String getPackageXml(String triggerName) {
        return '<?xml version="1.0" encoding="UTF-8"?>'
            + '<Package xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '<types>'
            + '<members>' + triggerName + '</members>'
            + '<name>ApexTrigger</name>'
            + '</types>'
            + '<version>' + API_VERSION + '</version>'
            + '</Package>';
    }

    private static String getTriggerMetadata() {
        return '<?xml version="1.0" encoding="UTF-8"?>'
            + '<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">'
            + '<apiVersion>' + API_VERSION + '</apiVersion>'
            + '<status>Active</status>'
            + '</ApexTrigger>';
    }

    private static MetadataServiceHelper.DeployOptions getDeployOptions() {
        MetadataServiceHelper.DeployOptions opts = new MetadataServiceHelper.DeployOptions();
        opts.allowMissingFiles  = false;
        opts.autoUpdatePackage  = true;
        opts.checkOnly          = false;
        opts.ignoreWarnings     = true;
        opts.performRetrieve    = false;
        opts.purgeOnDelete      = false;
        opts.rollbackOnError    = true;
        opts.runTests           = new String[]{};
        opts.singlePackage      = true;
        opts.testLevel          = 'NoTestRun';
        return opts;
    }
}