@isTest
private class ActionCenterHandlerTest {

    @testSetup
    static void setupData() {
        // Insert test Accounts
        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < 3; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                AnnualRevenue = 100000 + (i * 10000),
                Industry = 'Technology'
            ));
        }
        insert accounts;

        // Insert test Contacts
        List<Contact> contacts = new List<Contact>();
        for (Account acc : accounts) {
            contacts.add(new Contact(
                FirstName = 'Test',
                LastName = 'Contact ' + acc.Name,
                Email = 'contact@test.com',
                AccountId = acc.Id
            ));
        }
        insert contacts;

        // Insert test Leads
        Lead testLead = new Lead(
            FirstName = 'Test',
            LastName = 'Lead',
            Company = 'Test Company',
            Email = 'lead@test.com'
        );
        insert testLead;

        // Get Task RecordType if exists
        List<RecordType> taskRecordTypes = [
            SELECT Id, DeveloperName, Name 
            FROM RecordType 
            WHERE SObjectType = 'Task' 
            LIMIT 1
        ];
        String taskRecordTypeValue = taskRecordTypes.isEmpty() ? 'Standard' : taskRecordTypes[0].DeveloperName;

        // Insert Action Center Template with all fields
        Action_Center_Template__c act = new Action_Center_Template__c(
            Name = 'Test Template',
            Object_Name__c = 'Account',
            Is_Active__c = true,
            Email_Subject__c = 'Hello {Name}',
            Email_Body__c = 'This is a test for {Name} with revenue {AnnualRevenue}',
            Notification_Title__c = 'Notification: {Name}',
            Notification_Body__c = 'Account {Name} needs attention',
            Post_Body__c = 'Chatter post for {Name}',
            Post_to_Chatter_Email__c = true,
            Post_to_Chatter_Push_Notification__c = true,
            Task_Subject__c = 'Task for {Name}',
            Task_Comments__c = 'Please review account {Name}',
            Task_Status__c = 'Not Started',
            Task_Priority__c = 'Normal',
            Task_RecordType__c = taskRecordTypeValue,
            Org_Wide_Email_Address__c = 'noreply@test.com'
        );
        insert act;
        
        Action_Template__c at = new Action_Template__c(
        	Action_Owner__c = 'System Admin',
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert at;

        // Insert Notification Config
        Notification_Config__c notifConfig = new Notification_Config__c(
            Name = 'Test Notification Config',
            Object_Name__c = 'Account'
        );
        insert notifConfig;

        // Insert Notification Process Config
        Notification_Process_Config__c npc = new Notification_Process_Config__c(
            Name = 'Test NPC',
            Is_Active__c = true,
            Action_Center_Template__c = act.Id,
            Notification_Config__c = notifConfig.Id,
            Order__c = 1
        );
        insert npc;
        
        // Insert Question Book and Question
        Question_Book__c qb = new Question_Book__c(
            Category__c = 'Simple'
        );
        insert qb;
        
        Question__c qn = new Question__c(
            Question_No__c = 1,
            Question_Book__c = qb.Id
        );
        insert qn;

        // Insert Field Meta records for Query operation
        List<Field_Meta__c> fieldMetas = new List<Field_Meta__c>();
        
        // Direct fields
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Name',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        ));
        
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'AnnualRevenue',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        ));
        
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Industry',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        ));

        // Relationship fields
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Owner.Name',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        ));
        
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Owner.Email',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        ));

        // Field Meta for Notification Process Config (Conditional)
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Name',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Conditional',
            Notification_Process_Config__c = npc.Id
        ));
        
        fieldMetas.add(new Field_Meta__c(
            api_name__c = 'Industry',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Conditional',
            Notification_Process_Config__c = npc.Id
        ));

        insert fieldMetas;

        // Create delegated user for delegation testing
        Profile standardProfile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        
        User delegatedUser = new User(
            FirstName = 'Delegated',
            LastName = 'Approver',
            Email = 'delegated@test.com',
            Username = 'delegatedapprover' + System.currentTimeMillis() + '@test.com',
            Alias = 'delapp',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
        insert delegatedUser;

        // Create inactive user for testing
        User inactiveUser = new User(
            FirstName = 'Inactive',
            LastName = 'User',
            Email = 'inactive@test.com',
            Username = 'inactiveuser' + System.currentTimeMillis() + '@test.com',
            Alias = 'inact',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = standardProfile.Id,
            LanguageLocaleKey = 'en_US',
            IsActive = false
        );
        insert inactiveUser;

        // Insert Action Template (child approver records)
        List<Action_Template__c> approvers = new List<Action_Template__c>();
        
        // User type with User ID
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserId(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // User type with Email
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserEmail(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // User type with Username
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserName(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // User type with Name
        User currentUser = [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()];
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = currentUser.Name,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Comma-separated users
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserId() + ',' + UserInfo.getUserEmail(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Semicolon-separated users
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserEmail() + ';' + UserInfo.getUserName(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Newline-separated users
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = UserInfo.getUserId() + '\n' + UserInfo.getUserEmail(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Non-existent user
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = 'nonexistent@user.com',
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Blank owner
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = '',
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Inactive user
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = inactiveUser.Id,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));
        
        // Delegated user
        approvers.add(new Action_Template__c(
            Parent_Action_Template__c = at.Id,
            Action_Owner__c = delegatedUser.Id,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        ));

        insert approvers;
    }

    // ========== Test processEmailContent ==========
    
    @isTest
    static void testProcessEmailContent() {
        Action_Center_Template__c act = [SELECT Id, Object_Name__c FROM Action_Center_Template__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };
        Set<Id> accIds = new Set<Id>{ acc.Id };

        Test.startTest();
        Map<Id, SObject> results = ActionCenterHandler.processEmailContent(actMap, accIds);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return 1 record');
    }

    @isTest
    static void testProcessEmailContentMultipleRecords() {
        Action_Center_Template__c act = [SELECT Id, Object_Name__c FROM Action_Center_Template__c LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accIds = new Set<Id>();
        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

        Test.startTest();
        Map<Id, SObject> results = ActionCenterHandler.processEmailContent(actMap, accIds);
        Test.stopTest();

        System.assertEquals(3, results.size(), 'Should return 3 records');
    }

    @isTest
    static void testProcessEmailContentEmptyTemplateMap() {
        Set<Id> accIds = new Set<Id>{ [SELECT Id FROM Account LIMIT 1].Id };
        Map<Id, Action_Center_Template__c> emptyMap = new Map<Id, Action_Center_Template__c>();

        Test.startTest();
        Map<Id, SObject> results = ActionCenterHandler.processEmailContent(emptyMap, accIds);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty map');
    }

    @isTest
    static void testProcessEmailContentNoObjectName() {
        Action_Center_Template__c act = new Action_Center_Template__c(
            Name = 'No Object Template',
            Object_Name__c = null,
            Is_Active__c = true
        );
        insert act;

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };
        Set<Id> accIds = new Set<Id>{ [SELECT Id FROM Account LIMIT 1].Id };

        Test.startTest();
        Map<Id, SObject> results = ActionCenterHandler.processEmailContent(actMap, accIds);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty map when no object name');
    }

    // ========== Test processNotificationContent ==========
    
    @isTest
    static void testProcessNotificationContent() {
        Action_Center_Template__c act = [
            SELECT Id, Object_Name__c, Notification_Title__c, Notification_Body__c, 
                   Post_Body__c, Post_to_Chatter_Email__c, Post_to_Chatter_Push_Notification__c
            FROM Action_Center_Template__c 
            LIMIT 1
        ];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };
        Set<Id> accIds = new Set<Id>{ acc.Id };

        Test.startTest();
        Map<Id, NotificationContent> results = 
            ActionCenterHandler.processNotificationContent(actMap, accIds);
        Test.stopTest();

        System.assertNotEquals(null, results, 'Results should not be null');
        System.assertEquals(1, results.size(), 'Should return 1 notification content');
        
        NotificationContent content = results.get(acc.Id);
        System.assertNotEquals(null, content.notificationTitle, 'Notification title should be set');
        System.assertNotEquals(null, content.notificationBody, 'Notification body should be set');
        System.assertNotEquals(null, content.chatterPostBody, 'Chatter post body should be set');
        System.assertEquals(true, content.postToChatterEnabled, 'Chatter should be enabled');
        System.assertEquals(true, content.pushNotificationEnabled, 'Push notification should be enabled');
    }

    @isTest
    static void testProcessNotificationContentEmptyMap() {
        Set<Id> accIds = new Set<Id>{ [SELECT Id FROM Account LIMIT 1].Id };
        Map<Id, Action_Center_Template__c> emptyMap = new Map<Id, Action_Center_Template__c>();

        Test.startTest();
        Map<Id, NotificationContent> results = 
            ActionCenterHandler.processNotificationContent(emptyMap, accIds);
        Test.stopTest();

        System.assertEquals(0, results.size(), 'Should return empty map');
    }

    @isTest
    static void testProcessNotificationContentBlankFields() {
        Action_Center_Template__c act = new Action_Center_Template__c(
            Name = 'Blank Notification Template',
            Object_Name__c = 'Account',
            Is_Active__c = true,
            Notification_Title__c = '',
            Notification_Body__c = '',
            Post_Body__c = '',
            Post_to_Chatter_Email__c = false,
            Post_to_Chatter_Push_Notification__c = false
        );
        insert act;

        // Insert Field Meta for this template
        Question__c qn = [SELECT Id FROM Question__c LIMIT 1];
        Field_Meta__c fm = new Field_Meta__c(
            api_name__c = 'Name',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        );
        insert fm;

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };
        Set<Id> accIds = new Set<Id>{ [SELECT Id FROM Account LIMIT 1].Id };

        Test.startTest();
        Map<Id, NotificationContent> results = 
            ActionCenterHandler.processNotificationContent(actMap, accIds);
        Test.stopTest();

        System.assertEquals(1, results.size(), 'Should return 1 notification content');
    }

    // ========== Test sendEmailNotification ==========
    
    @isTest
    static void testSendEmailNotification() {
        Notification_Process_Config__c npc = [SELECT Id FROM Notification_Process_Config__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        List<String> emails = new List<String>{ 'test@example.com' };

        Test.startTest();
        ActionCenterHandler.sendEmailNotification(new Set<Id>{ npc.Id }, emails, new Set<Id>{ acc.Id });
        Test.stopTest();

        System.assert(true, 'sendEmailNotification executed without error');
    }

    @isTest
    static void testSendEmailNotificationInactive() {
        Notification_Process_Config__c npc = [SELECT Id FROM Notification_Process_Config__c LIMIT 1];
        npc.Is_Active__c = false;
        update npc;

        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> emails = new List<String>{ 'test@example.com' };

        Test.startTest();
        ActionCenterHandler.sendEmailNotification(new Set<Id>{ npc.Id }, emails, new Set<Id>{ acc.Id });
        Test.stopTest();

        System.assert(true, 'Should handle inactive config gracefully');
    }

    @isTest
    static void testSendEmailNotificationNoConfig() {
        Set<Id> fakeIds = new Set<Id>();
        List<String> emails = new List<String>{ 'test@example.com' };
        Set<Id> accIds = new Set<Id>{ [SELECT Id FROM Account LIMIT 1].Id };

        Test.startTest();
        ActionCenterHandler.sendEmailNotification(fakeIds, emails, accIds);
        Test.stopTest();

        System.assert(true, 'Should handle empty config gracefully');
    }

    @isTest
    static void testSendEmailNotificationInactiveTemplate() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        act.Is_Active__c = false;
        update act;

        Notification_Process_Config__c npc = [SELECT Id FROM Notification_Process_Config__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];
        List<String> emails = new List<String>{ 'test@example.com' };

        Test.startTest();
        ActionCenterHandler.sendEmailNotification(new Set<Id>{ npc.Id }, emails, new Set<Id>{ acc.Id });
        Test.stopTest();

        System.assert(true, 'Should handle inactive template gracefully');
    }

    // ========== Test prepareMailTemplate ==========
    
    @isTest
    static void testPrepareMailTemplate() {
        List<String> emails = new List<String>{ 'user@test.com' };

        Test.startTest();
        List<Messaging.SingleEmailMessage> mails = ActionCenterHandler.prepareMailTemplate(
            'Test Subject', 
            'Test Body', 
            emails, 
            null
        );
        Test.stopTest();

        System.assertEquals(1, mails.size(), 'Should prepare 1 email');
        System.assertEquals('Test Subject', mails[0].getSubject(), 'Subject should match');
        System.assertEquals('Test Body', mails[0].getHtmlBody(), 'Body should match');
    }

    @isTest
    static void testPrepareMailTemplateMultipleRecipients() {
        List<String> emails = new List<String>{ 'user1@test.com', 'user2@test.com', 'user3@test.com' };

        Test.startTest();
        List<Messaging.SingleEmailMessage> mails = ActionCenterHandler.prepareMailTemplate(
            'Test Subject', 
            'Test Body', 
            emails, 
            null
        );
        Test.stopTest();

        System.assertEquals(1, mails.size(), 'Should prepare 1 email');
        System.assertEquals(3, mails[0].getToAddresses().size(), 'Should have 3 recipients');
    }

    @isTest
    static void testPrepareMailTemplateEmptyList() {
        List<String> emails = new List<String>();

        Test.startTest();
        List<Messaging.SingleEmailMessage> mails = ActionCenterHandler.prepareMailTemplate(
            'Test Subject', 
            'Test Body', 
            emails, 
            null
        );
        Test.stopTest();

        System.assertEquals(0, mails.size(), 'Should return empty list');
    }

    @isTest
    static void testPrepareMailTemplateWithOrgWideEmail() {
        List<String> emails = new List<String>{ 'user@test.com' };

        Test.startTest();
        List<Messaging.SingleEmailMessage> mails = ActionCenterHandler.prepareMailTemplate(
            'Test Subject', 
            'Test Body', 
            emails, 
            'noreply@test.com'
        );
        Test.stopTest();

        System.assertEquals(1, mails.size(), 'Should prepare 1 email');
    }

    // ========== Test resolveTaskRecordTypeIds ==========
    
    @isTest
    static void testResolveTaskRecordTypeIds() {
        Action_Center_Template__c act = [SELECT Id, Task_RecordType__c FROM Action_Center_Template__c LIMIT 1];
        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

        Test.startTest();
        Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(actMap);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testResolveTaskRecordTypeIdsWithSalesforceId() {
        List<RecordType> taskRecordTypes = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Task' 
            LIMIT 1
        ];

        if (!taskRecordTypes.isEmpty()) {
            Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
            act.Task_RecordType__c = taskRecordTypes[0].Id;
            update act;

            Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

            Test.startTest();
            Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(actMap);
            Test.stopTest();

            System.assertEquals(taskRecordTypes[0].Id, result.get(act.Id), 'Should resolve RecordType ID');
        }
    }

    @isTest
    static void testResolveTaskRecordTypeIdsByName() {
        List<RecordType> taskRecordTypes = [
            SELECT Id, Name, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Task' 
            LIMIT 1
        ];

        if (!taskRecordTypes.isEmpty()) {
            Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
            act.Task_RecordType__c = taskRecordTypes[0].Name;
            update act;

            Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

            Test.startTest();
            Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(actMap);
            Test.stopTest();

            System.assertEquals(taskRecordTypes[0].Id, result.get(act.Id), 'Should resolve RecordType by Name');
        }
    }

    @isTest
    static void testResolveTaskRecordTypeIdsByDeveloperName() {
        List<RecordType> taskRecordTypes = [
            SELECT Id, DeveloperName 
            FROM RecordType 
            WHERE SObjectType = 'Task' 
            LIMIT 1
        ];

        if (!taskRecordTypes.isEmpty()) {
            Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
            act.Task_RecordType__c = taskRecordTypes[0].DeveloperName;
            update act;

            Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

            Test.startTest();
            Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(actMap);
            Test.stopTest();

            System.assertEquals(taskRecordTypes[0].Id, result.get(act.Id), 'Should resolve RecordType by DeveloperName');
        }
    }

    @isTest
    static void testResolveTaskRecordTypeIdsEmptyMap() {
        Map<Id, Action_Center_Template__c> emptyMap = new Map<Id, Action_Center_Template__c>();

        Test.startTest();
        Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(emptyMap);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map');
    }

    @isTest
    static void testResolveTaskRecordTypeIdsNullMap() {
        Test.startTest();
        Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for null input');
    }

    @isTest
    static void testResolveTaskRecordTypeIdsBlankValue() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        act.Task_RecordType__c = '';
        update act;

        Map<Id, Action_Center_Template__c> actMap = new Map<Id, Action_Center_Template__c>{ act.Id => act };

        Test.startTest();
        Map<Id, Id> result = ActionCenterHandler.resolveTaskRecordTypeIds(actMap);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should not resolve blank RecordType');
    }

    // ========== Test buildTaskFromTemplate ==========
    
    @isTest
    static void testBuildTaskFromTemplate() {
        Account acc = [SELECT Id, Name, AnnualRevenue FROM Account LIMIT 1];
        Action_Center_Template__c act = [
            SELECT Id, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c
            FROM Action_Center_Template__c 
            LIMIT 1
        ];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(
            act, 
            acc.Id, 
            acc, 
            UserInfo.getUserId(),
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created');
        System.assertNotEquals(null, result.Subject, 'Subject should be set');
        System.assertEquals('Not Started', result.Status, 'Status should match');
        System.assertEquals('Normal', result.Priority, 'Priority should match');
        System.assertEquals(acc.Id, result.WhatId, 'WhatId should be Account');
    }
    
    
    @isTest
    static void testBuildTaskFromTemplateWithContact() {
        Contact con = [SELECT Id, FirstName, LastName, Name FROM Contact LIMIT 1];
        Action_Center_Template__c act = [
            SELECT Id, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c
            FROM Action_Center_Template__c 
            LIMIT 1
        ];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(
            act, 
            con.Id, 
            con, 
            UserInfo.getUserId(),
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created');
        System.assertEquals(null, result.WhatId, 'WhatId should not be set for Contact');
    }

    @isTest
    static void testBuildTaskFromTemplateWithLead() {
        Lead lead = [SELECT Id, FirstName, LastName, Name FROM Lead LIMIT 1];
        Action_Center_Template__c act = [
            SELECT Id, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c
            FROM Action_Center_Template__c 
            LIMIT 1
        ];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(
            act, 
            lead.Id, 
            lead, 
            UserInfo.getUserId(),
            null
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created');
        System.assertEquals(null, result.WhatId, 'WhatId should not be set for Lead');
    }

    @isTest
    static void testBuildTaskFromTemplateWithRecordTypeId() {
        List<RecordType> taskRecordTypes = [
            SELECT Id 
            FROM RecordType 
            WHERE SObjectType = 'Task' 
            LIMIT 1
        ];

        if (!taskRecordTypes.isEmpty()) {
            Account acc = [SELECT Id, Name FROM Account LIMIT 1];
            Action_Center_Template__c act = [
                SELECT Id, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c
                FROM Action_Center_Template__c 
                LIMIT 1
            ];

            Test.startTest();
            Task result = ActionCenterHandler.buildTaskFromTemplate(
                act, 
                acc.Id, 
                acc, 
                UserInfo.getUserId(),
                taskRecordTypes[0].Id
            );
            Test.stopTest();

            System.assertNotEquals(null, result, 'Task should be created');
        }
    }

    @isTest
    static void testBuildTaskFromTemplateNullTemplate() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(null, acc.Id, acc, null, null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for null template');
    }

    @isTest
    static void testBuildTaskFromTemplateNullRecordId() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, null, null, null, null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null for null record ID');
    }

    @isTest
    static void testBuildTaskFromTemplateBlankSubjectAndComments() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Action_Center_Template__c act = new Action_Center_Template__c(
            Task_Subject__c = '',
            Task_Comments__c = '',
            Task_Status__c = 'Not Started',
            Task_Priority__c = 'Normal'
        );

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, acc.Id, acc, null, null);
        Test.stopTest();

        System.assertEquals(null, result, 'Should return null when subject and comments are blank');
    }

    @isTest
    static void testBuildTaskFromTemplateOnlySubject() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Action_Center_Template__c act = new Action_Center_Template__c(
            Task_Subject__c = 'Test Subject',
            Task_Comments__c = '',
            Task_Status__c = 'Not Started',
            Task_Priority__c = 'Normal'
        );

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, acc.Id, acc, null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created with only subject');
        System.assertEquals('Test Subject', result.Subject, 'Subject should match');
    }

    @isTest
    static void testBuildTaskFromTemplateOnlyComments() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Action_Center_Template__c act = new Action_Center_Template__c(
            Task_Subject__c = '',
            Task_Comments__c = 'Test Comments',
            Task_Status__c = 'Not Started',
            Task_Priority__c = 'Normal'
        );

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, acc.Id, acc, null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created with only comments');
        System.assertEquals('Approval Task', result.Subject, 'Should use default subject');
        System.assertEquals('Test Comments', result.Description, 'Comments should be set');
    }

    @isTest
    static void testBuildTaskFromTemplateLongSubject() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        String longSubject = 'This is a very long subject that exceeds 255 characters. '.repeat(10);
        
        Action_Center_Template__c act = new Action_Center_Template__c(
            Task_Subject__c = longSubject,
            Task_Comments__c = 'Test',
            Task_Status__c = 'Not Started',
            Task_Priority__c = 'Normal'
        );

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, acc.Id, acc, null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created');
        System.assert(result.Subject.length() <= 255, 'Subject should be trimmed to 255 characters');
    }

    @isTest
    static void testBuildTaskFromTemplateWithWhoIdFromRecordData() {
        Account acc = [SELECT Id, Name FROM Account LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        // Create Account with ContactId populated
        Account accWithContact = new Account(
            Id = acc.Id,
            Name = acc.Name
        );
        // Simulate WhoId field in record data
        Map<String, Object> populatedFields = new Map<String, Object>{
            'Id' => acc.Id,
            'Name' => acc.Name,
            'ContactId' => con.Id
        };

        Action_Center_Template__c act = [
            SELECT Id, Task_Subject__c, Task_Comments__c, Task_Status__c, Task_Priority__c
            FROM Action_Center_Template__c 
            LIMIT 1
        ];

        Test.startTest();
        Task result = ActionCenterHandler.buildTaskFromTemplate(act, acc.Id, accWithContact, null, null);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Task should be created');
    }

    // ========== Test resolveApproverRecipientsByTemplate ==========
    
    @isTest
    static void testResolveApproverRecipientsByTemplate() {
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        List<Action_Template__c> approvers = [
            SELECT Id, Parent_Action_Template__c, Action_Owner__c, Action_Owner_Type__c
            FROM Action_Template__c
            WHERE Parent_Action_Template__c = :act.Id
        ];

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(approvers);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Should resolve approvers');
    }

    @isTest
    static void testResolveApproverRecipientsNullList() {
        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(null);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for null list');
    }

    @isTest
    static void testResolveApproverRecipientsEmptyList() {
        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>());
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map for empty list');
    }

    @isTest
    static void testResolveApproverRecipientsWithDelegation() {
        User delegatedUser = [SELECT Id FROM User WHERE Email = 'delegated@test.com' LIMIT 1];
        
        // Update current user to have delegated approver
        User currentUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
        currentUser.DelegatedApproverId = delegatedUser.Id;
        update currentUser;

        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = currentUser.Id,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should resolve 1 approver');
        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should have 1 recipient');
        
        ActionCenterHandler.ApproverRecipient recipient = recipients[0];
        System.assertEquals(true, recipient.delegated, 'Should be marked as delegated');
        System.assertEquals(delegatedUser.Id, recipient.userId, 'Should use delegated user');
    }

    @isTest
    static void testResolveApproverRecipientsInactiveUser() {
        User inactiveUser = [SELECT Id FROM User WHERE Email = 'inactive@test.com' LIMIT 1];
        
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = inactiveUser.Id,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Should resolve 1 approver');
        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should have 1 recipient');
        System.assertEquals(false, recipients[0].effectiveOwnerActive, 'Should mark as inactive');
    }

    @isTest
    static void testResolveApproverRecipientsCommaSeparated() {
        User currentUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        
        String commaSeparated = currentUser.Id + ',' + currentUser.Email;
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = commaSeparated,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should deduplicate to 1 recipient');
    }

    @isTest
    static void testResolveApproverRecipientsSemicolonSeparated() {
        User currentUser = [SELECT Id, Username FROM User WHERE Id = :UserInfo.getUserId()];
        
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        String semicolonSeparated = currentUser.Id + ';' + currentUser.Username;
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = semicolonSeparated,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should deduplicate to 1 recipient');
    }

    @isTest
    static void testResolveApproverRecipientsNewlineSeparated() {
        User currentUser = [SELECT Id, Email FROM User WHERE Id = :UserInfo.getUserId()];
        
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        String newlineSeparated = currentUser.Id + '\n' + currentUser.Email;
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = newlineSeparated,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should deduplicate to 1 recipient');
    }

    @isTest
    static void testResolveApproverRecipientsNonUserType() {
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = 'Support Queue',
            Action_Owner_Type__c = 'Queue',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should have 1 unresolved recipient');
        System.assertEquals('Support Queue', recipients[0].effectiveOwner, 'Should keep original value');
    }

    @isTest
    static void testResolveApproverRecipientsNonExistentUser() {
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = 'nonexistent@user.com',
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should have 1 unresolved recipient');
        System.assertEquals('nonexistent@user.com', recipients[0].effectiveOwner, 'Should keep original value');
    }

    @isTest
    static void testResolveApproverRecipientsBlankOwner() {
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = '',
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should not resolve blank owner');
    }

    @isTest
    static void testResolveApproverRecipientsNullParent() {
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = null,
            Action_Owner__c = UserInfo.getUserId(),
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should not resolve approver without parent');
    }

    @isTest
    static void testResolveApproverRecipientsByUserAlias() {
        User currentUser = [SELECT Alias FROM User WHERE Id = :UserInfo.getUserId()];
        
        Action_Template__c act = [SELECT Id FROM Action_Template__c LIMIT 1];
        
        Action_Template__c approver = new Action_Template__c(
            Parent_Action_Template__c = act.Id,
            Action_Owner__c = currentUser.Alias,
            Action_Owner_Type__c = 'User',
            Is_Active__c = true
        );
        insert approver;

        Test.startTest();
        Map<Id, List<ActionCenterHandler.ApproverRecipient>> result = 
            ActionCenterHandler.resolveApproverRecipientsByTemplate(new List<Action_Template__c>{ approver });
        Test.stopTest();

        List<ActionCenterHandler.ApproverRecipient> recipients = result.get(approver.Id);
        System.assertEquals(1, recipients.size(), 'Should resolve by alias');
    }

    // ========== Test convertFieldMetaToData ==========
    
    @isTest
    static void testConvertFieldMetaToData() {
        Action_Center_Template__c act = [SELECT Id, Object_Name__c FROM Action_Center_Template__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(1, result.size(), 'Should return 1 record');
    }

    @isTest
    static void testConvertFieldMetaToDataMultipleRecords() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        List<Account> accounts = [SELECT Id FROM Account];
        Set<Id> accIds = new Set<Id>();
        for (Account acc : accounts) {
            accIds.add(acc.Id);
        }

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            accIds, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertEquals(3, result.size(), 'Should return 3 records');
    }

    @isTest
    static void testConvertFieldMetaToDataWithRelationshipFields() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        SObject record = result.get(acc.Id);
        System.assertNotEquals(null, record.get('Name'), 'Name should be populated');
    }

    @isTest
    static void testConvertFieldMetaToDataWithNPC() {
        Notification_Process_Config__c npc = [SELECT Id FROM Notification_Process_Config__c LIMIT 1];
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Notification_Process_Config__c', 
            new Set<Id>{ npc.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testConvertFieldMetaToDataNoFieldMeta() {
        Action_Center_Template__c act = new Action_Center_Template__c(
            Name = 'No Field Meta Template',
            Object_Name__c = 'Account',
            Is_Active__c = true
        );
        insert act;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should return empty map when no field meta');
    }

    @isTest
    static void testConvertFieldMetaToDataInactiveFieldMeta() {
        Action_Center_Template__c act = new Action_Center_Template__c(
            Name = 'Inactive Field Meta Template',
            Object_Name__c = 'Account',
            Is_Active__c = true
        );
        insert act;

        Question__c qn = [SELECT Id FROM Question__c LIMIT 1];
        Field_Meta__c fm = new Field_Meta__c(
            api_name__c = 'Name',
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = false,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        );
        insert fm;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Should not include inactive field meta');
    }

    @isTest
    static void testConvertFieldMetaToDataNullObjectName() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        
        Question__c qn = [SELECT Id FROM Question__c LIMIT 1];
        Field_Meta__c fm = new Field_Meta__c(
            api_name__c = 'Name',
            Object_Name__c = null,
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        );
        insert fm;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    static void testConvertFieldMetaToDataNullApiName() {
        Action_Center_Template__c act = [SELECT Id FROM Action_Center_Template__c LIMIT 1];
        
        Question__c qn = [SELECT Id FROM Question__c LIMIT 1];
        Field_Meta__c fm = new Field_Meta__c(
            api_name__c = null,
            Object_Name__c = 'Account',
            Question__c = qn.Id,
            Is_Active__c = true,
            Operation_Type__c = 'Query',
            Action_Center_Template__c = act.Id
        );
        insert fm;

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        Map<Id, SObject> result = ActionCenterHandler.convertFieldMetaToData(
            'Account', 
            new Set<Id>{ acc.Id }, 
            'Action_Center_Template__c', 
            new Set<Id>{ act.Id }
        );
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
    }

    // ========== Test buildRecipientDedupeKey ==========
    
    @isTest
    static void testBuildRecipientDedupeKey() {
        ActionCenterHandler.ApproverRecipient recipient = new ActionCenterHandler.ApproverRecipient();
        recipient.configuredOwner = 'Test User';
        recipient.configuredOwnerId = UserInfo.getUserId();
        recipient.effectiveOwner = 'Test User';
        recipient.userId = UserInfo.getUserId();
        recipient.delegated = false;

        Test.startTest();
        String dedupeKey = ActionCenterHandler.buildRecipientDedupeKey(recipient);
        Test.stopTest();

        System.assertNotEquals(null, dedupeKey, 'Dedupe key should not be null');
        System.assert(dedupeKey.contains('|'), 'Dedupe key should contain pipe separator');
        System.assert(dedupeKey.contains('N|'), 'Should indicate not delegated');
    }

    @isTest
    static void testBuildRecipientDedupeKeyDelegated() {
        ActionCenterHandler.ApproverRecipient recipient = new ActionCenterHandler.ApproverRecipient();
        recipient.configuredOwner = 'Original User';
        recipient.configuredOwnerId = UserInfo.getUserId();
        recipient.effectiveOwner = 'Delegated User';
        recipient.userId = [SELECT Id FROM User WHERE Email = 'delegated@test.com' LIMIT 1].Id;
        recipient.delegated = true;
        recipient.delegatedFromOwner = 'Original User';

        Test.startTest();
        String dedupeKey = ActionCenterHandler.buildRecipientDedupeKey(recipient);
        Test.stopTest();

        System.assertNotEquals(null, dedupeKey, 'Dedupe key should not be null');
        System.assert(dedupeKey.contains('D|'), 'Should indicate delegated');
    }

    @isTest
    static void testBuildRecipientDedupeKeyNull() {
        Test.startTest();
        String dedupeKey = ActionCenterHandler.buildRecipientDedupeKey(null);
        Test.stopTest();

        System.assertEquals(null, dedupeKey, 'Should return null for null recipient');
    }
}