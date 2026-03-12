/**
 * @description Utility class to process notifications to action owners and start approval processes.
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version - notification processing
 * 2.0        02/01/2026    Roopan Thangam A       Enhanced email, chatter posts, custom notifications
 */
public with sharing class NotificationProcessHandler {

    private static final String STATUS_SUBMITTED = 'Submitted For Approval';
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_PENDING = 'Pending';
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String FLOW_PARALLEL = 'Parallel';
    private static final String FLOW_SEQUENTIAL = 'Sequential';
    private static final String OWNER_TYPE_USER = 'User';
    private static final String AUTO_APPROVE_INACTIVE_REASON = 'Auto-approved: Assignee inactive';

    /**
     * @description Main entry point for processing records and creating notifications
     * @param records List of SObjects to process
     * @param configIds Set of configuration IDs
     */
    public static void processRecords(List<SObject> records, Set<Id> configIds) {
        if (records == null || records.isEmpty()) {
            return;
        }

        ProcessingContext ctx = initializeContext(records, configIds);
        if (ctx == null || ctx.recordsNeedingApproval.isEmpty()) {
            return;
        }

        NotificationCollector collector = new NotificationCollector();
        processAllRecords(records, ctx, collector);
        executeNotifications(collector);
    }

    private static ProcessingContext initializeContext(List<SObject> records, Set<Id> configIds) {
        ProcessingContext ctx = new ProcessingContext();
        ctx.objectName = records[0].getSObjectType().getDescribe().getName();
        ctx.loggedInUser = getLoggedInUser();

        ctx.configMap = getNotificationConfigs(ctx.objectName, configIds);
        if (ctx.configMap.isEmpty()) {
            return null;
        }

        ctx.conditionMap = getConditionTemplates(ctx.configMap.keySet());
        ctx.actionTemplateMap = getActionTemplates(ctx.configMap);
        ctx.actionCenterMap = getActionCenterTemplates(ctx.configMap);

        // Old global record-level evaluation (kept for reference):
        // ctx.recordsNeedingApproval = evaluateConditions(records, ctx.conditionMap);
        ctx.approvedRecordIdsByConfig = evaluateConditionsByConfig(records, ctx.conditionMap);
        ctx.recordsNeedingApproval = collectApprovedRecordIds(ctx.approvedRecordIdsByConfig);
        if (ctx.recordsNeedingApproval.isEmpty()) {
            return null;
        }

        ctx.recordDataMap = ActionCenterHandler.processEmailContent(ctx.actionCenterMap, ctx.recordsNeedingApproval);
        ctx.notificationContentMap = ActionCenterHandler.processNotificationContent(ctx.actionCenterMap, ctx.recordsNeedingApproval);
        ctx.taskRecordTypeIdMap = ActionCenterHandler.resolveTaskRecordTypeIds(ctx.actionCenterMap);
        ctx.orgWideEmailMap = getOrgWideEmailAddresses(ctx.actionCenterMap);
        ctx.flowTypeNameMap = getFlowType(configIds);
        ctx.recordToParentMap = insertParentCommCenter(records, ctx.objectName, ctx.loggedInUser, ctx.flowTypeNameMap, configIds, ctx.approvedRecordIdsByConfig);

        return ctx;
    }

    private static void processAllRecords(List<SObject> records, ProcessingContext ctx, NotificationCollector collector) {
        for (SObject record : records) {
            if (!ctx.recordsNeedingApproval.contains(record.Id)) {
                continue;
            }
            processRecordConfigs(record, ctx, collector);
        }
    }

    private static void processRecordConfigs(SObject record, ProcessingContext ctx, NotificationCollector collector) {
        for (Id configId : ctx.configMap.keySet()) {
            // Old behavior evaluated records globally and then processed all configs.
            // Keep this check to ensure a record is processed only for configs whose conditions matched.
            if (!isRecordApprovedForConfig(record.Id, configId, ctx.approvedRecordIdsByConfig)) {
                continue;
            }

            Map<Id, Id> parentMap = ctx.recordToParentMap.get(configId);
            if (parentMap == null) {
                continue;
            }

            Id parentCommId = parentMap.get(record.Id);
            String flowTypeName = ctx.flowTypeNameMap.get(configId);
            Notification_Process_Config__c config = ctx.configMap.get(configId);

            processConfigApprovers(record, config, configId, parentCommId, flowTypeName, ctx, collector);
        }
    }

    private static void processConfigApprovers(SObject record, Notification_Process_Config__c config, Id configId,
                                                Id parentCommId, String flowTypeName, ProcessingContext ctx,
                                                NotificationCollector collector) {
        Action_Center_Template__c act = ctx.actionCenterMap.get(config.Action_Center_Template__c);
        List<Action_Template__c> approvers = ctx.actionTemplateMap.get(config.Action_Template__c);

        if (approvers == null) {
            return;
        }

        EmailContent emailContent = prepareEmailContent(record, act, ctx.recordDataMap);
        NotificationContent notifContent = ctx.notificationContentMap.get(record.Id);
        Integer firstSequentialOrder = getFirstSequentialOrder(approvers, flowTypeName);
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> recipientsByTemplateId =
            ActionCenterHandler.resolveApproverRecipientsByTemplate(approvers);

        for (Action_Template__c approver : approvers) {
            if (approver.Parent_Action_Template__c == null) {
                continue;
            }

            List<ActionCenterHandler.ApproverRecipient> recipients = recipientsByTemplateId.get(approver.Id);
            if (recipients == null || recipients.isEmpty()) {
                ActionCenterHandler.ApproverRecipient fallbackRecipient = new ActionCenterHandler.ApproverRecipient();
                fallbackRecipient.configuredOwner = approver.Action_Owner__c;
                fallbackRecipient.effectiveOwner = approver.Action_Owner__c;
                recipients = new List<ActionCenterHandler.ApproverRecipient>{ fallbackRecipient };
            }

            for (ActionCenterHandler.ApproverRecipient recipient : recipients) {
                Comm_Center__c cc = buildCommCenterRecord(
                    record,
                    approver,
                    recipient,
                    configId,
                    parentCommId,
                    flowTypeName,
                    firstSequentialOrder,
                    ctx,
                    emailContent.body
                );
                collector.commCenterRecords.add(cc);

                if (shouldSendNotification(approver, flowTypeName, firstSequentialOrder, cc.Status__c, recipient)) {
                    addNotifications(recipient, act, emailContent, notifContent, record.Id, ctx, collector);
                }
            }
        }
    }

    private static EmailContent prepareEmailContent(SObject record, Action_Center_Template__c act, Map<Id, SObject> recordDataMap) {
        EmailContent content = new EmailContent();
        if (act != null && recordDataMap.containsKey(record.Id)) {
            SObject recordData = recordDataMap.get(record.Id);
            content.body = ActionCenterHub.mergeTemplate(act.Email_Body__c, recordData);
            content.subject = ActionCenterHub.mergeTemplate(act.Email_Subject__c, recordData);
        }
        return content;
    }

    private static Comm_Center__c buildCommCenterRecord(SObject record, Action_Template__c approver,
                                                         ActionCenterHandler.ApproverRecipient recipient, Id configId,
                                                         Id parentCommId, String flowTypeName, Integer firstSequentialOrder,
                                                         ProcessingContext ctx, String emailBody) {
        Comm_Center__c cc = new Comm_Center__c();
        String actionOwnerName = resolveActionOwnerDisplayName(approver, recipient);
        Boolean autoApproveInactive = shouldAutoApproveInactiveFirstApprover(
            approver,
            recipient,
            flowTypeName,
            firstSequentialOrder
        );
        Boolean isFirstSequentialOrder = flowTypeName == FLOW_SEQUENTIAL &&
            approver.Order__c != null &&
            firstSequentialOrder != null &&
            approver.Order__c.intValue() == firstSequentialOrder;
        String recordStatus = STATUS_PENDING;

        if (flowTypeName == FLOW_PARALLEL) {
            recordStatus = STATUS_APPROVED;
        } else if (isFirstSequentialOrder) {
            recordStatus = autoApproveInactive ? STATUS_APPROVED : STATUS_SUBMITTED;
        }

        cc.Name = ctx.loggedInUser.Name + ' - ' + actionOwnerName;
        cc.Record_Id__c = record.Id;
        cc.Status__c = recordStatus;
        cc.Notification_Process_Config__c = configId;
        cc.Action_Owner_Name__c = actionOwnerName;
        cc.User_Name__c = ctx.loggedInUser.Name;
        cc.User_Mail_ID__c = ctx.loggedInUser.Email;
        cc.Object_Name__c = ctx.objectName;
        cc.Description__c = emailBody;
        cc.Order__c = approver.Order__c;
        cc.Is_Optional__c = approver.Is_Optional__c;
        cc.Parent_Comm_Center__c = parentCommId;
        cc.Flow_Type__c = flowTypeName;
        cc.Is_Email_Sent__c = isFirstSequentialOrder || flowTypeName == FLOW_PARALLEL;

        if (recipient != null) {
            if (String.isNotBlank(recipient.email)) {
                cc.Action_Owner_Email_ID__c = recipient.email;
            }
            if (recipient.userId != null) {
                cc.OwnerId = recipient.userId;
            }
            if (autoApproveInactive) {
                cc.Reason__c = AUTO_APPROVE_INACTIVE_REASON;
                cc.Is_Email_Sent__c = true;
            }
        }

        return cc;
    }

    private static Boolean shouldSendNotification(Action_Template__c approver, String flowTypeName,
                                                   Integer firstSequentialOrder, String recordStatus,
                                                   ActionCenterHandler.ApproverRecipient recipient) {
        if (recipient != null && recipient.userId != null && recipient.effectiveOwnerActive == false) {
            return false;
        }
        if (flowTypeName == FLOW_SEQUENTIAL) {
            return approver != null &&
                approver.Order__c != null &&
                firstSequentialOrder != null &&
                approver.Order__c.intValue() == firstSequentialOrder &&
                recordStatus == STATUS_SUBMITTED;
        }
        return flowTypeName == FLOW_PARALLEL;
    }

    private static void addNotifications(ActionCenterHandler.ApproverRecipient recipient, Action_Center_Template__c act,
                                          EmailContent emailContent, NotificationContent notifContent,
                                          Id recordId, ProcessingContext ctx, NotificationCollector collector) {
        String ownerEmail = recipient != null ? recipient.email : null;
        Id ownerId = recipient != null ? recipient.userId : null;

        if (act != null && String.isNotBlank(emailContent.subject) && String.isNotBlank(emailContent.body) && String.isNotBlank(ownerEmail)) {
            collector.emails.add(buildEmail(emailContent, ownerEmail, act, ctx.orgWideEmailMap));
        }

        if (notifContent != null) {
            if (notifContent.pushNotificationEnabled == true && notifContent.chatterPostBody != null) {
                collector.chatterPosts.add(notifContent.chatterPostBody);
            }

            if (String.isNotBlank(notifContent.notificationTitle) && String.isNotBlank(notifContent.notificationBody) && ownerId != null) {
                collector.pushNotifications.add(new PushNotificationData(ownerId, notifContent.notificationTitle, notifContent.notificationBody, recordId));
            }
        }

        if (act != null) {
            Id taskRecordTypeId = ctx.taskRecordTypeIdMap.get(act.Id);
            SObject recordData = ctx.recordDataMap != null ? ctx.recordDataMap.get(recordId) : null;
            Task task = ActionCenterHandler.buildTaskFromTemplate(act, recordId, recordData, ownerId, taskRecordTypeId);
            if (task != null) {
                collector.tasks.add(task);
            }
        }
    }

    private static Messaging.SingleEmailMessage buildEmail(EmailContent content, String toAddress,
                                                            Action_Center_Template__c act, Map<String, Id> orgWideEmailMap) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setSubject(content.subject);
        email.setHtmlBody(content.body);
        email.setToAddresses(new List<String>{ toAddress });

        if (String.isNotBlank(act.Org_Wide_Email_Address__c) && orgWideEmailMap.containsKey(act.Org_Wide_Email_Address__c)) {
            email.setOrgWideEmailAddressId(orgWideEmailMap.get(act.Org_Wide_Email_Address__c));
        }
        return email;
    }

    private static void executeNotifications(NotificationCollector collector) {
        List<Comm_Center__c> insertedCommCenterRecords = new List<Comm_Center__c>();
        if (!collector.commCenterRecords.isEmpty() && Comm_Center__c.SObjectType.getDescribe().isCreateable()) {
            Database.SaveResult[] insertResults = Database.insert(collector.commCenterRecords, false);
            for (Integer i = 0; i < insertResults.size(); i++) {
                if (insertResults[i].isSuccess()) {
                    insertedCommCenterRecords.add(collector.commCenterRecords[i]);
                }
            }
        }

        if (!insertedCommCenterRecords.isEmpty()) {
            progressAutoApprovedFirstApprovers(insertedCommCenterRecords);
        }

        if (!collector.tasks.isEmpty() && Task.SObjectType.getDescribe().isCreateable()) {
            Database.insert(collector.tasks, false);
        }

        if (!collector.emails.isEmpty() && !Test.isRunningTest()) {
            sendEmails(collector.emails);
        }

        if (!collector.chatterPosts.isEmpty()) {
            ActionCenterHub.postChatterPosts(collector.chatterPosts);
        }

        if (!collector.pushNotifications.isEmpty() && !Test.isRunningTest()) {
            sendCustomNotifications(collector.pushNotifications);
        }
    }

    private static String resolveActionOwnerDisplayName(Action_Template__c approver, ActionCenterHandler.ApproverRecipient recipient) {
        if (recipient == null) {
            return approver.Action_Owner__c;
        }
        String baseName = String.isNotBlank(recipient.effectiveOwner) ? recipient.effectiveOwner : approver.Action_Owner__c;
        if (recipient.delegated == true && String.isNotBlank(recipient.delegatedFromOwner)) {
            return baseName + ' (Delegated from ' + recipient.delegatedFromOwner + ')';
        }
        return baseName;
    }

    private static Boolean shouldAutoApproveInactiveFirstApprover(Action_Template__c approver,
                                                                   ActionCenterHandler.ApproverRecipient recipient,
                                                                   String flowTypeName,
                                                                   Integer firstSequentialOrder) {
        if (approver == null || recipient == null || flowTypeName != FLOW_SEQUENTIAL) {
            return false;
        }
        if (approver.Order__c == null || firstSequentialOrder == null) {
            return false;
        }
        if (approver.Order__c.intValue() != firstSequentialOrder) {
            return false;
        }
        return recipient.userId != null && recipient.effectiveOwnerActive == false;
    }

    private static void progressAutoApprovedFirstApprovers(List<Comm_Center__c> insertedCommCenterRecords) {
        Map<String, Comm_Center__c> progressionSeedsByKey = new Map<String, Comm_Center__c>();

        for (Comm_Center__c commRecord : insertedCommCenterRecords) {
            if (commRecord == null || commRecord.Parent_Comm_Center__c == null) {
                continue;
            }
            if (commRecord.Flow_Type__c != FLOW_SEQUENTIAL) {
                continue;
            }
            if (commRecord.Status__c != STATUS_APPROVED || commRecord.Reason__c != AUTO_APPROVE_INACTIVE_REASON) {
                continue;
            }
            if (commRecord.Order__c == null) {
                continue;
            }

            Id recordId = parseRecordId(commRecord.Record_Id__c);
            if (recordId == null) {
                continue;
            }

            String seedKey = String.valueOf(recordId) + '|' + String.valueOf(commRecord.Order__c.intValue());
            if (!progressionSeedsByKey.containsKey(seedKey)) {
                progressionSeedsByKey.put(seedKey, commRecord);
            }
        }

        for (Comm_Center__c seed : progressionSeedsByKey.values()) {
            Id recordId = parseRecordId(seed.Record_Id__c);
            if (recordId == null || seed.Order__c == null) {
                continue;
            }
            try {
                CommCenterHelper.processNextApprovers(
                    seed.Order__c.intValue(),
                    recordId,
                    STATUS_APPROVED,
                    seed.Parent_Comm_Center__c
                );
            } catch (Exception ex) {
                System.debug(
                    LoggingLevel.ERROR,
                    'Failed to auto-progress inactive first approver for Comm Center ' + seed.Id + ': ' + ex.getMessage()
                );
            }
        }
    }

    private static Integer getFirstSequentialOrder(List<Action_Template__c> approvers, String flowTypeName) {
        if (flowTypeName != FLOW_SEQUENTIAL || approvers == null || approvers.isEmpty()) {
            return null;
        }
        Integer firstOrder = null;
        for (Action_Template__c approver : approvers) {
            if (approver == null || approver.Parent_Action_Template__c == null || approver.Order__c == null) {
                continue;
            }
            Integer orderValue = approver.Order__c.intValue();
            if (firstOrder == null || orderValue < firstOrder) {
                firstOrder = orderValue;
            }
        }
        return firstOrder;
    }

    private static Id parseRecordId(String recordIdValue) {
        if (String.isBlank(recordIdValue)) {
            return null;
        }
        String trimmedValue = recordIdValue.trim();
        if (!Utility.isSalesforceId(trimmedValue)) {
            return null;
        }
        return (Id) trimmedValue;
    }
    /**
     * @description Public method to send custom notifications for approval status changes
     *              RT 22JAN26 - Added for CommCenterHelper to call on approval/rejection
     * @param title Notification title
     * @param body Notification body
     * @param targetRecordId The record to navigate to when notification is clicked
     * @param recipientUserIds Set of user IDs to send notifications to
     */
    public static void sendApprovalNotifications(String title, String body, Id targetRecordId, Set<Id> recipientUserIds) {
        if (String.isBlank(title) || String.isBlank(body) || targetRecordId == null || recipientUserIds == null || recipientUserIds.isEmpty()) {
            return;
        }

        if (Test.isRunningTest()) {
            return;
        }

        List<PushNotificationData> pushDataList = new List<PushNotificationData>();
        for (Id userId : recipientUserIds) {
            pushDataList.add(new PushNotificationData(userId, title, body, targetRecordId));
        }

        sendCustomNotifications(pushDataList);
    }

    /**
     * @description Sends custom notifications to specified users
     * @param pushDataList List of push notification data
     */
    private static void sendCustomNotifications(List<PushNotificationData> pushDataList) {
        List<CustomNotificationType> notificationTypes = [
            SELECT Id, DeveloperName
            FROM CustomNotificationType
            WHERE DeveloperName = 'Approval_Notification'
            LIMIT 1
        ];

        if (notificationTypes.isEmpty()) {
            System.debug(LoggingLevel.WARN, 'Custom Notification Type "Approval_Notification" not found.');
            return;
        }

        Id notificationTypeId = notificationTypes[0].Id;

        for (PushNotificationData pushData : pushDataList) {
            sendSingleNotification(pushData, notificationTypeId);
        }
    }

    private static void sendSingleNotification(PushNotificationData pushData, Id notificationTypeId) {
        try {
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            notification.setTitle(pushData.title);
            notification.setBody(pushData.body);
            notification.setNotificationTypeId(notificationTypeId);
            notification.setTargetId(pushData.recordId);

            Set<String> recipients = new Set<String>{ String.valueOf(pushData.userId) };
            notification.send(recipients);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Notification failed for user ' + pushData.userId + ': ' + e.getMessage());
        }
    }

    /**
     * @description Sends all emails with error handling
     * @param emailMessages List of email messages to send
     */
    private static void sendEmails(List<Messaging.SingleEmailMessage> emailMessages) {
        try {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailMessages);
            logEmailResults(results);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Email sending failed: ' + e.getMessage());
        }
    }

    private static void logEmailResults(Messaging.SendEmailResult[] results) {
        for (Integer i = 0; i < results.size(); i++) {
            if (!results[i].isSuccess()) {
                System.debug(LoggingLevel.ERROR, 'Email failed at index ' + i + ': ' + results[i].getErrors()[0].getMessage());
            }
        }
    }

    private static User getLoggedInUser() {
        return [SELECT Id, Name, Email FROM User WHERE Id = :UserInfo.getUserId() WITH SECURITY_ENFORCED LIMIT 1];
    }

    private static Set<String> extractActionOwnerNames(Map<Id, List<Action_Template__c>> actionTemplateMap) {
        Set<String> actionOwnerNames = new Set<String>();
        for (List<Action_Template__c> templates : actionTemplateMap.values()) {
            for (Action_Template__c template : templates) {
                if (template.Action_Owner_Type__c == OWNER_TYPE_USER && String.isNotBlank(template.Action_Owner__c)) {
                    actionOwnerNames.add(template.Action_Owner__c);
                }
            }
        }
        return actionOwnerNames;
    }

    private static Map<String, String> getActionOwnerEmails(Set<String> actionOwnerNames) {
        Map<String, String> actionOwnerEmailMap = new Map<String, String>();
        if (actionOwnerNames.isEmpty()) {
            return actionOwnerEmailMap;
        }

        for (User usr : [SELECT Name, Email FROM User WHERE Name IN :actionOwnerNames AND IsActive = true]) {
            actionOwnerEmailMap.put(usr.Name, usr.Email);
        }
        return actionOwnerEmailMap;
    }

    private static Map<String, Id> getActionOwnerIds(Set<String> actionOwnerNames) {
        Map<String, Id> actionOwnerIdMap = new Map<String, Id>();
        if (actionOwnerNames.isEmpty()) {
            return actionOwnerIdMap;
        }

        for (User usr : [SELECT Id, Name FROM User WHERE Name IN :actionOwnerNames AND IsActive = true]) {
            actionOwnerIdMap.put(usr.Name, usr.Id);
        }
        return actionOwnerIdMap;
    }
    
    private static Map<Id, Notification_Process_Config__c> getNotificationConfigs(String objectName, Set<Id> configIds) {
        return new Map<Id, Notification_Process_Config__c>([
            SELECT Id, Name, Status__c, Is_Active__c, Action_Template__c, Action_Center_Template__c,
                   Parent_Notification_Process_Config__c, Order__c, Notification_Config__c,
                   Notification_Config__r.Object_Name__c
            FROM Notification_Process_Config__c
            WHERE Id IN :configIds
              AND Notification_Config__r.Object_Name__c = :objectName
              AND Order__c = 1
              AND Is_Active__c = true
        ]);
    }

    /**
     * @description Retrieves condition templates for given config IDs
     * @param configIds Set of configuration IDs
     * @return Map of config ID to list of Field_Meta__c conditions
     */
    public static Map<Id, List<Field_Meta__c>> getConditionTemplates(Set<Id> configIds) {
        Map<Id, List<Field_Meta__c>> conditionMap = new Map<Id, List<Field_Meta__c>>();

        for (Field_Meta__c cond : [
            SELECT Id, Name, api_name__c, filterValue__c, order__c, Notification_Process_Config__c,
                   Condition__c, Logical_Criteria__c, Object_Name__c, Is_Active__c, Next_Condition__c, Operation_Type__c
            FROM Field_Meta__c
            WHERE Notification_Process_Config__c IN :configIds
            AND Is_Active__c = true
            AND Operation_Type__c = 'Conditional'
            ORDER BY Order__c ASC
        ]) {
            if (!conditionMap.containsKey(cond.Notification_Process_Config__c)) {
                conditionMap.put(cond.Notification_Process_Config__c, new List<Field_Meta__c>());
            }
            conditionMap.get(cond.Notification_Process_Config__c).add(cond);
        }
        return conditionMap;
    }

    private static Map<Id, List<Action_Template__c>> getActionTemplates(Map<Id, Notification_Process_Config__c> configMap) {
        Map<Id, List<Action_Template__c>> actionTemplateMap = new Map<Id, List<Action_Template__c>>();
        Set<Id> actionTemplateIds = new Set<Id>();

        for (Notification_Process_Config__c config : configMap.values()) {
            if (config.Action_Template__c != null) {
                actionTemplateIds.add(config.Action_Template__c);
            }
        }

        if (actionTemplateIds.isEmpty()) {
            return actionTemplateMap;
        }

        for (Action_Template__c approver : [
            SELECT Id, Name, Order__c, Action_Owner_Type__c, Action_Owner__c, Parent_Action_Template__c,
                   Is_Optional__c, Is_Active__c, Flow_Type__c,
                   (SELECT Id, Name, Order__c, Action_Owner_Type__c, Action_Owner__c, Parent_Action_Template__c,
                           Is_Optional__c, Is_Active__c, Flow_Type__c
                    FROM Action_Template__r
                    WHERE Is_Active__c = true
                    ORDER BY Order__c ASC)
            FROM Action_Template__c
            WHERE Id IN :actionTemplateIds
              AND Is_Active__c = true
            ORDER BY Order__c ASC
        ]) {
            if (!actionTemplateMap.containsKey(approver.Id)) {
                actionTemplateMap.put(approver.Id, new List<Action_Template__c>());
            }
            actionTemplateMap.get(approver.Id).add(approver);

            if (approver.Action_Template__r != null && !approver.Action_Template__r.isEmpty()) {
                for (Action_Template__c child : approver.Action_Template__r) {
                    actionTemplateMap.get(approver.Id).add(child);
                }
            }
        }
        return actionTemplateMap;
    }

    /*
    private static Set<Id> evaluateConditions(List<SObject> records, Map<Id, List<Field_Meta__c>> conditionMap) {
        Set<Id> approvedRecords = new Set<Id>();
        for (SObject record : records) {
            for (Id configId : conditionMap.keySet()) {
                if (ConditionControlHandler.evaluateConditions(record, conditionMap.get(configId))) {
                    approvedRecords.add(record.Id);
                }
            }
        }
        return approvedRecords;
    }
    */

    private static Map<Id, Set<Id>> evaluateConditionsByConfig(List<SObject> records, Map<Id, List<Field_Meta__c>> conditionMap) {
        Map<Id, Set<Id>> approvedRecordIdsByConfig = new Map<Id, Set<Id>>();

        for (Id configId : conditionMap.keySet()) {
            approvedRecordIdsByConfig.put(configId, new Set<Id>());
        }

        for (SObject record : records) {
            for (Id configId : conditionMap.keySet()) {
                if (ConditionControlHandler.evaluateConditions(record, conditionMap.get(configId))) {
                    approvedRecordIdsByConfig.get(configId).add(record.Id);
                }
            }
        }

        return approvedRecordIdsByConfig;
    }

    private static Set<Id> collectApprovedRecordIds(Map<Id, Set<Id>> approvedRecordIdsByConfig) {
        Set<Id> approvedRecords = new Set<Id>();
        for (Set<Id> recordIds : approvedRecordIdsByConfig.values()) {
            approvedRecords.addAll(recordIds);
        }
        return approvedRecords;
    }

    private static Boolean isRecordApprovedForConfig(Id recordId, Id configId, Map<Id, Set<Id>> approvedRecordIdsByConfig) {
        if (recordId == null || configId == null || approvedRecordIdsByConfig == null) {
            return false;
        }
        if (!approvedRecordIdsByConfig.containsKey(configId)) {
            return false;
        }
        return approvedRecordIdsByConfig.get(configId).contains(recordId);
    }

    private static Map<Id, Map<Id, Id>> insertParentCommCenter(List<SObject> records, String objectName,
                                                                User loggedInUser, Map<Id, String> flowTypeNameMap,
                                                                Set<Id> validConfigIds, Map<Id, Set<Id>> approvedRecordIdsByConfig) {
        List<Comm_Center__c> parentRecords = new List<Comm_Center__c>();
        Map<Id, Map<Id, Id>> recordToParentMap = new Map<Id, Map<Id, Id>>();
        Integer orderNumber = 1;

        for (SObject record : records) {
            // Old behavior (kept for reference):
            // for (Id configId : validConfigIds) {
            //     String flowTypeName = flowTypeNameMap.get(configId);
            //     Comm_Center__c parentCC = new Comm_Center__c(
            //         Name = 'Approval Process - ' + objectName,
            //         Record_Id__c = record.Id,
            //         Status__c = (flowTypeName == FLOW_PARALLEL) ? STATUS_COMPLETED : STATUS_PENDING,
            //         Object_Name__c = objectName,
            //         User_Name__c = loggedInUser.Name,
            //         User_Mail_ID__c = loggedInUser.Email,
            //         Flow_Type__c = flowTypeName,
            //         Notification_Process_Config__c = configId,
            //         Order__c = orderNumber
            //     );
            //     parentRecords.add(parentCC);
            //     orderNumber++;
            // }
            for (Id configId : validConfigIds) {
                if (!isRecordApprovedForConfig(record.Id, configId, approvedRecordIdsByConfig)) {
                    continue;
                }

                String flowTypeName = flowTypeNameMap.get(configId);
                Comm_Center__c parentCC = new Comm_Center__c(
                    Name = 'Approval Process - ' + objectName,
                    Record_Id__c = record.Id,
                    Status__c = (flowTypeName == FLOW_PARALLEL) ? STATUS_COMPLETED : STATUS_PENDING,
                    Object_Name__c = objectName,
                    User_Name__c = loggedInUser.Name,
                    User_Mail_ID__c = loggedInUser.Email,
                    Flow_Type__c = flowTypeName,
                    Notification_Process_Config__c = configId,
                    Order__c = orderNumber
                );
                parentRecords.add(parentCC);
                orderNumber++;
            }
        }

        if (!parentRecords.isEmpty()) {
            insert parentRecords;

            for (Comm_Center__c parentComm : parentRecords) {
                if (!recordToParentMap.containsKey(parentComm.Notification_Process_Config__c)) {
                    recordToParentMap.put(parentComm.Notification_Process_Config__c, new Map<Id, Id>());
                }
                recordToParentMap.get(parentComm.Notification_Process_Config__c).put(parentComm.Record_Id__c, parentComm.Id);
            }
        }
        return recordToParentMap;
    }

    private static Map<Id, Action_Center_Template__c> getActionCenterTemplates(Map<Id, Notification_Process_Config__c> configMap) {
        Set<Id> actionCenterTemplateIds = new Set<Id>();
        for (Notification_Process_Config__c config : configMap.values()) {
            if (config.Action_Center_Template__c != null) {
                actionCenterTemplateIds.add(config.Action_Center_Template__c);
            }
        }

        if (actionCenterTemplateIds.isEmpty()) {
            return new Map<Id, Action_Center_Template__c>();
        }

        return new Map<Id, Action_Center_Template__c>([
            SELECT Id, Name, Object_Name__c, Task_RecordType__c, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c,
                   Post_to_Chatter_Email__c, Email_Subject__c, Email_Body__c, Post_to_Chatter_Push_Notification__c,
                   Notification_Title__c, Notification_Body__c, Post_Body__c, Is_Active__c, Org_Wide_Email_Address__c
            FROM Action_Center_Template__c
            WHERE Id IN :actionCenterTemplateIds
              AND Is_Active__c = true
        ]);
    }

    private static Map<String, Id> getOrgWideEmailAddresses(Map<Id, Action_Center_Template__c> actionCenterMap) {
        Set<String> emailAddresses = new Set<String>();
        for (Action_Center_Template__c act : actionCenterMap.values()) {
            if (String.isNotBlank(act.Org_Wide_Email_Address__c)) {
                emailAddresses.add(act.Org_Wide_Email_Address__c);
            }
        }

        Map<String, Id> orgWideEmailMap = new Map<String, Id>();
        if (!emailAddresses.isEmpty()) {
            for (OrgWideEmailAddress owea : [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address IN :emailAddresses]) {
                orgWideEmailMap.put(owea.Address, owea.Id);
            }
        }
        return orgWideEmailMap;
    }

    private static Map<Id, String> getFlowType(Set<Id> validConfigIds) {
        Map<Id, String> flowTypeNameMap = new Map<Id, String>();

        for (Notification_Process_Config__c npc : [
            SELECT Id, Action_Template__r.Flow_Type__c
            FROM Notification_Process_Config__c
            WHERE Id IN :validConfigIds
              AND Is_Active__c = true
        ]) {
            if (npc.Action_Template__r != null) {
                flowTypeNameMap.put(npc.Id, npc.Action_Template__r.Flow_Type__c);
            }
        }
        return flowTypeNameMap;
    }

    // RT 22JAN26 - Added Wrapper Classes for better structure
    /**
     * @description Inner class to hold processing context data
     */
    private class ProcessingContext {
        public String objectName;
        public User loggedInUser;
        public Map<Id, Notification_Process_Config__c> configMap;
        public Map<Id, List<Field_Meta__c>> conditionMap;
        public Map<Id, List<Action_Template__c>> actionTemplateMap;
        public Map<Id, Action_Center_Template__c> actionCenterMap;
        public Map<String, String> actionOwnerEmailMap;
        public Map<String, Id> actionOwnerIdMap;
        public Map<Id, Set<Id>> approvedRecordIdsByConfig;
        public Set<Id> recordsNeedingApproval;
        public Map<Id, SObject> recordDataMap;
        public Map<Id, NotificationContent> notificationContentMap;
        public Map<Id, Id> taskRecordTypeIdMap;
        public Map<String, Id> orgWideEmailMap;
        public Map<Id, String> flowTypeNameMap;
        public Map<Id, Map<Id, Id>> recordToParentMap;
    }

    /**
     * @description Inner class to collect notification data before execution
     */
    private class NotificationCollector {
        public List<Comm_Center__c> commCenterRecords = new List<Comm_Center__c>();
        public List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        public List<Task> tasks = new List<Task>();
        public List<PushNotificationData> pushNotifications = new List<PushNotificationData>();
        public List<ConnectApi.FeedItemInput> chatterPosts = new List<ConnectApi.FeedItemInput>();
    }

    /**
     * @description Inner class to hold email content
     */
    private class EmailContent {
        public String subject = '';
        public String body = '';
    }

    /**
     * @description Inner class to hold push notification data
     */
    private class PushNotificationData {
        public Id userId;
        public String title;
        public String body;
        public Id recordId;

        public PushNotificationData(Id userId, String title, String body, Id recordId) {
            this.userId = userId;
            this.title = title;
            this.body = body;
            this.recordId = recordId;
        }
    }
}