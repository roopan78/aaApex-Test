public class ExceptionController {
 // Method to return exception details
    @AuraEnabled(Cacheable=true)
    public static list<Exception__b> getExceptions(String ApexClassSelected) {
        if(ApexClassSelected != null){
        return [Select Id,Flow_Stack__c,Message__c,Print_Stack__c,Stack_Trace_String__c,Timestamp__c,
                Type_Name__c, Class_Name__c from Exception__b where Class_Name__c = : ApexClassSelected];
        }
        
        // below is to test this component independent when ApexClass is not selected from the UI and passed to this method.
        
        return [Select Id,Flow_Stack__c,Message__c,Print_Stack__c,Stack_Trace_String__c,Timestamp__c,
                Type_Name__c, Class_Name__c from Exception__b];
    }
}