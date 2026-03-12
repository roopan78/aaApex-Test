@isTest
public class ExceptionControllerTest {
    @isTest
    public static void getExceptionsTest(){
       /* Exception__b excep = new Exception__b();
        excep.Flow_Stack__c = '';
        excep.Message__c ='';
        excep.Print_Stack__c ='';
        excep.Stack_Trace_String__c ='';
        excep.Timestamp__c = DateTime.now();
        excep.Type_Name__c = '';
        excep.Class_Name__c = 'getException';
        
       // Database.insertImmediate(excep);*/
        Exception__b[] checkException = [Select Id,Flow_Stack__c,Message__c,Print_Stack__c,Stack_Trace_String__c,Timestamp__c,
                Type_Name__c, Class_Name__c from Exception__b];
        
        Test.startTest();
        System.assertEquals(ExceptionController.getExceptions('else'),checkException);
        Test.stopTest();
    }

}