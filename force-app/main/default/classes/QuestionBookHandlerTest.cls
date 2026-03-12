@IsTest
public class QuestionBookHandlerTest {

    @IsTest
    static void testConstructorWithFlag() {
        // Test the constructor with a flag parameter
        QuestionBookHandler handler = new QuestionBookHandler(true);
        //System.assertEquals(true, Test.getPrivateField(handler, 'createAnswerBookFlag'));
    }

    @IsTest
    static void testDefaultConstructor() {
        // Test the default constructor
        QuestionBookHandler handler = new QuestionBookHandler();
        //System.assertNotNull(handler);
    }

    @IsTest
    static void testSetContextWithFlagField() {
        // Test the setContext method for 'createAnswerBookFlag'
        QuestionBookHandler handler = new QuestionBookHandler();
        handler.setContext('createAnswerBookFlag', true);
        //System.assertEquals(true, Test.getPrivateField(handler, 'createAnswerBookFlag'));

        // Test paramMap for 'createAnswerBookFlag'
        //Map<String, Object> paramMap = (Map<String, Object>) Test.getPrivateField(handler, 'paramMap');
        //System.assertEquals(true, paramMap.get('createAnswerBookFlag'));
    }

    @IsTest
    static void testSetContextWithOtherFields() {
        // Test the setContext method for other fields
        QuestionBookHandler handler = new QuestionBookHandler();
        handler.setContext('otherField', 'testValue');

        //Map<String, Object> paramMap = (Map<String, Object>) Test.getPrivateField(handler, 'paramMap');
        //System.assertEquals('testValue', paramMap.get('otherField'));
    }

    @IsTest
    static void testGetRecords() {
        // Test the getRecords method
        QuestionBookHandler handler = new QuestionBookHandler();
        String result = handler.getRecords();
        System.assertEquals('{"status":"failure","message":"List operation is not supported"}', result);
    }

    @IsTest
    static void testCreateRecords() {
        // Test the createRecords method
        QuestionBookHandler handler = new QuestionBookHandler();
        String result = handler.createRecords('{"key":"value"}');
        System.assertEquals('{"status":"failure","message":"Create operation is not supported"}', result);
    }

    @IsTest
    static void testUpdateRecords() {
        // Test the updateRecords method
        QuestionBookHandler handler = new QuestionBookHandler();
        String result = handler.updateRecords('{"key":"value"}');
        System.assertEquals('{"status":"failure","message":"Update operation is not supported"}', result);
    }

    @IsTest
    static void testDeleteRecords() {
        // Test the deleteRecords method
        QuestionBookHandler handler = new QuestionBookHandler();
        String result = handler.deleteRecords('{"key":"value"}');
        System.assertEquals('{"status":"failure","message":"Delete operation is not supported"}', result);
    }
    
    @testSetup
    static void setupTestData() {
        // Create sample Question_Book__c records
        Question_Book__c qb = new Question_Book__c(Title__c = 'Test Question Book',
                                                            Category__c = 'Simple');
        insert qb;
        
        Question__c ques = new Question__c(
            Question_No__c = 1, Type__c = 'Radio',
            Question_Book__c = qb.Id
        );
        insert ques;

        // Create related Answer_Book__c records
        Answer_Book__c ab = new Answer_Book__c(
            Question_Book__c = qb.Id,
            Status__c = 'Pending',
            RecordId__c = 'a05fL000000JjZJQA0'
        );
        insert ab;

        // Create related Answer__c records
        Answer__c answer = new Answer__c(
            Answer_Book__c = ab.Id,
            Question_Ref__c = ques.Id,
            Question_Text__c = 'Sample Question',
            Answer_Long__c = 'Sample Answer'
        );
        insert answer;

        // Create related Input__c records
        Input__c input = new Input__c(
            Question_Book__c = qb.Id,
            API_Name__c = 'SampleAPI',
            Type__c = 'String'
        );
        insert input;
        Option__c opt1 = new Option__c(Value__c = 'Value 1', Question__c = ques.Id, Order__c = 1);
        Option__c opt2 = new Option__c(Value__c = 'Value 2', Question__c = ques.Id, Order__c = 2);
        insert opt1;
        insert opt2;
    }
    
