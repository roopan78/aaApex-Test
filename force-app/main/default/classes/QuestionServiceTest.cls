/*
 * Test class for QuestionService.
 */
@isTest
public with sharing class QuestionServiceTest {
  @isTest
  static void testUpdateFieldMeta() {
    // Step 1: Setup Test Data
    // Create a Question Book record
    // Create a Question__c record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    Question__c question = new Question__c(
      Question_No__c = 1,
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id
    );
    insert question;

    // Create Field_Meta__c records
    Field_Meta__c fieldMeta1 = new Field_Meta__c(
      Unique_Identifier__c = 'mass',
      Question__c = question.Id
    );
    Field_Meta__c fieldMeta2 = new Field_Meta__c(
      Unique_Identifier__c = 'massii',
      Question__c = question.Id
    );
    insert new List<Field_Meta__c>{ fieldMeta1, fieldMeta2 };

    // Step 2: Call the method
    Test.startTest();
    QuestionService.updateFieldMeta(new Set<Id>{ question.Id });
    Test.stopTest();

    // Step 3: Verify Results
    Question__c updatedQuestion = [
      SELECT Id, Fields_Meta__c
      FROM Question__c
      WHERE Id = :question.Id
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      updatedQuestion.Fields_Meta__c,
      'Fields_Meta__c should be populated'
    );
    System.debug('Fields_Meta__c JSON: ' + updatedQuestion.Fields_Meta__c);
  }

  @isTest
  static void testUpdateQuestionMeta() {
    // Step 1: Setup Test Data
    // Create a Question_Book__c record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    // Create a Question__c record
    Question__c question = new Question__c(
      Question_No__c = 1,
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
        .get('CONDITIONAL')
        .getRecordTypeId(),
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id
    );
    insert question;

    // Step 2: Call the method with a valid qbReferenceId
    Test.startTest();
    Map<String, String> qbRefMap = new Map<String, String>{
      String.valueOf(question.Id) => String.valueOf(questionBook.Id)
    };
    QuestionService.updateQuestionMeta(
      new Set<String>{ String.valueOf(question.Id) },
      qbRefMap
    );
    Test.stopTest();

    // Step 3: Verify Results
    Question__c updatedQuestion = [
      SELECT Id, QB_Reference_Questions__c
      FROM Question__c
      WHERE Id = :question.Id
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      updatedQuestion.QB_Reference_Questions__c,
      'QB_Reference_Questions__c should be populated'
    );
    System.debug(
      'QB_Reference_Questions__c: ' + updatedQuestion.QB_Reference_Questions__c
    );
  }

  @isTest
  static void testUpdateFieldMeta_EmptyFields() {
    // Test when there are no Field_Meta__c records
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    Question__c question = new Question__c(
      Question_No__c = 1,
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id,
      QB_Reference_Questions__c = 'reference'
    );
    insert question;

    Test.startTest();
    QuestionService.updateFieldMeta(new Set<Id>{ question.Id });
    Test.stopTest();

    Question__c updatedQuestion = [
      SELECT Id, Fields_Meta__c
      FROM Question__c
      WHERE Id = :question.Id
      LIMIT 1
    ];
    System.assertEquals(
      null,
      updatedQuestion.Fields_Meta__c,
      'Fields_Meta__c should be an empty JSON array'
    );
  }

  @isTest
  static void testAfterInsert() {
    // Create a Question record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    Question__c question = new Question__c(
      Question_No__c = 1,
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id,
      QB_Reference_Questions__c = 'reference'
    );
    insert question;

    // Create a Field_Meta__c record
    Field_Meta__c fieldMeta = new Field_Meta__c(
      Unique_Identifier__c = 'mass',
      Question__c = question.Id,
      File_Type__c = '.csv;.jpeg;.pdf;.xlsx'
    );

    Test.startTest();
    insert fieldMeta;
    Test.stopTest();

    // Verify that the QuestionService method was called
    // Use appropriate assertions if you have a mock or log tracking in QuestionService
  }

  @isTest
  static void testAfterUpdate() {
    // Create a Question record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    Question__c question = new Question__c(
      Question_No__c = 1,
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id,
      QB_Reference_Questions__c = 'reference'
    );
    insert question;

    // Create and update a Field_Meta__c record
    Field_Meta__c fieldMeta = new Field_Meta__c(
      Unique_Identifier__c = 'mass',
      Question__c = question.Id
    );
    insert fieldMeta;

    Test.startTest();
    update fieldMeta;
    Test.stopTest();

    // Verify that the QuestionService method was called
    // Use appropriate assertions if you have a mock or log tracking in QuestionService
  }

  @isTest
  static void testAfterDelete() {
    // Create a Question record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Simple'
    );
    insert questionBook;

    Question__c question = new Question__c(
      Question_No__c = 1,
      Type__c = 'Radio',
      Unique_Identifier__c = 'Test',
      Question_Book__c = questionBook.Id,
      QB_Reference_Questions__c = 'reference'
    );
    insert question;

    // Create and delete a Field_Meta__c record
    Field_Meta__c fieldMeta = new Field_Meta__c(
      Unique_Identifier__c = 'mass',
      Question__c = question.Id
    );
    insert fieldMeta;

    Test.startTest();
    delete fieldMeta;
    Test.stopTest();
  }

  @isTest
  static void testUpdateStyle() {
      // Setup Test Data
      Question_Book__c questionBook = new Question_Book__c(
          Title__c = 'Test Question Book',
          Unique_Identifier__c = '12345',
          Category__c = 'Simple'
      );
      insert questionBook;

      Question__c question = new Question__c(
          Question_No__c = 1,
          Type__c = 'Radio',
          Unique_Identifier__c = 'Test',
          Question_Book__c = questionBook.Id
      );
      insert question;

      // Create Style__c records
      Style__c style1 = new Style__c(
          Question__c = question.Id,
          Name = 'Test Style 1',
          showLabel__c = true,
          external_id__c = '1233'
      );
      insert style1;

      // Call the method
      Test.startTest();
      QuestionService.updateParentObject(new Set<Id>{question.Id},'RNXT__Style__c',
      'RNXT__Question__c',
      'RNXT__Style__c',
      'RNXT__Question__c');
      Test.stopTest();

      // Verify Results
      Question__c updatedQuestion = [
          SELECT Id, Style__c 
          FROM Question__c 
          WHERE Id = :question.Id 
          LIMIT 1
      ];
      System.assertNotEquals(null, updatedQuestion.Style__c, 'Style__c should be populated');
  }

    // Test method for updateStyle with null/empty parameters and no records
  @isTest
  static void testUpdateStyle_EdgeCases() {
      // Test null parameter
      Test.startTest();
      QuestionService.updateParentObject(null,'RNXT__Style__c',
      'RNXT__Question__c',
      'RNXT__Style__c',
      'RNXT__Question__c');
      QuestionService.updateParentObject(new Set<Id>(),'RNXT__Style__c',
      'RNXT__Question__c',
      'RNXT__Style__c',
      'RNXT__Question__c');
      
      // Test with question that has no Style records
      Question_Book__c questionBook = new Question_Book__c(
          Title__c = 'Test Question Book',
          Unique_Identifier__c = '12345',
          Category__c = 'Simple'
      );
      insert questionBook;

      Question__c question = new Question__c(
          Question_No__c = 1,
          Type__c = 'Radio',
          Unique_Identifier__c = 'Test',
          Question_Book__c = questionBook.Id
      );
      insert question;

      QuestionService.updateParentObject(new Set<Id>{question.Id},'RNXT__Style__c',
      'RNXT__Question__c',
      'RNXT__Style__c',
      'RNXT__Question__c');
      Test.stopTest();

      // Verify no exceptions thrown and Style__c remains null
      Question__c updatedQuestion = [
          SELECT Id, Style__c 
          FROM Question__c 
          WHERE Id = :question.Id 
          LIMIT 1
      ];
      System.assertEquals(null, updatedQuestion.Style__c, 'Style__c should be null when no Style records exist');
  }
}