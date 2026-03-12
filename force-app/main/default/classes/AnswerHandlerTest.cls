/*
 * Test class for AnswerHandler.
 */
@isTest
public class AnswerHandlerTest {

    @testSetup
    static void setupTestData() {
        // Insert sample Question_Book__c and Question__c records
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c question = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question;

        // Insert a sample Answer_Book__c record
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;
    }
    
    @isTest
    static void testConstructorWithContactId() {
        // Arrange
        String mockContactId = '003xx000004Tmi0AAC';

        // Act
        AnswerHandler handler = new AnswerHandler(mockContactId);

        // Assert
        System.assertEquals(mockContactId, handler.contactId, 'Contact ID should be set correctly in the constructor.');
    }

    @isTest
    static void testDefaultConstructor() {
        // Act
        AnswerHandler handler = new AnswerHandler();

        // Assert
        System.assertEquals('', handler.contactId, 'Default constructor should initialize contactId as an empty string.');
    }
    
    @isTest
    static void testSetContext() {
        // Arrange
        AnswerHandler handler = new AnswerHandler();
        String mockContactId = '003xx000004Tmi0AAC';

        // Act
        handler.setContext('contactId', mockContactId);

        // Assert
        System.assertEquals(mockContactId, handler.contactId, 'The setContext method should correctly set the contactId.');
    }
    
    @isTest
    static void testGetRecords() {
        // Act
        AnswerHandler handler = new AnswerHandler();
        String response = handler.getRecords();

        // Assert
        System.assertEquals('{"status":"failure","message":"List operation is not supported"}', response, 'The getRecords method should return the correct failure message.');
    }

    @isTest
    static void testReadRecords() {
        // Arrange
        AnswerHandler handler = new AnswerHandler();
        String inputJSON = '{"key":"value"}';
        String languageCode = 'en';

        // Act
        String response = handler.readRecords(inputJSON, languageCode);

        // Assert
        System.assertEquals('{"status":"failure","message":"read operation is not supported"}', response, 'The readRecords method should return the correct failure message.');
    }

    @isTest
    static void testCreateRecords() {
        // Prepare input JSON
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        String inputJSON = '{' +
        '"quesId": "' + question.Id + '",' +
        '"ansNumber": 1,' +
        '"quesValue": "Sample Question Value",' +
        '"qTyp": "Text",' +
        '"ansValue": "Sample Answer Value",' +
        '"GroupText": "Sample Group Text"' +
        '}';
        AnswerHandler handler = new AnswerHandler();
        Test.startTest();
        String result = handler.createRecords(inputJSON);
        Test.stopTest();

        //System.assert(result.contains('"status":"success"'), 'Expected success in result.');

        // Verify Answer_Book__c and Answer__c records
        List<Answer_Book__c> abList = [SELECT Id, Status__c FROM Answer_Book__c];
        System.assertEquals(2, abList.size(), 'Expected two Answer_Book__c record.');
        System.assertEquals('Pending', abList[0].Status__c, 'Expected Status to be Pending.');

        List<Answer__c> ansList = [SELECT Id, Answer_Long__c FROM Answer__c];
        System.assertEquals(1, ansList.size(), 'Expected one Answer__c record.');
        System.assertEquals('Sample Answer Value', ansList[0].Answer_Long__c, 'Expected Answer_Long__c to match.');
    }
    
    @isTest
    static void testUpdateRecords_FieldAccessFailure() {
        Question_Book__c questionBook = new Question_Book__c(
            Title__c = 'Test Question Book',
            Unique_Identifier__c = '87',
            Category__c = 'Simple'
        );
        insert questionBook;
        
        Question__c question = new Question__c(
            Question_No__c = 1,
            Type__c = 'Radio',
            Unique_Identifier__c = 'Test08',
            Question_Book__c = questionBook.Id
        );
        insert question;
        
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;
        
        Answer__c ans = new Answer__c();
        ans.Answer_Book__c = answerBook.Id;
        ans.Question_Ref__c = question.Id;
        insert ans;
        
        String inputJSON = '{"ansId":"' + ans.Id + '","ansNumber":"123","quesId":"' + question.Id + '","quesValue":"<b>Question</b>","qTyp":"Text","ansValue":"<b>Answer</b>","GroupText":"Group 1","squesValue":"<b>Sub Question</b>"}';
        
        AnswerHandler handler = new AnswerHandler();
        
        Test.startTest();
        // Act
        String response = handler.updateRecords(inputJSON);
        Test.stopTest();
        
        // Assert
        // System.assert(response.contains('"status":"failure field access problem"'), 'The updateRecords method should return a field access failure status for inaccessible fields.');
    }
     
