@isTest
public class QuestionTriggerHelperTest {

    @isTest
    static void testStaticVariables() {
        // Initial value should be false
        System.assertEquals(false, QuestionTriggerHelper.hasRun, 'Initial value of hasRun should be false');
        // Set to true and verify
        QuestionTriggerHelper.hasRun = true;
        System.assertEquals(true, QuestionTriggerHelper.hasRun, 'hasRun should be true after setting');

        // processedQuestionIds should be empty initially
        System.assertEquals(0, QuestionTriggerHelper.processedQuestionIds.size(), 'processedQuestionIds should be empty initially');

        // Add an Id and verify
        Id testId = '001000000000001AAA';
        QuestionTriggerHelper.processedQuestionIds.add(testId);
        System.assertEquals(1, QuestionTriggerHelper.processedQuestionIds.size(), 'processedQuestionIds should have one entry');
        System.assertEquals(true, QuestionTriggerHelper.processedQuestionIds.contains(testId), 'processedQuestionIds should contain the test Id');
    }
}