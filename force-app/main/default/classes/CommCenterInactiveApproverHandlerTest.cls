/**
 * @description Test class for CommCenterInactiveApproverHandler and User trigger.
 *              Covers all logic paths, mixed DML handled via runAs, required fields set.
 */
@isTest
private class CommCenterInactiveApproverHandlerTest {

    // ===== HELPER METHODS =====

    /** Creates a test user with required fields and IsActive = true. */
    private static User createTestUser(String suffix) {
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        String uniqueSuffix = suffix + DateTime.now().getTime();
        return new User(
            ProfileId = p.Id,
            FirstName = 'Test',
            LastName = 'User ' + suffix,
            Email = 'test.user.' + uniqueSuffix + '@example.com',
            Username = 'test.user.' + uniqueSuffix + '@example.com',
            Alias = 'tuser' + suffix.left(3),
            CommunityNickname = 'tuser' + suffix,
            TimeZoneSidKey = 'America/New_York',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            IsActive = true
        );
    }

    /** Creates a parent Action_Template__c. */
    private static Action_Template__c createParentTemplate(String name) {
        return new Action_Template__c(
            Name = name,
            Is_Active__c = false
        );
    }

    /** Creates a child Action_Template__c with given Action_Owner__c token. */
    private static Action_Template__c createChildTemplate(Id parentId, String ownerToken, Boolean isActive) {
        return new Action_Template__c(
            Name = 'Child ' + ownerToken,
            Parent_Action_Template__c = parentId,
            Action_Owner__c = ownerToken,
            Is_Active__c = isActive
        );
    }

    /** Creates a Notification_Config__c. */
    private static Notification_Config__c createNotifConfig(String name) {
        return new Notification_Config__c(Name = name);
    }

    /** Creates a Notification_Process_Config__c linking a template to a config (Order__c required). */
    private static Notification_Process_Config__c createNotifProcessConfig(Id templateId, Id configId) {
        return new Notification_Process_Config__c(
            Action_Template__c = templateId,
            Notification_Config__c = configId,
            Order__c = 1  // Required field
        );
    }

    // ===== TESTS =====

    /** 1. No deactivation → should not block. */
    @isTest
    static void testNoDeactivation() {
        User u = createTestUser('noDeact');
        insert u;

        Test.startTest();
        u.FirstName = 'Changed';
        // Use runAs to avoid mixed DML (even though no deactivation, it's safe)
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u;
        }
        Test.stopTest();

