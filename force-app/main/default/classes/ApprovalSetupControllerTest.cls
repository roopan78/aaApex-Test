@isTest
public class ApprovalSetupControllerTest {
    
    @testSetup
    static void setup() {
        // Create test data
        Notification_Config__c config = new Notification_Config__c(
            Name = 'Test Config',
            Is_Active__c = true,
            Object_Name__c = 'Account',
            Trigger_Name__c = 'TestTrigger',
            Approval_Step__c = 'Step1',
            Do_you_want_to_create_a_trigger__c = true
        );
        insert config;
        
        // Create Action Template
        Action_Template__c parentTemplate = new Action_Template__c(
            Name = 'Parent Template',
            Flow_Type__c = 'Sequential'
        );
        insert parentTemplate;
        
        Action_Template__c childTemplate = new Action_Template__c(
            Name = 'Child Template',
            Parent_Action_Template__c = parentTemplate.Id,
            Is_Active__c = true,
            Is_Optional__c = false,
            Order__c = 1,
            Action_Owner_Type__c = 'User',
            Action_Owner__c = UserInfo.getUserId()
        );
        insert childTemplate;
        
        // Create Action Center Template
        Action_Center_Template__c actionCenter = new Action_Center_Template__c(
            Name = 'Test Action Center',
            Object_Name__c = 'Account',
            Is_Active__c = true,
            Task_Subject__c = 'Test Task',
            Task_Comments__c = 'Test Comments',
            Post_to_Chatter_Email__c = true,
            Post_to_Chatter_Push_Notification__c = false,
            Email_Body__c = 'Test Email Body',
            Email_Subject__c = 'Test Email Subject',
            Notification_Title__c = 'Test Notification',
            Notification_Body__c = 'Test Body',
            Post_Body__c = 'Test Post'
        );
        insert actionCenter;
        
        // Create Question Book and Question for Field Meta
        Question_Book__c qBook = new Question_Book__c(Title__c = 'Test Book');
        insert qBook;
        Question__c question = new Question__c(Question_No__c = 1, Question_Book__c = qBook.Id);
        insert question;
        
        // Create Notification Process Config
        Notification_Process_Config__c processConfig = new Notification_Process_Config__c(
            Name = 'Test Process Config',
            Status__c = 'Approved',
            Notification_Config__c = config.Id,
            Is_Active__c = true,
            Order__c = 1,
            Action_Template__c = parentTemplate.Id,
            Action_Center_Template__c = actionCenter.Id
        );
        insert processConfig;
        
        // Create Field Metas
        List<Field_Meta__c> fieldMetas = new List<Field_Meta__c>{
            new Field_Meta__c(
                Api_Name__c = 'Name',
                Object_Name__c = 'Account',
                Order__c = 1,
                RecordTypeId = Schema.SObjectType.Field_Meta__c.getRecordTypeInfosByName().get('Query Builder').getRecordTypeId(),
                fld_type__c = 'Text',
                Is_Active__c = true,
                Operation_Type__c = 'Updateable',
                Logical_Criteria__c = 'AND',
                Condition__c = 'Equals',
                FilterValue__c = 'Test',
                Question__c = question.Id,
                Notification_Process_Config__c = processConfig.Id
            ),
            new Field_Meta__c(
                Api_Name__c = 'Type',
                Object_Name__c = 'Account',
                Order__c = 2,
                fld_type__c = 'Text',
                Is_Active__c = true,
                Question__c = question.Id,
                Action_Center_Template__c = actionCenter.Id
            )
        };
        insert fieldMetas;
    }
    @isTest
    static void testAllMethods() {
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        
        // Test fetchConfig
        ApprovalSetupController.ConfigWrapper fetchedConfig = ApprovalSetupController.fetchConfig(config.Id);
        
        // Test saveConfig with existing record
        ApprovalSetupController.ConfigWrapper wrapper = new ApprovalSetupController.ConfigWrapper();
        wrapper.id = config.Id;
        wrapper.name = 'Updated Config';
        wrapper.isActive = false;
        wrapper.objectApiName = 'Contact';
        wrapper.triggerName = 'UpdatedTrigger';
        wrapper.createTrigger = false;
        
        String jsonInput = JSON.serialize(wrapper);
        Id savedId = ApprovalSetupController.saveConfig(jsonInput);
        
        // Test saveConfig with new record
        wrapper.id = null;
        wrapper.name = 'New Config';
        jsonInput = JSON.serialize(wrapper);
        Id newId = ApprovalSetupController.saveConfig(jsonInput);
        
        // Test updateApprovalStep
        Id updatedId = ApprovalSetupController.updateApprovalStep('Step2', config.Id);
        
        // Test getProcessConfig with data
        String processConfigJson = ApprovalSetupController.getProcessConfig(config.Id, 'Submitted For Approval');
        
        // Test getProcessConfig with no data
        String emptyConfigJson = ApprovalSetupController.getProcessConfig(config.Id, 'NonExistent');
        
        // Test saveProcessConfig - prepare complex wrapper
        ConfigProcessWrapper processWrapper = new ConfigProcessWrapper();
        processWrapper.processConfig = new List<ConfigProcessWrapper.ProcessConfigWrapper>();
        
        ConfigProcessWrapper.ProcessConfigWrapper pc = new ConfigProcessWrapper.ProcessConfigWrapper();
        pc.id = null; // New record
        pc.configName = 'New Process Config';
        pc.status = 'Submitted for Approval';
        pc.isActive = true;
        pc.order = 2;
        
        // Template Config
       ConfigProcessWrapper.TemplateConfigWrapper templateConfig = 
            new ConfigProcessWrapper.TemplateConfigWrapper();
        
        // Action Template
        ConfigProcessWrapper.ActionTemplateWrapper actionTemplate = 
            new ConfigProcessWrapper.ActionTemplateWrapper();
        actionTemplate.id = null;
        actionTemplate.name = 'New Action Template';
        actionTemplate.flowType = 'Parallel';
        actionTemplate.templates = new List<ConfigProcessWrapper.TemplateWrapper>();
        
        ConfigProcessWrapper.TemplateWrapper template = 
            new ConfigProcessWrapper.TemplateWrapper();
        template.id = null;
        template.name = 'New Child Template';
        template.isActive = true;
        template.isOptional = true;
        template.order = 1;
        template.actionOwnerType = 'Queue';
        template.actionOwnerName = 'TestQueue';
        template.parentActionTemplateId = null;
        
        actionTemplate.templates.add(template);
        templateConfig.actionTemplate = actionTemplate;
        
        // Action Center Template
        ConfigProcessWrapper.ActionCenterTemplateWrapper actionCenter = 
            new ConfigProcessWrapper.ActionCenterTemplateWrapper();
        actionCenter.id = null;
        actionCenter.name = 'New Action Center';
        actionCenter.objectApiName = 'Contact';
        actionCenter.isActive = true;
        actionCenter.taskSubject = 'New Task';
        actionCenter.taskComments = 'New Comments';
        actionCenter.isPostChatterEmail = false;
        actionCenter.isPostChatterPushNotification = true;
        actionCenter.emailBody = 'New Email Body';
        actionCenter.emailSubject = 'New Email Subject';
        actionCenter.notificationTitle = 'New Title';
        actionCenter.notificationBody = 'New Body';
        actionCenter.postBody = 'New Post';
        actionCenter.fieldMetas = new List<ConfigProcessWrapper.FieldMetaWrapper>();
        
        // Field Meta for Action Center
        ConfigProcessWrapper.FieldMetaWrapper fieldMeta = 
            new ConfigProcessWrapper.FieldMetaWrapper();
        fieldMeta.id = null;
        fieldMeta.apiName = 'Email';
        fieldMeta.objectApiName = 'Contact';
        fieldMeta.order = 1;
        fieldMeta.recordType = 'Query Builder';
        fieldMeta.type = 'Text';
        fieldMeta.isActive = true;
        fieldMeta.operationalType = 'Updateable';
        fieldMeta.logicalCriteria = 'OR';
        fieldMeta.condition = 'Equals';
        fieldMeta.filterValue = '@test.com';
        
        actionCenter.fieldMetas.add(fieldMeta);
        templateConfig.actionCenterTemplate = actionCenter;
        
        pc.templateConfig = templateConfig;
        
        // Field Metas for Process Config
        pc.fieldMetas = new List<ConfigProcessWrapper.FieldMetaWrapper>();
       	ConfigProcessWrapper.FieldMetaWrapper pcFieldMeta = 
            new ConfigProcessWrapper.FieldMetaWrapper();
        pcFieldMeta.id = null;
        pcFieldMeta.apiName = 'Phone';
        pcFieldMeta.objectApiName = 'Contact';
        pcFieldMeta.order = 2;
        pcFieldMeta.recordType = 'Query Builder';
        pcFieldMeta.type = 'Text';
        pcFieldMeta.isActive = false;
        pcFieldMeta.question = null; // This will trigger getMocQuestion
        
        pc.fieldMetas.add(pcFieldMeta);
        processWrapper.processConfig.add(pc);
        
        String wrapperJson = JSON.serialize(processWrapper);
        ApprovalSetupController.saveProcessConfig(wrapperJson, config.Id);
        
        // Test with null wrapper
        ApprovalSetupController.saveProcessConfig('{}', config.Id);
        
        // Test exception scenarios to cover catch blocks
        try {
            ApprovalSetupController.getProcessConfig(null, 'Approved');
        } catch (Exception e) {
            // Expected exception
        }
        
        // Create a wrapper that will cause DML exception due to required field missing
        ConfigProcessWrapper exceptionWrapper = new ConfigProcessWrapper();
        exceptionWrapper.processConfig = new List<ConfigProcessWrapper.ProcessConfigWrapper>();
        
        ConfigProcessWrapper.ProcessConfigWrapper errorPc = new ConfigProcessWrapper.ProcessConfigWrapper();
        errorPc.id = null;
        errorPc.configName = null; // This will cause DML exception as Name is required
        errorPc.status = 'Submitted for Approval';
        errorPc.isActive = true;
        errorPc.order = 1;
        
        exceptionWrapper.processConfig.add(errorPc);
        String exceptionJson = JSON.serialize(exceptionWrapper);
        
        try {
            ApprovalSetupController.saveProcessConfig(exceptionJson, config.Id);
        } catch (AuraHandledException e) {
            // This covers the catch block in saveProcessConfig
            System.debug('Expected AuraHandledException: ' + e.getMessage());
        }
        
         try {
            ApprovalSetupController.getProcessConfig(null, 'Approved');
        } catch (Exception e) {
            // Expected exception
        }
        
        // Assertions - only two as requested
        System.assertNotEquals(null, fetchedConfig.id, 'Config should be fetched successfully');
        System.assertNotEquals(null, savedId, 'Config should be saved successfully');
    }
    @IsTest
    static void testGetProcessConfigSuccess() {
        // Get test data
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'Approved');
        Test.stopTest();
        
