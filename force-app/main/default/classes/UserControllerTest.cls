@isTest
public class UserControllerTest {
    @testSetup
    static void setup() {
        List<User> users = new List<User>();
        for (Integer i = 0; i < 5; i++) {
            User u = new User(
                FirstName = 'Test',
                LastName = 'User' + i,
                Email = 'testuser' + i + '@example.com',
                Username = 'testuser' + i + System.currentTimeMillis() + '@example.com',
                Alias = 'test' + i,
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US'
            );
            users.add(u);
        }
        insert users;
        
        List<History_Tracking_Fields__c> historyRecords = new List<History_Tracking_Fields__c>();
        for (User u : users) {
            historyRecords.add(new History_Tracking_Fields__c(
                Object_Name__c = 'TestObject',
                User_ID__c = u.Id,
                Fields__c = 'TestField'
            ));
        }
        insert historyRecords;
    }

    @isTest
    static void testGetAllUsersOrderedByName() {
        Test.startTest();
        String result = UserController.getAllUsersOrderedByName(5, 0);
        Test.stopTest();
        System.debug('getAllUsersOrderedByName Result: ' + result);
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testUserfieldValue() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        Test.startTest();
        String result = UserController.UserfieldValue('NewField', 'TestObject', testUser.Id);
        Test.stopTest();
        System.assertEquals('Success', result, 'Expected success response');
    }

    @isTest
    static void testFetchSelectedFieldHistories() {
        User testUser = [SELECT Id FROM User LIMIT 1];
        insert new History_Tracking_Fields__c(Object_Name__c = 'TestObject', User_ID__c = testUser.Id, Fields__c = 'TestField');
        Test.startTest();
        String result = UserController.fetchselectedfieldHistories('TestObject', testUser.Id);
        Test.stopTest();
        System.debug('fetchselectedfieldHistories Result: ' + result);
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testFieldValue() {
        Test.startTest();
        String result = UserController.fieldValue('UpdatedField', 'TestObject');
        Test.stopTest();
        System.debug('fieldValue Result: ' + result);
        System.assertEquals('Success', result, 'Expected success response');
    }
}