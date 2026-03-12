/*
 * Test class for RCustomLookupController.
 */
@isTest
public class RCustomLookupControllerTest {

    @isTest
    static void testCustomLookupController() {
        // Test the CustomLookupResult class
        RCustomLookupController.CustomLookupResult lookupResult = new RCustomLookupController.CustomLookupResult();
        System.assertEquals(0, lookupResult.records.size(), 'Records list should be initialized empty');
        System.assertEquals(null, lookupResult.queryStr, 'Query string should be null initially');

        // Add a record to the CustomLookupResult
        RCustomLookupController.CustomLookupRecord customRecord = new RCustomLookupController.CustomLookupRecord();
        customRecord.recordId = '001TestId123';
        customRecord.recordName = 'Test Record Name';
        customRecord.labelName = 'Test Label Name';
        customRecord.addlFldMap.put('Field1', 'Value1');
        
        // Add a child record map
        customRecord.childRecordsMap.put('ChildObjectName', new List<SObject> { new Account(Name='Test Child') });
        
        lookupResult.records.add(customRecord);
        System.assertEquals(1, lookupResult.records.size(), 'Records list should have one record after addition');
        System.assertEquals('Test Record Name', lookupResult.records[0].recordName, 'Record name should match');

        // Test the FieldValueWrapper class
        RCustomLookupController.FieldValueWrapper fieldWrapper = new RCustomLookupController.FieldValueWrapper();
        fieldWrapper.fieldId = 'FieldId1';
        fieldWrapper.fieldName = 'FieldName1';
        fieldWrapper.fieldValue = 'FieldValue1';
        fieldWrapper.fieldType = 'Text';
        fieldWrapper.fieldStyle = 'bold';
        fieldWrapper.fieldApiName = 'CustomField__c';
        
        System.assertEquals('FieldId1', fieldWrapper.fieldId, 'FieldId should match');
        System.assertEquals('FieldValue1', fieldWrapper.fieldValue, 'FieldValue should match');

        // Test the SObjectQueryResult class
        RCustomLookupController.SObjectQueryResult queryResult = new RCustomLookupController.SObjectQueryResult();
        queryResult.recordId = '002TestId456';
        queryResult.recordName = 'Query Record Name';
        queryResult.labelName = 'Query Label';
        queryResult.addlFldMap = new Map<String, Object>();
        queryResult.addlFldMap.put('SomeField', 'SomeValue');
        queryResult.recordPersonBirthdate = Date.newInstance(1990, 01, 01);

        System.assertEquals('002TestId456', queryResult.recordId, 'SObjectQueryResult recordId should match');
        System.assertEquals('SomeValue', queryResult.addlFldMap.get('SomeField'), 'Field map value should match');
        System.assertEquals(Date.newInstance(1990, 01, 01), queryResult.recordPersonBirthdate, 'Birthdate should match');
        
 
    }
    
    private static void createTestData() {
        // Create Accounts
        Account acc1 = new Account(Name = 'Test Account 1');
        Account acc2 = new Account(Name = 'Test Account 2');
        insert new List<Account>{ acc1, acc2 };

        // Create Contacts
        Contact con1 = new Contact(FirstName = 'John', LastName = 'Doe', AccountId = acc1.Id);
        Contact con2 = new Contact(FirstName = 'Jane', LastName = 'Smith', AccountId = acc2.Id);
        insert new List<Contact>{ con1, con2 };

        // Create Cases
        Case case1 = new Case(Subject = 'Test Case 1', AccountId = acc1.Id);
        insert case1;
    }

    @isTest
    static void testQueryRecords() {
        // Arrange
        createTestData();
        
        // Input parameters
        String inputString = 'Test';
        String objectName = 'Account';
        String fieldsWrapper = '[{"apiName":"Name","searchFlag":true,"orderByFlag":true,"filterFlag":false,"outputFlag":true,"resultantFlag":true,"fldType":"String","widthStyle":"width:100px","isFoot":false,"colspan":4}]';
        String filterQuery = 'Name != null';
        Boolean isSearchBox = true;
        
        // Act
        Test.startTest();
        RCustomLookupController.CustomLookupResult result = RCustomLookupController.queryRecords(inputString, objectName, fieldsWrapper, filterQuery, isSearchBox);
        Test.stopTest();
        
        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.records.size() > 0, 'Records should be returned');
        
