public with sharing class QuestionUtility {
    // MR 18MAY25 QB Builder Changes
    public static Map<String, Id> recordTypeIdByName = new Map<String, Id>{
        'UNCONDITIONAL' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('UNCONDITIONAL')
          .getRecordTypeId(),
        'OPTIONONLY' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId(),
        'CONDITIONAL' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('CONDITIONAL')
          .getRecordTypeId()
    };
}