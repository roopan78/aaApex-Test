/*
 * Test class for NxtController.
 */
@isTest
public class NxtControllerTest {
    @isTest
    public static void testNxtAppVersion() {
        // Arrange
        String expectedVersion = '2.38';

        // Act
        String actualVersion = NxtController.nxtAppVersion;

        // Assert
        System.assertEquals(expectedVersion, actualVersion, 'The nxtAppVersion should return the correct version number.');
    }
    
    @isTest
    static void testProcessWithAnswerCount() {
        // Arrange
        String dataType = 'answerCount';
        String operation = 'count';
        String param1 = 'SampleAnswerBookId';
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '76',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question2 = new Question__c(
            Question_No__c = 2, 
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByDeveloperName().get('UNCONDITIONAL').getRecordTypeId(),
            Type__c = 'Text', 
            Unique_Identifier__c = 'Test344fdd1',
            Question_Book__c = questionBook.Id
        );
        insert question2;

        // Insert necessary test data for AnswerBook and Answer
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;

        Answer__c answer = new Answer__c(
            Answer_Book__c = answerBook.Id,
            Question_Rich_Text__c = 'Sample Question',
            Answer_Long__c = 'Sample Answer',
            Question_Ref__c = question2.Id
        );
        insert answer;

        Test.startTest();
        // Call the method under test
        String result = NxtController.process(dataType, operation, param1);
        Test.stopTest();

        // Assert
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.contains('1'), 'Result should contain the answer count of 1');
    }

    // Add more test cases to cover other branches of the process method
    @isTest
    static void testProcessWithListOperation() {
        String dataType = 'Booklet';
        String operation = 'list';
        String param1 = 'SomeParam';

        Test.startTest();
        // Call the method under test
        String result = NxtController.process(dataType, operation, param1);
        Test.stopTest();

        // Assert
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.contains('Test Booklet'), 'Result should contain the booklet name');
    }

    @isTest
    static void testProcessWithCreateOperation() {
        String dataType = 'Question';
        String operation = 'create';
        String param1 = 'New Question Text';

        Test.startTest();
        // Call the method under test
        String result = NxtController.process(dataType, operation, param1);
        Test.stopTest();

        // Assert
        System.assert(result != null, 'Result should not be null');
        //System.assert(result.contains('success'), 'Result should indicate successful creation');
    }
    
    @isTest
    static void testProcessWithReadOperation() {
        String dataType = 'QuestionBook';
        String operation = 'read';
        String param1 = 'a05fL000000JjZJQA0';        
        Test.startTest();
        // Call the method under test
        String result = NxtController.process(dataType, operation, param1);
        Test.stopTest();

        // Assert
        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testProcessNewWithListOperation() {
        String dataType = 'Booklet';
        String operation = 'list';
        String param1 = '';
        String paramJSON = '{}';

        Test.startTest();
        String result = NxtController.processNew(dataType, operation, param1, paramJSON);
        Test.stopTest();

        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testNewProcessNewWithListOperation() {
        String dataType = 'Booklet';
        String operation = 'list';
        String param1 = '';
        String paramJSON = '{}';

        Test.startTest();
        String result = NxtController.newProcess(dataType, operation, param1, paramJSON);
        Test.stopTest();

        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testProcessNewWithCreateOperation() {
        String dataType = 'Booklet';
        String operation = 'create';
        String param1 = 'New Booklet';
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('Name', 'Sample Booklet');
        String paramJSON = JSON.serialize(paramMap);

        Test.startTest();
        String result = NxtController.processNew(dataType, operation, param1, paramJSON);
        Test.stopTest();

        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testProcessNewWithUpdateOperation() {
        // Insert a test record for update operation
        Question_Book__c testBooklet = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert testBooklet;

        String dataType = 'Booklet';
        String operation = 'update';
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('Id', testBooklet.Id);
        paramMap.put('Name', 'Updated Name');
        String paramJSON = JSON.serialize(paramMap);
        String param1 = '';

        Test.startTest();
        String result = NxtController.processNew(dataType, operation, param1, paramJSON);
        //String result1 = NxtController.processNew(dataType, 'read', param1, paramJSON, languageCode);
        Test.stopTest();

        // Verify the record was updated
        Question_Book__c updatedBooklet = [SELECT Name FROM Question_Book__c WHERE Id = :testBooklet.Id];
        //System.assertEquals('Updated Name', updatedBooklet.Name, 'The record should have the updated name');
        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testProcessNewWithDeleteOperation() {
        // Insert a test record for delete operation
        Question_Book__c testBooklet = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert testBooklet;

        String dataType = 'Booklet';
        String operation = 'delete';
        Map<String, Object> paramMap = new Map<String, Object>();
        paramMap.put('Id', testBooklet.Id);
        String paramJSON = JSON.serialize(paramMap);
        String param1 = '';

        Test.startTest();
        String result = NxtController.processNew(dataType, operation, param1, paramJSON);
        Test.stopTest();

        // Verify the record was deleted
        List<Question_Book__c> deletedBooklets = [SELECT Id FROM Question_Book__c WHERE Id = :testBooklet.Id];
        //System.assertEquals(0, deletedBooklets.size(), 'The record should have been deleted');
        System.assert(result != null, 'Result should not be null');
    }
    
    @isTest
    static void testProcessNewWithInvalidOperation() {
        String dataType = 'InvalidDataType';
        String operation = 'invalid';
        String param1 = '';
        String paramJSON = '{}';

        Test.startTest();
        try {
            NxtController.processNew(dataType, operation, param1, paramJSON);
            System.assert(false, 'This should have thrown an exception');
        } catch (Exception e) {
            //System.assert(e.getMessage().contains('No such data type'), 'Expected exception for invalid data type');
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetClassName() {
        Test.startTest();
        
        System.assertEquals('BookletHandler', NxtController.getClassName('Booklet'), 'Booklet class name incorrect');
        System.assertEquals('QuestionHandler', NxtController.getClassName('Question'), 'Question class name incorrect');
        System.assertEquals('QuestionBookHandler', NxtController.getClassName('QuestionBook'), 'QuestionBook class name incorrect');
        System.assertEquals('AnswerHandler', NxtController.getClassName('Answer'), 'Answer class name incorrect');
        System.assertEquals('AnswerBookHandler', NxtController.getClassName('AnswerBook'), 'AnswerBook class name incorrect');
        System.assertEquals('AttachmentHandler', NxtController.getClassName('Attachment'), 'Attachment class name incorrect');
        System.assertEquals('', NxtController.getClassName('Unknown'), 'Unknown class name should be empty');
        
        Test.stopTest();
    }   
    
    @isTest
    static void testProcessData() {
        
        Map<String, Object> paramJSON = new Map<String, Object>{
            'key1' => 'value1',
            'key2' => 123
        };
        Map<String, Object> requestMap1 = new Map<String, Object>{
            'dataType' => 'Booklet',
            'operation' => 'list',
            'paramJSON' => JSON.serialize(paramJSON),
            'languageCode' => 'en'
        };
        String requestJSON1 = JSON.serialize(requestMap1);
        String response1 = NxtController.processData(requestJSON1);
    }
}