        System.assert(true, 'Update without deactivation succeeded.');
    }

    /** 2. Deactivation with no matching templates → should succeed. */
    @isTest
    static void testDeactivationNoMatchingTemplates() {
        User u = createTestUser('noMatch');
        insert u;

        // Create templates (non‑setup objects) AFTER user insert
        Action_Template__c parent = createParentTemplate('Parent NoMatch');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, 'someOtherToken', true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        // Update user inside runAs to separate context
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u;
        }
        Test.stopTest();

        System.assertEquals(false, [SELECT IsActive FROM User WHERE Id = :u.Id].IsActive);
    }

    /** 3. Deactivation blocked by token matching full 18‑character Id. */
    @isTest
    static void testDeactivationBlockedById18() {
        User u = createTestUser('id18');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Id18');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Id, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'),
                    'Error message missing expected text. Got: ' + e.getDmlMessage(0));
            }
        }
        Test.stopTest();
    }

    /** 4. Deactivation blocked by token matching 15‑character Id. */
    @isTest
    static void testDeactivationBlockedById15() {
        User u = createTestUser('id15');
        insert u;

        String id15 = String.valueOf(u.Id).substring(0, 15);
        Action_Template__c parent = createParentTemplate('Parent Id15');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, id15, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 5. Deactivation blocked by token matching Name. */
    @isTest
    static void testDeactivationBlockedByName() {
        User u = createTestUser('name');
        insert u;
        // Requery to get the populated Name field
        u = [SELECT Id, Name, Username, Email, Alias FROM User WHERE Id = :u.Id];
    
        Action_Template__c parent = createParentTemplate('Parent Name');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Name, true);
        insert child;
    
        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 6. Deactivation blocked by token matching Email. */
    @isTest
    static void testDeactivationBlockedByEmail() {
        User u = createTestUser('email');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Email');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Email, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 7. Deactivation blocked by token matching Username. */
    @isTest
    static void testDeactivationBlockedByUsername() {
        User u = createTestUser('username');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Username');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Username, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 8. Deactivation blocked by token matching Alias. */
    @isTest
    static void testDeactivationBlockedByAlias() {
        User u = createTestUser('alias');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Alias');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Alias, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 9. Multiple tokens in Action_Owner__c – one matches, block should occur. */
    @isTest
    static void testMultipleTokens() {
        User u = createTestUser('multi');
        insert u;

        String tokens = 'nonMatching1, ' + u.Email + ', nonMatching2';
        Action_Template__c parent = createParentTemplate('Parent Multi');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, tokens, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 10. Deactivation with notification configs – config names appear in error. */
    @isTest
    static void testDeactivationWithNotificationConfigs() {
        User u = createTestUser('notif');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Notif');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Id, true);
        insert child;

        // Create notification config and link to child (Order__c required)
        Notification_Config__c nc = createNotifConfig('Test Config');
        insert nc;
        Notification_Process_Config__c npc = createNotifProcessConfig(child.Id, nc.Id);
        insert npc;

        // Also create a config for the parent template
        Notification_Config__c ncParent = createNotifConfig('Parent Config');
        insert ncParent;
        Notification_Process_Config__c npcParent = createNotifProcessConfig(parent.Id, ncParent.Id);
        insert npcParent;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                String msg = e.getDmlMessage(0);
                System.assert(msg.contains('Approval Process(es): Parent Config, Test Config') ||
                              msg.contains('Approval Process(es): Test Config, Parent Config'),
                    'Config names not correctly appended. Got: ' + msg);
            }
        }
        Test.stopTest();
    }

    /** 11. Multiple users updated, only the deactivating one with a template is blocked. */
    @isTest
    static void testMultipleUsersOneDeactivating() {
        User u1 = createTestUser('multi1');
        User u2 = createTestUser('multi2');
        insert new List<User>{u1, u2};
    
        // Template for u1 only
        Action_Template__c parent = createParentTemplate('Parent MultiUser');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u1.Id, true);
        insert child;
    
        Test.startTest();
        // First, update u2 alone – should succeed
        u2.FirstName = 'Changed';
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u2;
        }
        User updatedU2 = [SELECT FirstName FROM User WHERE Id = :u2.Id];
        System.assertEquals('Changed', updatedU2.FirstName, 'u2 should have been updated.');
    
        // Now attempt to deactivate u1 – should be blocked
        u1.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u1;
                System.assert(false, 'Expected DmlException was not thrown for u1.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 12. Template is inactive → should not block. */
    @isTest
    static void testInactiveTemplate() {
        User u = createTestUser('inactive');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Inactive');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, u.Id, false); // inactive
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u;
        }
        Test.stopTest();

        System.assertEquals(false, [SELECT IsActive FROM User WHERE Id = :u.Id].IsActive);
    }

    /** 13. Parent template only (no child) → should not block. */
    @isTest
    static void testParentOnlyTemplate() {
        User u = createTestUser('parentOnly');
        insert u;

        // Parent template (no parent reference) – should be ignored because query filters on Parent_Action_Template__c != null
        Action_Template__c parent = new Action_Template__c(
            Name = 'Parent Only',
            Parent_Action_Template__c = null,
            Action_Owner__c = u.Id,
            Is_Active__c = true
        );
        insert parent;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u;
        }
        Test.stopTest();

        System.assertEquals(false, [SELECT IsActive FROM User WHERE Id = :u.Id].IsActive);
    }

    /** 14. Child template with null Action_Owner__c → ignored. */
    @isTest
    static void testNullActionOwner() {
        User u = createTestUser('nullOwner');
        insert u;

        Action_Template__c parent = createParentTemplate('Parent Null');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, null, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            update u;
        }
        Test.stopTest();

        System.assertEquals(false, [SELECT IsActive FROM User WHERE Id = :u.Id].IsActive);
    }

    /** 15. Case‑insensitivity: token in uppercase still matches. */
    @isTest
    static void testCaseInsensitivity() {
        User u = createTestUser('case');
        insert u;

        // Use uppercase version of email
        String upperEmail = u.Email.toUpperCase();
        Action_Template__c parent = createParentTemplate('Parent Case');
        insert parent;
        Action_Template__c child = createChildTemplate(parent.Id, upperEmail, true);
        insert child;

        Test.startTest();
        u.IsActive = false;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            try {
                update u;
                System.assert(false, 'Expected DmlException was not thrown.');
            } catch (DmlException e) {
                System.assert(e.getDmlMessage(0).contains('This user is assigned as an approver'));
            }
        }
        Test.stopTest();
    }

    /** 16. Direct test of splitOwnerTokens (private method, covered via TestVisible). */
    @isTest
    static void testSplitOwnerTokens() {
        List<String> result = CommCenterInactiveApproverHandler.splitOwnerTokens('token1,token2;token3\n token4');
        System.assertEquals(4, result.size());
        System.assert(result.contains('token1'));
        System.assert(result.contains('token2'));
        System.assert(result.contains('token3'));
        System.assert(result.contains('token4'));

        result = CommCenterInactiveApproverHandler.splitOwnerTokens('dup, dup');
        System.assertEquals(1, result.size());

        result = CommCenterInactiveApproverHandler.splitOwnerTokens('');
        System.assertEquals(0, result.size());

        result = CommCenterInactiveApproverHandler.splitOwnerTokens(null);
        System.assertEquals(0, result.size());
    }

    /** 17. Direct test of getNewlyInactiveUserIds (optional, for coverage). */
    @isTest
    static void testGetNewlyInactiveUserIds() {
        User u1 = createTestUser('new1');
        User u2 = createTestUser('new2');
        insert new List<User>{u1, u2};

        List<User> newUsers = new List<User>{
            new User(Id = u1.Id, IsActive = false),
            new User(Id = u2.Id, IsActive = true)
        };
        Map<Id, User> oldMap = new Map<Id, User>{
            u1.Id => new User(Id = u1.Id, IsActive = true),
            u2.Id => new User(Id = u2.Id, IsActive = true)
        };

        Set<Id> result = CommCenterInactiveApproverHandler.getNewlyInactiveUserIds(newUsers, oldMap);
        System.assertEquals(1, result.size());
        System.assert(result.contains(u1.Id));
    }
}