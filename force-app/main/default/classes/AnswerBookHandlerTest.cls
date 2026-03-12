/* 
 * Test class for AnswerBookHandler
 */
@isTest
public class AnswerBookHandlerTest {

    @testSetup
    static void setupTestData() {
        // Create test data for Answer_Book__c
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'okk',
            Question_Book__c = questionBook.Id,
            Reference_Field__c = 'Account.Description'
        );
        insert question1;

        Answer_Book__c answerBook = new Answer_Book__c(
            //Name = 'Test Answer Book',
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;

        List<Answer__c> answers = new List<Answer__c>();
        for (Integer i = 0; i < 3; i++) {
            answers.add(new Answer__c(
                Answer_Book__c = answerBook.Id,
                Question_Ref__c = question1.Id,
                Question_Text__c = 'Test Question ' + i,
                Answer_Long__c = 'Test Answer ' + i
            ));
        }
        insert answers;
    }
    
    @isTest
    static void testErrorWrapper() {
        // Create an instance of ErrorWrapper
        ErrorWrapper errorWrapper = new ErrorWrapper();

        // Assign values
        errorWrapper.errorCode = 'ERR001';
        errorWrapper.errorMsg = 'An unexpected error occurred';
        errorWrapper.errorDetails = 'Details of the error';

        // Assert values
        System.assertEquals('ERR001', errorWrapper.errorCode, 'Error code should match');
        System.assertEquals('An unexpected error occurred', errorWrapper.errorMsg, 'Error message should match');
        System.assertEquals('Details of the error', errorWrapper.errorDetails, 'Error details should match');
    }
    
    @isTest
    static void testGetRecords() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call getRecords method
        String response = handler.getRecords();

