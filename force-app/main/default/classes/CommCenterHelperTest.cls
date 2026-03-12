@isTest
public class CommCenterHelperTest {

    @testSetup
    static void setupData() {

        Account acc = new Account(Name = 'Test Account');
        insert acc;

        Notification_Config__c notifConfig = new Notification_Config__c(
            Name = 'Test Config',
            Object_Name__c = 'Account',
            Is_Active__c = true
        );
        insert notifConfig;

        Action_Center_Template__c actTemplate = new Action_Center_Template__c(
            Name = 'Approved Template',
            Object_Name__c = 'Account',
            Email_Subject__c = 'Subject {!Name}',
            Email_Body__c = 'Body {!Name}',
            Is_Active__c = true
        );
        insert actTemplate;

        Notification_Process_Config__c npcApproved = new Notification_Process_Config__c(
            Name = 'Approved Config',
            Status__c = 'Approved',
            Notification_Config__c = notifConfig.Id,
            Order__c = 1,
            Is_Active__c = true,
            Action_Center_Template__c = actTemplate.Id
        );
        insert npcApproved;

        Notification_Process_Config__c npcSubmitted = new Notification_Process_Config__c(
            Name = 'Submitted Config',
            Status__c = 'Submitted For Approval',
            Notification_Config__c = notifConfig.Id,
            Order__c = 2,
            Is_Active__c = true,
            Parent_Notification_Process_Config__c = npcApproved.Id,
            Action_Center_Template__c = actTemplate.Id
        );
        insert npcSubmitted;

        Question_Book__c qb = new Question_Book__c();
        insert qb;

        Question__c q = new Question__c(
            RecordTypeId = Schema.SObjectType.Question__c
                .getRecordTypeInfosByName()
                .get('UNCONDITIONAL')
                .getRecordTypeId(),
            Type__c = 'Text',
            Question_No__c = 1,
            Question_Book__c = qb.Id
        );
        insert q;

        Field_Meta__c updateableMeta = new Field_Meta__c(
            api_name__c = 'Description',
            filterValue__c = 'Updated Description',
            order__c = 1,
            Question__c = q.Id,
            Notification_Process_Config__c = npcApproved.Id,
            Object_Name__c = 'Account',
            Is_Active__c = true,
            Operation_Type__c = 'Updateable'
        );
        insert updateableMeta;
    }

    /* -----------------------------------------------------------
       GET APPROVAL RECORD
    ------------------------------------------------------------ */

    @isTest
    static void testGetApprovalRecord() {

        Account acc = [SELECT Id FROM Account LIMIT 1];
        Notification_Process_Config__c npc =
            [SELECT Id FROM Notification_Process_Config__c WHERE Status__c='Approved' LIMIT 1];

        Comm_Center__c cc = new Comm_Center__c(
            Name = 'Test CC',
            Status__c = 'Pending',
            Notification_Process_Config__c = npc.Id,
            Object_Name__c = 'Account',
            Order__c = 1,
            Record_Id__c = acc.Id
        );
        insert cc;

        Test.startTest();
        CommCenterHelper.CommCenterWrapper wrap =
            CommCenterHelper.getApprovalRecord(cc.Id);
        Test.stopTest();

        System.assertEquals(cc.Id, wrap.id);
    }

    /* -----------------------------------------------------------
       APPROVAL FLOW (SEQUENTIAL CHILD APPROVAL)
    ------------------------------------------------------------ */

    @isTest
    static void testSequentialApproval() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Notification_Process_Config__c npcApproved =
            [SELECT Id FROM Notification_Process_Config__c WHERE Status__c='Approved' LIMIT 1];

        Notification_Process_Config__c npcSubmitted =
            [SELECT Id FROM Notification_Process_Config__c WHERE Status__c='Submitted For Approval' LIMIT 1];

        // Parent
        Comm_Center__c parent = new Comm_Center__c(
            Name = 'Parent',
            Status__c = 'Pending',
            Notification_Process_Config__c = npcApproved.Id,
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Order__c = 1
        );
        insert parent;

