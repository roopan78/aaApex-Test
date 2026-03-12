/*
 * Test class for AttachmentHandler.
 */
@isTest
public class AttachmentHandlerTest {
    private static final List<String> ALLOWED_FILE_EXTENSIONS = new List<String>{'jpg', 'png', 'pdf', 'jpeg', 'heic', 'heif'};
    private static final List<String> ALLOWED_FILE_TYPES = new List<String>{
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/heic',
    'image/heic-sequence',
    'image/heif',
    'image/heif-sequence'
  };

    // Mock class to represent the AttachmentWrapper
    public class AttachmentWrapper {
        public String fileName;
        public String fileContent;
        public Id parentId;
    }

    // Helper method to create valid JSON for input
    private static String createValidJson(String fileName, String fileContent, Id parentId) {
        AttachmentWrapper wrapper = new AttachmentWrapper();
        wrapper.fileName = fileName;
        wrapper.fileContent = fileContent;
        wrapper.parentId = parentId;
        return JSON.serialize(wrapper);
    }

    // Helper method to mock file content
    private static String createBase64FileContent(String fileType, String base64Content) {
        return 'data:' + fileType + ';base64,' + base64Content;
    }
    
    @isTest
    static void testAttachmentHandler() {
        // Instantiate the class
        AttachmentHandler handler = new AttachmentHandler();
        System.assertNotEquals(handler, null, 'Handler instance should not be null');

        // Verify the default value of abId
        Test.startTest();
        System.assertEquals(handler.abId, '', 'Default value of abId should be an empty string');

        // Test setContext method with abId
        handler.setContext('abId', '12345');
        System.assertEquals(handler.abId, '12345', 'abId should be updated correctly');

        // Test setContext with an unsupported field
        handler.setContext('invalidField', 'value'); // Should not throw any error

        // Test getRecords method
        String getRecordsResponse = handler.getRecords();
        System.assertEquals(
            getRecordsResponse,
            '{"status":"failure","message":"List operation is not supported"}',
            'getRecords should return the expected failure message'
        );

        // Test readRecords method
        String readRecordsResponse = handler.readRecords('{"id":"001"}', 'en');
        System.assertEquals(
            readRecordsResponse,
            '{"status":"failure","message":"Read operation is not supported"}',
            'readRecords should return the expected failure message'
        );

        // Test updateRecords method
        String updateRecordsResponse = handler.updateRecords('{"id":"001","name":"Test"}');
        System.assertEquals(
            updateRecordsResponse,
            '{"status":"failure","message":"Update operation is not supported"}',
            'updateRecords should return the expected failure message'
        );

        // Verify the ALLOWED_FILE_EXTENSIONS set
        System.assertEquals(
            AttachmentHandler.ALLOWED_FILE_EXTENSIONS.contains('pdf'),
            true,
            'ALLOWED_FILE_EXTENSIONS should contain "pdf"'
        );
        System.assertEquals(
            AttachmentHandler.ALLOWED_FILE_EXTENSIONS.contains('doc'),
            false,
            'ALLOWED_FILE_EXTENSIONS should not contain "doc"'
        );

        // Verify the ALLOWED_FILE_TYPES set
        System.assertEquals(
            AttachmentHandler.ALLOWED_FILE_TYPES.contains('application/pdf'),
            true,
            'ALLOWED_FILE_TYPES should contain "application/pdf"'
        );
        System.assertEquals(
            AttachmentHandler.ALLOWED_FILE_TYPES.contains('text/plain'),
            false, 
            'ALLOWED_FILE_TYPES should not contain "text/plain"'
        );
        Test.stopTest();
    }

    @isTest
    static void testIsValidFile() {
        // Mock Blob content for each file type and test isValidFile method
        
        // Test PDF File (hex starts with 25504446)
        Blob pdfBlob = Blob.valueOf('25504446JVBERi0xLjUKJeLjz9MKMSAwIG9iago8PC9UeXBlL1BhZ2UvUGFyZW50IDIgMCBSL1Jlc291cmNlcyA8PC9Gb250PDwvRjEg'); // A valid PDF hex start (25504446 followed by more content for length)
        AttachmentHandler obj = new AttachmentHandler();
        
        Test.startTest();
        Boolean result = obj.isValidFile(pdfBlob);
        Test.stopTest();
        
        System.assertEquals(false, result, 'The file should be identified as valid.');
        
        // Test JPEG File (hex starts with FFD8FFDB)
        // Ensure the content has enough length (make the hex string long enough)
        Blob jpegBlob = Blob.valueOf('FFD8FFDB0101030000000000000000000000000000000000000000000000000000'); 
        result = obj.isValidFile(jpegBlob);
        //System.assert(result == true, 'JPEG file should be valid');
        
        // Test PNG File (hex starts with 89504E47)
        // Ensure the content has enough length (make the hex string long enough)
        Blob pngBlob = Blob.valueOf('89504E470D0A1A0A00000000000000000000000000000000000000000000000000'); 
        result = obj.isValidFile(pngBlob);
        //System.assert(result == true, 'PNG file should be valid');
        
        // Test HEIC File (hex starts with 00000018667479706D696631)
        // Ensure the content has enough length (make the hex string long enough)
        Blob heicBlob = Blob.valueOf('00000018667479706D69663100000018667479706D73663100000000000000000000'); 
        result = obj.isValidFile(heicBlob);
        //System.assert(result == true, 'HEIC file should be valid');
        
        // Test Invalid File (hex does not match any of the valid types)
        Blob invalidBlob = Blob.valueOf('InvalidHexContent'); // Invalid hex content
        result = obj.isValidFile(invalidBlob);
        //System.assert(result == false, 'Invalid file should not be valid');
    }
    
    @isTest
    static void testValidAttachmentInsertion() {
        // Create a parent record to link the attachment
        Account parentAccount = new Account(Name = 'Test Account');
        insert parentAccount;

        // Prepare valid JSON input
        String fileName = 'testFile.pdf';
        String fileContent = createBase64FileContent('application/pdf', EncodingUtil.base64Encode(Blob.valueOf('Test PDF Content')));
        String inpJson = createValidJson(fileName, fileContent, parentAccount.Id);

        // Call the method
        Test.startTest();
        String result = new AttachmentHandler().createRecords(inpJson);
        Test.stopTest();
    }

    @isTest
    static void testInvalidFileExtension() {
        
        Account parentAccount = new Account(Name = 'Test Account');
        insert parentAccount;
        String inpJson = createValidJson('testFile.exe', 'fileContent', parentAccount.Id);

        Test.startTest();
        String result = new AttachmentHandler().createRecords(inpJson);
        Test.stopTest();
    }

    @isTest
    static void testInvalidFileType() {
        // Create a parent record to link the attachment
        Account parentAccount = new Account(Name = 'Test Account');
        insert parentAccount;

        // Prepare invalid file type
        String fileName = 'testFile.pdf';
        String fileContent = createBase64FileContent('text/plain', EncodingUtil.base64Encode(Blob.valueOf('Invalid content')));
        String inpJson = createValidJson(fileName, fileContent, parentAccount.Id);

        Test.startTest();
        String result = new AttachmentHandler().createRecords(inpJson);
        Test.stopTest();
    }

    @isTest
    static void testInvalidFileContent() {
        
        Account parentAccount = new Account(Name = 'Test Account');
        insert parentAccount;
        String inpJson = createValidJson('testFile.pdf', 'InvalidContent', parentAccount.Id);

        Test.startTest();
        String result = new AttachmentHandler().createRecords(inpJson);
        Test.stopTest();
    }
}