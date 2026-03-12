/*
 * Test class for BookletHandler.
 */
@isTest
public class BookletHandlerTest {
    @isTest static void testConstructorWithParam() {
        BookletHandler handler = new BookletHandler('12345');
    }
    @isTest static void testSetContext() {
        BookletHandler handler = new BookletHandler();
        handler.setContext('contactId', '67890');
    }
    @isTest static void testGetRecords() {
        BookletHandler handler = new BookletHandler();
        String response = handler.getRecords();
        System.assertEquals('{"status":"failure","message":"List operation is not supported"}', 
            response, 'getRecords should return the failure message');
    }

    // Test method for createRecords method
    @isTest static void testCreateRecords() {
        BookletHandler handler = new BookletHandler();
        String response = handler.createRecords('{"name":"Test"}');
        System.assertEquals('{"status":"failure","message":"Create operation is not supported"}', 
            response, 'createRecords should return the failure message');
    }

    // Test method for updateRecords method
    @isTest static void testUpdateRecords() {
        BookletHandler handler = new BookletHandler();
        String response = handler.updateRecords('{"id":"12345"}');
        System.assertEquals('{"status":"failure","message":"Update operation is not supported"}', 
            response, 'updateRecords should return the failure message');
    }

    // Test method for deleteRecords method
    @isTest static void testDeleteRecords() {
        BookletHandler handler = new BookletHandler();
        String response = handler.deleteRecords('{"id":"12345"}');
        System.assertEquals('{"status":"failure","message":"Delete operation is not supported"}', 
            response, 'deleteRecords should return the failure message');
    }
    
