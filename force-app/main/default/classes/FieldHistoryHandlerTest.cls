@isTest
public class FieldHistoryHandlerTest {
    public static void callHandler() {
	    List<Field_History__b> inpList = new List<Field_History__b>();
		
		 Field_History__b his = new Field_History__b();
                his.Record_ID__c = '';
                his.Field_Name__c = '';
                his.New_Value__c = '5';
                his.Old_Value__c = '3';
                his.Timestamp__c = System.now();


                inpList.add(his);
				
				 FieldHistoryHandler f = new FieldHistoryHandler(inpList);
        
        // startTest/stopTest block to force async processes to run
		Test.startTest();        
        System.enqueueJob(f);
        Test.stopTest();           
    }
@isTest
public static void handler() {
List<Field_History__b> fhList = new List<Field_History__b>();
		
		 Field_History__b his = new Field_History__b();
                his.Record_ID__c = '';
                his.Field_Name__c = '';
                his.New_Value__c = '';
                his.Old_Value__c = '';
                his.Timestamp__c = System.now();


                fhList.add(his);
				
				 FieldHistoryHandler f = new FieldHistoryHandler(fhList);
        
        // startTest/stopTest block to force async processes to run
		Test.startTest();    
        system.debug('Fhlist='+fhList);    
        System.enqueueJob(f);
        Test.stopTest();    
        System.assertNotEquals(null, f,'value is null');   
}
}