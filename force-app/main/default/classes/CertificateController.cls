/*
    @description: Controller to handle Digital Signature Certificate Configurations
    @author: Roopan Thangam
    @date: 12DEC25
    
    Version       Date           Author              Description
    1.0          12DEC25       Roopan Thangam     Initial version to create and retrieve CMDT records for digital signature configurations.
*/
public with sharing class CertificateController {

    @AuraEnabled
    public static void saveDigitalSignConfig(
        String contentDocumentId,
        String password
    ) {
        if (String.isBlank(contentDocumentId)) {
            throw new AuraHandledException('PFX file is required.');
        }
        if (String.isBlank(password)) {
            throw new AuraHandledException('PFX password is required.');
        }

        if(!Schema.sObjectType.ContentVersion.isAccessible()) {
            throw new AuraHandledException('Insufficient permissions to access ContentVersion.');
        }

        ContentVersion cv = [
            SELECT Id, ContentDocumentId, Title
            FROM ContentVersion
            WHERE ContentDocumentId = :contentDocumentId
            LIMIT 1
        ];

        // ✅ CREATE DEPLOYMENT CONTAINER
        Metadata.DeployContainer dc = new Metadata.DeployContainer();
        Metadata.CustomMetadata cmd = new Metadata.CustomMetadata();

        // ✅ UNIQUE DEVELOPER NAME (REQUIRED FOR NEW RECORDS)
        // Format: CustomMetadataTypeName.DeveloperName
        String uniqueName = 'Config_' + String.valueOf(System.now().getTime()).replaceAll('[^a-zA-Z0-9]', '_');
        cmd.fullName = 'Digital_Sign_Config__mdt.' + uniqueName;
        
        // ✅ LABEL FOR THE RECORD
        cmd.label = 'Digital Sign Config' + cv.Title;
        
        // ✅ PROTECTED (optional - set to false if you want it editable in target org)
        cmd.protected_x = false;

        // ✅ INITIALIZE VALUES LIST
        cmd.values = new List<Metadata.CustomMetadataValue>();

        // ✅ ADD contentDocumentId FIELD
        Metadata.CustomMetadataValue fileVal = new Metadata.CustomMetadataValue();
        fileVal.field = 'PFX_ContentVersionId__c';  // Must match API name exactly
        fileVal.value = String.valueOf(cv.Id);
        cmd.values.add(fileVal);

        // ✅ ADD Password FIELD
        Metadata.CustomMetadataValue pwdVal = new Metadata.CustomMetadataValue();
        pwdVal.field = 'PFX_Password__c';  // Must match API name exactly
        pwdVal.value = password;
        cmd.values.add(pwdVal);

        // ✅ ADD METADATA TO CONTAINER
        dc.addMetadata(cmd);

        if (!Test.isRunningTest()) {
            Id jobId = Metadata.Operations.enqueueDeployment(
                dc,
                new DigitalSignCMDTCallback()
            );
            System.debug('Deployment Job ID: ' + jobId);
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<CertificateOption> getCertificates() {
        try {
            // Security check
            if (!Schema.sObjectType.Digital_Sign_Config__mdt.isAccessible()) {
                throw new AuraHandledException('Insufficient permissions to access Digital_Sign_Config__mdt.');
            }
            
            // Query configs with non-null ContentVersionIds only
            Digital_Sign_Config__mdt[] configs = [
                SELECT PFX_ContentVersionId__c, PFX_Password__c 
                FROM Digital_Sign_Config__mdt 
                WHERE PFX_ContentVersionId__c != null
            ];
            
            if (configs.isEmpty()) {
                return new List<CertificateOption>();
            }
            
            // Extract ContentVersion IDs directly during iteration
            Set<Id> contentVersionIds = new Set<Id>();
            for (Digital_Sign_Config__mdt config : configs) {
                contentVersionIds.add(config.PFX_ContentVersionId__c);
            }
            
            // Query ContentVersions and build map in one step
            Map<Id, String> contentVersionTitleMap = new Map<Id, String>();
            for (ContentVersion cv : [SELECT Id, Title FROM ContentVersion WHERE Id IN :contentVersionIds]) {
                contentVersionTitleMap.put(cv.Id, cv.Title);
            }
            
            // Build options list
            List<CertificateOption> options = new List<CertificateOption>();
            for (Digital_Sign_Config__mdt config : configs) {
                String title = contentVersionTitleMap.get(config.PFX_ContentVersionId__c);
                if (title != null) {
                    options.add(new CertificateOption(title, config.PFX_ContentVersionId__c));
                }
            }
            
            return options;
            
        } catch (Exception e) {
            throw new AuraHandledException('Unable to retrieve certificates: ' + e.getMessage());
        }
    }
}