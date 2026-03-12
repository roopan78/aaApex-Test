@isTest
public class QuestionBookRecControllerTest {
    
    @testSetup
    static void setup() {
        // Create test data
        Question_Book__c qb1 = new Question_Book__c(Title__c = 'Test Book 1');
        Question_Book__c qb2 = new Question_Book__c(Title__c = 'Test Book 2');
        insert new List<Question_Book__c>{qb1, qb2};
    }
    
    @isTest
    static void testGetQuestionBooks() {
        // Call the method to test
        List<QuestionBookWrapper> result = QuestionBookRecController.getQuestionBooks();
        
        // Verify the results
        System.assertEquals(2, result.size(), 'Expected 2 Question Books');
        System.assertNotEquals(null, result[0].Id, 'Expected non-null Id for first Question Book');
        System.assertNotEquals(null, result[1].Id, 'Expected non-null Id for second Question Book');
    }
    
    @isTest
    static void testCreateQuestionBook() {
        Question_Book__c newBook = QuestionBookRecController.createQuestionBook('New Test Book');
        
     System.assertNotEquals(null, newBook.Id, 'Expected non-null Id for new Question Book');
        System.assertEquals('New Test Book', newBook.Title__c, 'Expected Title to be "New Test Book"');
        
        Question_Book__c insertedBook = [SELECT Id, Title__c FROM Question_Book__c WHERE Id = :newBook.Id];
        System.assertEquals('New Test Book', insertedBook.Title__c, 'Expected Title to be "New Test Book"');
    }
}