public with sharing class ObjectDropdownController {
    @AuraEnabled(cacheable=true)
    public static List<String> getObjectList() {
        List<String> objectNames = new List<String>();
        for (Schema.SObjectType sObjType : Schema.getGlobalDescribe().values()) {
            objectNames.add(sObjType.getDescribe().getName());
        }
        return objectNames;
    }
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> getFieldList(String objectName) {
        Schema.DescribeSObjectResult describeResult = Schema.getGlobalDescribe().get(objectName).getDescribe();
        Map<String, Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
        List<Map<String, String>> fieldsList = new List<Map<String, String>>();
        for (String fieldName : fieldsMap.keySet()) {
            Map<String, String> fieldData = new Map<String, String>();
            fieldData.put('label', fieldName); 
            fieldData.put('value', fieldName); 
            fieldsList.add(fieldData);
        }
        return fieldsList;
    }
    @AuraEnabled
    public static string fieldValue(String values, string objectname) {
        //system.debug(values);
        // system.debug(values.replace('\\"',''));
        List<History_Tracking_Fields__c> htfList = [SELECT Id, Name, Fields__c, Object_Name__c FROM History_Tracking_Fields__c WHERE Object_Name__c =:objectname];
        //system.debug(htfList);
        List<History_Tracking_Fields__c> sfList = new List<History_Tracking_Fields__c>();
        History_Tracking_Fields__c sf = new History_Tracking_Fields__c();
        string fieldValue ='';
        string status; 
        if(values != null  ){
            string str = values.replace('[','').replace(']','').replace('"','');
            fieldValue = str.toLowerCase();
            //system.debug(str);
        }
        //system.debug(fieldValue);
        sf.Fields__c = fieldValue;
        sf.Object_Name__c = objectname;
        sfList.add(sf); 
        //system.debug(sfList.size());   
        if(sfList.size()>0){
            if(htfList.size()== 0){
                status = 'Success';
                Database.insert(sfList);
            }else{
                for(History_Tracking_Fields__c htf : htfList){
                    if(htf.Object_Name__c == objectname){ 
                        htf.Fields__c = fieldValue;
                        Database.update(htf);
                        status = 'Success';
                    }
                }
            }
        }else{
            status = 'Failure';
        }
        //system.debug('size for big Data: '+ sfList.size());
        //system.debug('values for big Data: '+ sfList);
        return status;
    }
    @AuraEnabled(Cacheable=true)
    public static string fetchselectedfieldHistories(string objectname) {
        string fieldVal;
        try{
            fieldVal = [SELECT Id, Name, Fields__c, Object_Name__c FROM History_Tracking_Fields__c WHERE Object_Name__c =:objectname].Fields__c;
        } catch (Exception e) {
            fieldVal = null;
        }
        //system.debug(fieldVal);
        return fieldVal;
    }
    @AuraEnabled(cacheable = true)
    public static String getNameSpace() {
        ApexClass cs = [
            SELECT NamespacePrefix
            FROM ApexClass
            WHERE Name = 'FieldHistoryLogger'
            WITH SECURITY_ENFORCED
        ];
        return ((cs.NamespacePrefix != null) ? cs.NamespacePrefix : '');
    }
}