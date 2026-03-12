public with sharing class UserController {
    public class UserWrapper {
        public String userId;
        public String name;
        public String email;
    }
    @AuraEnabled(cacheable=true)
    public static string getAllUsersOrderedByName(Integer maxLimit, Integer offsetValue) {
        Map<Id, User> userMap = new Map<Id, User>();
        List<UserWrapper> userList = new List<UserWrapper>();
        for (User u : [SELECT Id, Name, Email FROM User WHERE IsActive = TRUE ORDER BY Name ASC LIMIT :maxLimit OFFSET :offsetValue]) {
            userMap.put(u.Id, u);
        }
        for (Id userId : userMap.keySet()) {
            User u = userMap.get(userId);
            UserWrapper uw = new UserWrapper();
            uw.userId = u.Id;
            uw.name = u.Name;
            uw.email = u.Email;
            userList.add(uw);
        }
        return JSON.serialize(userList);
    }
    @AuraEnabled
    public static String UserfieldValue(String values, String objectname, Id userId) {
    try {
        History_Tracking_Fields__c record;
        List<History_Tracking_Fields__c> existingRecords = [SELECT Id, Fields__c FROM History_Tracking_Fields__c WHERE Object_Name__c = :objectname AND User_ID__c = :userId LIMIT 1]; 
        if (!existingRecords.isEmpty()) {
            record = existingRecords[0];
            record.Fields__c = values;
            update record;
        } else {
            record = new History_Tracking_Fields__c(
                Object_Name__c = objectname,
                User_ID__c = userId,
                Fields__c = values
            );
            insert record;
        }
        return 'Success';
    } catch (Exception e) {
        System.debug('Error saving selected fields: ' + e.getMessage());
        return 'Error: ' + e.getMessage();
    }
    }
    @AuraEnabled(Cacheable=false)
    public static String fetchselectedfieldHistories(String objectname, Id userId) {
    try {
        List<History_Tracking_Fields__c> records = [SELECT Fields__c FROM History_Tracking_Fields__c WHERE Object_Name__c = :objectname AND User_ID__c = :userId LIMIT 1];    
        if (!records.isEmpty()) {
            return records[0].Fields__c; 
        }
    } catch (Exception e) {
        System.debug('Error fetching field histories: ' + e.getMessage());
    }
    return null;  
    }
    @AuraEnabled
    public static String fieldValue(String values, String objectname) {
    List<User> allUsers = [SELECT Id FROM User WHERE IsActive = TRUE];
    Map<Id, History_Tracking_Fields__c> userHistoryMap = new Map<Id, History_Tracking_Fields__c>();
    List<History_Tracking_Fields__c> existingRecords = [
        SELECT Id, Fields__c, Object_Name__c, User_ID__c 
        FROM History_Tracking_Fields__c 
        WHERE Object_Name__c = :objectname
    ];
    for (History_Tracking_Fields__c record : existingRecords) {
        if (record.User_ID__c != null) {
            userHistoryMap.put(record.User_ID__c, record);
        }
    }
    String fieldValue = (values != null) ? values.replace('[', '').replace(']', '').replace('"', '').toLowerCase() : '';
    List<History_Tracking_Fields__c> recordsToInsert = new List<History_Tracking_Fields__c>();
    List<History_Tracking_Fields__c> recordsToUpdate = new List<History_Tracking_Fields__c>();
    for (User u : allUsers) {
        if (userHistoryMap.containsKey(u.Id)) {
            History_Tracking_Fields__c existingRecord = userHistoryMap.get(u.Id);
            if (String.isBlank(existingRecord.Fields__c)) { 
                existingRecord.Fields__c = fieldValue;
                recordsToUpdate.add(existingRecord);
            }
        } else {
            History_Tracking_Fields__c newRecord = new History_Tracking_Fields__c();
            newRecord.Fields__c = fieldValue;
            newRecord.Object_Name__c = objectname;
            newRecord.User_ID__c = u.Id;
            recordsToInsert.add(newRecord);
        }
    }
    if (!recordsToInsert.isEmpty()) {
        insert recordsToInsert;
    }
    if (!recordsToUpdate.isEmpty()) {
        update recordsToUpdate;
    }
    return 'Success';
    }
}