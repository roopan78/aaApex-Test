@isTest
public class ReusableLookupHandlerTest {
    
    @testSetup
    static void setupTestData() {
        // Create a test Account record
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;
    }
    
    @isTest
    static void testGetRecordTypes() {
        // Test valid object
        List<RecordType> recordTypes = ReusableLookupHandler.getRecordTypes('Account');
        System.assertNotEquals(null, recordTypes, 'Record types should not be null');
        
        // Test invalid object - should throw exception
        try {
            ReusableLookupHandler.getRecordTypes('InvalidObject');
            System.assert(false, 'Should have thrown exception for invalid object');
        } catch (AuraHandledException e) {
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
    }
    
    @isTest
    static void testFetchRecords() {
        Account testAcc = [SELECT Id, Name FROM Account LIMIT 1];
        
        // Test search with field and search string
        ReusableLookupHandler.SearchWrapper searchWrapper = new ReusableLookupHandler.SearchWrapper();
        searchWrapper.objectApiName = 'Account';
        searchWrapper.fieldApiName = 'Name';
        searchWrapper.searchString = 'Test';
        
        String inputJSON = JSON.serialize(searchWrapper);
        List<ReusableLookupHandler.ResultWrapper> results = ReusableLookupHandler.fetchRecords(inputJSON);
        
        System.assertNotEquals(null, results, 'Results should not be null');
        
        // Test search with selected record ID
        searchWrapper.selectedRecordId = testAcc.Id;
        searchWrapper.searchString = null;
        inputJSON = JSON.serialize(searchWrapper);
        results = ReusableLookupHandler.fetchRecords(inputJSON);
        
        System.assertEquals(1, results.size(), 'Should return one record when searching by ID');
    }
    
    @isTest
    static void testGetWritableFields() {
        List<String> writableFields = ReusableLookupHandler.getWritableFields('Account');
        System.assertNotEquals(null, writableFields, 'Writable fields should not be null');
    }
}