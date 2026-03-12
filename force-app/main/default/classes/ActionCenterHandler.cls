/**
 * @description Support class to convert field API names to real-time data and manage email template creation.
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version - field meta to data conversion
 * 2.0        02/01/2026    Roopan Thangam A       Added notification content and chatter processing and code optimised
 */
public with sharing class ActionCenterHandler {

    private static final String TEMPLATE_NPC = 'Notification_Process_Config__c';
    private static final String TEMPLATE_ACT = 'Action_Center_Template__c';
    private static final String OP_CONDITIONAL = 'Conditional';
    private static final String OP_QUERY = 'Query';
    private static final String TASK_SOBJECT = 'Task';
    private static final String OWNER_TYPE_USER = 'User';

    /**
     * @description Processes email content by fetching and merging field data
     * @param actionCenterMap Map of Action Center Templates
     * @param sobjectrecordIds Set of record IDs to process
     * @return Map of record ID to SObject with merged data
     */
    public static Map<Id, SObject> processEmailContent(Map<Id, Action_Center_Template__c> actionCenterMap, Set<Id> sobjectrecordIds) {
        TemplateContext ctx = extractTemplateContext(actionCenterMap);

        if (ctx.templateIds.isEmpty()) {
            return new Map<Id, SObject>();
        }

        return convertFieldMetaToData(ctx.objectName, sobjectrecordIds, TEMPLATE_ACT, ctx.templateIds);
    }

    /**
     * @description Processes notification content (Chatter and Push Notifications)
     * @param actionCenterMap Map of Action Center Templates
     * @param sobjectrecordIds Set of record IDs to process
     * @return Map of record ID to NotificationContent
     */
    public static Map<Id, NotificationContent> processNotificationContent(Map<Id, Action_Center_Template__c> actionCenterMap, Set<Id> sobjectrecordIds) {
        Map<Id, NotificationContent> notificationContentMap = new Map<Id, NotificationContent>();
        TemplateContext ctx = extractTemplateContext(actionCenterMap);

        if (ctx.templateIds.isEmpty()) {
            return notificationContentMap;
        }

        Map<Id, SObject> parentRecords = convertFieldMetaToData(ctx.objectName, sobjectrecordIds, TEMPLATE_ACT, ctx.templateIds);

        for (Id recordId : parentRecords.keySet()) {
            SObject recordData = parentRecords.get(recordId);
            NotificationContent content = buildNotificationContent(recordData, recordId, actionCenterMap, ctx.objectName);
            if (content != null) {
                notificationContentMap.put(recordId, content);
            }
        }

        return notificationContentMap;
    }

    /**
     * @description Sends email notifications based on configuration
     * @param notificationProcessConfigId Set of config IDs
     * @param emailList List of recipient email addresses
     * @param recordIds Set of record IDs
     */
    public static void sendEmailNotification(Set<Id> notificationProcessConfigId, List<String> emailList, Set<Id> recordIds) {
        List<Notification_Process_Config__c> configs = [
            SELECT Id, Action_Center_Template__c, Notification_Config__r.Object_Name__c
            FROM Notification_Process_Config__c
            WHERE Id IN :notificationProcessConfigId
              AND Is_Active__c = true
            LIMIT 1
        ];

        if (configs.isEmpty()) {
            return;
        }

        Notification_Process_Config__c config = configs[0];
        Action_Center_Template__c act = getActionCenterTemplate(config);

        if (act == null) {
            return;
        }

        List<Messaging.SingleEmailMessage> mailList = buildEmailsFromTemplate(act, recordIds, emailList);

        if (!mailList.isEmpty()) {
            Messaging.sendEmail(mailList);
        }
    }

    /**
     * @description Prepares email template message
     * @param subject Email subject
     * @param messageBody Email body
     * @param emailList List of recipients
     * @param orgWideEmailAddress Org-wide email address
     * @return List of prepared email messages
     */
    public static List<Messaging.SingleEmailMessage> prepareMailTemplate(String subject, String messageBody,
                                                                          List<String> emailList, String orgWideEmailAddress) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();

        if (emailList.isEmpty()) {
            return mailList;
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setUseSignature(false);
        mail.setToAddresses(emailList);
        mail.setSubject(subject);
        mail.setHtmlBody(messageBody);
        mail.setSaveAsActivity(false);

        setOrgWideEmailAddress(mail, orgWideEmailAddress);
        mailList.add(mail);

        return mailList;
    }

    // RT 20FEB26 - Added method to resolve Task RecordTypeIds based on Action Center Template configuration
    public static Map<Id, Id> resolveTaskRecordTypeIds(Map<Id, Action_Center_Template__c> actionCenterMap) {
        Map<Id, Id> templateToRecordTypeId = new Map<Id, Id>();
        if (actionCenterMap == null || actionCenterMap.isEmpty()) {
            return templateToRecordTypeId;
        }

        Set<String> recordTypeKeys = new Set<String>();
        for (Action_Center_Template__c act : actionCenterMap.values()) {
            if (String.isNotBlank(act.Task_RecordType__c)) {
                recordTypeKeys.add(act.Task_RecordType__c.trim());
            }
        }

        if (recordTypeKeys.isEmpty()) {
            return templateToRecordTypeId;
        }

        Map<String, Id> resolvedByKey = new Map<String, Id>();
        for (String key : recordTypeKeys) {
            if (Utility.isSalesforceId(key) && String.valueOf(key).startsWith('012')) {
                resolvedByKey.put(key, (Id) key);
            }
        }

        Set<String> lookupKeys = new Set<String>();
        for (String key : recordTypeKeys) {
            if (!resolvedByKey.containsKey(key)) {
                lookupKeys.add(key);
            }
        }

        if (!lookupKeys.isEmpty()) {
            for (RecordType rt : [
                SELECT Id, Name, DeveloperName
                FROM RecordType
                WHERE SObjectType = :TASK_SOBJECT
                  AND (Name IN :lookupKeys OR DeveloperName IN :lookupKeys)
            ]) {
                resolvedByKey.put(rt.Name, rt.Id);
                resolvedByKey.put(rt.DeveloperName, rt.Id);
            }
        }

        for (Action_Center_Template__c act : actionCenterMap.values()) {
            String key = String.isBlank(act.Task_RecordType__c) ? null : act.Task_RecordType__c.trim();
            if (key != null && resolvedByKey.containsKey(key)) {
                templateToRecordTypeId.put(act.Id, resolvedByKey.get(key));
            }
        }

        return templateToRecordTypeId;
    }

    /**
     * @description Creates a Task from Action Center template and record data.
     * @param act Action Center template
     * @param recordId Business record Id used for Task relation
     * @param recordData Merged field data for template tokens
     * @param ownerId Task owner Id
     * @param taskRecordTypeId Task RecordTypeId
     * @return Built Task or null when no subject/comments are configured
     */
    public static Task buildTaskFromTemplate(Action_Center_Template__c act, Id recordId, SObject recordData,
                                             Id ownerId, Id taskRecordTypeId) {
        if (act == null || recordId == null) {
            return null;
        }

        String mergedSubject = mergeTaskField(act.Task_Subject__c, recordData);
        String mergedComments = mergeTaskField(act.Task_Comments__c, recordData);

        if (String.isBlank(mergedSubject) && String.isBlank(mergedComments)) {
            return null;
        }

        Task task = new Task();
        task.Status = act.Task_Status__c;
        task.Priority = act.Task_Priority__c;
        task.Subject = String.isBlank(mergedSubject) ? 'Approval Task' : trimToLength(mergedSubject, 255);

        if (String.isNotBlank(mergedComments)) {
            task.Description = mergedComments;
        }

        if (ownerId != null) {
            task.OwnerId = ownerId;
        }

        if (!canUseAsWhoId(recordId)) {
            task.WhatId = recordId;
        }

        Id whoId = resolveWhoId(recordId, recordData);
        if (whoId != null) {
            task.WhoId = whoId;
        }

        return task;
    }

    /**
     * @description Represents a resolved approval recipient, optionally delegated from a configured owner.
     */
    public class ApproverRecipient {
        public String configuredOwner;
        public String effectiveOwner;
        public Id configuredOwnerId;
        public String configuredOwnerEmail;
        public Id userId;
        public String email;
        public Boolean effectiveOwnerActive = true;
        public Boolean delegated = false;
        public String delegatedFromOwner;
    }

    /**
     * @description Resolves approvers (including comma/semicolon-separated users) and delegated approvers.
     * @param approvers Action template child approvers for a config
     * @return Map of Action_Template__c.Id to resolved recipients
     */
    public static Map<Id, List<ApproverRecipient>> resolveApproverRecipientsByTemplate(List<Action_Template__c> approvers) {
        Map<Id, List<ApproverRecipient>> recipientsByTemplateId = new Map<Id, List<ApproverRecipient>>();
        if (approvers == null || approvers.isEmpty()) {
            return recipientsByTemplateId;
        }

        Map<Id, List<String>> userTokensByTemplateId = new Map<Id, List<String>>();
        Set<Id> userIds = new Set<Id>();
        Set<String> userLookupValues = new Set<String>();

        for (Action_Template__c approver : approvers) {
            if (approver == null || approver.Id == null || approver.Parent_Action_Template__c == null) {
                continue;
            }

            List<String> ownerTokens = splitOwnerTokens(approver.Action_Owner__c);
            if (ownerTokens.isEmpty()) {
                continue;
            }

            if (approver.Action_Owner_Type__c != OWNER_TYPE_USER) {
                List<ApproverRecipient> unresolvedRecipients = new List<ApproverRecipient>();
                for (String ownerToken : ownerTokens) {
                    ApproverRecipient unresolved = new ApproverRecipient();
                    unresolved.configuredOwner = ownerToken;
                    unresolved.effectiveOwner = ownerToken;
                    unresolvedRecipients.add(unresolved);
                }
                recipientsByTemplateId.put(approver.Id, unresolvedRecipients);
                continue;
            }

            userTokensByTemplateId.put(approver.Id, ownerTokens);
            for (String ownerToken : ownerTokens) {
                if (Utility.isSalesforceId(ownerToken) && ownerToken.startsWith('005')) {
                    userIds.add((Id) ownerToken);
                } else {
                    userLookupValues.add(ownerToken);
                }
            }
        }

        Map<String, List<User>> usersByLookupKey = new Map<String, List<User>>();
        Set<Id> delegatedApproverIds = new Set<Id>();
        if (!userIds.isEmpty() || !userLookupValues.isEmpty()) {
            for (User usr : [
                SELECT Id, Name, Email, Username, Alias, DelegatedApproverId, IsActive
                FROM User
                WHERE (
                    Id IN :userIds
                    OR Name IN :userLookupValues
                    OR Username IN :userLookupValues
                    OR Email IN :userLookupValues
                    OR Alias IN :userLookupValues
                )
            ]) {
                addUserLookupKey(usersByLookupKey, String.valueOf(usr.Id), usr);
                addUserLookupKey(usersByLookupKey, usr.Name, usr);
                addUserLookupKey(usersByLookupKey, usr.Username, usr);
                addUserLookupKey(usersByLookupKey, usr.Email, usr);
                addUserLookupKey(usersByLookupKey, usr.Alias, usr);
                if (usr.DelegatedApproverId != null) {
                    delegatedApproverIds.add(usr.DelegatedApproverId);
                }
            }
        }

        Map<Id, User> delegatedUsersById = new Map<Id, User>();
        if (!delegatedApproverIds.isEmpty()) {
            for (User delegateUser : [
                SELECT Id, Name, Email, IsActive
                FROM User
                WHERE Id IN :delegatedApproverIds
            ]) {
                delegatedUsersById.put(delegateUser.Id, delegateUser);
            }
        }

        for (Id templateId : userTokensByTemplateId.keySet()) {
            List<ApproverRecipient> recipients = new List<ApproverRecipient>();
            Set<String> seenRecipientKeys = new Set<String>();

            for (String userToken : userTokensByTemplateId.get(templateId)) {
                List<User> matchingUsers = usersByLookupKey.get(userToken.toLowerCase());
                if (matchingUsers == null || matchingUsers.isEmpty()) {
                    ApproverRecipient unresolved = new ApproverRecipient();
                    unresolved.configuredOwner = userToken;
                    unresolved.effectiveOwner = userToken;
                    recipients.add(unresolved);
                    continue;
                }

                for (User configuredUser : matchingUsers) {
                    ApproverRecipient recipient = buildRecipient(configuredUser, userToken, delegatedUsersById);
                    String dedupeKey = buildRecipientDedupeKey(recipient);
                    if (String.isNotBlank(dedupeKey) && seenRecipientKeys.contains(dedupeKey)) {
                        continue;
                    }
                    if (String.isNotBlank(dedupeKey)) {
                        seenRecipientKeys.add(dedupeKey);
                    }
                    recipients.add(recipient);
                }
            }
            recipientsByTemplateId.put(templateId, recipients);
        }

        return recipientsByTemplateId;
    }

    /**
     * @description Converts field metadata to actual record data
     * @param sobjName Object API name
     * @param sobjectrecordIds Record IDs to query
     * @param templateObjectName Template object type
     * @param templateObjectId Template object IDs
     * @return Map of record ID to SObject data
     */
    public static Map<Id, SObject> convertFieldMetaToData(String sobjName, Set<Id> sobjectrecordIds,
                                                           String templateObjectName, Set<Id> templateObjectId) {
        Map<Id, SObject> parentRecords = new Map<Id, SObject>();
        List<Field_Meta__c> fieldLoaderRecords = queryFieldMeta(templateObjectName, templateObjectId, sobjName);

        if (fieldLoaderRecords.isEmpty()) {
            return parentRecords;
        }

        FieldOrganizer organizer = organizeFields(fieldLoaderRecords);
        return executeFieldQuery(organizer, sobjectrecordIds);
    }

    private static TemplateContext extractTemplateContext(Map<Id, Action_Center_Template__c> actionCenterMap) {
        TemplateContext ctx = new TemplateContext();

        for (Action_Center_Template__c act : actionCenterMap.values()) {
            if (String.isNotBlank(act.Object_Name__c)) {
                ctx.objectName = act.Object_Name__c;
                ctx.templateIds.add(act.Id);
            }
        }

        return ctx;
    }

    private static NotificationContent buildNotificationContent(SObject recordData, Id recordId,
                                                                 Map<Id, Action_Center_Template__c> actionCenterMap,
                                                                 String objectName) {
        for (Action_Center_Template__c act : actionCenterMap.values()) {
            if (act.Object_Name__c == objectName) {
                NotificationContent content = new NotificationContent();

                if (String.isNotBlank(act.Notification_Title__c)) {
                    content.notificationTitle = ActionCenterHub.mergeTemplate(act.Notification_Title__c, recordData);
                }

                if (String.isNotBlank(act.Notification_Body__c)) {
                    content.notificationBody = ActionCenterHub.mergeTemplate(act.Notification_Body__c, recordData);
                }

                if (String.isNotBlank(act.Post_Body__c)) {
                    content.chatterPostBody = ActionCenterHub.buildChatterPost(recordId, act.Post_Body__c, recordData);
                }

                content.postToChatterEnabled = act.Post_to_Chatter_Email__c;
                content.pushNotificationEnabled = act.Post_to_Chatter_Push_Notification__c;

                return content;
            }
        }
        return null;
    }

    private static Action_Center_Template__c getActionCenterTemplate(Notification_Process_Config__c config) {
        List<Action_Center_Template__c> templates = [
            SELECT Id, Name, Object_Name__c, Email_Subject__c, Email_Body__c, Org_Wide_Email_Address__c
            FROM Action_Center_Template__c
            WHERE Id = :config.Action_Center_Template__c
              AND Object_Name__c = :config.Notification_Config__r.Object_Name__c
              AND Is_Active__c = true
            LIMIT 1
        ];

        return templates.isEmpty() ? null : templates[0];
    }

    private static List<Messaging.SingleEmailMessage> buildEmailsFromTemplate(Action_Center_Template__c act,
                                                                               Set<Id> recordIds, List<String> emailList) {
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        Set<Id> templateIds = new Set<Id>{ act.Id };
        Map<Id, SObject> parentRecords = convertFieldMetaToData(act.Object_Name__c, recordIds, TEMPLATE_ACT, templateIds);

        for (Id recordId : parentRecords.keySet()) {
            SObject recordData = parentRecords.get(recordId);
            String mergedBody = ActionCenterHub.mergeTemplate(act.Email_Body__c, recordData);
            String mergedSubject = ActionCenterHub.mergeTemplate(act.Email_Subject__c, recordData);
            mailList.addAll(prepareMailTemplate(mergedSubject, mergedBody, emailList, act.Org_Wide_Email_Address__c));
        }

        return mailList;
    }

    private static void setOrgWideEmailAddress(Messaging.SingleEmailMessage mail, String orgWideEmailAddress) {
        if (String.isBlank(orgWideEmailAddress)) {
            return;
        }

        List<OrgWideEmailAddress> owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :orgWideEmailAddress LIMIT 1];
        if (!owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
    }

    private static List<Field_Meta__c> queryFieldMeta(String templateObjectName, Set<Id> templateObjectId, String sobjName) {
        String operationType = (templateObjectName == TEMPLATE_NPC) ? OP_CONDITIONAL : OP_QUERY;

        if (templateObjectName == TEMPLATE_NPC) {
            return [
                SELECT Id, api_name__c, Object_Name__c, childObjFldName__c, childObjName__c
                FROM Field_Meta__c
                WHERE Notification_Process_Config__c IN :templateObjectId
                  AND Object_Name__c = :sobjName
                  AND Is_Active__c = true
                  AND Operation_Type__c = :operationType
            ];
        }

        return [
            SELECT Id, api_name__c, Object_Name__c, childObjFldName__c, childObjName__c
            FROM Field_Meta__c
            WHERE Action_Center_Template__c IN :templateObjectId
              AND Object_Name__c = :sobjName
              AND Is_Active__c = true
              AND Operation_Type__c = :operationType
        ];
    }

    private static FieldOrganizer organizeFields(List<Field_Meta__c> fieldLoaderRecords) {
        FieldOrganizer organizer = new FieldOrganizer();

        for (Field_Meta__c record : fieldLoaderRecords) {
            String objectName = record.Object_Name__c;
            String apiName = record.api_name__c;

            if (objectName == null || apiName == null) {
                continue;
            }

            if (apiName.contains('.')) {
                if (!organizer.relationshipFields.containsKey(objectName)) {
                    organizer.relationshipFields.put(objectName, new Set<String>());
                }
                organizer.relationshipFields.get(objectName).add(apiName);
            } else {
                if (!organizer.directFields.containsKey(objectName)) {
                    organizer.directFields.put(objectName, new Set<String>());
                }
                organizer.directFields.get(objectName).add(apiName);
            }
        }

        return organizer;
    }

    // RT 20FEB26 - Added method to check for existing triggers on the object and merge notification logic if needed
    private static String mergeTaskField(String templateValue, SObject recordData) {
        if (String.isBlank(templateValue)) {
            return '';
        }
        if (recordData == null) {
            return templateValue;
        }
        return ActionCenterHub.mergeTemplate(templateValue, recordData);
    }

    private static Boolean canUseAsWhoId(Id recordId) {
        if (recordId == null) {
            return false;
        }
        Schema.SObjectType sObjectType = recordId.getSObjectType();
        return sObjectType == Contact.SObjectType || sObjectType == Lead.SObjectType;
    }

    private static Id resolveWhoId(Id recordId, SObject recordData) {
        if (canUseAsWhoId(recordId)) {
            return recordId;
        }

        if (recordData == null) {
            return null;
        }

        Map<String, Object> populatedFields = recordData.getPopulatedFieldsAsMap();
        for (String fieldName : new List<String>{ 'WhoId', 'ContactId', 'LeadId' }) {
            if (!populatedFields.containsKey(fieldName)) {
                continue;
            }
            Object value = populatedFields.get(fieldName);
            if (value == null) {
                continue;
            }

            Id candidateId = (Id) value;
            if (canUseAsWhoId(candidateId)) {
                return candidateId;
            }
        }
        return null;
    }

    private static String trimToLength(String value, Integer maxLength) {
        if (String.isBlank(value) || maxLength == null || maxLength <= 0 || value.length() <= maxLength) {
            return value;
        }
        return value.substring(0, maxLength);
    }

    private static ApproverRecipient buildRecipient(User configuredUser, String configuredOwnerValue,
                                                    Map<Id, User> delegatedUsersById) {
        ApproverRecipient recipient = new ApproverRecipient();
        recipient.configuredOwner = configuredUser != null ? configuredUser.Name : configuredOwnerValue;
        recipient.configuredOwnerId = configuredUser != null ? configuredUser.Id : null;
        recipient.configuredOwnerEmail = configuredUser != null ? configuredUser.Email : null;

        User delegatedUser = (delegatedUsersById != null && configuredUser.DelegatedApproverId != null)
            ? delegatedUsersById.get(configuredUser.DelegatedApproverId)
            : null;
        Boolean hasDelegatedApprover = delegatedUser != null && delegatedUser.IsActive == true;

        if (hasDelegatedApprover) {
            recipient.delegated = true;
            recipient.delegatedFromOwner = configuredUser.Name;
            recipient.effectiveOwner = delegatedUser.Name;
            recipient.userId = delegatedUser.Id;
            recipient.email = delegatedUser.Email;
            recipient.effectiveOwnerActive = delegatedUser.IsActive;
            return recipient;
        }

        recipient.effectiveOwner = configuredUser.Name;
        recipient.userId = configuredUser.Id;
        recipient.email = configuredUser.Email;
        recipient.effectiveOwnerActive = configuredUser.IsActive;
        return recipient;
    }

    @TestVisible
    private static String buildRecipientDedupeKey(ApproverRecipient recipient) {
        if (recipient == null) {
            return null;
        }
        String delegatedFlag = recipient.delegated == true ? 'D' : 'N';
        String configuredOwnerId = recipient.configuredOwnerId == null ? '' : String.valueOf(recipient.configuredOwnerId);
        String configuredOwner = String.isBlank(recipient.configuredOwner) ? '' : recipient.configuredOwner.toLowerCase();
        String effectiveUserId = recipient.userId == null ? '' : String.valueOf(recipient.userId);
        String effectiveOwner = String.isBlank(recipient.effectiveOwner) ? '' : recipient.effectiveOwner.toLowerCase();
        String delegatedFromOwner = String.isBlank(recipient.delegatedFromOwner) ? '' : recipient.delegatedFromOwner.toLowerCase();
        return String.join(
            new List<String>{ delegatedFlag, configuredOwnerId, configuredOwner, effectiveUserId, effectiveOwner, delegatedFromOwner },
            '|'
        );
    }

    private static void addUserLookupKey(Map<String, List<User>> usersByLookupKey, String value, User usr) {
        if (String.isBlank(value)) {
            return;
        }
        String key = value.toLowerCase();
        if (!usersByLookupKey.containsKey(key)) {
            usersByLookupKey.put(key, new List<User>());
        }
        usersByLookupKey.get(key).add(usr);
    }

    private static List<String> splitOwnerTokens(String ownerFieldValue) {
        List<String> ownerTokens = new List<String>();
        if (String.isBlank(ownerFieldValue)) {
            return ownerTokens;
        }

        String normalized = ownerFieldValue.replace('\n', ',').replace(';', ',');
        Set<String> uniqueTokens = new Set<String>();

        for (String token : normalized.split(',')) {
            String cleaned = token == null ? null : token.trim();
            if (String.isBlank(cleaned)) {
                continue;
            }
            if (!uniqueTokens.contains(cleaned)) {
                uniqueTokens.add(cleaned);
                ownerTokens.add(cleaned);
            }
        }

        return ownerTokens;
    }

    private static Map<Id, SObject> executeFieldQuery(FieldOrganizer organizer, Set<Id> sobjectrecordIds) {
        Map<Id, SObject> parentRecords = new Map<Id, SObject>();

        for (String parentObject : organizer.directFields.keySet()) {
            Set<String> fields = new Set<String>(organizer.directFields.get(parentObject));

            if (organizer.relationshipFields.containsKey(parentObject)) {
                fields.addAll(organizer.relationshipFields.get(parentObject));
            }

            if (fields.isEmpty()) {
                continue;
            }

            String query = 'SELECT Id, ' + String.join(new List<String>(fields), ', ') +
                           ' FROM ' + String.escapeSingleQuotes(parentObject) + ' WHERE Id IN :sobjectrecordIds';

            for (SObject parent : Database.query(query)) {
                parentRecords.put(parent.Id, parent);
            }
        }

        return parentRecords;
    }

    /**
     * @description Inner class to hold template context
     */
    private class TemplateContext {
        public String objectName;
        public Set<Id> templateIds = new Set<Id>();
    }

    /**
     * @description Inner class to organize field types
     */
    private class FieldOrganizer {
        public Map<String, Set<String>> directFields = new Map<String, Set<String>>();
        public Map<String, Set<String>> relationshipFields = new Map<String, Set<String>>();
    }
}