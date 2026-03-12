@isTest
public class QueryHandlerTest {

    @isTest
    static void testConstructQueryWithRecursion() {
        // ===== STEP 1: Create Question Books =====
        Question_Book__c mainBook = new Question_Book__c(Title__c ='QB1');
        insert mainBook;

        Question_Book__c refBook1 = new Question_Book__c(Title__c ='QB2');
        insert refBook1;

        Question_Book__c refBook2 = new Question_Book__c(Title__c ='QB3');
        insert refBook2;

        // ===== STEP 2: Create Questions to simulate recursion =====
        // mainBook references refBook1
        Question__c q1 = new Question__c(
            Question_Book__c = mainBook.Id,
            Type__c = 'Book',
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            QB_Reference__c = refBook1.Id
        );

        // refBook1 references refBook2
        Question__c q2 = new Question__c(
            Question_Book__c = refBook1.Id,
            Type__c = 'Book',
            Question_No__c = 2,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            QB_Reference__c = refBook2.Id
        );

        insert new List<Question__c>{ q1, q2 };

        // ===== STEP 3: Create Field_Meta__c for each question book =====
        Field_Meta__c fm1 = new Field_Meta__c(
            Question__c = q1.Id,
            Api_Name__c = 'Test_Field_1__c'
        );

        Field_Meta__c fm2 = new Field_Meta__c(
            Question__c = q2.Id,
            Api_Name__c = 'Test_Field_2__c'
        );

        insert new List<Field_Meta__c>{ fm1, fm2 };

        // ===== STEP 4: Call the method under test =====
        Test.startTest();
        String result = QueryHandler.constructQuery(mainBook.Id, 'Account');
        Test.stopTest();

        // ===== STEP 5: Assertions =====
        // 1. Verify recursion added all referenced books
        Set<Id> expectedBooks = new Set<Id>{ mainBook.Id, refBook1.Id, refBook2.Id };
        System.debug('Expected books: ' + expectedBooks);

        // 2. Verify the output message
        System.assert(result.contains('Query updated'), 'Expected query update message');

        // 3. Verify that Query__c field got updated properly
        Question_Book__c updatedBook = [SELECT Id, Query__c FROM Question_Book__c WHERE Id = :mainBook.Id];
        System.assertNotEquals(null, updatedBook.Query__c, 'Query__c should not be null');
        System.assert(updatedBook.Query__c.contains('SELECT Id,Name'), 'Query should start with SELECT Id,Name');
        System.assert(updatedBook.Query__c.contains('Test_Field_1__c'), 'Expected field from Field_Meta__c');
        System.assert(updatedBook.Query__c.contains('FROM Account'), 'Expected FROM clause');
    }

    @isTest
    static void testConstructQueryWithNoReferences() {
        // Create a simple Question Book with no references
        Question_Book__c book = new Question_Book__c(Title__c = 'QB');
        insert book;

        Question__c question = new Question__c(
            Question_Book__c = book.Id,
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            Type__c = 'Text'
        );
        insert question;

        Field_Meta__c fm = new Field_Meta__c(
            Question__c = question.Id,
            Api_Name__c = 'Simple_Field__c'
        );
        insert fm;

        Test.startTest();
        String result = QueryHandler.constructQuery(book.Id, 'Contact');
        Test.stopTest();

        // Verify Query__c was updated
        Question_Book__c updatedBook = [SELECT Id, Query__c FROM Question_Book__c WHERE Id = :book.Id];
        System.assert(updatedBook.Query__c.contains('Simple_Field__c'));
        System.assert(updatedBook.Query__c.contains('FROM Contact'));
        System.assert(result.contains('fields added'));
    }
}