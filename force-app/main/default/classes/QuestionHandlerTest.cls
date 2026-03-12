/*
 * Test class for QuestionHandler.
 */
@isTest
private class QuestionHandlerTest {
    // Test method for the constructor with a parameter
    @isTest static void testConstructorWithParam() {
        QuestionHandler handler = new QuestionHandler('12345');
        System.assertEquals('12345', handler.contactId, 'Contact ID should be set to 12345');
    }

    // Test method for the default constructor
    @isTest static void testDefaultConstructor() {
        QuestionHandler handler = new QuestionHandler();
        System.assertEquals('', handler.contactId, 'Contact ID should be initialized to empty string');
    }

    // Test method for setContext method
    @isTest static void testSetContext() {
        QuestionHandler handler = new QuestionHandler();
        handler.setContext('contactId', '67890');
        System.assertEquals('67890', handler.contactId, 'Contact ID should be updated to 67890');
    }

    // Test method for getRecords method
    @isTest static void testGetRecords() {
        QuestionHandler handler = new QuestionHandler();
        String response = handler.getRecords();
        System.assertEquals('{"status":"failure","message":"List operation is not supported"}', 
            response, 'getRecords should return the failure message');
    }

    // Test method for createRecords method
    @isTest static void testCreateRecords() {
        QuestionHandler handler = new QuestionHandler();
        String response = handler.createRecords('{"name":"Test"}');
        System.assertEquals('{"status":"failure","message":"Create operation is not supported"}', 
            response, 'createRecords should return the failure message');
    }

    // Test method for updateRecords method
    @isTest static void testUpdateRecords() {
        QuestionHandler handler = new QuestionHandler();
        String response = handler.updateRecords('{"id":"12345"}');
        System.assertEquals('{"status":"failure","message":"Update operation is not supported"}', 
            response, 'updateRecords should return the failure message');
    }

    // Test method for deleteRecords method
    @isTest static void testDeleteRecords() {
        QuestionHandler handler = new QuestionHandler();
        String response = handler.deleteRecords('{"id":"12345"}');
        System.assertEquals('{"status":"failure","message":"Delete operation is not supported"}', 
            response, 'deleteRecords should return the failure message');
    }

    // Test method for @TestVisible variable
    @isTest static void testTestVisibleVariable() {
        QuestionHandler handler = new QuestionHandler();
        handler.contactId = 'test123';
        System.assertEquals('test123', handler.contactId, 'TestVisible variable contactId should be directly accessible');
    }
    
    @isTest static void testReadRecordsSuccess() {
        //testSetup
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c parentQuestion = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert parentQuestion;
        
        Option__c qopt = new Option__c(
        Unique_Identifier__c = 'click', Question__c = parentQuestion.Id, Value__c = 'value', Order__c = 3);
        insert qopt;
        
        Question__c childQuestion = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Tester',
            Question_Book__c = questionBook.Id //Next_Question__c = parentQuestion.Id
        );
        insert childQuestion;
        // Step 1: Set up test data
        String questionId = parentQuestion.Id;

        // Step 2: Call the readRecords method
        QuestionHandler handler = new QuestionHandler();
        String response = handler.readRecords(questionId, 'EN');

