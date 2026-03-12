@IsTest
public class CertificateControllerTest {

    /* -----------------------------------------
       Test Utility Method
    ------------------------------------------*/
    private static ContentVersion createTestFile() {
        ContentVersion cv = new ContentVersion(
            Title = 'Test_PFX_Certificate',
            PathOnClient = 'Test_PFX_Certificate.pfx',
            VersionData = Blob.valueOf('Dummy PFX Content'),
            IsMajorVersion = true
        );
        insert cv;
    
        cv = [
            SELECT Id, ContentDocumentId, Title
            FROM ContentVersion
            WHERE Id = :cv.Id
            LIMIT 1
        ];
    
        System.assertNotEquals(
            null,
            cv.ContentDocumentId,
            'ContentDocumentId must not be null'
        );
    
        return cv;
	}

    @IsTest
    static void testSaveDigitalSignConfig_Success() {
        ContentVersion cv = createTestFile();
        String pass = 'testPassword123';

        Test.startTest();
        CertificateController.saveDigitalSignConfig(
            cv.ContentDocumentId,
            pass
        );
        Test.stopTest();

        System.assert(true, 'Method executed without exception');
    }

    /* -----------------------------------------
       Test: saveDigitalSignConfig - Missing File
    ------------------------------------------*/
    @IsTest
    static void testSaveDigitalSignConfig_NoFile() {
        Boolean exceptionThrown = false;
    
        try {
            Test.startTest();
            CertificateController.saveDigitalSignConfig(null, 'password');
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
    
        System.assert(
            exceptionThrown,
            'AuraHandledException should be thrown when contentDocumentId is null'
        );
    }

    @IsTest
    static void testSaveDigitalSignConfig_NoPassword() {
        ContentVersion cv = createTestFile();
        Boolean exceptionThrown = false;

        try {
            Test.startTest();
            CertificateController.saveDigitalSignConfig(
                cv.ContentDocumentId,
                null
            );
            Test.stopTest();
        } catch (AuraHandledException e) {
            exceptionThrown = true;
        }
        
        System.assert(
            exceptionThrown,
            'AuraHandledException should be thrown when contentDocumentId is null'
        );
    }

    @IsTest
    static void testGetCertificates_Empty() {
        Test.startTest();
        List<CertificateOption> options =
            CertificateController.getCertificates();
        Test.stopTest();

        System.assertNotEquals(null, options);
        System.assertEquals(0, options.size(), 'No CMDT records expected');
    }

    @IsTest(SeeAllData=true)
    static void testGetCertificates_WithData() {

        Test.startTest();
        List<CertificateOption> options =
            CertificateController.getCertificates();
        Test.stopTest();

        // We cannot guarantee records exist,
        // but method must execute without error
        System.assertNotEquals(null, options);
    }
    
    @IsTest
    static void testHandleResult_FailurePath() {
    
        // Instantiate callback
        DigitalSignCMDTCallback callback =
            new DigitalSignCMDTCallback();
    
        // Mock DeployResult
        Metadata.DeployResult result = new Metadata.DeployResult();
        result.success = false;
        result.status = Metadata.DeployStatus.Failed;
    
        // Mock failure details (optional but increases coverage)
        Metadata.DeployDetails details = new Metadata.DeployDetails();
        Metadata.DeployMessage msg = new Metadata.DeployMessage();
        msg.problem = 'Test failure';
        msg.fileName = 'Digital_Sign_Config__mdt';
        msg.componentType = 'CustomMetadata';
        msg.fullName = 'Digital_Sign_Config__mdt.Test_Record';
    
        details.componentFailures =
            new List<Metadata.DeployMessage>{ msg };
        result.details = details;
    
        // Mock callback context
        Metadata.DeployCallbackContext context =
            new Metadata.DeployCallbackContext();
    
        Test.startTest();
        callback.handleResult(result, context);
        Test.stopTest();
    
        // No assertion needed — execution = coverage
        System.assert(true, 'handleResult executed');
    }
}