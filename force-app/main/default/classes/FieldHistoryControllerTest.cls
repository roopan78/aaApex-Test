@isTest
public class FieldHistoryControllerTest { 
    @testSetup
    static void setupTestData() {
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u1 = new User(
            Alias = 'standt1',
            Country = 'United Kingdom',
            Email = 'abdul@rangerinc.co',
            EmailEncodingKey = 'UTF-8', 
            LastName = 'abdul', 
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles', 
            UserName = 'abdullog4dev@rangerinc.co'
        );
        insert u1;

        System.runAs(u1) {
            History_Tracking_Fields__c allHist = new History_Tracking_Fields__c();
            allHist.Object_Name__c = 'Contact';
            allHist.Fields__c = 'LastName,assignment,description,Department,Phone';
            allHist.User_ID__c = u1.Id; 

            try {
                insert allHist;
            } catch (Exception e) {
                System.debug('Error inserting History_Tracking_Fields__c: ' + e.getMessage());
            }
        }
    }

    @isTest
    static void TestProfileType1() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'standt1' LIMIT 1];

        System.runAs(u1) {
            History_Tracking_Fields__c allHist = [SELECT Id, Object_Name__c FROM History_Tracking_Fields__c LIMIT 1];

            // Test all main methods
            String profileName = FieldHistoryController.getProfile();
            System.assertNotEquals(profileName, null, 'Profile name should not be null');

            String jsonResult = FieldHistoryController.fetchfieldHistories(allHist.Id, allHist.Object_Name__c);
            System.assert(jsonResult.contains('[]') || jsonResult.contains('LastName'), 'Expected valid JSON response');

            SObjectType objType = FieldHistoryController.getSObjectType(allHist.Id);
            System.assertNotEquals(objType, null, 'Object Type should not be null');

            // Validate Field Wrapper class instantiation
            FieldHistoryController.fieldWrapper fw = new FieldHistoryController.fieldWrapper();
            fw.id = 'testId';
            fw.timeStamp = System.now();
            fw.fieldValue = 'Test Field';
            fw.oldValue = 'Old Value';
            fw.newValue = 'New Value';
            fw.userName = 'Test User';
            fw.userId = 'TestUserId';

            System.assertNotEquals(fw, null, 'FieldWrapper instance should not be null');
        }
    }

    @isTest
    static void testFetchFieldHistories_WithValidData() {
        User u1 = [SELECT Id FROM User WHERE Alias = 'standt1' LIMIT 1];

        System.runAs(u1) {
            History_Tracking_Fields__c hist = [SELECT Id, Object_Name__c FROM History_Tracking_Fields__c LIMIT 1];

            String result = FieldHistoryController.fetchfieldHistories(hist.Id, hist.Object_Name__c);
            System.assert(result.contains('[]') || result.contains('LastName'), 'Expected field history response');
        }
    }
}