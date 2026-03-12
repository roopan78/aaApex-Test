public with sharing class QuickActionDeployer {
  public class QuickActionInput {
    public String objectApiName;
    public String label;
    public String componentName;
    public String actionType;
    public String builderType; //VD 10-Oct25 button Invoke changes
    // VD 13Nov25 button invoke changes
    public String description;
    public String buttonType;
    public String title;
    public String templateId; // templateId
    public String questionBookId; // Added missed required variable
    public String eventMode; // 'createNew' or 'override'
    public String buttonToOverride; // 'New', 'View', 'Edit', etc. (used in override)
    public Boolean skipRecordTypeSelect = false; // override-specific
    public String formFactor = 'Large'; // override-specific
  }

  public static MetadataServiceHelper.DeployOptions getDeployOptions() {
    MetadataServiceHelper.DeployOptions options = new MetadataServiceHelper.DeployOptions();
    options.allowMissingFiles = false;
    options.autoUpdatePackage = true;
    options.checkOnly = false;
    options.ignoreWarnings = true;
    options.performRetrieve = false;
    options.purgeOnDelete = false;
    options.rollbackOnError = true;
    options.runTests = new List<String>{};
    options.singlePackage = true;
    options.testLevel = 'NoTestRun';
    return options;
  }
  // VD 13Nov25 button invoke changes - removed actionxml used createCustomButton method

  public static String getOverridePackageXml(String objectApiName) {
    return '<?xml version="1.0" encoding="UTF-8"?>' +
      '<Package xmlns="http://soap.sforce.com/2006/04/metadata">' +
      '    <types>' +
      '        <members>' +
      objectApiName +
      '</members>' +
      '        <name>CustomObject</name>' +
      '    </types>' +
      '    <version>61.0</version>' +
      '</Package>';
  }

  // Metadata XML for standard button override
    public static String getOverrideMetadata(QuickActionInput input) {
    return '<?xml version="1.0" encoding="UTF-8"?>' +
      '<CustomObject xmlns="http://soap.sforce.com/2006/04/metadata">' +
      '    <actionOverrides>' +
      '        <actionName>' +
      input.buttonToOverride +
      '</actionName>' +
      '        <comment>' +
      input.description +
      '</comment>' +
      '        <content>' +
      input.componentName +
      '</content>' +
      '        <formFactor>' +
      input.formFactor +
      '</formFactor>' +
      '        <skipRecordTypeSelect>false</skipRecordTypeSelect>' +
      '        <type>' +
      input.actionType +
      '</type>' +
      '    </actionOverrides>' +
      '</CustomObject>';
}

  public static String generateZip(QuickActionInput input) {
    Zippex zip = new Zippex();
    String actionApiName = input.label.trim().replaceAll('[^A-Za-z0-9_]', '_');
// VD 13Nov25 button invoke changes - for create new button used createCustomButton method
    if (input.eventMode == 'override') {
      zip.addFile(
        'package.xml',
        Blob.valueOf(getOverridePackageXml(input.objectApiName)),
        null
      );
      zip.addFile(
        'objects/' + input.objectApiName + '.object-meta.xml',
        Blob.valueOf(getOverrideMetadata(input)),
        null
      );
    }
    return EncodingUtil.base64Encode(zip.getZipArchive());
  }
// VD 08May25 standard button override changes
  // VD 09May25 model title changes
  // // VD 13Nov25 button invoke changes - added Create new custom button part
  // VD 13-Oct25 button Invoke changes
  public static String getAuraComponentMarkup(QuickActionInput input) {
    String templateId = input.templateId != null ? input.templateId : '';
    String title = input.title != null ? input.title : '';
    String builderType = input.builderType != null ? input.builderType : 'Form Builder';

    System.debug('⚙️ Aura Create → BuilderType: ' + builderType + ', EventMode: ' + input.eventMode + ', ButtonType: ' + input.buttonType + ', TemplateId: ' + templateId);

    // ⚙️ SPA BUILDER PATH
    if (builderType == 'SPA Builder') {
        if (input.eventMode == 'Override') {
            return '<aura:component implements="force:hasRecordId,lightning:actionOverride,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
                '    <aura:attribute name="recordId" type="String"/>\n' +
                '    <aura:attribute name="isActive" type="Boolean" default="true" />\n' +
                '    <aura:attribute name="formId" type="String" default="' + templateId + '"/>\n' +
                '    <rnxt:invokemodel title="' + title + '" isActive="{!v.isActive}">\n' +
                '        <rnxt:spa formId="{!v.formId}" recordId="{!v.recordId}" onhandlesave="{!c.handleSave}" onhandleaction="{!c.handleAction}" />\n' +
                '    </rnxt:invokemodel>\n' +
                '</aura:component>';
        } 
        else if (input.eventMode == 'createNew' && input.buttonType == 'DetailPage') {
            return '<aura:component implements="force:hasRecordId,lightning:isUrlAddressable,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
                '    <aura:attribute name="recordId" type="String"/>\n' +
                '    <aura:attribute name="isActive" type="Boolean" default="true" />\n' +
                '    <aura:attribute name="formId" type="String" default="' + templateId + '"/>\n' +
                '    <aura:attribute name="pageReference" type="Object"/>\n' +
                '    <aura:handler name="change" value="{!v.pageReference}" action="{!c.onPageReferenceChange}"/>\n' +
                '    <rnxt:invokemodel title="' + title + '" isActive="{!v.isActive}">\n' +
                '        <rnxt:spa formId="{!v.formId}" recordId="{!v.recordId}" onhandlesave="{!c.handleSave}" onhandleaction="{!c.handleAction}" />\n' +
                '    </rnxt:invokemodel>\n' +
                '</aura:component>';
        } 
        else if (input.eventMode == 'createNew' && input.buttonType == 'List') {
            return '<aura:component implements="lightning:isUrlAddressable,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
                '    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>\n' +
                '    <aura:attribute name="formId" type="String" default="' + templateId + '"/>\n' +
                '    <aura:attribute name="pageReference" type="Object"/>\n' +
                '    <aura:handler name="change" value="{!v.pageReference}" action="{!c.onPageReferenceChange}"/>\n' +
                '    <lightning:card title="' + title + '">\n' +
                '        <rnxt:spa formId="{!v.formId}" onhandlesave="{!c.handleSave}" onhandleaction="{!c.handleAction}" />\n' +
                '    </lightning:card>\n' +
                '</aura:component>';
        } 
        else {
            throw new AuraHandledException('Unsupported SPA Builder mode or buttonType combination');
        }
    }

    // ⚙️ FORM BUILDER PATH (existing logic)
    if (input.eventMode == 'Override') {
        return '<aura:component implements="force:hasRecordId,lightning:actionOverride,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
            '    <aura:attribute name="recordId" type="String" />\n' +
            '    <aura:attribute name="isActive" type="Boolean" default="true" />\n' +
            '    <aura:attribute name="questionBookId" type="String" default="' + templateId + '" />\n' +
            '    <aura:html tag="style">.slds-modal__footer { display: none !important; }</aura:html>\n' +
            '    <rnxt:invokemodel title="' + title + '" isActive="{!v.isActive}">\n' +
            '        <rnxt:booklet recordId="{!v.questionBookId}" onhandlesubmit="{!c.handleSave}" onhandlebookletaction="{!c.handleAction}" />\n' +
            '    </rnxt:invokemodel>\n' +
            '</aura:component>';
    } 
    else if (input.eventMode == 'createNew' && input.buttonType == 'DetailPage') {
        return '<aura:component implements="force:hasRecordId,lightning:isUrlAddressable,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
            '    <aura:attribute name="recordId" type="String" />\n' +
            '    <aura:attribute name="isActive" type="Boolean" default="true" />\n' +
            '    <aura:attribute name="questionBookId" type="String" default="' + templateId + '" />\n' +
            '    <aura:attribute name="pageReference" type="Object"/>\n' +
            '    <aura:handler name="change" value="{!v.pageReference}" action="{!c.onPageReferenceChange}"/>\n' +
            '    <aura:html tag="style">.slds-modal__footer { display: none !important; }</aura:html>\n' +
            '    <rnxt:invokemodel title="' + title + '" isActive="{!v.isActive}">\n' +
            '        <rnxt:booklet recordId="{!v.questionBookId}" onhandlesubmit="{!c.handleSave}" onhandlebookletaction="{!c.handleAction}" />\n' +
            '    </rnxt:invokemodel>\n' +
            '</aura:component>';
    } 
    else if (input.eventMode == 'createNew' && input.buttonType == 'List') {
        return '<aura:component implements="force:hasRecordId,lightning:isUrlAddressable,flexipage:availableForAllPageTypes,force:lightningQuickAction" access="global">\n' +
            '    <aura:handler name="init" value="{!this}" action="{!c.doInit}" />\n' +
            '    <aura:attribute name="recordId" type="String"/>\n' +
            '    <aura:attribute name="isActive" type="Boolean" default="true" />\n' +
            '    <aura:attribute name="pageReference" type="Object"/>\n' +
            '    <aura:handler name="change" value="{!v.pageReference}" action="{!c.onPageReferenceChange}"/>\n' +
            '    <lightning:card title="' + title + '">\n' +
            '        <aura:if isTrue="{!v.isActive}">\n' +
            '            <rnxt:booklet recordId="' + templateId + '" onhandlesubmit="{!c.handleSave}" onhandlebookletaction="{!c.handleAction}" />\n' +
            '        </aura:if>\n' +
            '    </lightning:card>\n' +
            '</aura:component>';
    } 
    else {
        throw new AuraHandledException('Unsupported Form Builder mode or buttonType combination');
    }
}
// VD 13-Oct25 button Invoke changes
// RT 13OCT25 - Voided
  public static String getAuraComponentController(String eventMode) {
    // RT 13OCT25 - Voided
    return '';
  }

  // RT 13OCT25 - Cloned and In use
  // VD 29OCT25 edit issue fix
  public static String getAuraComponentControllerCloned(String eventMode,String builderType) {

    if (builderType == 'SPA Builder') {
      if (eventMode == 'createNew') {
        return '({\n' +
        '    doInit: function(component, event, helper) {\n' +
        '        // Optional init logic\n' +
        '    },\n' +
        '    onPageReferenceChange: function(component, event, helper) {\n' +
        '        console.log("Page reference changed");\n' +
        '        var pageRef = component.get("v.pageReference");\n' +
        '        if (pageRef && pageRef.state && pageRef.state.c__recordId) {\n' +
        '            component.set("v.recordId", pageRef.state.c__recordId);\n' +
        '        }\n' +
        '        component.set("v.isActive", true);\n' +
        '    },\n' +
        '    handleSave: function(component, event, helper) {\n' +
        '        var eventResult = event.getParam("result");\n' +
        '        if (eventResult && eventResult.status === "success") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    },\n' +
        '    handleAction: function(component, event, helper) {\n' +
        '        var action = event.getParam("action");\n' +
        '        if (action == "Cancel") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    }\n' +
        '})';
      } else {
        return '({\n' +
        '    startForm: function(component, event, helper) {\n' +
        '        const inputVal = component.get("v.formId");\n' +
        '        if (!inputVal) {\n' +
        '            alert("Please enter a Form ID.");\n' +
        '            return;\n' +
        '        }\n' +
        '    },\n' +
        '    handleSave: function(component, event, helper) {\n' +
        '        var eventResult = event.getParam("result");\n' +
        '        if (eventResult && eventResult.status === "success") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    },\n' +
        '    handleAction: function(component, event, helper) {\n' +
        '        var action = event.getParam("action");\n' +
        '        if (action == "Cancel") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    }\n' +
        '})';
      }
  }
    if (eventMode == 'createNew') {
      // VD 29OCT25 edit issue fix
      return '({\n' +
        '    doInit: function(component, event, helper) {\n' +
        '        // Optional init logic\n' +
        '    },\n' +
        '    onPageReferenceChange: function(component, event, helper) {\n' +
        '        console.log("Page reference changed");\n' +
        '        var pageRef = component.get("v.pageReference");\n' +
        '        if (pageRef && pageRef.state && pageRef.state.c__recordId) {\n' +
        '            component.set("v.recordId", pageRef.state.c__recordId);\n' +
        '        }\n' +
        '        component.set("v.isActive", true);\n' +
        '    },\n' +
        '    handleSave: function(component, event, helper) {\n' +
        '        var eventData = event.getParam("data");\n' +
        '        if (eventData && eventData.status.RNXT__Status__c === "Completed") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    },\n' +
        '    handleAction: function(component, event, helper) {\n' +
        '        var action = event.getParam("action");\n' +
        '        if(action == "close"){\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    }\n' +
        '})';
    } else {
      return '({\n' +
        '    startBooklet: function(component, event, helper) {\n' +
        '        const inputVal = component.get("v.questionBookId");\n' +
        '        if (!inputVal) {\n' +
        '            alert("Please enter a Question Book ID.");\n' +
        '            return;\n' +
        '        }\n' +
        '    },\n' +
        '    handleSave: function(component, event, helper) {\n' +
        '        var eventData = event.getParam("data");\n' +
        '        if (eventData && eventData.status.Status__c === "Completed") {\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    },\n' +
        '    handleAction: function(component, event, helper) {\n' +
        '        var action = event.getParam("action");\n' +
        '        if(action == "close"){\n' +
        '            component.set("v.isActive", false);\n' +
        '            window.history.back();\n' +
        '        }\n' +
        '    }\n' +
        '})';
    }
  }


  public static String getAuraMetaXml(String componentName) {
    return '<?xml version="1.0" encoding="UTF-8"?>\n' +
      '<AuraDefinitionBundle xmlns="http://soap.sforce.com/2006/04/metadata">\n' +
      '    <apiVersion>61.0</apiVersion>\n' +
      '    <description>Auto-generated component for standard button override</description>\n' +
      '    <isExposed>true</isExposed>\n' +
      '</AuraDefinitionBundle>';
  }

  // RT 13OCT25 - added missed methods.
  public static MetadataService.MetadataPort createService() {
    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataServiceHelper.SessionHeader_element();
    service.SessionHeader.sessionId = UserInfo.getSessionId();
    return service;
  }

  // @AuraEnabled
  // public static String deployQuickAction(String inputJson) {
  //   // VD 14OCT25 exception handling
  //   try {
  //     String resultData = '';
  //     QuickActionInput input = (QuickActionInput) JSON.deserialize(
  //       inputJson,
  //       QuickActionInput.class
  //     );

  //     MetadataService.MetadataPort service = createMetadataService(); // VD 10-Oct25 button Invoke changes
  //     // VD 08May25 standard button override changes
  //     // VD 09May25 title changes
  //     // create Dynamic Aura component
  //     // // VD 13Nov25 new button invoke changes - result handling
  //     // Step 1: Deploy Aura component and wait
  //     String resultStatus = createAuraComponentNew(input);
  //     resultData = resultStatus;
  //     // Check for error in Aura deployment
  //     if (resultStatus == 'Failed') {
  //       return resultStatus;
  //     } else if (resultStatus == 'DUPLICATE_DEVELOPER_NAME') {
  //       return resultStatus;
  //     }

  //     // Step 2: Logic based on event mode
  //     if (input.eventMode == 'createNew') {
  //       // Create a custom button (List or Detail)
  //       String buttonResult = createCustomButton(input);
  //       resultData = buttonResult;
  //       if (buttonResult == 'Failed') {
  //         return buttonResult;
  //       }
  //     } else if (input.eventMode == 'Override') {
  //       // Proceed with standard button override deployment
  //       String zipBase64 = generateZip(input);
  //       MetadataServiceHelper.AsyncResult asyncResult = service.deploy(
  //         zipBase64,
  //         getDeployOptions()
  //       );

  //       MetadataService.DeployResult result = service.checkDeployStatus(
  //         asyncResult.id,
  //         true
  //       );
  //       System.debug('Deploy Success: ' + result.success);
  //       System.debug('Deploy Status: ' + result.status);
  //       resultData = result.status;
  //       return result.status;
  //       } else {
  //         return 'Unsupported eventMode: ' + input.eventMode;
  //       }
  //       return resultData;
  //   } catch (Exception ex) {
  //     // Generic fallback
  //     System.debug('❌ Unexpected Exception: ' + ex.getMessage() + ' | Stack: ' + ex.getStackTraceString());
  //     throw new AuraHandledException('Deployment failed: ' + ex.getMessage());
  // }
    
  // }

@AuraEnabled
public static String deployQuickAction(String inputJson) {
    try {
        QuickActionInput input = (QuickActionInput) JSON.deserialize(inputJson, QuickActionInput.class);

        // Step 1: Deploy Aura component
        String auraResult = createAuraComponentNew(input);

        // Parse JSON to check status
        Map<String, Object> auraResultMap = (Map<String,Object>) JSON.deserializeUntyped(auraResult);
        if (auraResultMap.get('status') != 'Succeeded') {
            return auraResult; // Return structured JSON directly to LWC
        }

        // Step 2: Deploy Button or Override
        if (input.eventMode == 'createNew') {
            String buttonResult = createCustomButton(input);
            if (buttonResult != 'Succeeded') {
                return JSON.serialize(new Map<String,Object>{
                    'status' => 'Failed',
                    'errors' => new List<String>{buttonResult}
                });
            }
        } else if (input.eventMode == 'Override') {
            MetadataService.MetadataPort service = createMetadataService();
            String zipBase64 = generateZip(input);
            MetadataServiceHelper.AsyncResult asyncResult = service.deploy(zipBase64, getDeployOptions());
            MetadataService.DeployResult result = service.checkDeployStatus(asyncResult.id, true);

            // System.debug('result-->'+ result);
            // System.debug('result.success-->'+ result.success);
            // System.debug('result.status-->'+ result.status);
            if (!result.success && result.status != 'Pending') {
              // Extract all error info from DeployResult dynamically
              List<String> deployErrors = new List<String>();

              // Check for any top-level errorMessage
              if (result.errorMessage != null && result.errorMessage != '') {
                  deployErrors.add(result.errorMessage);
              }
              if (result.details != null) {
                // Serialize details to JSON and parse to Map
                String jsonDetails = JSON.serialize(result.details);
                Map<String,Object> detailsMap = (Map<String,Object>) JSON.deserializeUntyped(jsonDetails);

                if (detailsMap.containsKey('componentFailures')) {
                    List<Object> failures = (List<Object>) detailsMap.get('componentFailures');
                    if(!failures.isEmpty()){
                      for (Object f : failures) {
                        Map<String,Object> failMap = (Map<String,Object>) f;
                        String problem = (String) failMap.get('problem');
                        String fullName = (String) failMap.get('fullName');
                        deployErrors.add((problem != null ? problem : 'Unknown problem') + 
                                         (fullName != null ? ' (' + fullName + ')' : ''));
                    }
                    }
                }
            }
              if (deployErrors.isEmpty()) {
                  deployErrors.add('Unknown deployment failure');
              }

              return JSON.serialize(new Map<String,Object>{
                  'status' => 'Failed',
                  'errors' => deployErrors
              });
          }
        } else {
            return JSON.serialize(new Map<String,Object>{
                'status' => 'Failed',
                'errors' => new List<String>{'Unsupported eventMode: ' + input.eventMode}
            });
        }

        // Success
        return JSON.serialize(new Map<String,Object>{'status' => 'Succeeded'});

    } catch (Exception ex) {
        System.debug('❌ Unexpected Exception: ' + ex.getMessage() + ' | Stack: ' + ex.getStackTraceString());
        throw new AuraHandledException('Deployment failed: ' + ex.getMessage());
    }
}


  // VD 08May25 standard button override changes
  // create Dynamic Aura component
  // VD 09May25 title changes
  // VD 13Nov25 new button invoke changes - updated method to handle new custom button

//   @AuraEnabled
//   public static String createAuraComponentNew(QuickActionInput input) {
//     String customizedName = input.componentName.replace(' ', '_');
//     input.componentName = customizedName;
//     // VD 10-Oct25 button Invoke changes
//     MetadataService.MetadataPort service = createMetadataService();
//     MetadataService.AuraDefinitionBundle auraBundle = new MetadataService.AuraDefinitionBundle();
//     auraBundle.fullName = customizedName;
//     auraBundle.type_x = 'Component';
//     auraBundle.markup = EncodingUtil.base64Encode(
//       Blob.valueOf(getAuraComponentMarkup(input))
//     );
// // VD 10-Oct25 button Invoke changes
//     auraBundle.controllerContent = EncodingUtil.base64Encode(
//       Blob.valueOf(getAuraComponentControllerCloned(input.eventMode,input.builderType))
//     );

//     List<MetadataService.SaveResult> results = service.createMetadata(
//       new List<MetadataService.Metadata>{ auraBundle }
//     );
//     MetadataService.SaveResult result = results[0];
//     if (result == null) {
//       return 'Failed';
//     } else if (result.success) {
//       return 'Succeeded';
//     } else if (result.errors != null && result.errors.size() > 0) {
//       for (MetadataService.Error error : result.errors) {
//         if (error.statusCode == 'DUPLICATE_DEVELOPER_NAME') {
//           return 'DUPLICATE_DEVELOPER_NAME';
//         }
//       }
//       // Other error(s)
//       return 'Failed';
//     } else {
//       return 'Failed';
//     }
//   }

@AuraEnabled
public static String createAuraComponentNew(QuickActionInput input) {
    try {
        if (input == null) {
            return JSON.serialize(new Map<String,Object>{
                'status' => 'Failed',
                'errors' => new List<String>{'Input cannot be null'}
            });
        }

        // Clean component name
        String customizedName = input.componentName.replace(' ', '_');
        input.componentName = customizedName;

        // Create MetadataService
        MetadataService.MetadataPort service = createMetadataService();

        // Prepare Aura Component bundle
        MetadataService.AuraDefinitionBundle auraBundle = new MetadataService.AuraDefinitionBundle();
        auraBundle.fullName = customizedName;
        auraBundle.type_x = 'Component';
        auraBundle.markup = EncodingUtil.base64Encode(Blob.valueOf(getAuraComponentMarkup(input)));
        auraBundle.controllerContent = EncodingUtil.base64Encode(
            Blob.valueOf(getAuraComponentControllerCloned(input.eventMode, input.builderType))
        );

        // Call Metadata API to create component
        List<MetadataService.SaveResult> results = service.createMetadata(
            new List<MetadataService.Metadata>{ auraBundle }
        );

        MetadataService.SaveResult result = results[0];

        if (result == null) {
            return JSON.serialize(new Map<String,Object>{
                'status' => 'Failed',
                'errors' => new List<String>{'No result returned from Metadata API'}
            });
        }

        if (result.success) {
            return JSON.serialize(new Map<String,Object>{
                'status' => 'Succeeded'
            });
        }

        // Collect all errors
        List<String> errorMessages = new List<String>();
        if (result.errors != null && !result.errors.isEmpty()) {
            for (MetadataService.Error error : result.errors) {
                System.debug('Metadata API Error: ' + error.message + ' | Status: ' + error.statusCode);
                if (error.statusCode == 'DUPLICATE_DEVELOPER_NAME') {
                    errorMessages.add('Duplicate component name "' + customizedName + '"');
                } else {
                    errorMessages.add(error.statusCode + ': ' + error.message);
                }
            }
        } else {
            errorMessages.add('Unknown deployment failure');
        }

        return JSON.serialize(new Map<String,Object>{
            'status' => 'Failed',
            'errors' => errorMessages
        });

    } catch (Exception ex) {
        System.debug('❌ Exception in createAuraComponentNew: ' + ex.getMessage() + ' | Stack: ' + ex.getStackTraceString());
        return JSON.serialize(new Map<String,Object>{
            'status' => 'Exception',
            'errors' => new List<String>{ex.getMessage()}
        });
    }
}



// VD 10-Oct25 button Invoke changes
  private static MetadataService.MetadataPort createMetadataService() {
    PageReference vfPage = Page.GetSessionId;
    String sessionId = Utils.getSessionIdFromVFPage(vfPage);
    if (String.isBlank(sessionId)) {
      throw new AuraHandledException('❌ Unable to retrieve Session ID');
    }

    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataServiceHelper.SessionHeader_element();
    service.SessionHeader.sessionId = sessionId;
    return service;
  }

  // // VD 13Nov25 button invoke changes - new method to create custom button
  @AuraEnabled
  public static String createCustomButton(QuickActionInput input) {
    try {
      String displayType = input.buttonType == 'DetailPage'
        ? 'button'
        : 'massActionButton';
      String componentName = input.componentName.replace(' ', '_');
      // VD 29OCT25 Dynamically create merge field for recordId
      String buttonURL = '/lightning/cmp/c__' + componentName;
      // Append recordId param ONLY for Detail Page buttons
      if (input.buttonType == 'DetailPage') {
        String recordIdMergeField = '{!' + input.objectApiName + '.Id}';
        buttonURL += '?c__recordId=' + recordIdMergeField;
      }
      MetadataService.MetadataPort service = createMetadataService();
      MetadataService.WebLink webLink = new MetadataService.WebLink();
      String customizedName = input.label.replace(' ', '_');
      webLink.fullName = input.objectApiName + '.' + customizedName;
      webLink.availability = 'online';
      webLink.displayType = displayType;
      webLink.linkType = 'url';
      webLink.url = buttonURL;
      webLink.encodingKey = 'UTF-8';
      webLink.masterLabel = input.label;
      webLink.description = input.description;
      webLink.openType = 'newWindow';
      webLink.position = 'none';
      webLink.width = 600;
      webLink.protected_x = false;

      List<MetadataService.UpsertResult> results = service.upsertMetadata(
        new List<MetadataService.Metadata>{ webLink }
      );

      if (results != null && !results.isEmpty()) {
        if (results[0].success) {
          return 'Succeeded';
        } else {
          return 'Failed';
          // System.debug('error-->'+ results[0].errors[0].message);
        }
      }
      return 'Unknown error occurred.';
    } catch (Exception ex) {
      return 'Exception: ' + ex.getMessage();
    }
  }
// VD 10-Oct25 button Invoke changes
  @AuraEnabled
  public static String createDetailPageButton(String inputJson) {
    try {
        // Deserialize JSON
        Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(inputJson);

        String objectApiName = (String) inputMap.get('objectApiName');
        String label = (String) inputMap.get('label');
        String buttonName = (String) inputMap.get('buttonName');
        String buttonType = (String) inputMap.get('buttonType');
        String url = (String) inputMap.get('url');
        String description = (String) inputMap.get('description');

        if (String.isBlank(objectApiName) || String.isBlank(url) || String.isBlank(buttonName)) {
            return '❌ Missing required fields: objectApiName, url, or buttonName';
        }

        // Determine display type
        String displayType = buttonType == 'DetailPage' ? 'button' : 'massActionButton';

        // MetadataService setup
        MetadataService.MetadataPort service = createMetadataService();
        MetadataService.WebLink webLink = new MetadataService.WebLink();
        String customizedName = String.isNotBlank(buttonName) ? buttonName.replace(' ', '_') : label;
        webLink.fullName = objectApiName + '.' + customizedName;
        webLink.availability = 'online';
        webLink.displayType = displayType;
        webLink.linkType = 'url';
        webLink.url = url;
        webLink.encodingKey = 'UTF-8';
        webLink.masterLabel = String.isNotBlank(label) ? label : buttonName;
        webLink.description = description;
        webLink.openType = 'newWindow';
        webLink.position = 'none';
        webLink.width = 600;
        webLink.protected_x = false;

        // Deploy
        List<MetadataService.UpsertResult> results = service.upsertMetadata(
            new List<MetadataService.Metadata>{ webLink }
        );

        if (!results.isEmpty()) {
            MetadataService.UpsertResult result = results[0];
            if (result.success) return 'SUCCESS: ' + webLink.fullName;
            else if (!result.errors.isEmpty()) return 'ERROR: ' + result.errors[0].message;
        }

        return '⚠️ Unknown error occurred.';
    } catch (Exception ex) {
        return '❌ Exception: ' + ex.getMessage();
    }
  }

}