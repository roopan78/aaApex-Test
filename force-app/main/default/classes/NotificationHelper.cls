/**
 * @description Global utility class for processing notification workflows triggered by record changes.
 *              Entry point for subscriber orgs to invoke approval processes via triggers.
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version
 * 2.0        22/01/2026    Roopan Thangam A       RT 22JAN26 - Optimized Code and Consolidated comparison logic to ConditionControlHandler
 */
global with sharing class NotificationHelper {

    /**
     * @description Main entry point for processing record changes and triggering notifications.
     * @param newRecords List of new/updated records
     * @param oldRecordsMap Map of old record values (null for inserts)
     */
    global static void decisionProcess(List<SObject> newRecords, Map<Id, SObject> oldRecordsMap) {
        if (newRecords == null || newRecords.isEmpty()) {
            return;
        }

        String objectName = newRecords[0].getSObjectType().getDescribe().getName();

        Map<Id, Notification_Process_Config__c> configMap = getNotificationConfigs(objectName);
        if (configMap.isEmpty()) {
            return;
        }

        Map<Id, List<Field_Meta__c>> conditionMap = NotificationProcessHandler.getConditionTemplates(configMap.keySet());
        if (conditionMap.isEmpty()) {
            return;
        }

        List<SObject> recordsToProcess = new List<SObject>();
        Set<Id> validConfigIds = new Set<Id>();

        for (SObject newRecord : newRecords) {
            SObject oldRecord = oldRecordsMap != null ? oldRecordsMap.get(newRecord.Id) : null;
            Set<Id> matchedConfigIds = findMatchingConfigs(newRecord, oldRecord, conditionMap);

            if (!matchedConfigIds.isEmpty()) {
                recordsToProcess.add(newRecord);
                validConfigIds.addAll(matchedConfigIds);
            }
        }

        if (!recordsToProcess.isEmpty() && !validConfigIds.isEmpty()) {
            enqueueProcessing(recordsToProcess, validConfigIds);
        }
    }

    /**
     * @description Global access for CommCenter's UpdateApprovalStatus
     * @param recordId The Comm Center record Id
     * @param newStatus The new status value
     * @param reason The reason for status change
     * @param sobjId The related SObject Id
     */
    global static void commCenterUpdateApprovalStatus(Id recordId, String newStatus, String reason, Id sobjId) {
        CommCenterHelper.updateApprovalStatuslogic(recordId, newStatus, reason, sobjId);
    }

    /**
     * @description Archive Comm Center records when parent record is deleted
     * @param deletedRecords List of records being deleted
     */
    global static void handleDelete(List<SObject> deletedRecords) {
        archiveCommCenterRecords(deletedRecords);
    }

    /**
     * @description Enqueues records for async processing
     * @param records Records to process
     * @param validConfigIds Configuration IDs to apply
     */
    public static void enqueueProcessing(List<SObject> records, Set<Id> validConfigIds) {
        if (records.isEmpty() || validConfigIds.isEmpty()) {
            return;
        }
        System.enqueueJob(new NotificationQueueableHandler(records, validConfigIds));
    }

    private static Set<Id> findMatchingConfigs(SObject newRecord, SObject oldRecord, Map<Id, List<Field_Meta__c>> conditionMap) {
        Set<Id> matchingConfigIds = new Set<Id>();
        Boolean isInsert = (oldRecord == null);

        for (Id configId : conditionMap.keySet()) {
            List<Field_Meta__c> conditions = conditionMap.get(configId);
            if (hasMatchingCondition(newRecord, oldRecord, conditions, isInsert)) {
                matchingConfigIds.add(configId);
            }
        }
        return matchingConfigIds;
    }

    private static Boolean hasMatchingCondition(SObject newRecord, SObject oldRecord, List<Field_Meta__c> conditions, Boolean isInsert) {
        for (Field_Meta__c fieldMeta : conditions) {
            String fieldName = fieldMeta.api_name__c;
            String filterValue = fieldMeta.filterValue__c;

            if (String.isBlank(fieldName) || filterValue == null) {
                continue;
            }

            Object newValue = newRecord.get(fieldName);

            if (isInsert) {
                if (valuesMatch(filterValue, newValue)) {
                    return true;
                }
            } else {
                Object oldValue = oldRecord.get(fieldName);
                if (!valuesMatch(filterValue, oldValue) && valuesMatch(filterValue, newValue)) {
                    return true;
                }
            }
        }
        return false;
    }

    private static Boolean valuesMatch(String filterValue, Object fieldValue) {
        try {
            return ConditionControlHandler.valuesEqual(filterValue, fieldValue);
        } catch (Exception e) {
            System.debug(LoggingLevel.WARN, 'Value comparison error: ' + e.getMessage());
            return false;
        }
    }

    private static Map<Id, Notification_Process_Config__c> getNotificationConfigs(String objectName) {
        return new Map<Id, Notification_Process_Config__c>([
            SELECT Id, Name, Status__c, Is_Active__c, Action_Template__c, Action_Center_Template__c,
                   Parent_Notification_Process_Config__c, Order__c, Notification_Config__c,
                   Notification_Config__r.Object_Name__c
            FROM Notification_Process_Config__c
            WHERE Notification_Config__r.Object_Name__c = :objectName
              AND Order__c = 1
              AND Is_Active__c = true
        ]);
    }

    private static void archiveCommCenterRecords(List<SObject> recordsToArchive) {
        if (recordsToArchive == null || recordsToArchive.isEmpty()) {
            return;
        }

        String objectName = recordsToArchive[0].getSObjectType().getDescribe().getName();
        Set<Id> recordIds = extractRecordIds(recordsToArchive);

        if (recordIds.isEmpty()) {
            return;
        }

        List<Comm_Center__c> commCenters = [
            SELECT Id, Is_Active__c
            FROM Comm_Center__c
            WHERE Record_Id__c IN :recordIds
              AND Object_Name__c = :objectName
              AND Is_Active__c = true
            WITH SECURITY_ENFORCED
        ];

        if (commCenters.isEmpty()) {
            return;
        }

        validateUpdatePermissions();

        for (Comm_Center__c cc : commCenters) {
            cc.Is_Active__c = false;
        }
        update commCenters;
    }

    private static Set<Id> extractRecordIds(List<SObject> records) {
        Set<Id> recordIds = new Set<Id>();
        for (SObject sobj : records) {
            if (sobj.Id != null) {
                recordIds.add(sobj.Id);
            }
        }
        return recordIds;
    }

    private static void validateUpdatePermissions() {
        if (!Schema.sObjectType.Comm_Center__c.isUpdateable() ||
            !Schema.sObjectType.Comm_Center__c.fields.Is_Active__c.isUpdateable()) {
            throw new SecurityException('Insufficient permissions to update Comm_Center__c records');
        }
    }

    /**
     * Custom exception for security-related errors
     */
    public class SecurityException extends Exception {}
}