        // Verify result is not null and contains data
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertNotEquals('', result, 'Result should not be empty');
        
        // Deserialize and verify structure
        ConfigProcessWrapper wrapper = (ConfigProcessWrapper) JSON.deserialize(result, ConfigProcessWrapper.class);
        System.assertNotEquals(null, wrapper, 'Wrapper should not be null');
        System.assertNotEquals(null, wrapper.processConfig, 'ProcessConfig list should not be null');
        System.assertEquals(1, wrapper.processConfig.size(), 'Should have one process config');
        
        ConfigProcessWrapper.ProcessConfigWrapper pc = wrapper.processConfig[0];
        
        // Verify ProcessConfigWrapper fields
        System.assertEquals('Approved', pc.status, 'Status should match');
        System.assertEquals('Test Process Config', pc.configName, 'Config name should match');
        System.assertEquals(true, pc.isActive, 'Should be active');
        System.assertEquals(1, pc.order, 'Order should be 1');
        System.assertNotEquals(null, pc.actionTemplateId, 'Action template ID should not be null');
        System.assertNotEquals(null, pc.actionCenterTemplateId, 'Action center template ID should not be null');
        
        // Verify Field Metas
        System.assertNotEquals(null, pc.fieldMetas, 'Field metas should not be null');
        System.assertEquals(1, pc.fieldMetas.size(), 'Should have one field meta for process config');
        
