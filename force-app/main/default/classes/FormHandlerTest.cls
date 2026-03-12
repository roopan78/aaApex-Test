@isTest
public class FormHandlerTest {
    
    @TestSetup
    static void setupTestData() {
        // Create standalone QB for QuestionBook type test
        Question_Book__c standaloneQB = new Question_Book__c(
            Title__c = 'Standalone QB',
            Category__c = 'Booklet',
            Order__c = 1
        );
        insert standaloneQB;
        
        // Create Form with QuestionBook type
        Form__c qbForm = new Form__c(
            Name = 'QB Form',
            Type__c = 'QuestionBook',
            Question_Book__c = standaloneQB.Id
        );
        insert qbForm;
        
        // Create Form with SPA type
        Form__c spaForm = new Form__c(
            Name = 'SPA Form',
            Type__c = 'SPA',
            Question_Book__c = standaloneQB.Id
        );
        insert spaForm;
        
        // Create regular Form
        Form__c testForm = new Form__c(
            Name = 'Test Form',
            Type__c = 'Form',
            Anchor_Object__c = 'Account',
            Question_Book__c = standaloneQB.Id
        );
        insert testForm;
        
        // Create Booklet
        Question_Book__c testBooklet = new Question_Book__c(
            Title__c = 'Test Booklet',
            Form__c = testForm.Id,
            Category__c = 'Booklet',
            Order__c = 1
        );
        insert testBooklet;
        
        // Create Section with First Question
        Question_Book__c testSection = new Question_Book__c(
            Title__c = 'Test Section',
            Parent_Booklet_QB__c = testBooklet.Id,
            Category__c = 'Simple',
            Order__c = 1
        );
        insert testSection;
        
        // Create Questions
        Question__c bookQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Type__c = 'Book',
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId()
        );
        insert bookQuestion;
        
