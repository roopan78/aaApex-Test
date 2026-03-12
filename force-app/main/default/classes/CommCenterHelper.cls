/*
* Created by: Mohamed Abdul Kadher N 
* Description: A utility class to process the notification to action owner(who has the authorization/access to approve the request) and start the process to approve it
* Created on (DD/MM/YYYY): 06/02/2025.
*/
public with sharing class CommCenterHelper { 
    private static final String STATUS_SUBMITTED = 'Submitted For Approval';
    private static final String STATUS_APPROVED = 'Approved';
    private static final String STATUS_REJECTED = 'Rejected';
    private static final String STATUS_PENDING = 'Pending';
    private static final String STATUS_COMPLETED = 'Completed';
    private static final String AUTO_APPROVE_INACTIVE_REASON = 'Auto-approved: Assignee inactive';

    public class CommCenterWrapper {
        @AuraEnabled public String id;
        @AuraEnabled public String name;
        @AuraEnabled public String status;
        @AuraEnabled public String actionCenterName;
        @AuraEnabled public String actionOwnerEmail;
        @AuraEnabled public String actionOwnerName;
        @AuraEnabled public String description;
        @AuraEnabled public Boolean isOptional;
        @AuraEnabled public String notificationConfig;
        @AuraEnabled public String objectName;
        @AuraEnabled public Boolean isActive; // RT 02/01/2026 - Added isActive field
        @AuraEnabled public Integer order;
        @AuraEnabled public String reason;
        @AuraEnabled public String recordId;
        @AuraEnabled public String userMail;
        @AuraEnabled public String userName;
        @AuraEnabled public String parentCommCenterId;
    
        public CommCenterWrapper(Comm_Center__c record) {
            this.id = record.Id;
            this.name = record.Name;
            this.status = record.Status__c;
            this.actionCenterName = record.Action_Center_Name__c;
            this.actionOwnerEmail = record.Action_Owner_Email_ID__c;
            this.actionOwnerName = record.Action_Owner_Name__c;
            this.description = record.Description__c;
            this.isOptional = record.Is_Optional__c;
            this.notificationConfig = record.Notification_Process_Config__c;
            this.objectName = record.Object_Name__c;
            this.isActive = record.Is_Active__c;
            this.order = Integer.valueOf(record.Order__c);
            this.reason = record.Reason__c;
            this.recordId = record.Record_Id__c;
            this.userMail = record.User_Mail_ID__c;
            this.userName = record.User_Name__c;
            this.parentCommCenterId = record.Parent_Comm_Center__c;
        }
    }

    // RT 02/01/2026 - Added Is_Active__c field
    @AuraEnabled(cacheable=true)
    public static CommCenterWrapper getApprovalRecord(Id recordId) {
        Comm_Center__c record = [SELECT Id, Name, Status__c, Action_Center_Name__c, Action_Owner_Email_ID__c, Action_Owner_Name__c, 
                                    Description__c, Is_Optional__c, Notification_Process_Config__c, Object_Name__c, Order__c, Is_Active__c,
                                    Reason__c, Record_Id__c, User_Mail_ID__c, User_Name__c, Parent_Comm_Center__c FROM Comm_Center__c WHERE Id = :recordId LIMIT 1];
        return new CommCenterWrapper(record);
    }
    
    // RT 19DEC25 - Moved logic for Global Access from NotificationHelper
    public static void updateApprovalStatuslogic(Id recordId, String newStatus, String reason, Id sobjId) {
        try {
            Comm_Center__c currentApprover = [SELECT Id, Name, Status__c, Action_Center_Name__c, Action_Owner_Email_ID__c, Action_Owner_Name__c, 
                                 Description__c, Is_Optional__c, Notification_Process_Config__c, Object_Name__c, Order__c, 
                                 Reason__c, Record_Id__c, User_Mail_ID__c, User_Name__c, Parent_Comm_Center__c FROM Comm_Center__c 
                                 WHERE Record_Id__c = :sobjId AND Id =: recordId
                                ORDER BY Order__c DESC LIMIT 1];
            Integer currentOrder = 0;
            currentOrder = currentApprover.Order__c.intValue(); 
            System.debug('Current Approver Order: ' + currentOrder);
            currentApprover.Status__c = newStatus;
            if (reason != null) {
                currentApprover.Reason__c = reason;
            }
            update currentApprover;
            processNextApprovers(currentOrder, sobjId, newStatus, currentApprover.Parent_Comm_Center__c);
        } catch (Exception e) {
            System.debug(e.getMessage());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void updateApprovalStatus(Id recordId, String newStatus, String reason, Id sobjId) {
        updateApprovalStatuslogic(recordId,newStatus,reason,sobjId);
    }

    public static void processNextApprovers(Integer currentOrder, Id sobjId, String operationStatus) {
        processNextApprovers(currentOrder, sobjId, operationStatus, null);
    }

    public static void processNextApprovers(Integer currentOrder, Id sobjId, String operationStatus, Id parentCommCenterId) {
        system.debug(currentOrder);
        system.debug(sobjId);
        system.debug(operationStatus);
        SystemContextAccess systemAccess = new SystemContextAccess();
        List<Comm_Center__c> allNextApprovers = systemAccess.queryChainApprovers(sobjId, parentCommCenterId);
        
        System.debug('All Next Approvers: ' + allNextApprovers);
        if (allNextApprovers.isEmpty()) {
            return;
        }
        Set<Id> notificationConfigIds = new set<Id>();
        Set<Id> uniqueIds = new Set<Id>();
        Map<string, List<Comm_Center__c>> ccMap = new Map<string, List<Comm_Center__c>>();
        String ccMapName;
        // Select the next required approval order
        List<Comm_Center__c> selectedApprovers = new List<Comm_Center__c>();
        Integer nextApprovalOrder = -1; // Initialize to -1 for first selection
        Boolean mandatoryFound = false;
        
        if (operationStatus == STATUS_REJECTED) {
            processRejection(currentOrder, sobjId, allNextApprovers);
        }
        
        if(operationStatus == STATUS_APPROVED){
            if (!canAdvanceFromCurrentOrder(allNextApprovers, currentOrder)) {
                System.debug('Skipping progression because current order is not fully approved. currentOrder=' + currentOrder);
                return;
            }

            Map<Id, Boolean> userActiveMap = getOwnerUserActiveMap(allNextApprovers);
            List<Comm_Center__c> submittedApprovers = new List<Comm_Center__c>();
            Integer pointerOrder = currentOrder;

            while (true) {
                Integer nextOrder = -1;
                for (Comm_Center__c approver : allNextApprovers) {
                    if (approver.Parent_Comm_Center__c == null || approver.Order__c == null) {
                        continue;
                    }
                    if (approver.Order__c.intValue() <= pointerOrder) {
                        continue;
                    }
                    if (approver.Status__c != STATUS_PENDING) {
                        continue;
                    }
                    Integer approverOrder = approver.Order__c.intValue();
                    if (nextOrder == -1 || approverOrder < nextOrder) {
                        nextOrder = approverOrder;
                    }
                }

                if (nextOrder == -1) {
                    break;
                }

                Boolean hasActiveApproverAtOrder = false;
                for (Comm_Center__c approver : allNextApprovers) {
                    if (approver.Parent_Comm_Center__c == null || approver.Order__c == null) {
                        continue;
                    }
                    if (approver.Order__c.intValue() != nextOrder || approver.Status__c != STATUS_PENDING) {
                        continue;
                    }

                    if (isInactiveOwner(approver, userActiveMap)) {
                        approver.Status__c = STATUS_APPROVED;
                        approver.Reason__c = AUTO_APPROVE_INACTIVE_REASON;
                        approver.Is_Email_Sent__c = true;
                        selectedApprovers.add(approver);
                    } else {
                        approver.Status__c = STATUS_SUBMITTED;
                        approver.Is_Email_Sent__c = true;
                        selectedApprovers.add(approver);
                        submittedApprovers.add(approver);
                        hasActiveApproverAtOrder = true;
                    }

                    if (approver.Notification_Process_Config__c != null) {
                        notificationConfigIds.add(approver.Notification_Process_Config__c);
                    }
                    uniqueIds.add(approver.Id);
                }

                if (hasActiveApproverAtOrder) {
                    break;
                }
                pointerOrder = nextOrder;
            }

            if (!submittedApprovers.isEmpty()) {
                ccMapName = STATUS_SUBMITTED;
                ccMap.put(ccMapName, submittedApprovers);
            }

            Boolean hasOpenChild = false;
            for (Comm_Center__c approver : allNextApprovers) {
                if (approver.Parent_Comm_Center__c != null &&
                    (approver.Status__c == STATUS_PENDING || approver.Status__c == STATUS_SUBMITTED)) {
                    hasOpenChild = true;
                    break;
                }
            }

            if (!hasOpenChild) {
                ccMapName = STATUS_COMPLETED;
                List<Comm_Center__c> parentRecords = new List<Comm_Center__c>();
                for (Comm_Center__c approver : allNextApprovers) {
                    if (approver.Parent_Comm_Center__c == null) {
                        approver.Status__c = STATUS_COMPLETED;
                        approver.Is_Email_Sent__c = true;
                        parentRecords.add(approver);
                        selectedApprovers.add(approver);
                        if (approver.Notification_Process_Config__c != null) {
                            notificationConfigIds.add(approver.Notification_Process_Config__c);
                        }
                    }
                }
                if (!parentRecords.isEmpty()) {
                    ccMap.put(ccMapName, parentRecords);
                }
            }
        }
        if (!ccMap.isEmpty()) {
            handleApprovalProcess(notificationConfigIds, ccMap, sobjId);
        }

        if (!selectedApprovers.isEmpty()) {
            List<Comm_Center__c> recList = new List<Comm_Center__c>();
            for(Comm_Center__c cc : selectedApprovers){
                cc.Is_Email_Sent__c = true;
                recList.add(cc);
            }
            systemAccess.updateCommCenterRecords(recList);
        }

    }

    private static Map<Id, Boolean> getOwnerUserActiveMap(List<Comm_Center__c> approvers) {
        Map<Id, Boolean> userActiveMap = new Map<Id, Boolean>();
        Set<Id> ownerUserIds = new Set<Id>();

        for (Comm_Center__c approver : approvers) {
            if (approver == null || approver.OwnerId == null) {
                continue;
            }
            if (approver.OwnerId.getSObjectType() == User.SObjectType) {
                ownerUserIds.add(approver.OwnerId);
            }
        }

        if (ownerUserIds.isEmpty()) {
            return userActiveMap;
        }

        for (User usr : [SELECT Id, IsActive FROM User WHERE Id IN :ownerUserIds]) {
            userActiveMap.put(usr.Id, usr.IsActive);
        }
        return userActiveMap;
    }

    private static Boolean isInactiveOwner(Comm_Center__c approver, Map<Id, Boolean> userActiveMap) {
        if (approver == null || approver.OwnerId == null || userActiveMap == null) {
            return false;
        }
        if (!userActiveMap.containsKey(approver.OwnerId)) {
            return false;
        }
        return userActiveMap.get(approver.OwnerId) == false;
    }

    private static Boolean canAdvanceFromCurrentOrder(List<Comm_Center__c> allApprovers, Integer currentOrder) {
        if (allApprovers == null || allApprovers.isEmpty() || currentOrder == null) {
            return false;
        }

        Boolean hasCurrentOrderApprover = false;
        for (Comm_Center__c approver : allApprovers) {
            if (approver == null || approver.Parent_Comm_Center__c == null || approver.Order__c == null) {
                continue;
            }
            if (approver.Order__c.intValue() != currentOrder) {
                continue;
            }

            hasCurrentOrderApprover = true;
            if (approver.Status__c != STATUS_APPROVED) {
                return false;
            }
        }
        return hasCurrentOrderApprover;
    }
    
    public static void processRejection(Integer currentOrder, Id sobjId, List<Comm_Center__c> allApprovers) {
        system.debug(currentOrder);
        system.debug(sobjId);
        System.debug('allApprovers: ' + allApprovers);
        List<Comm_Center__c> recordsToUpdate = new List<Comm_Center__c>();
        Map<string, List<Comm_Center__c>> ccMap = new Map<string, List<Comm_Center__c>>();
        set<Id> notificationConfigIds = new set<Id>();
        for (Comm_Center__c approver : allApprovers) {
            // Update parent record status to "Rejected"
            system.debug('inside rejection');
            system.debug('approver.Order__c = '+approver.Order__c+' currentOrder = '+currentOrder);
            if (approver.Parent_Comm_Center__c == null) {
                approver.Status__c = 'Rejected';
                recordsToUpdate.add(approver);
            }
            
            // Update all upcoming child records status to "Rejected"
            if (approver.Parent_Comm_Center__c != null &&
                approver.Order__c != null &&
                approver.Order__c.intValue() >= currentOrder) {
                approver.Status__c = 'Rejected';
                recordsToUpdate.add(approver);
            }
            notificationConfigIds.add(approver.Notification_Process_Config__c);
        }
        
        if (!recordsToUpdate.isEmpty()) {
           // update recordsToUpdate;
            ccMap.put('Rejected',recordsToUpdate);
        }

        if (!ccMap.isEmpty()) {
            handleApprovalProcess(notificationConfigIds, ccMap, sobjId);
        }

        if (!recordsToUpdate.isEmpty()) {
            List<Comm_Center__c> recList = new List<Comm_Center__c>();
            for(Comm_Center__c cc : recordsToUpdate){
                cc.Is_Email_Sent__c = true;
                recList.add(cc);
            }
            (new SystemContextAccess()).updateCommCenterRecords(recList);
        }
    }

    // RT 22JAN26 - Enhanced to support custom notifications and chatter posts on approval/rejection
    public static void handleApprovalProcess(Set<Id> notificationConfigIds, Map<String, List<Comm_Center__c>> ccMap, Id sObjectId) {
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        List<ConnectApi.FeedItemInput> chatterPostsToSend = new List<ConnectApi.FeedItemInput>();

        Map<Id, List<Field_Meta__c>> conditionMap = new Map<Id, List<Field_Meta__c>>();
        Map<Id, Action_Center_Template__c> actionCenterMap = new Map<Id, Action_Center_Template__c>();
        Map<Id, Notification_Process_Config__c> configMap = new Map<Id, Notification_Process_Config__c>();

        Set<Id> actionCenterTemplateIds = new Set<Id>();
        Set<Id> sObjId = new Set<Id>{sObjectId};

        List<Notification_Process_Config__c> notificationConfigs = [
            SELECT Id, Name, Status__c, Is_Active__c, Action_Template__c, Action_Center_Template__c,
                   Parent_Notification_Process_Config__c, Order__c, Notification_Config__c, Notification_Config__r.Object_Name__c,
                   (SELECT Id, Name, Status__c, Is_Active__c, Action_Template__c, Action_Center_Template__c,
                           Parent_Notification_Process_Config__c, Order__c, Notification_Config__c, Notification_Config__r.Object_Name__c
                    FROM Parent_Notification_Process_Config__r
                    WHERE Is_Active__c = true)
            FROM Notification_Process_Config__c
            WHERE Is_Active__c = true AND Id IN :notificationConfigIds
        ];

        for (Notification_Process_Config__c parentconfig : notificationConfigs) {
            if (parentconfig.Action_Center_Template__c != null) {
                actionCenterTemplateIds.add(parentconfig.Action_Center_Template__c);
            }
            configMap.put(parentconfig.Id, parentconfig);

            if (parentconfig.Parent_Notification_Process_Config__r != null && !parentconfig.Parent_Notification_Process_Config__r.isEmpty()) {
                for (Notification_Process_Config__c config : parentconfig.Parent_Notification_Process_Config__r) {
                    if (config.Action_Center_Template__c != null) {
                        actionCenterTemplateIds.add(config.Action_Center_Template__c);
                    }
                    configMap.put(config.Id, config);
                }
            }
        }

        for (Field_Meta__c cond : [
            SELECT Id, Name, api_name__c, filterValue__c, order__c, Notification_Process_Config__c,
                   Condition__c, Logical_Criteria__c, Object_Name__c, Is_Active__c, Next_Condition__c, Operation_Type__c
            FROM Field_Meta__c
            WHERE Notification_Process_Config__c IN :notificationConfigIds
              AND Is_Active__c = true
              AND Operation_Type__c = 'Conditional'
            ORDER BY Order__c ASC
        ]) {
            if (!conditionMap.containsKey(cond.Notification_Process_Config__c)) {
                conditionMap.put(cond.Notification_Process_Config__c, new List<Field_Meta__c>());
            }
            conditionMap.get(cond.Notification_Process_Config__c).add(cond);
        }

        for (Action_Center_Template__c act : [
            SELECT Id, Name, Object_Name__c, Task_RecordType__c, Task_Subject__c, Task_Comments__c, Post_to_Chatter_Email__c,
                   Email_Subject__c, Email_Body__c, Post_to_Chatter_Push_Notification__c, Notification_Title__c, Notification_Body__c,
                   Post_Body__c, Is_Active__c, Org_Wide_Email_Address__c
            FROM Action_Center_Template__c
            WHERE Id IN :actionCenterTemplateIds AND Is_Active__c = true
        ]) {
            actionCenterMap.put(act.Id, act);
        }

        Map<Id, SObject> recordDataMap = ActionCenterHandler.processEmailContent(actionCenterMap, sObjId);

        // RT 22JAN26 - Process notification content for custom notifications and chatter posts
        Map<Id, NotificationContent> notificationContentMap = ActionCenterHandler.processNotificationContent(actionCenterMap, sObjId);

        for (String statusType : ccMap.keySet()) {
            List<Comm_Center__c> records = ccMap.get(statusType);

            if (statusType == 'Submitted For Approval') {
                emailsToSend.addAll(constructEmailWithDataValue(actionCenterMap, recordDataMap, records, 'Submitted For Approval', configMap, false));
                processNotificationsForStatus(records, notificationContentMap, sObjectId, 'Submitted For Approval', chatterPostsToSend);
            } else if (statusType == 'Rejected') {
                emailsToSend.addAll(constructEmailWithDataValue(actionCenterMap, recordDataMap, records, 'Rejected', configMap, false));
                processNotificationsForStatus(records, notificationContentMap, sObjectId, 'Rejected', chatterPostsToSend);
            } else if (statusType == 'Completed') {
                emailsToSend.addAll(constructEmailWithDataValue(actionCenterMap, recordDataMap, records, 'Completed', configMap, true));
                processNotificationsForStatus(records, notificationContentMap, sObjectId, 'Completed', chatterPostsToSend);
            }
        }

        // Send emails
        if (!emailsToSend.isEmpty()) {
            try {
                Messaging.sendEmail(emailsToSend);
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, 'Email sending failed: ' + e.getMessage());
            }
        }

        // RT 22JAN26 - Post to Chatter using ActionCenterHub
        if (!chatterPostsToSend.isEmpty()) {
            ActionCenterHub.postChatterPosts(chatterPostsToSend);
        }
    }

    // RT 22JAN26 - Process custom notifications and chatter posts for approval status changes
    private static void processNotificationsForStatus(List<Comm_Center__c> records, Map<Id, NotificationContent> notificationContentMap,
                                                       Id sObjectId, String status, List<ConnectApi.FeedItemInput> chatterPostsToSend) {
        if (notificationContentMap == null || notificationContentMap.isEmpty() || !notificationContentMap.containsKey(sObjectId)) {
            return;
        }

        NotificationContent notifContent = notificationContentMap.get(sObjectId);

        if (notifContent == null) {
            return;
        }

        // Process Chatter Post
        if (notifContent.pushNotificationEnabled && notifContent.chatterPostBody != null) {
            chatterPostsToSend.add(notifContent.chatterPostBody);
        }

        // Process Custom Notification
        if (notifContent.pushNotificationEnabled &&
            String.isNotBlank(notifContent.notificationTitle) &&
            String.isNotBlank(notifContent.notificationBody)) {

            Set<Id> recipientUserIds = getNotificationRecipients(records, status);

            if (!recipientUserIds.isEmpty()) {
                // Use the public method from NotificationProcessHandler
                NotificationProcessHandler.sendApprovalNotifications(
                    notifContent.notificationTitle,
                    notifContent.notificationBody,
                    sObjectId,
                    recipientUserIds
                );
            }
        }
    }

    // RT 22JAN26 - Get notification recipients based on status
    private static Set<Id> getNotificationRecipients(List<Comm_Center__c> records, String status) {
        Set<Id> recipientUserIds = new Set<Id>();
        Set<String> userNames = new Set<String>();

        for (Comm_Center__c cc : records) {
            if (status == 'Submitted For Approval' && String.isNotBlank(cc.Action_Owner_Name__c)) {
                userNames.add(cc.Action_Owner_Name__c);
            } else if ((status == 'Rejected' || status == 'Completed') && String.isNotBlank(cc.User_Name__c)) {
                userNames.add(cc.User_Name__c);
            }
        }

        if (!userNames.isEmpty()) {
            for (User usr : [SELECT Id, Name FROM User WHERE Name IN :userNames AND IsActive = true]) {
                recipientUserIds.add(usr.Id);
            }
        }

        return recipientUserIds;
    }

    public static Messaging.SingleEmailMessage[] constructEmailWithDataValue(Map<Id, Action_Center_Template__c> actionCenterMap, Map<Id, SObject> recordDataMap,List<Comm_Center__c> children, String status, Map<Id, Notification_Process_Config__c> configMap, boolean isUpdateable) {
        Messaging.SingleEmailMessage[] emailsToSend = new List<Messaging.SingleEmailMessage>();
        system.debug('inside constructEmailWithDataValue');
        String actID = getActionTemplateId(status, configMap);
        system.debug(actId);
        if (String.isBlank(actID)) {
            return emailsToSend;
        }
        system.debug(actionCenterMap);
        Action_Center_Template__c act = actionCenterMap.get(actID);
        system.debug(act);
        if (act == null) {
            return emailsToSend;
        }
        
        if ((status == 'Rejected' || status == 'Completed') && recordDataMap.containsKey(children[0].Record_Id__c)) {
            // RT 21JAN26 - Always update SObject records for Rejected/Completed status
            recordsToUpdate(actID, children[0].Record_Id__c);
            // Only send email if User_Mail_ID__c is present and email not already sent
            if(!String.isBlank(children[0].User_Mail_ID__c) && !children[0].Is_Email_Sent__c) {
                String emailBody = actionCenterHub.mergeTemplate(act.Email_Body__c, recordDataMap.get(children[0].Record_Id__c));
                String emailSubject = actionCenterHub.mergeTemplate(act.Email_Subject__c, recordDataMap.get(children[0].Record_Id__c));
                system.debug(' inside if Rejected/completed'+status);
                emailsToSend.add(constructEmail(children[0].User_Mail_ID__c, emailSubject, emailBody));
            }
        } else if(status == 'Submitted For Approval'){
            for (Comm_Center__c child : children) {
                system.debug('inside child');
                system.debug(child);
                if (recordDataMap.containsKey(child.Record_Id__c) && !child.Is_Email_Sent__c) {
                    String emailBody = actionCenterHub.mergeTemplate(act.Email_Body__c, recordDataMap.get(child.Record_Id__c));
                    String emailSubject = actionCenterHub.mergeTemplate(act.Email_Subject__c, recordDataMap.get(child.Record_Id__c));
                    system.debug(status);
                    if(!String.isBlank(child.Action_Owner_Email_ID__c) && status == 'Submitted For Approval'){
                        system.debug(' inside else if status'+status);
                        emailsToSend.add(constructEmail(child.Action_Owner_Email_ID__c, emailSubject, emailBody));
                    }
                }
            }
        }

        system.debug(emailsToSend);
        return emailsToSend;
    }
    
    public static String getActionTemplateId(String status, Map<Id, Notification_Process_Config__c> configMap) {
        System.debug('status: '+status);
        
        if (String.isBlank(status) || configMap.isEmpty()) {
            return null;
        }
        if(status == 'Completed'){
            status = 'Approved';
        }
        //System.debug('configMap: '+configMap);)
        for (Notification_Process_Config__c config : configMap.values()) {
            System.debug(config);
            if (config.Status__c == status) {
                return config.Action_Center_Template__c;
            }
        }
        return null;
    }
    
    public static Messaging.SingleEmailMessage constructEmail(String recipientEmail, String subject, String body) {
        system.debug('inside email construct');
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new List<String>{recipientEmail});
        mail.setSubject(subject);
        mail.setPlainTextBody(body);
        system.debug(mail);
        return mail;
    }

    public static void recordsToUpdate(Id actionCenterTemplateId, string sobjId) {
        Notification_Process_Config__c npc = [SELECT Id, Name, Status__c, Is_Active__c, Action_Template__c, Action_Center_Template__c, 
                                                Parent_Notification_Process_Config__c, Order__c, Notification_Config__c, Notification_Config__r.Object_Name__c
                                                FROM Notification_Process_Config__c
                                                WHERE Is_Active__c = true  AND Action_Center_Template__c =:actionCenterTemplateId LIMIT 1];
        try {
            // Step 1: Fetch Field_Meta__c records for updates
            List<Field_Meta__c> metaRecords = [SELECT Id, Name, api_name__c, filterValue__c,  order__c, Notification_Process_Config__c, Condition__c, Logical_Criteria__c, 
                                                Object_Name__c, Is_Active__c, Next_Condition__c, Operation_Type__c FROM Field_Meta__c
                                                WHERE Notification_Process_Config__c =:npc.Id AND Is_Active__c = true AND Operation_Type__c = 'Updateable' ORDER BY Order__c ASC];
            
            if (metaRecords.isEmpty()) {
                System.debug('No field metadata found for updates.');
                return;
            }

            // Step 2: Organize updates by Object Name
            Map<String, List<Field_Meta__c>> objectFieldMap = new Map<String, List<Field_Meta__c>>();
            
            for (Field_Meta__c meta : metaRecords) {
                if (!objectFieldMap.containsKey(meta.Object_Name__c)) {
                    objectFieldMap.put(meta.Object_Name__c, new List<Field_Meta__c>());
                }
                objectFieldMap.get(meta.Object_Name__c).add(meta);
            }

            List<SObject> recordsToUpdate = new List<SObject>();

            // Step 3: Iterate through each object type and update records
            for (String objectName : objectFieldMap.keySet()) {
                List<Field_Meta__c> fieldsToUpdate = objectFieldMap.get(objectName);

                // Extract field names as a comma-separated string
                List<String> fieldNamesList = new List<String>();
                for (Field_Meta__c meta : fieldsToUpdate) {
                    fieldNamesList.add(meta.api_name__c);
                }
                List<SObject> records = (new SystemContextAccess()).queryObjectRecordsById(objectName, fieldNamesList, sobjId);
                system.debug(records);
                // Step 5: Assign new values dynamically
                for (SObject record : records) {
                    for (Field_Meta__c fieldMeta : fieldsToUpdate) {
                        record.put(fieldMeta.api_name__c, fieldMeta.filterValue__c);
                    }
                    recordsToUpdate.add(record);
                }
            }

            // Step 6: Perform DML Update
            if (!recordsToUpdate.isEmpty()) {
                (new SystemContextAccess()).updateGenericRecords(recordsToUpdate);
                System.debug('Records updated successfully: ' + recordsToUpdate);
            } else {
                System.debug('No records to update.');
            }

        } catch (Exception e) {
            System.debug('Error updating records: ' + e.getMessage());
        }
    }

    private without sharing class SystemContextAccess {
        public List<Comm_Center__c> queryChainApprovers(Id sobjId, Id parentCommCenterId) {
            if (parentCommCenterId != null) {
                return [
                    SELECT Id, Name, Status__c, Action_Center_Name__c, Action_Owner_Email_ID__c, Action_Owner_Name__c,
                           Description__c, Is_Optional__c, Notification_Process_Config__c, Object_Name__c, Order__c,
                           Reason__c, Record_Id__c, User_Mail_ID__c, User_Name__c, Parent_Comm_Center__c, Is_Email_Sent__c, OwnerId
                    FROM Comm_Center__c
                    WHERE Is_Active__c = true
                      AND (Id = :parentCommCenterId OR Parent_Comm_Center__c = :parentCommCenterId)
                    ORDER BY Order__c ASC
                ];
            }

            return [
                SELECT Id, Name, Status__c, Action_Center_Name__c, Action_Owner_Email_ID__c, Action_Owner_Name__c,
                       Description__c, Is_Optional__c, Notification_Process_Config__c, Object_Name__c, Order__c,
                       Reason__c, Record_Id__c, User_Mail_ID__c, User_Name__c, Parent_Comm_Center__c, Is_Email_Sent__c, OwnerId
                FROM Comm_Center__c
                WHERE Record_Id__c = :sobjId
                  AND Is_Active__c = true
                ORDER BY Order__c ASC
            ];
        }

        public void updateCommCenterRecords(List<Comm_Center__c> recordsToUpdate) {
            if (recordsToUpdate == null || recordsToUpdate.isEmpty()) {
                return;
            }
            update recordsToUpdate;
        }

        public void updateGenericRecords(List<SObject> recordsToUpdate) {
            if (recordsToUpdate == null || recordsToUpdate.isEmpty()) {
                return;
            }
            update recordsToUpdate;
        }

        public List<SObject> queryObjectRecordsById(String objectName, List<String> fieldNames, String sobjId) {
            if (String.isBlank(objectName) || fieldNames == null || fieldNames.isEmpty() || String.isBlank(sobjId)) {
                return new List<SObject>();
            }
            if (!Utility.isSalesforceId(sobjId)) {
                return new List<SObject>();
            }

            String fieldsClause = String.join(fieldNames, ',');
            String query = 'SELECT Id, ' + fieldsClause + ' FROM ' + objectName + ' WHERE Id = :recordId';
            String cleanQuery = String.escapeSingleQuotes(query);
            Id recordId = (Id) sobjId;
            return Database.query(cleanQuery);
        }
    }
}