        ConfigProcessWrapper.FieldMetaWrapper fieldMeta = pc.fieldMetas[0];
        System.assertEquals('Name', fieldMeta.apiName, 'API name should match');
        System.assertEquals('Account', fieldMeta.objectApiName, 'Object name should match');
        System.assertEquals(1, fieldMeta.order, 'Order should be 1');
        System.assertEquals('Text', fieldMeta.type, 'Type should be Text');
        System.assertEquals(true, fieldMeta.isActive, 'Should be active');
        System.assertEquals('Query Builder', fieldMeta.recordType, 'Record type should be Query Builder');
        
        // Verify Template Config
        System.assertNotEquals(null, pc.templateConfig, 'Template config should not be null');
        
        // Verify Action Template
        ConfigProcessWrapper.ActionTemplateWrapper actionTemplate = pc.templateConfig.actionTemplate;
        System.assertNotEquals(null, actionTemplate, 'Action template should not be null');
        System.assertEquals('Parent Template', actionTemplate.name, 'Template name should match');
        System.assertEquals('Sequential', actionTemplate.flowType, 'Flow type should match');
        System.assertNotEquals(null, actionTemplate.templates, 'Child templates should not be null');
        System.assertEquals(1, actionTemplate.templates.size(), 'Should have one child template');
        