        // Step 3: Parse the JSON response and verify
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        // Assertions
        System.assertEquals('success', responseMap.get('status'), 'Status should be success');
        System.assert(responseMap.containsKey('question'), 'Response should include question details');
    }

    @isTest static void testReadRecordsFailure() {
        // Step 1: Pass an invalid Question ID
        String invalidQuestionId = 'invalidId';

        // Step 2: Call the readRecords method
        QuestionHandler handler = new QuestionHandler();
        String response = handler.readRecords(invalidQuestionId, 'EN');

        // Step 3: Parse the JSON response and verify error details
        Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response);

        // Assertions
        System.assertEquals('failure', responseMap.get('status'), 'Status should be failure');
        System.assert(responseMap.containsKey('errorCode'), 'Response should include errorCode');
        System.assert(responseMap.containsKey('errorMessage'), 'Response should include errorMessage');
    }
    
    @isTest
    static void testConstructorWithValidOption() {
        // Create a mock Option__c record
        Option__c testOption = new Option__c(
            Unique_Identifier__c = 'test1', Value__c = 'Value 1', Question__c = 'a05fL000000Hjf3QAC', Order__c = 1
        );

        // Call the constructor
        QuestionOptionWrapper wrapper = new QuestionOptionWrapper(testOption);

        // Assertions
        System.assertEquals(testOption.Id, wrapper.optionId, 'Option Id should match');
        System.assertEquals(testOption.Name, wrapper.optionName, 'Option Name should match');
        System.assertEquals(testOption.Value__c, wrapper.value, 'Value should match');
        System.assertEquals(testOption.Next_Question__c, wrapper.nextQuestion, 'Next Question should match');
    }

    @isTest
    static void testConstructorWithNullFields() {
        // Create an Option__c record with null fields
        Option__c testOption = new Option__c(
            Unique_Identifier__c = 'test1', Value__c = 'Value 1', Question__c = 'a05fL000000Hjf3QAC', Order__c = 1
        );

        // Call the constructor
        QuestionOptionWrapper wrapper = new QuestionOptionWrapper(testOption);

        // Assertions
        System.assertEquals(testOption.Id, wrapper.optionId, 'Option Id should match');
        System.assertEquals(null, wrapper.optionName, 'Option Name should be null');
        //System.assertEquals(null, wrapper.value, 'Value should be null');
        System.assertEquals(null, wrapper.nextQuestion, 'Next Question should be null');
    }

    @isTest
    static void testConstructorWithEmptyOption() {
        // Create an empty Option__c record
        Option__c testOption = new Option__c(
            Unique_Identifier__c = 'test1', Value__c = 'Value 1', Question__c = 'a05fL000000Hjf3QAC', Order__c = 1
        );

        // Call the constructor
        QuestionOptionWrapper wrapper = new QuestionOptionWrapper(testOption);

        // Assertions
        System.assertEquals(null, wrapper.optionId, 'Option Id should be null');
        System.assertEquals(null, wrapper.optionName, 'Option Name should be null');
        //System.assertEquals(null, wrapper.value, 'Value should be null');
        System.assertEquals(null, wrapper.nextQuestion, 'Next Question should be null');
    }

    @isTest
    static void testAfterInsert() {
        // Test setup for after insert
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c question = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question;

        // Verify logic after insert
        Test.startTest();
        Question__c insertedQuestion = [SELECT Id, Question_Book__c FROM Question__c WHERE Id = :question.Id];
        System.assertNotEquals(null, insertedQuestion);
        Test.stopTest();
    }

    @isTest
    static void testAfterUpdate() {
        // Test setup for after update
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c question = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question;

        // Update question
        question.Question_No__c = 2;
        update question;

        // Verify logic after update
        Test.startTest();
        Question__c updatedQuestion = [SELECT Id, Question_No__c FROM Question__c WHERE Id = :question.Id];
        System.assertEquals(2, updatedQuestion.Question_No__c);
        Test.stopTest();
    }

    @isTest
    static void testAfterDelete() {
        // Test setup for after delete
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c question = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question;

        delete question;

        // Verify logic after delete
        Test.startTest();
        List<Question__c> deletedQuestions = [SELECT Id FROM Question__c WHERE Id = :question.Id];
        System.assertEquals(0, deletedQuestions.size());
        Test.stopTest();
    }

    @isTest
    static void testFieldMetaReferences() {
        // Test setup for Field_Meta__c references
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question1;
        
        Question__c question2 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'TestTest',
            Question_Book__c = questionBook.Id
        );
        insert question2;
        
        Set<Id> QRefIds = new Set<Id>{question1.Id};

        Field_Meta__c fieldMeta = new Field_Meta__c(Question__c = question2.Id, Question_Reference__c = question1.Id, Unique_Identifier__c = 'bot');
        insert fieldMeta;

        // Trigger logic to verify field meta updates
        Test.startTest();
        update question1;
        Test.stopTest();
        
        List<Field_Meta__c> fieldMetas = [SELECT Id, Question__c FROM Field_Meta__c WHERE Question_Reference__c = :question1.Id];
        System.assertEquals(1, fieldMetas.size());
        System.assertEquals(question2.Id, fieldMetas[0].Question__c);
   
    }

    @isTest
    static void testQuestionBookReferences() {
        // Test setup for Question Book references
        Question_Book__c questionBook1 = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook1;
        
        Question_Book__c questionBook2 = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '6789',
                                                            Category__c = 'Simple');
        insert questionBook2;

        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test1',
            Question_Book__c = questionBook1.Id
        );
        insert question1;
        Question__c question2 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test2',
            Question_Book__c = questionBook2.Id
        );
        insert question2;
        
        Set<Id> QBRefIds = new Set<Id>{questionBook1.Id};

        // Trigger logic to verify question book updates
        Test.startTest();
        update question1;
        Test.stopTest();
        List<Question__c> questions = [SELECT Id, Question_Book__c, QB_Reference__c FROM Question__c WHERE QB_Reference__c IN :QBRefIds];

    }
}