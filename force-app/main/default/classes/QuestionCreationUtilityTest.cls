/*
 * Test class for QuestionCreationUtility.
 */
@isTest
public class QuestionCreationUtilityTest {

    @isTest
    static void testOptionCreation() {
        // Create a Question record to reference
         Id  recType = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('CONDITIONAL').getRecordTypeId();
            Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Bdook1',
                                                            Category__c = 'Simple');
        	insert questionBook;
            Question__c question = new Question__c(
            Question_No__c = 1, 
            Type__c = 'Radio',
            RecordTypeId = recType,
            Question_Book__c = questionBook.Id
        );
        insert question;

        // Define test data for options
        List<String> optionsValueList = new List<String>{'Optionytyt 1', 'Optionfgh 5', 'Optionhghg 6'};
        String questionId = question.Id;
        Integer questionNumber = 101;

        // Call the method
        Test.startTest();
        QuestionCreationUtility.optionCreation(optionsValueList, questionId, questionNumber);
        Test.stopTest();

        // Verify the results
        List<Option__c> insertedOptions = [SELECT Id, Order__c, Question__c, Value__c, Unique_Identifier__c 
                                           FROM Option__c WHERE Question__c = :questionId];

        System.assertEquals(3, insertedOptions.size(), 'There should be 3 options inserted');

        // Verify each option's data
        for (Integer i = 0; i < insertedOptions.size(); i++) {
            System.assertEquals(questionId, insertedOptions[i].Question__c, 'Question ID should match');
            System.assertEquals(optionsValueList[i], insertedOptions[i].Value__c, 'Option value should match');
            System.assertEquals(i + 1, insertedOptions[i].Order__c, 'Order should match');
        }
    }

    @isTest
    static void testQuestionCreation() {
        // Create a Question Book record to reference
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert questionBook;

        String questionbookId = questionBook.Id;
        String questionBookNumber = '001';

        // Call the method
        Test.startTest();
        QuestionCreationUtility.questionCreation(questionbookId, questionBookNumber);
        Test.stopTest();

        // Verify the results
        List<Question__c> insertedQuestions = [SELECT Id, Question_Book__c, Type__c, Question_No__c, Unique_Identifier__c
                                               FROM Question__c WHERE Question_Book__c = :questionbookId];

        System.assertEquals(20, insertedQuestions.size(), 'There should be 20 questions inserted');

        // Verify each question's data
        for (Integer i = 0; i < insertedQuestions.size(); i++) {
            Integer questionNumber = 9 + i;
            System.assertEquals(questionbookId, insertedQuestions[i].Question_Book__c, 'Question Book ID should match');
            System.assertEquals('Radio', insertedQuestions[i].Type__c, 'Type should be Radio');
            System.assertEquals(questionNumber, insertedQuestions[i].Question_No__c, 'Question number should match');
        }
    }
}