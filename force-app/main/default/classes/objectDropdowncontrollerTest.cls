@isTest
public class objectDropdowncontrollerTest {
    @testSetup
    static void setup() {
        // Create test data for History_Tracking_Fields__c
        History_Tracking_Fields__c testRecord = new History_Tracking_Fields__c(
            Object_Name__c = 'Account',
            Fields__c = 'Name, Industry'
        );
        insert testRecord;
    }

    @isTest
    static void testGetObjectList() {
        Test.startTest();
        List<String> objects = ObjectDropdownController.getObjectList();
        Test.stopTest();
        
        System.assert(objects != null, 'Object list should not be null');
        System.assert(objects.size() > 0, 'Object list should contain items');
    }

    @isTest
    static void testGetFieldList() {
        Test.startTest();
        List<Map<String, String>> fields = ObjectDropdownController.getFieldList('Account');
        Test.stopTest();
        
        System.assert(fields != null, 'Field list should not be null');
        System.assert(fields.size() > 0, 'Field list should contain items');
    }

    @isTest
    static void testFieldValueInsert() {
        Test.startTest();
        String result = ObjectDropdownController.fieldValue('["Phone"]', 'Contact');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Expected success for inserting a new record');
    }

    @isTest
    static void testFieldValueUpdate() {
        Test.startTest();
        String result = ObjectDropdownController.fieldValue('["Email"]', 'Account');
        Test.stopTest();
        
        System.assertEquals('Success', result, 'Expected success for updating an existing record');
    }

    @isTest
    static void testFetchSelectedFieldHistories() {
        Test.startTest();
        String fieldValues = ObjectDropdownController.fetchselectedfieldHistories('Account');
        Test.stopTest();
        
        System.assert(fieldValues != null, 'Field values should not be null');
    }

    @isTest
    static void testGetNameSpace() {
        Test.startTest();
        try {
            String namespace = ObjectDropdownController.getNameSpace();
            System.assert(namespace != null, 'Namespace should not be null');
        } catch (Exception e) {
            System.assert(false, 'Exception thrown: ' + e.getMessage());
        }
        Test.stopTest();
    }


}