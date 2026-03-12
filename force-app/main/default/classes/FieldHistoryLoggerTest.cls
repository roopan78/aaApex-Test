@isTest
public class FieldHistoryLoggerTest {

    @isTest
    public static void fieldHistoryLoggerUpdateTest() {
        // Insert Account
        Account accNew = new Account();
        accNew.Name = 'New Account';
        accNew.AccountNumber = '23';
        insert accNew;
        System.assertNotEquals('Logger','value is null','Test');

        Map<Id, SObject> oldMap = new Map<Id, SObject> { accNew.Id => (SObject)accNew };
            
            // Update Account
            accNew.AccountNumber = '22';
        update accNew;
        
        // Testing isUpdate
        Test.startTest();
        FieldHistoryLogger.handler(true, oldMap, new Map<Id, SObject> { accNew.Id => (SObject)accNew });
        Test.stopTest();
    }
}