@isTest
public class DynamicFieldControllerTest {
    @testSetup
    static void setup() {
        // Creating test data for History_Tracking_Fields__c
        History_Tracking_Fields__c htf = new History_Tracking_Fields__c(
            Object_Name__c = 'Account',
            Fields__c = 'Name,Industry'
        );
        insert htf;
    }

    @isTest
    static void testGetObjectList() {
        Test.startTest();
        List<String> objectNames = DynamicFieldController.getObjectList();
        Test.stopTest();
        
        System.assertNotEquals(0, objectNames.size(), 'Object list should not be empty');
    }

    @isTest
    static void testGetFieldList() {
        Test.startTest();
        List<Map<String, String>> fields = DynamicFieldController.getFieldList('Account');
        Test.stopTest();
        
        System.assertNotEquals(0, fields.size(), 'Field list should not be empty');
        System.assert(fields[0].containsKey('label'), 'Field data should have a label');
        System.assert(fields[0].containsKey('value'), 'Field data should have a value');
    }

    @isTest
    static void testFieldValue_Insert() {
        Test.startTest();
        String result = DynamicFieldController.fieldValue('[\"Phone\"]', 'Contact');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Field value insertion should be successful');
    }

    @isTest
    static void testFieldValue_Update() {
        Test.startTest();
        String result = DynamicFieldController.fieldValue('[\"Industry\"]', 'Account');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Field value update should be successful');
    }

    @isTest
    static void testFetchSelectedFieldHistories() {
        Test.startTest();
        String fieldHistory = DynamicFieldController.fetchselectedfieldHistories('Account');
        Test.stopTest();
        
        System.assertNotEquals(null, fieldHistory, 'Fetched field history should not be null');
        System.assertEquals('Name,Industry', fieldHistory, 'Field history should match expected value');
    }

    @isTest
    static void testGetNameSpace() {
        Test.startTest();
        String namespace = DynamicFieldController.getNameSpace();
        Test.stopTest();
        
        System.assertNotEquals(null, namespace, 'Namespace should not be null');
    }
}