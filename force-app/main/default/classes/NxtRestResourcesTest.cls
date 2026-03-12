/*
 * Test class for NxtRestResources.
 */
@isTest
public class NxtRestResourcesTest {

    @isTest
    static void testNxtRestResourcesProcess() {
        // Create test data
        Account account = new Account(Name = 'Test Account');
        insert account;

        Contact contact = new Contact(FirstName = 'Test', LastName = 'Contact', AccountId = account.Id);
        insert contact;

        Test.startTest();

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        RestContext.request = req;
        RestContext.response = res;

        // Test BookletHandler
        req.params.put('dataType', 'Booklet');
        req.params.put('operation', 'list');
        req.params.put('param1', 'SomeValue');
        String response = NxtRestResource.process();

        // Test QuestionHandler
        req.params.put('dataType', 'Question');
        req.params.put('operation', 'read');
        req.params.put('param1', contact.Id);
        response = NxtRestResource.process();

        // Test QuestionBookHandler
        req.params.put('dataType', 'QuestionBook');
        req.params.put('operation', 'create');
        req.params.put('param1', '{"Name":"Test QuestionBook"}');
        response = NxtRestResource.process();
        
        // Test Answer
        req.params.put('dataType', 'Answer');
        req.params.put('operation', 'list');
        req.params.put('param1', '{"Name":"Test Answer"}');
        response = NxtRestResource.process();

        // Test AnswerBookHandler
        req.params.put('dataType', 'AnswerBook');
        req.params.put('operation', 'delete');
        req.params.put('param1', contact.Id);
        response = NxtRestResource.process();

        // Test AttachmentHandler
        req.params.put('dataType', 'Attachment');
        req.params.put('operation', 'update');
        req.params.put('param1', 'SomeValue');
        response = NxtRestResource.process();

        // Test answerCount operation
        req.params.put('dataType', 'answerCount');
        req.params.put('param1', contact.Id);
        response = NxtRestResource.process();

        Test.stopTest();
    }
}