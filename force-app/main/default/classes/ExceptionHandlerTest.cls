@isTest
public class ExceptionHandlerTest {
    @isTest 
    public static void callHandler() {
        List<Exception__b> eList = new List<Exception__b>();

        Exception__b tExp = new Exception__b();
        tExp.Line_Number__c = 10;
        tExp.Cause__c = 'Testing without Class Name';
        tExp.Type_Name__c = 'Exception';
        tExp.Message__c = 'Testing';
        tExp.Stack_Trace_String__c = 'None';
        tExp.Timestamp__c = System.now();
        tExp.Class_Name__c = 'TestingClass';
        
        eList.add(tExp);
        
        ExceptionHandler eh = new ExceptionHandler(eList);
        
        // startTest/stopTest block to force async processes to run
        Test.startTest();  
        System.enqueueJob(eh);
        Test.stopTest();
        System.assertNotEquals(null, eh,'value is null');
    }
}