        // Assert failure response
        System.assert(response.contains('failure'), 'Expected failure status in response');
        System.assert(response.contains('List operation is not supported'), 'Expected specific failure message in response');
    }

    @isTest
    static void testReadRecords() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call readRecords method
        String response = handler.readRecords();

        // Assert failure response
        System.assert(response.contains('failure'), 'Expected failure status in response');
        System.assert(response.contains('Read operation is not supported'), 'Expected specific failure message in response');
    }

    @isTest
    static void testUpdateRecords() {
        // Get the test Answer_Book__c record
        Answer_Book__c answerBook = [SELECT Id FROM Answer_Book__c LIMIT 1];

        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call updateRecords method
        String response = handler.updateRecords(answerBook.Id);

        // Assert response
       // System.assert(response.contains('success'), 'Expected success status in response');

        // Verify the status field is updated
        Answer_Book__c updatedAnswerBook = [SELECT Status__c FROM Answer_Book__c WHERE Id = :answerBook.Id];
      //  System.assertEquals('Completed', updatedAnswerBook.Status__c, 'Status should be updated to Completed');
    }

    @isTest
    static void testDeleteRecords() {
        // Get the test Answer_Book__c record
        Answer_Book__c answerBook = [SELECT Id FROM Answer_Book__c LIMIT 1];

        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call deleteRecords method
        String response = handler.deleteRecords(answerBook.Id);

        // Assert response
        System.assert(response.contains('success'), 'Expected success status in response');

        // Verify the related answers are deleted
        List<Answer__c> relatedAnswers = [SELECT Id FROM Answer__c WHERE Answer_Book__c = :answerBook.Id];
        System.assertEquals(0, relatedAnswers.size(), 'All related answers should be deleted');
    }

    @isTest
    static void testConstructorWithParameter() {
        String contactId = '003XXXXXXXXXXXX';
        AnswerBookHandler handler = new AnswerBookHandler(contactId);
        Test.startTest();
        handler.setContext('contactId', contactId);
        Test.stopTest();
        System.assertEquals(contactId, handler.contactId, 'Contact ID should be set correctly');
    }

    @isTest
    static void testErrorHandlingInUpdateRecords() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Pass an invalid ID to simulate an error
        String invalidId = 'Invalid_Id';
        String response = handler.updateRecords(invalidId);

        // Assert failure response
        System.assert(response.contains('failure'), 'Expected failure status in response');
    }

    @isTest
    static void testErrorHandlingInDeleteRecords() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Pass an invalid ID to simulate an error
        String invalidId = 'Invalid_Id';
        String response = handler.deleteRecords(invalidId);

        // Assert error response
        System.assert(response.contains('error'), 'Expected error status in response');
    }
    
    @isTest
    static void testCreateRecords() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call createRecords method
        String response = handler.createRecords('{}');

        // Assert failure response
        System.assert(response.contains('failure'), 'Expected failure status in response');
        System.assert(response.contains('Create operation is not supported'), 'Expected specific failure message in response');
    }

    @isTest
    static void testReadRecordsWithLanguageCode() {
        // Create instance of the handler
        AnswerBookHandler handler = new AnswerBookHandler();

        // Call readRecords with language code method
        String response = handler.readRecords('{}', 'en');

        // Assert failure response
        System.assert(response.contains('failure'), 'Expected failure status in response');
        System.assert(response.contains('Read operation is not supported'), 'Expected specific failure message in response');
    }
    
    @isTest
    static void testAnswerBookHandlerWrapper() {
        // Retrieve a test Answer_Book__c record
        Answer_Book__c answerBook = [SELECT Id, Name, Status__c, Question_Book__c FROM Answer_Book__c LIMIT 1];

        // Create an instance of the wrapper
        AnswerBookHandlerWrapper wrapper = new AnswerBookHandlerWrapper(answerBook);

        // Assert wrapper fields
        System.assertEquals(answerBook.Id, wrapper.id, 'Wrapper ID should match Answer_Book__c ID');
        System.assertEquals(answerBook.Name, wrapper.name, 'Wrapper name should match Answer_Book__c name');
        System.assertEquals(answerBook.Status__c, wrapper.status, 'Wrapper status should match Answer_Book__c status');
        System.assertEquals(answerBook.Question_Book__c, wrapper.questionBookId, 'Wrapper questionBookId should match Answer_Book__c Question_Book__c');
    }
    
    @isTest
    static void testAnswerWrapperConversion() {
        // Retrieve a test Answer__c record
        Answer__c answer = [SELECT Id, Number__c,recordId__c , Answer_Book__c, Question_Ref__c, Question_Type__c, 
                             Question_Rich_Text__c, Answer_Long__c, Question_Group_Text__c
                            FROM Answer__c LIMIT 1];

        // Convert Answer__c record to AnswerWrapper
        AnswerWrapper wrapper = AnswerWrapper.convert(answer);

        // Assert wrapper fields
        System.assertEquals(answer.Id, wrapper.ansId, 'Wrapper ansId should match Answer__c Id');
        System.assertEquals((Integer)answer.Number__c, wrapper.ansNumber, 'Wrapper ansNumber should match Answer__c Number__c');
        System.assertEquals(answer.Answer_Book__c, wrapper.abId, 'Wrapper abId should match Answer__c Answer_Book__c');
        System.assertEquals(answer.Question_Ref__c, wrapper.quesId, 'Wrapper quesId should match Answer__c Question_Ref__c');
        System.assertEquals(answer.Question_Type__c, wrapper.qTyp, 'Wrapper qTyp should match Answer__c Question_Type__c');
        System.assertEquals(answer.Question_Group_Text__c, wrapper.groupText, 'Wrapper groupText should match Answer__c Question_Group_Text__c');

        // Validate unescapeHtml4 logic
        System.assertEquals(answer.Question_Rich_Text__c != null ? answer.Question_Rich_Text__c.unescapeHtml4() : '', wrapper.quesValue, 'Wrapper quesValue should match unescaped Question_Rich_Text__c');
        System.assertEquals(answer.Answer_Long__c != null ? answer.Answer_Long__c.unescapeHtml4() : '', wrapper.ansValue, 'Wrapper ansValue should match unescaped Answer_Long__c');
    }
}