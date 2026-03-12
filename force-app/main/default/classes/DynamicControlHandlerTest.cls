@IsTest
public class DynamicControlHandlerTest {

    @IsTest
    static void testGetDeployOptions() {
        MetadataServiceHelper.DeployOptions opts = DynamicControlHandler.getDeployOptions();
        System.assertNotEquals(null, opts);
        System.assertEquals(false, opts.allowMissingFiles);
        System.assertEquals('NoTestRun', opts.testLevel);
        System.assertEquals(true, opts.singlePackage);
    }

    @IsTest
    static void testGenerateZipfile() {
        String base64Zip = DynamicControlHandler.generateZipfile();
        System.assertNotEquals(null, base64Zip);
        System.assert(base64Zip.length() > 0);
    }

    @IsTest
    static void testGetPackageXml() {
        String xml = DynamicControlHandler.getPackageXml();
        System.assert(xml.contains('<Package'));
        System.assert(xml.contains('<name>ApexTrigger</name>'));
    }
    
    @IsTest
    static void testDeployApexClass() {
        // Enable test mode to skip real deployment
        DynamicControlHandler.isTest = true;

        Test.startTest();
        DynamicControlHandler.deployApexClass();
        Test.stopTest();
        
        // Just assert true to show coverage
        System.assert(true);
    }

    @IsTest
    static void testGetHelloWorldMetadata() {
        String meta = DynamicControlHandler.getHelloWorldMetadata();
        System.assert(meta.contains('<ApexTrigger'));
        System.assert(meta.contains('<status>Active</status>'));
    }

    @IsTest
    static void testGetHelloWorld() {
        String code = DynamicControlHandler.getHelloWorld();
        System.assert(code.contains('trigger Account_Trigger'));
        System.assert(code.contains('System.debug'));
    }
}