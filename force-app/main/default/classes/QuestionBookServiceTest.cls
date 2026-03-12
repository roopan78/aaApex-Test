@IsTest
public with sharing class QuestionBookServiceTest {
  @TestSetup
  static void setupTestData() {
    // Create a Question Book
    Question_Book__c qb = new Question_Book__c(
      Title__c = 'Test Question Book',
      Category__c = 'Simple',
      Anchor_Object__c = 'Account'
    );
    insert qb;

    // Create parent question
    Question__c parentQuestion = new Question__c(
      Question_Book__c = qb.Id,
      Question_Text__c = 'Parent Question',
      Type__c = 'Book',
      Question_No__c = 1,
      Size__c = 12,
      RecordTypeId = QuestionUtility.recordTypeIdByName.get('UNCONDITIONAL')
    );
    insert parentQuestion;

    // Create child questions
    List<Question__c> questions = new List<Question__c>();

    // Text question
    questions.add(
      new Question__c(
        Question_Book__c = qb.Id,
        Question_Parent__c = parentQuestion.Id,
        Question_Text__c = 'Text Question',
        Type__c = 'Text',
        Question_No__c = 2,
        Size__c = 6,
        RecordTypeId = QuestionUtility.recordTypeIdByName.get('UNCONDITIONAL')
      )
    );

    // Dropdown question with options
    Question__c dropdownQuestion = new Question__c(
      Question_Book__c = qb.Id,
      Question_Parent__c = parentQuestion.Id,
      Question_Text__c = 'Dropdown Question',
      Type__c = 'Dropdown',
      Question_No__c = 3,
      Size__c = 6,
      RecordTypeId = QuestionUtility.recordTypeIdByName.get('OPTIONONLY')
    );
    questions.add(dropdownQuestion);

    insert questions;

    // Add options to dropdown question
    List<Option__c> options = new List<Option__c>();
    options.add(
      new Option__c(
        Question__c = dropdownQuestion.Id,
        Value__c = '1',
        Order__c = 1
      )
    );
    options.add(
      new Option__c(
        Question__c = dropdownQuestion.Id,
        Value__c = '2',
        Order__c = 2
      )
    );
    insert options;

    // Create translation
    Translation__c translation = new Translation__c(
      Question_Book__c = qb.Id,
      Language__c = 'en_US',
      Translated_Text__c = '{"key":"value"}'
    );
    insert translation;

    // Create style
    Style__c style = new Style__c(
      Question__c = parentQuestion.Id,
      Label_Class__c = 'test-label-class',
      Input_Class__c = 'test-input-class'
    );
    insert style;

    // Create action
    Actions__c action = new Actions__c(
      Question__c = parentQuestion.Id,
      Name = 'Test Action',
      Event_to_Emit__c = 'testEvent',
      IsActive__c = true,
      Order__c = 1
    );
    insert action;
  }

  @IsTest
  static void testGetQuestionsWithValidQBId() {
    // Get the test question
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];

    Test.startTest();
    FormWrapper result = QuestionBookService.getQuestions(qb.Id, '');
    Test.stopTest();

    // Assertions
    System.assertNotEquals(null, result, 'FormWrapper should not be null');
    System.assertEquals(qb.Id, result.id, 'Question Book ID should match');
    System.assertNotEquals(null, result.qbMap, 'qbMap should not be null');
    System.assertNotEquals(null, result.qMap, 'qMap should not be null');
    System.assertNotEquals(null, result.oMap, 'oMap should not be null');
    System.assertNotEquals(null, result.tMap, 'tMap should not be null');

    // Verify questions were retrieved
    System.assert(result.qMap.size() > 0, 'Should have retrieved questions');

    // Verify options were retrieved for dropdown question
    System.assert(
      result.oMap.size() > 0,
      'Should have retrieved questions with options'
    );
  }

  @IsTest
  static void testGetQuestionsWithInvalidQBId() {
    Test.startTest();
    try {
      FormWrapper result = QuestionBookService.getQuestions('invalidId', '');
      System.assert(false, 'Expected an exception for invalid QB ID');
    } catch (Exception e) {
      System.assert(true, 'Expected exception was thrown');
    }
    Test.stopTest();
  }

  @IsTest
  static void testGetQuestionsWithAllLanguages() {
    // Get the test question book
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];

    Test.startTest();
    FormWrapper result = QuestionBookService.getQuestions(qb.Id, 'All');
    Test.stopTest();

    // Assertions
    System.assertNotEquals(null, result, 'FormWrapper should not be null');
    System.assertNotEquals(null, result.tMap, 'tMap should not be null');
  }

  @IsTest
  static void testGetQuestionsWithNoTranslations() {
    // Get the test question book
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];

    Test.startTest();
    FormWrapper result = QuestionBookService.getQuestions(qb.Id, ''); // Language with no translations
    Test.stopTest();

    // Assertions
    System.assertNotEquals(null, result, 'FormWrapper should not be null');
    // tMap might be empty but should exist
    System.assertNotEquals(
      null,
      result.tMap,
      'tMap should exist even if empty'
    );
  }
}

// Helper class for creating test users