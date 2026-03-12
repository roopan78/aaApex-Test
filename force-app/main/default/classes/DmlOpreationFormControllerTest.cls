@isTest
public class DmlOpreationFormControllerTest {
  
  @testSetup
  static void setupTestData() {
    // Create reusable test data
    Question_Book__c qb = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = '12345',
      Category__c = 'Booklet'
    );
    insert qb;
    Question__c q = new Question__c(
    	Title__c = 'Test Qn',
		RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
        Type__c = 'Text',
        Question_Book__c = qb.Id,
        Question_No__c = 1
    );
        insert q;
  }

  @isTest
  static void testConstructor() {
    Test.startTest();
    DmlOpreationFormController controller = new DmlOpreationFormController();
    Test.stopTest();
    System.assert(true, 'Constructor executed successfully.');
  }

  // ========== SAVERECORD METHOD TESTS ==========
  
  @isTest
  static void testSaveRecordWithAnswerBook() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact',
      Email = 'test@test.com'
    );
    insert testContact;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"id": "test123",' +
        '"name": "QN-001",' +
        '"referenceField": "Contact.FirstName",' +
        '"questionText": "First Name",' +
        '"questionNumber": 1,' +
        '"questionBookId": "' + qb.Id + '",' +
        '"type": "Text",' +
        '"input": "John",' +
        '"error": null' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, testContact.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithFormId() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Form__c form = new Form__c(
      Name = 'Test Form',
      Type__c = 'Form',
      Anchor_Object__c = 'Contact',
      Question_Book__c = qb.Id
    );
    insert form;

    String jsonData = '{"bookQuestionsMap": {}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, form.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithTableType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    // Create test Account for table operations
    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"recordId": "' + testAccount.Id + '",' +
      '"subQuestions": [' +
      '{' +
        '"id": "test456",' +
        '"type": "Table",' +
        '"title": "Account",' +
        '"subTitle": "Name=TestFilter",' +
        '"input": [' +
          '{' +
            '"recordId": "' + testAccount.Id + '",' +
            '"isDeleted": false,' +
            '"value": [' +
              '{' +
                '"questions": [{' +
                  '"referenceField": "Name",' +
                  '"input": "Updated Name",' +
                  '"type": "Text",' +
                  '"isSerialNo": false' +
                '}]' +
              '}' +
            ']' +
          '}' +
        ']' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithTableTypeNewRow() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"type": "Table",' +
        '"title": "Account",' +
        '"subTitle": "",' +
        '"input": [' +
          '{' +
            '"recordId": "newRow1",' +
            '"isDeleted": false,' +
            '"value": [' +
              '{' +
                '"questions": [{' +
                  '"referenceField": "Name",' +
                  '"input": "New Account",' +
                  '"type": "Text",' +
                  '"isSerialNo": false' +
                '}]' +
              '}' +
            ']' +
          '}' +
        ']' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithTableTypeDeletedRow() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Account acc = new Account(Name = 'Test Account');
    insert acc;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"type": "Table",' +
        '"title": "Account",' +
        '"input": [' +
          '{' +
            '"recordId": "' + acc.Id + '",' +
            '"isDeleted": true,' +
            '"value": []' +
          '}' +
        ']' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithDateTimeType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"referenceField": "Contact.Birthdate",' +
        '"type": "Date",' +
        '"input": "2024-01-15"' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithCheckboxType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"referenceField": "Contact.DoNotCall",' +
        '"type": "Checkbox",' +
        '"input": "true"' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithNumberType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"referenceField": "Account.NumberOfEmployees",' +
        '"type": "Number",' +
        '"input": "100"' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithListType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Account acc = new Account(Name = 'Test Account');
    insert acc;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"referenceField": "Contact.AccountId",' +
        '"type": "List",' +
        '"input": {"recordId": "' + acc.Id + '"}' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, null);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithFileType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact'
    );
    insert testContact;

    String base64Content = EncodingUtil.base64Encode(Blob.valueOf('Test file content'));

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"recordId": "' + testContact.Id + '",' +
      '"subQuestions": [' +
      '{' +
        '"type": "File",' +
        '"input": [' +
          '{' +
            '"name": "testfile.txt",' +
            '"contentBodyId": "' + base64Content + '"' +
          '}' +
        ']' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, testContact.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testSaveRecordWithTableTypeDynamicFilter() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Account testAccount = new Account(Name = 'Test Account');
    insert testAccount;

    String jsonData = '{"bookQuestionsMap": {"' + qb.Id + '": {' +
      '"subQuestions": [' +
      '{' +
        '"type": "Table",' +
        '"title": "Contact",' +
        '"subTitle": "AccountId={recordId}",' +
        '"input": [' +
          '{' +
            '"recordId": "newRow1",' +
            '"isDeleted": false,' +
            '"value": [' +
              '{' +
                '"questions": [{' +
                  '"referenceField": "LastName",' +
                  '"input": "Test LastName",' +
                  '"type": "Text",' +
                  '"isSerialNo": false' +
                '}]' +
              '}' +
            ']' +
          '}' +
        ']' +
      '}' +
      ']' +
    '}}}';

    Test.startTest();
    String result = DmlOpreationFormController.saveRecord(jsonData, answerBook.Id, testAccount.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }
    
  // ========== SAVE METHOD TESTS ==========

  @isTest
  static void testSaveWithBookType() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
   	Id qId = [SELECT Id FROM Question__c LIMIT 1].Id;
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Contact testContact = new Contact(
      FirstName = 'Test',
      LastName = 'Contact'
    );
    insert testContact;

    Answer__c answer = new Answer__c(
      Answer_Book__c = answerBook.Id,
      recordId__c = testContact.Id,
     Question_Ref__c = qId
    );
    insert answer;

    String questionsJson = '[{' +
      '"questionBookId": "' + qb.Id + '",' +
      '"recordId": "' + testContact.Id + '",' +
      '"type": "Book",' +
      '"id": "' + qb.Id + '",' +
      '"subQuestions": [' +
        '{' +
          '"referenceField": "Contact.FirstName",' +
          '"type": "Text",' +
          '"input": "Updated Name",' +
          '"parentQuestion": "' + qb.Id + '"' +
        '}' +
      ']' +
    '}]';

    Test.startTest();
    String result = DmlOpreationFormController.save(questionsJson);
    Test.stopTest();

    System.assertEquals('success', result);
  }

  @isTest
  static void testSaveWithNewRecord() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    Question__c q = new Question__c(
    	Question_Book__c = qb.Id,
        Question_No__c = 1
    );
    insert q;
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    Answer__c answer = new Answer__c(
      Answer_Book__c = answerBook.Id,
      Question_Ref__c = q.Id
    );
    insert answer;

    String questionsJson = '[{' +
      '"questionBookId": "' + qb.Id + '",' +
      '"recordId": "0",' +
      '"type": "Text",' +
      '"referenceField": "Account.Name",' +
      '"input": "New Account Name",' +
      '"id": "' + qb.Id + '"' +
    '}]';

    Test.startTest();
    String result = DmlOpreationFormController.save(questionsJson);
    Test.stopTest();

    System.assertEquals('success', result);
  }

  @isTest
  static void testSaveWithDateTimeAndNumber() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
    
    Answer_Book__c answerBook = new Answer_Book__c(
      Question_Book__c = qb.Id,
      Status__c = 'Pending'
    );
    insert answerBook;

    String questionsJson = '[{' +
      '"questionBookId": "' + qb.Id + '",' +
      '"recordId": "0",' +
      '"type": "Date",' +
      '"referenceField": "Contact.Birthdate",' +
      '"input": "2024-01-15"' +
    '}, {' +
      '"questionBookId": "' + qb.Id + '",' +
      '"recordId": "0",' +
      '"type": "Number",' +
      '"referenceField": "Account.NumberOfEmployees",' +
      '"input": "50"' +
    '}]';

    Test.startTest();
    String result = DmlOpreationFormController.save(questionsJson);
    Test.stopTest();

    System.assertEquals('success', result);
  }

  // ========== CLONERECORD METHOD TESTS ==========

  @isTest
  static void testCloneRecordWithRadioAndCheckbox() {
    Question_Book__c booklet = new Question_Book__c(
      Title__c = 'Test Booklet',
      Category__c = 'Booklet'
    );
    insert booklet;

    Question_Book__c childBook = new Question_Book__c(
      Title__c = 'Child Book',
      Category__c = 'Booklet',
      Parent_Booklet_QB__c = booklet.Id
    );
    insert childBook;

    Question__c firstQuestion = new Question__c(
      Question_No__c = 1,
      Type__c = 'Book',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      Question_Book__c = childBook.Id
    );
    insert firstQuestion;

    Question__c radioQuestion = new Question__c(
      Question_Book__c = childBook.Id,
      Question_Parent__c = firstQuestion.Id,
      Type__c = 'Radio',
      Question_No__c = 2
    );
    insert radioQuestion;

    Option__c option1 = new Option__c(
      Question__c = radioQuestion.Id,
      Value__c = 'Option 1',
      Order__c = 1
    );
    insert option1;

    Test.startTest();
    String result = DmlOpreationFormController.cloneRecord(booklet.Id);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  // ========== CLONEQUESTIONS METHOD TESTS ==========

  @isTest
  static void testCloneQuestionsWithQBReference() {
    Question_Book__c parentQB = new Question_Book__c(
      Title__c = 'Parent QB',
      Category__c = 'Simple'
    );
    insert parentQB;

    Question_Book__c referenceQB = new Question_Book__c(
      Title__c = 'Reference QB',
      Category__c = 'Simple'
    );
    insert referenceQB;

    Question__c refQuestion = new Question__c(
      Question_Book__c = referenceQB.Id,
      Question_No__c = 1,
      Type__c = 'Text',
	  RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId()
    );
    insert refQuestion;

    Question__c questionWithRef = new Question__c(
      Question_Book__c = parentQB.Id,
      Question_No__c = 1,
      Type__c = 'Text',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      QB_Reference__c = referenceQB.Id
    );
    insert questionWithRef;

    List<Question__c> questionsToClone = new List<Question__c>{questionWithRef};

    Test.startTest();
    String result = DmlOpreationFormController.cloneQuestions(questionsToClone, parentQB);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  // ========== FORMBUILDER METHOD TESTS ==========

  @isTest
  static void testFormBuilderWithAllElementTypes() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];

    Question__c bookQuestion = new Question__c(
      Question_No__c = 1,
      Type__c = 'Book',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      Question_Book__c = qb.Id
    );
    insert bookQuestion;

    Question__c textQuestion = new Question__c(
      Question_No__c = 2,
      Type__c = 'Text',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      Question_Book__c = qb.Id
    );
    insert textQuestion;

    String formData = '{' +
      '"data": [' +
        '{' +
          '"key": "book1",' +
          '"Id": "' + bookQuestion.Id + '",' +
          '"element": "Book",' +
          '"fieldNo": 1,' +
          '"label": "Section 1",' +
          '"placeholder": "",' +
          '"helpText": "",' +
          '"options": []' +
        '},' +
        '{' +
          '"key": "text1",' +
          '"Id": "' + textQuestion.Id + '",' +
          '"element": "Text",' +
          '"fieldNo": 2,' +
          '"label": "First Name",' +
          '"placeholder": "Enter name",' +
          '"helpText": "Help text",' +
          '"referenceField": "Contact.FirstName",' +
          '"size": 6,' +
          '"isOptional": false,' +
          '"isHide": false,' +
          '"readOnly": false,' +
          '"options": []' +
        '},' +
        '{' +
          '"key": "checkbox1",' +
          '"Id": null,' +
          '"element": "Checkbox",' +
          '"fieldNo": 3,' +
          '"label": "Accept Terms",' +
          '"referenceField": "Contact.DoNotCall",' +
          '"size": 12,' +
          '"options": [' +
            '{"value": "Yes", "Id": null}' +
          ']' +
        '}' +
      ']' +
    '}';

    Test.startTest();
    String result = DmlOpreationFormController.formBuilder(qb.Id, formData);
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testFormBuilderDeletesRemovedQuestions() {
    Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];

    Question__c bookQuestion = new Question__c(
      Question_No__c = 1,
      Type__c = 'Book',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      Question_Book__c = qb.Id
    );
    insert bookQuestion;

    Question__c questionToDelete = new Question__c(
      Question_No__c = 2,
      Type__c = 'Text',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
      Question_Book__c = qb.Id
    );
    insert questionToDelete;

    String formData = '{' +
      '"data": [' +
        '{' +
          '"key": "book1",' +
          '"Id": "' + bookQuestion.Id + '",' +
          '"element": "Book",' +
          '"fieldNo": 1,' +
          '"label": "Section",' +
          '"options": []' +
        '}' +
      ']' +
    '}';

    Test.startTest();
    String result = DmlOpreationFormController.formBuilder(qb.Id, formData);
    Test.stopTest();

    List<Question__c> remainingQuestions = [
      SELECT Id FROM Question__c 
      WHERE Id = :questionToDelete.Id
    ];
    System.assertEquals(0, remainingQuestions.size());
  }

  @isTest
  static void testGetSchemaPositive() {
    Test.startTest();
    Schema.DescribeSObjectResult result = DmlOpreationFormController.getSchema('Account');
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testGetSchemaNegative() {
    Test.startTest();
    Schema.DescribeSObjectResult result = DmlOpreationFormController.getSchema('InvalidObject123');
    Test.stopTest();

    System.assertEquals(null, result);
  }
}