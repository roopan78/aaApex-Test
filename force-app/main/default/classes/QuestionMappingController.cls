public with sharing class QuestionMappingController {
    public QuestionMappingController() {
    }
    public class referenceWrapper{
        public String Id, selectedValue;
        public List<Schema.DescribeFieldResult> fullList;
        public Decimal count;
        public List<String> option;
    }
    @AuraEnabled
    public static String getQuestionType(String quesId){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        string supportedType = '';
        string type = [SELECT Id, Type__c FROM Question__c WHERE Id =: quesId WITH SECURITY_ENFORCED ].Type__c;
        if(type != null){
            supportedType = [SELECT Id, Question_Type__c,Supported_Type__c FROM Question_Mapping__mdt WHERE Question_Type__c =: type WITH SECURITY_ENFORCED ].Supported_Type__c; }
        String[] types = new String[]{'Answer_Book__c'};

        List<Schema.DescribeFieldResult> fieldList = new List<Schema.DescribeFieldResult>();
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        Map<String, Schema.SObjectField> fields = results[0].fields.getMap();
        for (Schema.SObjectFIeld field: fields.values())
        {
            if(field.getDescribe().isUpdateable() && field.getDescribe().isAccessible()){
                fieldList.add(field.getDescribe());
            }
        }
        jsonGen.writeObjectField('type',type);
        jsonGen.writeObjectField('supportedType',supportedType);
        jsonGen.writeObjectField('list',fieldList);
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
    @AuraEnabled
    public static String getObjectDetail(String objApi){
        String[] types = new String[]{objApi};
        List<Schema.DescribeFieldResult> fieldList = new List<Schema.DescribeFieldResult>();

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        Map<String, Schema.SObjectField> fields = results[0].fields.getMap();
        referenceWrapper allList = new referenceWrapper();
        for (Schema.SObjectFIeld field: fields.values())
        {
            if(field.getDescribe().isUpdateable() && field.getDescribe().isAccessible()){
                fieldList.add(field.getDescribe());
            }
        }
        allList.fullList = fieldList;
        return JSON.serialize(allList);
    }
    @AuraEnabled
    public static String updateObject(String value,String quesId){
        JSONGenerator jsonGen = JSON.createGenerator(true);
        jsonGen.writeStartObject();
        if(value != null && quesId != null){
            Id queBookId = [SELECT Id,Question_Book__c FROM Question__c WHERE id =: quesId WITH SECURITY_ENFORCED].Question_Book__c;
            List<Question__c> quesList = new List<Question__c>();
            if(queBookId != null){
                quesList = [SELECT Id,Question_Book__c FROM Question__c WHERE Question_Book__c =: queBookId AND Reference_Field__c =: value WITH SECURITY_ENFORCED];
            }
            if(quesList.size() > 0){
                jsonGen.writeObjectField('status','failure');
                jsonGen.writeObjectField('message','The Value is already taken by another question');
            }else{
                Question__c ques = new Question__c(id = quesId ) ;
                ques.Reference_Field__c = value;
                try{
                    if (Question__c.SObjectType.getDescribe().isUpdateable() && Schema.sObjectType.Question__c.fields.Reference_Field__c.isUpdateable()) {
                        update ques;
                    }
                    jsonGen.writeObjectField('status','success');
                }catch (Exception ae) {
                    jsonGen.writeObjectField('status','failure');
                    jsonGen.writeObjectField('lineno',ae.getLineNumber());
                    jsonGen.writeObjectField('errormessage',ae.getMessage());
                    jsonGen.writeObjectField('message','Some error in updating ,please try again.');
                    jsonGen.writeObjectField('strack',ae.getStackTraceString());

                    System.debug(LoggingLevel.ERROR, 'Error while Update Object .Error Message = ' + ae.getMessage());
                }
           }
      }else{
            jsonGen.writeObjectField('status','failure');
            jsonGen.writeObjectField('message','Some error in updating ,please try again.');
        }
        jsonGen.writeEndObject();
        return jsonGen.getAsString();
    }
}