        Question__c radioQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Question_Parent__c = bookQuestion.Id,
            Type__c = 'Radio',
            Question_No__c = 2
        );
        insert radioQuestion;
        
        Question__c dropdownQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Question_Parent__c = bookQuestion.Id,
            Type__c = 'Dropdown',
            Question_No__c = 3
        );
        insert dropdownQuestion;
        
        Question__c checkboxQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Question_Parent__c = bookQuestion.Id,
            Type__c = 'Checkbox',
            Question_No__c = 4
        );
        insert checkboxQuestion;
        
        // Create nested questions for the radio question
        Question__c nestedQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Question_Parent__c = radioQuestion.Id,
            Type__c = 'Text',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            Question_No__c = 5
        );
        insert nestedQuestion;
        
        // Update section with first question
        testSection.First_Question__c = bookQuestion.Id;
        update testSection;
        
        // Create Question Options
        Option__c option1 = new Option__c(
            Question__c = radioQuestion.Id,
            Value__c = 'Option 1',
            Order__c = 1
        );
        insert option1;
        
        Actions__c act = new Actions__c(
        	Question_Book__c = testSection.Id
        );
        insert act;
        
        // Create Answer Book for exception path
        Answer_Book__c testAnswerBook = new Answer_Book__c(
            Question_Book__c = testBooklet.Id,
            Status__c = 'Pending'
        );
        insert testAnswerBook;
        
        // Create Answers
        Answer__c testAnswer = new Answer__c(
            Answer_Book__c = testAnswerBook.Id,
            Question_Text__c = 'Test Question',
            Question_Ref__c = bookQuestion.id 
        );
        insert testAnswer;
        
        // Create Actions
        Actions__c formAction = new Actions__c(
            Form__c = testForm.Id,
            IsActive__c = true,
            Order__c = 1
        );
        insert formAction;
        
        Actions__c qbAction = new Actions__c(
            Question_Book__c = testSection.Id,
            IsActive__c = true,
            Order__c = 1
        );
        insert qbAction;
        
        Actions__c questionAction = new Actions__c(
            Question__c = radioQuestion.Id,
            IsActive__c = true,
            Order__c = 1
        );
        insert questionAction;
        
        // Create Styles
        Style__c actionStyle = new Style__c(
            Action__c = qbAction.Id,
            Size__c = 12
        );
        insert actionStyle;
        
        Style__c questionStyle = new Style__c(
            Question__c = radioQuestion.Id,
            Size__c = 14
        );
        insert questionStyle;
        
        // Create Translations
        Translation__c translation = new Translation__c(
            Question_Book__c = testSection.Id,
            Language__c = 'en_US',
            Translated_Text__c = '{"key": "value"}'
        );
        insert translation;
        
        // Create Question Book
        Question_Book__c qb = new Question_Book__c(Category__c = 'Simple');
        insert qb;
        
        // Create parent question with nested child questions
        Question__c parentQuestion = new Question__c(
            Question_Book__c = qb.Id,
            Type__c = 'Book',
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId()
        );
        insert parentQuestion;

        // Create various question types to trigger different code paths
        Question__c radioQuestion1 = new Question__c(
            Question_Book__c = qb.Id,
            Question_Parent__c = parentQuestion.Id,
            Type__c = 'Radio',
            Question_No__c = 2
        );
        insert radioQuestion1;
        
        // Create options for question types that require them
        Option__c option = new Option__c(
            Question__c = radioQuestion1.Id,
            Value__c = 'Test Option',
            Order__c = 1
        );
        insert option;
        
        // Create translations for both language scenarios
        Translation__c translation1 = new Translation__c(
            Question_Book__c = qb.Id,
            Language__c = 'en_US',
            Translated_Text__c = 'Test Translation'
        );
        insert translation1;
    }
    
    @isTest
    static void testSetContextWithCreateAnswerBookFlag() {
        FormHandler handler = new FormHandler();
        handler.setContext('createAnswerBookFlag', true);
        System.assertEquals(true, handler.createAnswerBookFlag);
    }
    
    @isTest
    static void testSetContextWithRecordId() {
        FormHandler handler = new FormHandler();
        handler.setContext('c__record_id', '001000000000001');
        System.assert(handler.paramMap.containsKey('c__record_id'));
    }
    
    @isTest
    static void testReadRecordsWithQuestionBookType() {
        Question_Book__c qb = [SELECT Id FROM Question_Book__c WHERE Title__c = 'Standalone QB' LIMIT 1];
        
        Test.startTest();
        FormHandler handler = new FormHandler();
        String result = handler.readRecords(qb.Id, '');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testReadRecordsWithSPAType() {
        Form__c spaForm = [SELECT Id FROM Form__c WHERE Type__c = 'SPA' LIMIT 1];
        
        Test.startTest();
        FormHandler handler = new FormHandler();
        handler.setContext('c__record_id', '001000000000001');
        handler.setContext('createAnswerBookFlag', true);
        String result = handler.readRecords(spaForm.Id, '');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testReadRecordsWithFormType() {
        Form__c testForm = [SELECT Id FROM Form__c WHERE Type__c = 'Form' LIMIT 1];
        
        Test.startTest();
        FormHandler handler = new FormHandler();
        String result = handler.readRecords(testForm.Id, 'en_US');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('pages'));
    }
    
    @isTest
    static void testReadRecordsWithAllLanguages() {
        Form__c testForm = [SELECT Id FROM Form__c WHERE Type__c = 'Form' LIMIT 1];
        
        Test.startTest();
        FormHandler handler = new FormHandler();
        String result = handler.readRecords(testForm.Id, 'All');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void testGetRecords() {
        FormHandler handler = new FormHandler();
        String result = handler.getRecords();
        System.assert(result.contains('failure'));
    }
    
    @isTest
    static void testCreateRecords() {
        FormHandler handler = new FormHandler();
        String result = handler.createRecords('{}');
        System.assert(result.contains('failure'));
    }
    
    @isTest
    static void testUpdateRecords() {
        FormHandler handler = new FormHandler();
        String result = handler.updateRecords('{}');
        System.assert(result.contains('failure'));
    }
    
    @isTest
    static void testDeleteRecords() {
        FormHandler handler = new FormHandler();
        String result = handler.deleteRecords('{}');
        System.assert(result.contains('failure'));
    }
    
    @isTest
    static void testConstructors() {
        FormHandler handler1 = new FormHandler('003000000000001');
        FormHandler handler2 = new FormHandler();
        System.assertEquals('003000000000001', handler1.contactId);
        System.assertEquals('', handler2.contactId);
    }
}