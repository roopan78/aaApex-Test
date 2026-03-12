public with sharing class ReusableLookupHandler {

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes(String objectApiName) {
        try {
            Schema.SObjectType sObjectType = Schema.getGlobalDescribe().get(objectApiName);
            if (sObjectType == null || !sObjectType.getDescribe().isAccessible()) {
                throw new AuraHandledException('Invalid Object API Name');
            }

            List<RecordType> recordTypes = [
                SELECT Id, Name 
                FROM RecordType 
                WHERE SObjectType = :objectApiName 
                ORDER BY Name
            ];

            return recordTypes;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching record types: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(String inputJSON){
        SearchWrapper inpWrapper = (SearchWrapper) JSON.deserialize(inputJSON, SearchWrapper.class);
        try {
            // Build the SELECT clause
            String selectClause = 'SELECT Id';
            if (String.isNotBlank(inpWrapper.fieldApiName)) {
                selectClause += ', ' + String.escapeSingleQuotes(inpWrapper.fieldApiName);
            }
            
            // Build the FROM clause
            String fromClause = ' FROM ' + String.escapeSingleQuotes(inpWrapper.objectApiName);
            
            // Build the WHERE clause
            String whereClause = '';
            if (String.isNotBlank(inpWrapper.selectedRecordId)) {
                whereClause = ' WHERE Id = \'' + String.escapeSingleQuotes(inpWrapper.selectedRecordId) + '\'';
            } else if (String.isNotBlank(inpWrapper.fieldApiName) && String.isNotBlank(inpWrapper.searchString)) {
                whereClause = ' WHERE ' + String.escapeSingleQuotes(inpWrapper.fieldApiName) + 
                            ' LIKE \'' + String.escapeSingleQuotes(inpWrapper.searchString.trim()) + '%\'';
            }
            
            // Combine all parts
            String query = selectClause + fromClause + whereClause + ' WITH SECURITY_ENFORCED LIMIT 10';
            
            System.debug('Final Query: ' + query);
            
            List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
            for(SObject s : Database.query(query)) {
                ResultWrapper wrap = new ResultWrapper();
                wrap.id = (String)s.get('Id');
                
                if (String.isNotBlank(inpWrapper.fieldApiName)) {
                    Object fieldValue = s.get(inpWrapper.fieldApiName);
                    wrap.mainField = fieldValue != null ? String.valueOf(fieldValue) : null;
                }
                returnWrapperList.add(wrap);
            }
            return returnWrapperList;
        } catch (Exception err) {
            System.debug('Error: ' + err.getMessage() + ' StackTrace: ' + err.getStackTraceString() + ' Cause: ' + err.getCause() + ' LineNumber: ' + err.getLineNumber());
            throw new AuraHandledException('Error fetching records: ' + err.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getWritableFields(String objectApiName) {
        Set<String> fields = new Set<String>();

        // Fetch PermissionSetIds assigned to current user
        List<Id> permSetIds = new List<Id>();
        for (PermissionSetAssignment psa : [
            SELECT PermissionSetId 
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId()
        ]) {
            permSetIds.add(psa.PermissionSetId);
        }

        if (permSetIds.isEmpty()) {
            return new List<String>();
        }

        // Query Field Permissions where user has WRITE access
        for (FieldPermissions fp : [
            SELECT Field, PermissionsEdit 
            FROM FieldPermissions 
            WHERE ParentId IN :permSetIds
            AND SObjectType = :objectApiName
            AND PermissionsEdit = true
        ]) {
            // Example: Account.Name → "Name"
            fields.add(fp.Field.substringAfter('.'));
        }

        return new List<String>(fields);
    }
    
    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String id{get;set;}
    }
 
    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
    }
}