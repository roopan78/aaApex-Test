public with sharing class DynamicControlHandler {
    /*
* Created by: Mohamed Abdul Kadher N 
* Description: To create a dynamic trigger in production
* Created on (DD/MM/YYYY): 06/10/2023.

Overview
The DynamicControlHandler class automates the deployment of Apex classes and triggers using Salesforce Metadata API. It utilizes the Zippex library to create a ZIP file containing metadata files and then deploys them using the MetadataService class.

Features
*Generates a ZIP file with Apex triggers and metadata.
*Deploys the generated ZIP file to Salesforce using the Metadata API.
*Configurable deployment options for better control.

Apex classes used for this implementation
*Zippex to handle ZIP file creation in Apex.
1. HexUtil.cls
2. Puff.cls
3. Zippex.cls
4. ZippexTests.cls

*MetadataService to handle metadata api to create the object, field, Layout, VfPage, ListView, Apex class and Apex trigger
1. MetadataService.cls
2. MetadataServiceHelper
3. MetadataServiceTest

Usage
*Call the deployApexClass method to generate a ZIP file and deploy an Apex Trigger (Account_Trigger) to your Salesforce org.
DynamicControlHandler.deployApexClass();

For further info you can refer
1. https://github.com/certinia/apex-mdapi/tree/master - MetadataApi 
2. https://github.com/pdalcol/Zippex - Zippex
*/
    
    public static MetadataServiceHelper.DeployOptions getDeployOptions(){
        
        MetadataServiceHelper.DeployOptions lvDeployOption = new MetadataServiceHelper.DeployOptions();
        lvDeployOption.allowMissingFiles = false;
        lvDeployOption.autoUpdatePackage = true;
        lvDeployOption.checkOnly = false;
        lvDeployOption.ignoreWarnings = true;
        lvDeployOption.performRetrieve = false;
        lvDeployOption.purgeOnDelete = false;
        lvDeployOption.rollbackOnError = true;
        lvDeployOption.runTests = new String[]{};
        lvDeployOption.singlePackage = true;
        lvDeployOption.testLevel = 'NoTestRun';
        
        return lvDeployOption;
    }
    
    public static String generateZipfile() {
        Zippex sampleZip = new Zippex();
        Blob fileData = Blob.valueOf(getPackageXml());
        
        //Trigger logic
        sampleZip.addFile('package.xml', fileData, null);
        fileData = Blob.valueOf(getHelloWorldMetadata());
        sampleZip.addFile('triggers/Account_Trigger.trigger-meta.xml', fileData, null);
        fileData = Blob.valueOf(getHelloWorld());
        sampleZip.addFile('triggers/Account_Trigger.trigger', fileData, null);
        return EncodingUtil.base64Encode(sampleZip.getZipArchive());
        
    }
    @TestVisible
    private static Boolean isTest = false;
    public static void deployApexClass() {
    if (isTest) {
        System.debug('⚠️ Skipping deployApexClass in test context');
        return;
        }
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataServiceHelper.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        String zippedClass = generateZipfile();
        MetadataServiceHelper.AsyncResult deployResult= service.deploy(zippedClass, getDeployOptions());
        String jobId = deployResult.id;
        MetadataService.DeployResult result = service.checkDeployStatus(jobId,true);
        System.debug('deploy status is: ' + result);
        Long startTime = DateTime.now().getTime();
        Long finishTime = DateTime.now().getTime();
        while ((finishTime - startTime) < 3000) {         
            finishTime = DateTime.now().getTime();
        }
        result = service.checkDeployStatus( jobId,true);
        System.debug('deploy status is: ' + result);
    }
    
    public static String getPackageXml()
    {
        return '<?xml version="1.0" encoding="UTF-8"?>' + 
            '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' + 
            '<types>' + 
            '<members>Account_Trigger</members>' +
            '<name>ApexTrigger</name>' + 
            '</types>' + 
            '<version>61.0</version>' + 
            '</Package>';	
    }
    
    public static String getHelloWorldMetadata()
    {
        return '<?xml version="1.0" encoding="UTF-8"?>' +
            '<ApexTrigger xmlns="http://soap.sforce.com/2006/04/metadata">' +
            '<apiVersion>61.0</apiVersion>' +
            '<status>Active</status>' +
            '</ApexTrigger>';	
    }
    
    public static String getHelloWorld()	
    {
        return 'trigger Account_Trigger on Account (after update){ ' +
            'System.debug(\' Hello World\');' +
            '}';
    }
}