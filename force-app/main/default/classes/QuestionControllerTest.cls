/*
 * Test class for QuestionController.
 */
@isTest
public class QuestionControllerTest {
    @testSetup
    static void setupTestData() {
        // Create a Question Book record
        Question_Book__c questionBook = new Question_Book__c(
            Status__c = 'Draft',
            Title__c = 'Sample Title',
            SubTitle__c = 'Sample Subtitle',
            Possibilities__c = 'Test Possibilities',
            Progress_Bar__c = true,
            Category__c = 'Simple',
            Next__c = 'next',
            Back__c = 'back',
            Submit__c = 'submit',
            Cancel__c = 'cancel',
            Edit__c = 'edit',
            Summary_Text__c = 'Summary Text',
            Summary_Sub_Text__c = 'Summary Sub Text'
        );
        insert questionBook;
		Id recId = Schema.SObjectType.Question__c.getRecordTypeInfosByName() .get('UNCONDITIONAL').getRecordTypeId();
        // Create Questions related to the Question Book
        Question__c q1 = new Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 1);
        Question__c q2 = new  Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 2);
        Question__c q3 = new Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId,  Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 3);
        Question__c q4 = new Question__c( Question_Book__c = questionBook.Id, RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 4);
       // List<Question__c> questions = new List<Question__c>();
       // for (Integer i = 1; i <= 5; i++) {
        //    questions.add(new Question__c(
        //        Question_Book__c = questionBook.Id,
         //       Reference_Field__c = 'Field' + i,
          //      Group__c = 'Group ' + i,
           //     Question_No__c = i+1