        ConfigProcessWrapper.TemplateWrapper childTemplate = actionTemplate.templates[0];
        System.assertEquals('Child Template', childTemplate.name, 'Child template name should match');
        System.assertEquals(true, childTemplate.isActive, 'Child template should be active');
        System.assertEquals(false, childTemplate.isOptional, 'Child template should not be optional');
        System.assertEquals(1, childTemplate.order, 'Child template order should be 1');
        System.assertEquals('User', childTemplate.actionOwnerType, 'Action owner type should be User');
        
        // Verify Action Center Template
        ConfigProcessWrapper.ActionCenterTemplateWrapper actionCenter = pc.templateConfig.actionCenterTemplate;
        System.assertNotEquals(null, actionCenter, 'Action center template should not be null');
        System.assertEquals('Test Action Center', actionCenter.name, 'Action center name should match');
        System.assertEquals('Account', actionCenter.objectApiName, 'Object API name should match');
        System.assertEquals(true, actionCenter.isActive, 'Action center should be active');
        System.assertEquals('Test Task', actionCenter.taskSubject, 'Task subject should match');
        System.assertEquals('Test Comments', actionCenter.taskComments, 'Task comments should match');
        System.assertEquals(true, actionCenter.isPostChatterEmail, 'Post to chatter email should be true');
        System.assertEquals(false, actionCenter.isPostChatterPushNotification, 'Post to chatter push should be false');
        System.assertEquals('Test Email Body', actionCenter.emailBody, 'Email body should match');
        System.assertEquals('Test Email Subject', actionCenter.emailSubject, 'Email subject should match');
        System.assertEquals('Test Notification', actionCenter.notificationTitle, 'Notification title should match');
        System.assertEquals('Test Body', actionCenter.notificationBody, 'Notification body should match');
        System.assertEquals('Test Post', actionCenter.postBody, 'Post body should match');
        
        // Verify Action Center Field Metas
        System.assertNotEquals(null, actionCenter.fieldMetas, 'Action center field metas should not be null');
        System.assertEquals(1, actionCenter.fieldMetas.size(), 'Should have one field meta for action center');
        
