@isTest
public class QuestionMappingControllerTest {

    // Utility method to create test Question__c records
    private static Question__c createTestQuestion(String questionType, String questionBookId) {
        Question__c question = new Question__c();
        question.Type__c = questionType;
        question.Question_Book__c = questionBookId;
        question.Question_No__c = 10;
        question.Unique_Identifier__c = 'career_' + String.valueOf(System.currentTimeMillis()) + Math.random();
        insert question;
        return question;
    }

    // Utility method to create Question_Mapping__mdt records
    private static Question_Mapping__mdt createTestQuestionMapping(String questionType, String supportedType) {
        Question_Mapping__mdt mapping = new Question_Mapping__mdt();
        mapping.Question_Type__c = questionType;
        mapping.Supported_Type__c = supportedType;
        //insert mapping;
        return mapping;
    }

    @isTest
    static void testGetQuestionType() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        Question_Mapping__mdt mapping = createTestQuestionMapping('Book', 'Answer_Book__c');
        Question__c question = createTestQuestion('Dropdown', questionBook.Id);

        // Act: Call the method
        Test.startTest();
        String result = QuestionMappingController.getQuestionType(question.Id);
        Test.stopTest();

        // Assert: Validate the response
        System.assert(result.contains('Dropdown'), 'Type value is incorrect');
        //System.assert(result.contains('Answer_Book__c'), 'Supported type value is incorrect');
    }

    @isTest
    static void testGetObjectDetail() {
        // Arrange: Use a standard object like Account for testing
        String objectApiName = 'Account';

        // Act: Call the method
        Test.startTest();
        String result = QuestionMappingController.getObjectDetail(objectApiName);
        Test.stopTest();

        // Assert: Validate the response
        System.assert(result.contains('fullList'), 'Response does not contain fullList');
        System.assert(result.contains('Account'), 'API name is missing in the response');
    }

    @isTest
    static void testUpdateObject_Success() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question = createTestQuestion('Dropdown', questionBook.Id);

        // Act: Call the updateObject method with a valid value
        Test.startTest();
        String result = QuestionMappingController.updateObject('NewReferenceValue', question.Id);
        Test.stopTest();

        // Assert: Validate the response
        System.assert(result.contains('success'), 'Update should be successful');

        // Verify the updated field
        Question__c updatedQuestion = [SELECT Reference_Field__c FROM Question__c WHERE Id = :question.Id];
        System.assertEquals('NewReferenceValue', updatedQuestion.Reference_Field__c, 'Reference_Field__c was not updated');
    }

    @isTest
    static void testUpdateObject_Failure_ExistingValue() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question1 = createTestQuestion('Dropdown', questionBook.Id);
        question1.Reference_Field__c = 'ExistingValue';
        update question1;

        Question__c question2 = createTestQuestion('Dropdown', questionBook.Id);

        // Act: Call the updateObject method with a duplicate Reference_Field__c value
        Test.startTest();
        String result1 = QuestionMappingController.updateObject('ExistingValue', question2.Id);
        Test.stopTest();

        // Assert: Validate the failure response
        System.assert(result1.contains('failure'), 'Update should fail due to duplicate value');
        System.assert(result1.contains('The Value is already taken by another question'), 'Failure message is incorrect');
    }

    @isTest
    static void testUpdateObject_Failure_Exception() {
        
        Question_Book__c questionBook = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = 'ok',
                                                            Category__c = 'Simple');
        insert questionBook;
        
        Question__c question = createTestQuestion('Dropdown', questionBook.Id);

        // Use a fake invalid value to simulate exception
        String invalidValue = null;

        // Act: Call the updateObject method with null value
        Test.startTest();
        String result = QuestionMappingController.updateObject(invalidValue, question.Id);
        Test.stopTest();

        // Assert: Validate failure response
        System.assert(result.contains('failure'), 'Update should fail when an exception occurs');
        System.assert(result.contains('Some error in updating ,please try again.'), 'Error message is incorrect');
    }
}