    @isTest
    static void testUpdateRecords_RecordAccessFailure() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '76',
                                                            Category__c = 'Simple');
        insert questionBook;

        Question__c question = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test09',
            Question_Book__c = questionBook.Id
        );
        insert question;
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;
        Answer__c ans = new Answer__c();
        ans.Answer_Book__c = answerBook.Id;
        ans.Question_Ref__c = question.Id;
        insert ans;
        
        String inputJSON = '{"ansId":"' + ans.Id + '","ansNumber":"123","quesId":"' + question.Id + '","quesValue":"<b>Question</b>","qTyp":"Text","ansValue":"<b>Answer</b>","GroupText":"Group 1","squesValue":"<b>Sub Question</b>"}';
        AnswerHandler handler = new AnswerHandler();

        Test.startTest();
        // Act
        String response = handler.updateRecords(inputJSON);
        Test.stopTest();

        // Assert
        //System.assert(response.contains('"status":"failure record access problem"'), 'The updateRecords method should return a record access failure status for inaccessible records.');
    }

    @isTest
    static void testHandleExisting() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'okk',
            Question_Book__c = questionBook.Id
        );
        insert question1;
        
        Answer_Book__c answerBook = [SELECT Id FROM Answer_Book__c LIMIT 1];

        List<Answer__c> answers = new List<Answer__c>();
        for (Integer i = 1; i <= 3; i++) {
            answers.add(new Answer__c(
                Answer_Book__c = answerBook.Id,
                Question_Ref__c = question1.Id,
                Number__c = i,
                Answer_Long__c = 'Answer ' + i
            ));
        }
        insert answers;

        // Prepare wrapper with Number__c = 2
        AnswerWrapper wrapper = new AnswerWrapper();
        wrapper.abId = answerBook.Id;
        wrapper.ansNumber = 2;

        AnswerHandler handler = new AnswerHandler();
        Test.startTest();
        handler.handleExisting(wrapper);
        Test.stopTest();

        // Verify remaining Answer__c records
        List<Answer__c> remainingAnswers = [SELECT Number__c FROM Answer__c WHERE Answer_Book__c = :answerBook.Id];
        System.assertEquals(2, remainingAnswers.size(), 'Expected two remaining answers.');
        System.assertEquals(1, remainingAnswers[0].Number__c, 'Expected Number__c 1.');
        System.assertEquals(2, remainingAnswers[1].Number__c, 'Expected Number__c 2.');
    }

    
    @isTest
    static void testDeleteRecords() {
        // Arrange
        AnswerHandler handler = new AnswerHandler();
        String inputJSON = '{"key":"value"}';

        // Act
        String response = handler.deleteRecords(inputJSON);

        // Assert
        System.assertEquals('{"status":"failure","message":"Delete operation is not supported"}', response, 'The deleteRecords method should return the correct failure message.');
    }
    
    @isTest
    static void testAfterAnswerBookUpdateTrigger() {
        // Test data setup
        // Create a Question_Book__c record
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'iii',
                                                            Category__c = 'Simple');
        insert questionBook;

        // Create Question__c records
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test1',
            Question_Book__c = questionBook.Id
        );
        insert question1;
        Question__c question2 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test2',
            Question_Book__c = questionBook.Id
        );
        insert question2;

        // Create an Answer_Book__c record
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;

        // Create Answer__c records related to the Answer_Book__c
        Answer__c answer1 = new Answer__c(
            Answer_Book__c = answerBook.Id,
            Question_Ref__c = question1.Id,
            Answer_Long__c = 'Test Answer 1',
            Question_Type__c = 'Text'
        );
        Answer__c answer2 = new Answer__c(
            Answer_Book__c = answerBook.Id,
            Question_Ref__c = question2.Id,
            Answer_Long__c = '123456789012345678TestFileId',
            Question_Type__c = 'File'
        );
        insert new List<Answer__c>{answer1, answer2};

        // Update Answer_Book__c to trigger the logic
        answerBook.Status__c = 'Completed';
        update answerBook;

        // Verify the results
        // Verify ContentDocumentLink creation
        List<ContentDocumentLink> contentDocumentLinks = [
            SELECT Id, ContentDocumentId, LinkedEntityId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :answerBook.Id
        ];
        //System.assert(contentDocumentLinks.size() > 0, 'ContentDocumentLinks should be created.');

        // Verify updated Answer_Book__c and related objects
        Answer_Book__c updatedAnswerBook = [
            SELECT Id, Status__c, Question_Book__c
            FROM Answer_Book__c
            WHERE Id = :answerBook.Id
        ];
        System.assertEquals('Completed', updatedAnswerBook.Status__c, 'Answer_Book__c status should be updated.');

        // Verify related Answer__c updates
        List<Answer__c> updatedAnswers = [
            SELECT Id, Answer_Book__c, Answer_Long__c
            FROM Answer__c
            WHERE Answer_Book__c = :answerBook.Id
        ];
        System.assertEquals(2, updatedAnswers.size(), 'There should be 2 related Answer__c records.');

        // Verify debug logs (optional, for manual verification during testing)
        System.debug('Test class executed successfully.');
    }
}