        // Child (must be Submitted)
        Comm_Center__c child = new Comm_Center__c(
            Name = 'Child',
            Status__c = 'Submitted For Approval',
            Notification_Process_Config__c = npcSubmitted.Id,
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Parent_Comm_Center__c = parent.Id,
            Order__c = 2,
            Is_Optional__c = false
        );
        insert child;

        Test.startTest();
        CommCenterHelper.updateApprovalStatus(
            child.Id,
            'Approved',
            null,
            acc.Id
        );
        Test.stopTest();

        child = [SELECT Status__c FROM Comm_Center__c WHERE Id=:child.Id];
        System.assertEquals('Approved', child.Status__c);
    }

    /* -----------------------------------------------------------
       REJECTION FLOW
    ------------------------------------------------------------ */

    @isTest
    static void testRejectionFlow() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Notification_Process_Config__c npcApproved =
            [SELECT Id FROM Notification_Process_Config__c WHERE Status__c='Approved' LIMIT 1];

        Notification_Process_Config__c npcSubmitted =
            [SELECT Id FROM Notification_Process_Config__c WHERE Status__c='Submitted For Approval' LIMIT 1];

        Comm_Center__c parent = new Comm_Center__c(
            Name = 'Parent',
            Status__c = 'Pending',
            Notification_Process_Config__c = npcApproved.Id,
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Order__c = 1
        );
        insert parent;

        Comm_Center__c child = new Comm_Center__c(
            Name = 'Child',
            Status__c = 'Submitted For Approval',
            Notification_Process_Config__c = npcSubmitted.Id,
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Parent_Comm_Center__c = parent.Id,
            Order__c = 2
        );
        insert child;

        Test.startTest();
        CommCenterHelper.updateApprovalStatus(
            child.Id,
            'Rejected',
            'Invalid Data',
            acc.Id
        );
        Test.stopTest();

        child = [SELECT Status__c, Reason__c FROM Comm_Center__c WHERE Id=:child.Id];

        System.assertEquals('Rejected', child.Status__c);
        System.assertEquals('Invalid Data', child.Reason__c);
    }

    /* -----------------------------------------------------------
       METADATA UPDATE TEST
    ------------------------------------------------------------ */

    @isTest
    static void testRecordsToUpdate() {

        Account acc = [SELECT Id FROM Account LIMIT 1];

        Notification_Process_Config__c npcApproved =
            [SELECT Id, Action_Center_Template__c
             FROM Notification_Process_Config__c
             WHERE Status__c='Approved'
             LIMIT 1];

        Test.startTest();
        CommCenterHelper.recordsToUpdate(npcApproved.Action_Center_Template__c, acc.Id);
        Test.stopTest();

        acc = [SELECT Description FROM Account WHERE Id=:acc.Id];

        System.assertEquals('Updated Description', acc.Description);
    }

    /* -----------------------------------------------------------
       EMAIL CONSTRUCT
    ------------------------------------------------------------ */

    @isTest
    static void testConstructEmail() {

        Test.startTest();
        Messaging.SingleEmailMessage mail =
            CommCenterHelper.constructEmail(
                'test@test.com',
                'Subject',
                'Body'
            );
        Test.stopTest();

        System.assertEquals('Subject', mail.getSubject());
        System.assertEquals('Body', mail.getPlainTextBody());
    }

    /* -----------------------------------------------------------
       GET ACTION TEMPLATE ID
    ------------------------------------------------------------ */

    @isTest
    static void testGetActionTemplateId() {

        Notification_Process_Config__c npc =
            [SELECT Id, Status__c, Action_Center_Template__c
             FROM Notification_Process_Config__c
             WHERE Status__c='Approved'
             LIMIT 1];

        Map<Id, Notification_Process_Config__c> mapCfg =
            new Map<Id, Notification_Process_Config__c>{ npc.Id => npc };

        Test.startTest();
        String actId = CommCenterHelper.getActionTemplateId('Approved', mapCfg);
        Test.stopTest();

        System.assertEquals(npc.Action_Center_Template__c, actId);
    }
}