        ConfigProcessWrapper.FieldMetaWrapper acFieldMeta = actionCenter.fieldMetas[0];
        System.assertEquals('Type', acFieldMeta.apiName, 'Action center field meta API name should match');
        System.assertEquals('Account', acFieldMeta.objectApiName, 'Action center field meta object should match');
    }
    
    @IsTest
    static void testGetProcessConfigNoRecordFound() {
        // Get test data
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'Rejected');
        Test.stopTest();
        
        // Verify empty result structure
        System.assertNotEquals(null, result, 'Result should not be null');
        
        ConfigProcessWrapper wrapper = (ConfigProcessWrapper) JSON.deserialize(result, ConfigProcessWrapper.class);
        System.assertNotEquals(null, wrapper, 'Wrapper should not be null');
        System.assertNotEquals(null, wrapper.processConfig, 'ProcessConfig list should not be null');
        System.assertEquals(0, wrapper.processConfig.size(), 'Should have no process configs');
    }
    
    @IsTest
    static void testGetProcessConfigWithNullActionTemplate() {
        // Create a process config without Action Template
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        Action_Center_Template__c actionCenter = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        
        Notification_Process_Config__c processConfig = new Notification_Process_Config__c(
            Name = 'Test Process Config No AT',
            Status__c = 'Submitted for Approval',
            Notification_Config__c = config.Id,
            Is_Active__c = true,
            Order__c = 2,
            Action_Template__c = null,
            Action_Center_Template__c = actionCenter.Id
        );
        insert processConfig;
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'Pending');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetProcessConfigWithNullActionCenterTemplate() {
        // Create a process config without Action Center Template
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        Action_Template__c actionTemplate = [SELECT Id FROM Action_Template__c WHERE Parent_Action_Template__c = null LIMIT 1];
        
        Notification_Process_Config__c processConfig = new Notification_Process_Config__c(
            Name = 'Test Process Config No ACT',
            Status__c = 'Submitted for Approval',
            Notification_Config__c = config.Id,
            Is_Active__c = true,
            Order__c = 3,
            Action_Template__c = actionTemplate.Id,
            Action_Center_Template__c = null
        );
        insert processConfig;
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'Draft');
        Test.stopTest();
        
        // Verify result
    }
    
    @IsTest
    static void testGetProcessConfigWithNullRecordTypeFieldMeta() {
        // Create additional test data with null RecordType
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        
        Notification_Process_Config__c processConfig = new Notification_Process_Config__c(
            Name = 'Test Process Config Null RT',
            Status__c = 'Submitted for Approval',
            Notification_Config__c = config.Id,
            Is_Active__c = true,
            Order__c = 4
        );
        insert processConfig;
        
        Field_Meta__c fieldMeta = new Field_Meta__c(
            Api_Name__c = 'Industry',
            Object_Name__c = 'Account',
            Order__c = 3,
            fld_type__c = 'Text',
            Is_Active__c = true,
            Operation_Type__c = 'Updateable',
            Logical_Criteria__c = 'OR',
            Condition__c = 'Equals',
            FilterValue__c = 'Tech',
            Question__c = question.Id,
            Notification_Process_Config__c = processConfig.Id
        );
        insert fieldMeta;
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'InProgress');
        Test.stopTest();
    }
    
    @IsTest
    static void testGetProcessConfigExceptionHandling() {
        // Test with invalid ID to trigger exception
        Test.startTest();
        try {
            String result = ApprovalSetupController.getProcessConfig(null, 'Approved');
        } catch (AuraHandledException e) {
            System.debug('Error' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGetProcessConfigEmptyChildTemplates() {
        // Create Action Template without child templates
        Action_Template__c parentTemplateNoChild = new Action_Template__c(
            Name = 'Parent Template No Child',
            Flow_Type__c = 'Parallel'
        );
        insert parentTemplateNoChild;
        
        Notification_Config__c config = [SELECT Id FROM Notification_Config__c LIMIT 1];
        
        Notification_Process_Config__c processConfig = new Notification_Process_Config__c(
            Name = 'Test Process Config No Child',
            Status__c = 'Submitted for Approval',
            Notification_Config__c = config.Id,
            Is_Active__c = true,
            Order__c = 5,
            Action_Template__c = parentTemplateNoChild.Id
        );
        insert processConfig;
        
        Test.startTest();
        String result = ApprovalSetupController.getProcessConfig(config.Id, 'Review');
        Test.stopTest();
    }
    
}