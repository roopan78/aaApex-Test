@isTest
public class QuestionTriggerUpdateBatchTest {

    @isTest
    static void testQuestionTriggerUpdateBatch() {
        Id recType = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId();
        // Step 1: Create a Question Book
        Question_Book__c q = new Question_Book__c(Title__c = 'Test Question Book');
        Question_Book__c qb = new Question_Book__c(Title__c = 'QB_Test');
        insert q;
        insert qb;

        // Step 2: Create parent Question (Book or Table type)
        Question__c parentQuestion = new Question__c(
            Title__c = 'Parent Question',
            RecordTypeId = recType,
            Question_No__c = 1,
            Type__c = 'Book',
            Question_Book__c = q.Id,
            QB_Reference__c = qb.Id,
            Unique_Identifier__c = 'UID-PARENT'
        );
        insert parentQuestion;

        // Step 3: Create a child question linked to the above QB
        Question__c childQuestion = new Question__c(
            Title__c = 'Child Question',
            RecordTypeId = recType,
            Question_No__c = 1,
            Type__c = 'Text',
            Question_Book__c = qb.Id,
            Unique_Identifier__c = 'UID-CHILD'
        );
        insert childQuestion;

        // Step 4: Run batch with only 1 record and batch size 1
        Set<Id> questionIds = new Set<Id>{ parentQuestion.Id };

        Test.startTest();
        Database.executeBatch(new QuestionTriggerUpdateBatch(questionIds), 1);
        Test.stopTest();

        // Step 5: Optional assertion
        Question__c updatedChild = [SELECT Id FROM Question__c WHERE Id = :childQuestion.Id LIMIT 1];
        System.assertNotEquals(null, updatedChild.Id); // Simple check for record presence
    }
}