        // Verify Query String
        System.debug('Query String: ' + result.queryStr);
        System.assert(result.queryStr.contains('SELECT'), 'Query string must include SELECT');
        System.assert(result.queryStr.contains('Name LIKE'), 'Query must include Name LIKE clause');
        System.assert(result.queryStr.contains('LIMIT 10'), 'Query must limit results to 10');
        
        // Validate Records
        for (RCustomLookupController.CustomLookupRecord record : result.records) {
            System.assertNotEquals(null, record.recordId, 'Record ID should not be null');
            System.assertNotEquals(null, record.recordName, 'Record Name should not be null');
        }
        
         String fieldsWrapper1 = '[{ "name": "AccountName","isFoot":false, "apiName": "LastName","childObjName": "Contacts","childObjFldName":"LastName","isChild":true,"searchFlag": true, "orderByFlag": false,"filterFlag": false,"resultantFlag":true,"outputFlag": true},{ "name": "RecordName","apiName": "Name", "fldType": "String","isChild": false,"searchFlag": false, "isGrandChild": false, "orderByFlag": false, "filterFlag": false, "outputFlag": true, "isFoot":false}]';
        //object test1 = RCustomLookupController.queryRecords();
         RCustomLookupController.CustomLookupResult result1 = RCustomLookupController.queryRecords('','Account',fieldsWrapper1,'',false);
         String test = '[{ "name": "AccountName","apiName": "CommentBody","childObjName": "Cases","childObjFldName":"Id","grandChildObjName":"CaseComment","grandChildObjFldName":"CommentBody", "fldType": "String","isChild":true,"searchFlag": true,"isGrandChild": true, "orderByFlag": false,"filterFlag": false,"outputFlag": true,"isFoot":false},{ "name": "RecordName","apiName": "Name", "fldType": "String","isChild": false,"searchFlag": false, "isGrandChild": false, "orderByFlag": false, "filterFlag": false, "outputFlag": true, "isFoot":false}]';
         RCustomLookupController.CustomLookupResult result2 = RCustomLookupController.queryRecords('','Account',test,'',true);
    }

    @isTest
    static void testQueryRecordsWithFilter() {
        // Arrange
        createTestData();
        
        String inputString = 'John';
        String objectName = 'Contact';
        String fieldsWrapper = '[{"apiName":"FirstName","searchFlag":true,"orderByFlag":true,"isFoot":false,"filterFlag":false,"outputFlag":true,"resultantFlag":true,"fldType":"String","widthStyle":"width:100px"},' +
            '{"apiName":"Name","searchFlag":false,"orderByFlag":false,"filterFlag":false,"isFoot":false,"outputFlag":true,"resultantFlag":true,"fldType":"String","widthStyle":"width:100px"}]';
        String filterQuery = 'FirstName != null';
        Boolean isSearchBox = false;
        
        // Act
        Test.startTest();
        RCustomLookupController.CustomLookupResult result = RCustomLookupController.queryRecords(inputString, objectName, fieldsWrapper, filterQuery, isSearchBox);
        Test.stopTest();
        
        // Assert
        System.assert(result.records.size() > 0, 'Records should be returned');
        System.assert(result.queryStr.contains('LIMIT 1000'), 'Query must limit results to 1000');
    }

    @isTest
    static void testQueryRecordsWithException() {
        // Arrange
        createTestData();

        String inputString = '123';
        String objectName = 'Account';
        String fieldsWrapper = '[{"apiName":"Name","searchFlag":true,"orderByFlag":true,"filterFlag":false,"outputFlag":true,"resultantFlag":true,"fldType":"Number","widthStyle":"width:100px"}]';
        String filterQuery = null;
        Boolean isSearchBox = true;

        // Act
        Test.startTest();
        RCustomLookupController.CustomLookupResult result = RCustomLookupController.queryRecords(inputString, objectName, fieldsWrapper, filterQuery, isSearchBox);
        Test.stopTest();

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
    }
}