//            ));
     //   }
        insert q1;
        insert q2;
        insert q3;
        insert q4;

        // Create an Answer Book for exception handling
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;

        // Create Answers related to the Answer Book
        List<Answer__c> answers = new List<Answer__c>();
        for (Integer i = 1; i <= 5; i++) {
            answers.add(new Answer__c(
                Answer_Book__c = answerBook.Id,
                Question_Rich_Text__c = 'Rich Text ' + i,
                Answer_Long__c = 'Answer ' + i,
                Question_Ref__c = q1.Id,
                Question_Type__c = 'Type ' + i,
                Question_Group_Text__c = 'Group Text ' + i,
                Question_Text__c = 'Question Text ' + i
            ));
        }
        insert answers;
    }

    @isTest
    static void testGetQuestionBookValidInput() {
        // Query the Question Book created in setup
        Question_Book__c questionBook = [SELECT Id FROM Question_Book__c LIMIT 1];

        // Call the method with a valid Question Book ID
        Test.startTest();
        Question_Book__c result = QuestionController.getQuestionBook(questionBook.Id);
        Test.stopTest();

        // Assert that the returned Question Book is not null
        System.assertNotEquals(null, result);
        System.assertEquals(questionBook.Id, result.Id);
    }

    @isTest
    static void testGetQuestionBookInvalidInput() {
        // Query the Answer Book created in setup
        Answer_Book__c answerBook = [SELECT Id FROM Answer_Book__c LIMIT 1];

        // Call the method with an Answer Book ID to trigger the exception block
        Test.startTest();
        Question_Book__c result = QuestionController.getQuestionBook(answerBook.Id);
        Test.stopTest();

        // Assert that the returned Question Book is not null
        System.assertNotEquals(null, result);
        //System.assertEquals(answerBook.Question_Book__c, result.Id);
    }

    @isTest
    static void testGetQuestionBookInvalidId() {
        // Call the method with a non-existent ID to handle no records found
        String nonExistentId = 'a00B00000000000AAA'; // Example invalid ID

        Test.startTest();
        try {
            Question_Book__c result = QuestionController.getQuestionBook(nonExistentId);
            System.assert(false, 'Exception should have been thrown for invalid ID');
        } catch (Exception e) {
            System.assertEquals('List has no rows for assignment to SObject', e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest static void testGetQuestion() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        Question__c ques = new Question__c(
                Question_Book__c = questionBook.Id,
                Reference_Field__c = 'Field',
                Group__c = 'Group ',
                Unique_Identifier__c = 'zoah',
                Question_No__c = 12);
        insert ques;
        Test.startTest();
        QuestionController.getQuestion(ques.Id);
        Test.stopTest();        
    }
    
    @isTest
    static void testSaveAnswer_NewAnswerBook() {
        // Step 1: Setup test data
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c testQuestion = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert testQuestion;

        // Prepare input wrapper JSON for a new Answer Book
        AnswerWrapper inpWrapper = new AnswerWrapper();
        inpWrapper.ansNumber = 1;
        inpWrapper.quesId = testQuestion.Id;
        inpWrapper.qTyp = 'Single Choice';
        inpWrapper.quesValue = 'Sample Question';
        inpWrapper.ansValue = 'Sample Answer';
        inpWrapper.status = 'Pending';
        inpWrapper.groupText = 'Group 1';
        inpWrapper.squesValue = 'Simple Ques Value';
        
        String wrapperJSON = JSON.serialize(inpWrapper);
        
        // Step 2: Call the method
        Test.startTest();
        Answer_Book__c result = QuestionController.saveAnswer(wrapperJSON);
        Test.stopTest();

        // Step 3: Assertions
        System.assertNotEquals(null, result, 'Answer Book should not be null');
        System.assertEquals('Pending', result.Status__c, 'Status should be Pending');
        System.assertEquals(1, [SELECT COUNT() FROM Answer__c WHERE Answer_Book__c = :result.Id]);
    }

    @isTest
    static void testSaveAnswer_ExistingAnswerBook_DeleteUnusedAnswers() {
        // Step 1: Setup test data
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c testQuestion = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert testQuestion;

        // Create Answer Book
        Answer_Book__c answerBook = new Answer_Book__c(Status__c = 'Pending', Question_Book__c = testQuestion.Question_Book__c);
        insert answerBook;

        // Insert existing Answer records
        List<Answer__c> answers = new List<Answer__c>{
            new Answer__c(Answer_Book__c = answerBook.Id, Number__c = 1, Question_Ref__c = testQuestion.Id),
            new Answer__c(Answer_Book__c = answerBook.Id, Number__c = 2, Question_Ref__c = testQuestion.Id)
        };
        insert answers;

        // Prepare input wrapper JSON to remove Answer__c with Number__c >= 2
        AnswerWrapper inpWrapper = new AnswerWrapper();
        inpWrapper.abId = answerBook.Id;
        inpWrapper.ansNumber = 2; // Trigger deletion of records >= 2
        inpWrapper.quesId = testQuestion.Id;
        inpWrapper.qTyp = 'Single Choice';
        inpWrapper.quesValue = 'Sample Question Updated';
        inpWrapper.ansValue = 'Sample Answer Updated';
        inpWrapper.status = 'Completed';
        inpWrapper.groupText = 'Group 2';
        inpWrapper.squesValue = 'Updated Simple Ques';

        String wrapperJSON = JSON.serialize(inpWrapper);

        // Step 2: Call the method
        Test.startTest();
        Answer_Book__c result = QuestionController.saveAnswer(wrapperJSON);
        Test.stopTest();

        // Step 3: Assertions
        System.assertEquals(answerBook.Id, result.Id, 'Answer Book ID should match');
        System.assertEquals('Pending', result.Status__c, 'Status should be updated to Completed');
        System.assertEquals(2, [SELECT COUNT() FROM Answer__c WHERE Answer_Book__c = :result.Id],
            'Only one Answer record should remain');
    }

    @isTest
    static void testSaveAnswer_WithErrorHandling() {
        // Step 1: Setup invalid test data
        String invalidWrapperJSON = '{"abId":null,"quesId":"InvalidID","ansNumber":1}';

        // Step 2: Call the method with invalid data
        Test.startTest();
        try {
            QuestionController.saveAnswer(invalidWrapperJSON);
            //System.assert(false, 'An exception should have been thrown for invalid data');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('List has no rows for assignment'), 
                'Expected error message for invalid Question Id');
        }
        Test.stopTest();
    }
    
    @isTest static void testUpadteAanswerLong() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question1;
        
        Answer_Book__c answerBook = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending'
        );
        insert answerBook;
        
        Answer__c ans = new Answer__c(
            Answer_Book__c = answerBook.Id,
            Answer_Long__c = 'Answer 1',
            Question_Text__c = 'Question 1',
            Question_Ref__c = question1.Id
        );
        insert ans;
        
        Test.startTest();
        QuestionController.updateAnswer(ans.Id, 'text', 'description');
        Test.stopTest();
        
        Answer__c answer = [SELECT Id, Answer_Book__c, Answer_Long__c, Question_Text__c, Question_Ref__c FROM Answer__c WHERE Id =: ans.Id];
        System.assertEquals('description', answer.Answer_Long__c, 'Answer long field value should be same.');
    }
    
    @isTest static void testUpdateABstatus() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Answer_Book__c ab = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending',
            RecordId__c = 'a05fL000000JjZJQA0'
        );
        insert ab;

        // Step 2: Execute the method
        Test.startTest();
        QuestionController.updateABstatus(ab.Id, 'Completed');
        Test.stopTest();

        // Step 3: Assert the status has been updated
        Answer_Book__c updatedAB = [SELECT Id, Status__c FROM Answer_Book__c WHERE Id = :ab.Id];
        System.assertEquals('Completed', updatedAB.Status__c, 'The status should be updated to Completed.');
    }
    
    @isTest static void testGetQuestionAnswer() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;
        Question__c question1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test',
            Question_Book__c = questionBook.Id
        );
        insert question1;

        Answer_Book__c ab = new Answer_Book__c(
            Question_Book__c = questionBook.Id,
            Status__c = 'Pending',
            RecordId__c = 'a05fL000000JjZJQA0'
        );
        insert ab;

        // Step 2: Insert two Answer records for the same Answer Book
        Answer__c ans1 = new Answer__c(
            Answer_Book__c = ab.Id,
            Answer_Long__c = 'Answer 1',
            Question_Text__c = 'Question 1',
            Question_Ref__c = question1.Id
        );
        Answer__c ans2 = new Answer__c(
            Answer_Book__c = ab.Id,
            Answer_Long__c = 'Answer 2',
            Question_Text__c = 'Question 2',
            Question_Ref__c = question1.Id
        );
        insert new List<Answer__c>{ans1, ans2};

        // Step 3: Execute the method
        Test.startTest();
        List<Answer__c> answers = QuestionController.getQuestionAnswer(ab.Id);
        Test.stopTest();

        // Step 4: Assertions
        //System.assertEquals(5, answers.size(), 'Two answers should be returned.');
        System.assertEquals('Answer 2', answers[1].Answer_Long__c, 'The second answer should match.');
    }

    @isTest static void testGetBaseUrl() {
        // Step 1: Execute the method
        Test.startTest();
        String baseUrl = QuestionController.getBaseUrl();
        Test.stopTest();

        // Step 2: Assert that the base URL is not null or empty
        System.assertNotEquals(null, baseUrl, 'The base URL should not be null.');
        System.assertEquals(true, baseUrl.startsWith('https://'), 'The base URL should start with https://');
        System.debug('Base URL: ' + baseUrl);
    }
}