    @TestSetup
    static void setupTestData() {
        // Create Question_Book records
        Question_Book__c parentBook = new Question_Book__c(
            Title__c = 'Test Question Book123',
            Category__c = 'Simple'
        );
        insert parentBook;

        Question_Book__c childBook = new Question_Book__c(
            Title__c = 'Test Question Bookrrr',
            Category__c = 'Simple',
            Parent_Booklet_QB__c = parentBook.Id
        );
        insert childBook;

        // Create Questions
        Question__c question1 = new Question__c(
            Question_No__c = 1, 
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            Type__c = 'Book', 
            Question_Book__c = childBook.Id
        );
        insert question1; 
       
        Question__c question2 = new Question__c(
            Question_No__c = 2, 
            Type__c = 'Radio', 
            Question_Book__c = childBook.Id,
            Question_Parent__c = question1.Id
        );
        insert question2;

        Question__c question3 = new Question__c(
            Question_No__c = 3, 
            Type__c = 'Radio', 
            Question_Book__c = childBook.Id,
            Question_Parent__c = question1.Id
        );
        insert question3;
        // update
        Question_Book__c qb = [SELECT Id FROM Question_Book__c WHERE Title__c = 'Test Question Bookrrr' Limit 1];
        qb.First_Question__c = question1.Id;
        update qb;

        // Create Question Options
        Option__c questionOption = new Option__c( 
            Question__c = question2.Id, 
            Value__c = 'value', 
            Order__c = 3
        );
        insert questionOption;

        // Create Answer Book
        Answer_Book__c answerBook1 = new Answer_Book__c(
            Question_Book__c = parentBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook1;
        Answer_Book__c answerBook2 = new Answer_Book__c(
            Question_Book__c = childBook.Id,
            Status__c = 'Completed',
            Answer_Long__c = 'answers'
        );
        insert answerBook2;

        // Create Translations
        Translation__c translation1 = new Translation__c(
            Language__c = 'en_US',
            Translated_Text__c = '{"key1": "value1", "key2": "value2"}',
            Question_Book__c = childBook.Id
        );
        insert translation1;

        Translation__c translation2 = new Translation__c(
            Unique_Identifier__c = 'UID2',
            Language__c = 'fr_FR',
            Translated_Text__c = '{"key1": "value1", "key2": "value2"}' ,
            Question_Book__c = childBook.Id
        );
        insert translation2;
    }

    @IsTest
    static void testReadRecordsWithParentBookletId() {
        // Test with Parent Booklet ID
        String inputJSON = [SELECT Id FROM Question_Book__c WHERE Title__c = 'Test Question Book123' LIMIT 1].Id;
        String languageCode = 'en';
        Test.startTest();
        BookletHandler bklt = new BookletHandler ();
        String result = bklt.readRecords(inputJSON, languageCode);
        Test.stopTest();

        System.assertNotEquals(result, null, 'The result JSON should not be null.');
        System.assert(result.contains('translationMap'), 'The result JSON should include translationMap.');
    }
    
    @IsTest
    static void testReadRecordsWithChildBookletId() {
        // Test with Child Booklet ID
        String inputJSON = [SELECT Id FROM Question_Book__c WHERE Title__c = 'Test Question Bookrrr' LIMIT 1].Id;
        String languageCode = 'en';
        Test.startTest();
        BookletHandler bklt = new BookletHandler ();
        String result = bklt.readRecords(inputJSON, languageCode);
        Test.stopTest();

        System.assertNotEquals(result, null, 'The result JSON should not be null.');
        System.assert(result.contains('translationMap'), 'The result JSON should include translationMap.');
    }

    @IsTest
    static void testReadRecordsWithAnswerBook1Id() {
        // Test with Answer Book ID
        String inputJSON = [SELECT Id FROM Answer_Book__c LIMIT 1].Id;
        String languageCode = 'en';
        Test.startTest();
         BookletHandler bklt = new BookletHandler ();
        String result = bklt.readRecords(inputJSON, languageCode);
        Test.stopTest();

        System.assertNotEquals(result, null, 'The result JSON should not be null.');
        System.assert(result.contains('answerbook'), 'The result JSON should include answerbook.');
    }
    
    @IsTest
    static void testReadRecordsWithAnswerBook2Id() {
        
        Answer_Book__c ab = [SELECT Id FROM Answer_Book__c LIMIT 1];
        String inputJSON = ab.Id;
        String languageCode = 'en';
        
        Test.startTest();
        BookletHandler bklt = new BookletHandler ();
        String result = bklt.readRecords(inputJSON, languageCode);
        Test.stopTest();

        System.assertNotEquals(result, null, 'The result JSON should not be null.');
        System.assert(result.contains('answerbook'), 'The result JSON should include answerbook.');
    }

    @IsTest
    static void testReadRecordsWithNoLanguageSpecified() {
        // Test with languageCode as 'All'
        Answer_Book__c ab = [SELECT Id, Name, Question_Book__r.Name FROM Answer_Book__c WHERE Status__c = 'Completed' LIMIT 1];
        String inputJSON = ab.Id;
        String languageCode = 'en';
        Test.startTest();
        BookletHandler bklt = new BookletHandler ();
        String result = bklt.readRecords(inputJSON, languageCode);
        Test.stopTest();

        System.assert(result.contains('translationMap'), 'The result JSON should include translationMap.');
    }

    @IsTest
    static void testSecurityAndAccessControl() {
        // Test for field-level and object-level security
        Question_Book__c questionBook = [SELECT Id FROM Question_Book__c WHERE Title__c = 'Test Question Book123' LIMIT 1];
        String inputJSON = questionBook.Id;
        String languageCode = 'en';
        Test.startTest();
        System.runAs(new User(Id = UserInfo.getUserId())) {
            BookletHandler bklt = new BookletHandler ();
            String result = bklt.readRecords(inputJSON, languageCode);
            System.assert(result.contains('questionbook'), 'The result JSON should include questionbook.');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testTranslationWrapper() {
        // Step 1: Create test data
        Translation__c translationWithJson = new Translation__c(
            Language__c = 'English',
            Translated_Text__c = '{"key1": "value1", "key2": "value2"}'
        );

        Translation__c translationWithoutJson = new Translation__c(
            Language__c = 'French',
            Translated_Text__c = null
        );

        // Step 2: Test TranslationWrapper with JSON data
        TranslationWrapper wrapperWithJson = new TranslationWrapper(translationWithJson);

        // Assert the fields are correctly populated
        System.assertEquals('English', wrapperWithJson.language);
        //System.assertNotNull(wrapperWithJson.translatedText);
        System.assertEquals('value1', wrapperWithJson.translatedText.get('key1'));
        System.assertEquals('value2', wrapperWithJson.translatedText.get('key2'));

        // Step 3: Test TranslationWrapper with null JSON
        TranslationWrapper wrapperWithoutJson = new TranslationWrapper(translationWithoutJson);

        // Assert the fields are correctly populated
        System.assertEquals('French', wrapperWithoutJson.language);
        //System.assertNotNull(wrapperWithoutJson.translatedText);
        System.assertEquals(0, wrapperWithoutJson.translatedText.size());
    }
}