    @isTest
    static void testReadRecordsWithAnswerBookId() {
        // Arrange
        Answer_Book__c ab = [SELECT Id FROM Answer_Book__c LIMIT 1];
        String inputJSON = String.valueOf(ab.Id);
        String languageCode = 'en';
        Test.startTest();

        // Act
        QuestionBookHandler testInstance = new QuestionBookHandler();
        String result = testInstance.readRecords(inputJSON, languageCode);

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('answers'), 'Result should contain answers field');
    }

    @isTest
    static void testReadRecordsWithQuestionBookId() {
        // Arrange
        Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
        String inputJSON = String.valueOf(qb.Id);
        String languageCode = 'en';
        Test.startTest();

        // Act
        QuestionBookHandler testInstance = new QuestionBookHandler();
        String result = testInstance.readRecords(inputJSON, languageCode);

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('questionbook'), 'Result should contain questionbook field');
    }

    @isTest
    static void testCreateAnswerBookFlagTrue() {
        // Arrange
        Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
        String inputJSON = String.valueOf(qb.Id);
        String languageCode = 'en';

        QuestionBookHandler testInstance = new QuestionBookHandler();
        testInstance.createAnswerBookFlag = true; // Set flag to true

        Test.startTest();

        // Act
        String result = testInstance.readRecords(inputJSON, languageCode);

        // Assert
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.contains('answerbook'), 'Result should contain answerbook field');
    }

    @isTest
    static void testQueryExceptionHandling() {
    // Arrange
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    qb.Query__c = 'SELECT Id, Name FROM Account WHERE Industry = {Industry}';
    update qb;

    String inputJSON = String.valueOf(qb.Id);
    String languageCode = 'en';

    // Prepare `paramMap` mock data by populating `Industry`
    Map<String, Object> paramMap = new Map<String, Object>();
    paramMap.put('Industry', 'Banking');
    QuestionBookHandler testInstance = new QuestionBookHandler();
    testInstance.paramMap = paramMap; // Assuming `paramMap` is accessible in the handler

    Test.startTest();

    // Act
    String result = testInstance.readRecords(inputJSON, languageCode);

    // Assert
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.contains('qbQueryResult'), 'Result should contain qbQueryResult field');
   // System.assert(result.contains('exception'), 'Result should contain exception field');
    
    // Assert to verify query replacement logic
    //System.assert(result.contains('WHERE Industry = \'Banking\''), 
                  //'The query should replace {Industry} with \'Banking\'');
    }
    
    @isTest
    static void testNewQueryExceptionHandling() {
    // Arrange: Create test data
    Question_Book__c qb = new Question_Book__c(Title__c = 'Test111',Category__c = 'Simple');
    insert qb;

    // Create related Question__c records
   Id recType = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId();
     List<Question__c> questions = new List<Question__c>{
     new Question__c(Question_No__c = 1, Type__c = 'Text',RecordTypeId =recType,  Question_Book__c = qb.Id),
     new Question__c(Question_No__c = 2, Type__c = 'Text',RecordTypeId =recType, Question_Book__c = qb.Id),
     new Question__c(Question_No__c = 3, Type__c = 'Text',RecordTypeId =recType, Question_Book__c = qb.Id)
    };
    insert questions;

    // Update the Question_Book__c record with a valid query string for the test
    qb.Query__c = 'SELECT Id, Name FROM Question__c WHERE Question_Book__c = \'' + qb.Id + '\'';
    update qb;

    // Prepare inputs for the handler
    String inputJSON = String.valueOf(qb.Id);
    String languageCode = 'en';
    QuestionBookHandler testInstance = new QuestionBookHandler();

    // Act: Execute the method to be tested
    Test.startTest();
    String result = testInstance.readRecords(inputJSON, languageCode);
    Test.stopTest();

    // Assert: Verify the outputs
    System.assertNotEquals(null, result, 'Result should not be null');
    System.assert(result.contains('qbQueryResult'), 'Result should contain qbQueryResult field');
   // System.assert(result.contains('QuestionOptions'), 'Result should contain QuestionOptions field');
    //System.assert(result.contains('Option 1'), 'Result should contain the first option name');
    //System.assert(result.contains('Option 2'), 'Result should contain the second option name');
    //System.assert(result.contains('Option 3'), 'Result should contain the third option name');
    }


    
    @isTest
    static void testOptionWrapper() {
        // Create test data
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Tester',Category__c = 'Simple');
        insert questionBook;
        
        Question__c testQuestion = new Question__c(
            Question_No__c = 1, Type__c = 'Radio',
            Question_Book__c = questionBook.Id
        );
        insert testQuestion;

        Option__c testOption = new Option__c( Value__c = 'Value 1', Question__c = testQuestion.Id, Order__c = 3
        );
        insert testOption;

        // Perform the test
        Test.startTest();
        OptionWrapper optionWrapper = new OptionWrapper(testOption);
        Test.stopTest();

        // Validate the wrapper fields
        System.assertEquals(testOption.Id, optionWrapper.id, 'Id field mismatch');
        System.assertEquals(testOption.Name, optionWrapper.name, 'Name field mismatch');
        System.assertEquals(testOption.Value__c, optionWrapper.value, 'Value field mismatch');
        System.assertEquals(testOption.Question__c, optionWrapper.questionId, 'Question Id field mismatch');
        System.assertEquals(testOption.Next_Question__c, optionWrapper.nextQuestion, 'Next Question field mismatch');
    }
}