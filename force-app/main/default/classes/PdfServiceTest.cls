@isTest
public class PdfServiceTest {
    
    @testSetup
    static void setupData() {
        insert new BatchLabelPDF__c(Name = 'Default', PDFGenerateEndpoint__c = 'https://mockendpoint.com/generatePdf');
    }

    @isTest
    static void testFetchAndStorePDF_Success() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"success": true, "data": "JVBERi0xLjQKJf////0K"}'));

        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assertEquals(true, result.get('success'), 'Expected success response');
    }

    @isTest
    static void testFetchAndStorePDF_CustomSettingMissing() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        delete [SELECT Id FROM BatchLabelPDF__c];

        Test.startTest();
        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assertEquals(false, result.get('success'), 'Expected failure due to missing custom setting');
        System.assertEquals('PDF Generate Endpoint not configured in Custom Settings.', result.get('message'));
    }

    @isTest
    static void testFetchAndStorePDF_EmptyBase64Data() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"success": true, "data": ""}'));

        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assertEquals(false, result.get('success'));
        System.assertEquals('Base64 data is empty.', result.get('message'));
    }

    @isTest
    static void testFetchAndStorePDF_APIResponseUnsuccessful() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"success": false}'));

        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assertEquals(false, result.get('success'));
        System.assertEquals('API Response unsuccessful.', result.get('message'));
    }

    @isTest
    static void testFetchAndStorePDF_HTTPError() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, ''));

        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assert(result.get('message') != null && ((String) result.get('message')).contains('HTTP Error: 500'), 'Expected HTTP error message');
    }

    @isTest
    static void testFetchAndStorePDF_ExceptionHandling() {
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        BatchLabelPDF__c settings = [SELECT Id FROM BatchLabelPDF__c LIMIT 1];
        settings.PDFGenerateEndpoint__c = 'invalid-url';
        update settings;

        Test.startTest();
        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'TestPDF','QBName');
        Test.stopTest();

        System.assert(result.get('message') != null && ((String) result.get('message')).contains('Exception'), 'Expected exception handling message');
    }

    @isTest
    static void testFetchAndStorePDF_EmptyPdfName() {
        Account testAccount = new Account(Name = 'Test Empty Pdf');
        insert testAccount;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"success": true, "data": "JVBERi0xLjQKJf////0K"}'));

        // Pass empty pdfName to test defaulting logic
        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, '', 'QBName');
        Test.stopTest();

        System.assertEquals(true, result.get('success'));
        System.assertEquals('PDF stored successfully!', result.get('message'));
    }

    @isTest
    static void testGetNextAvailableTitleLogic() {
        Account testAccount = new Account(Name = 'Test Title Logic');
        insert testAccount;

        // Insert a dummy ContentVersion with similar name
        insert new ContentVersion(
            Title = 'DuplicatePDF',
            PathOnClient = 'DuplicatePDF.pdf',
            VersionData = Blob.valueOf('Dummy'),
            ContentLocation = 'S'
        );
        insert new ContentVersion(
            Title = 'DuplicatePDF1',
            PathOnClient = 'DuplicatePDF1.pdf',
            VersionData = Blob.valueOf('Dummy'),
            ContentLocation = 'S'
        );

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"success": true, "data": "JVBERi0xLjQKJf////0K"}'));
        Map<String, Object> result = PdfService.fetchAndStorePDF('{"key":"value"}', testAccount.Id, 'DuplicatePDF', 'QBName');
        Test.stopTest();

        System.assertEquals(true, result.get('success'));
    }
}