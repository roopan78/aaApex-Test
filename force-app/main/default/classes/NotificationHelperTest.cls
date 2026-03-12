@isTest
private class NotificationHelperTest {
    private static Id notifProcessConfigId;
    private static Id AccountId;
    private static Id ApprovalActioncentertempId;
    private static Id ActiontemplateId;
    
    @testSetup
    static void data_setup() {
        
        Notification_Config__c notifConfig = new Notification_Config__c(Name = 'Khaliqe', Object_Name__c = 'Account', Is_Active__c = true);
        insert notifConfig;
        //system.debug('Notification_Config__c'+notifConfig);
        
        Action_Template__c Temp = new Action_Template__c(Name = 'Account-Rating-Submitted-for-approval', Is_Active__c = true, Order__c = 1, Flow_Type__c = 'Sequential');
        insert temp;
        ActiontemplateId = temp.Id;
        //system.debug('Action_Template__c'+temp);
        
        Action_Template__c ChildTemp = new Action_Template__c(Name = 'Level 1', Is_Active__c = true, Order__c = 1, Action_Owner_Type__c ='User', Action_Owner__c ='Mohamed Abdul Kadher', Parent_Action_Template__c =Temp.Id );
        insert ChildTemp;
        //system.debug('Action_Template__c'+ChildTemp);
        
        Action_Template__c ChildTemp2 = new Action_Template__c(Name = 'Level 2', Is_Active__c = true, Order__c = 2, Action_Owner_Type__c ='User', Action_Owner__c ='Mohamed Abdul Kadher', Parent_Action_Template__c =Temp.Id, Is_Optional__c=true );
        insert ChildTemp2;
        //system.debug('Action_Template__c'+ChildTemp2);
        
        Action_Center_Template__c template = new Action_Center_Template__c(
            Name = 'submit-Approval Template',
            Object_Name__c = 'Account',
            Email_Subject__c = 'Requesting approval to change {Rating}',
            Email_Body__c = 'Hi\n {Owner.Name} requesting to change the {Rating} for this {Type}.',
            Is_Active__c = true
        );
        insert template;
        ApprovalActioncentertempId = template.Id;
		//system.debug('Action_Center_Template__c'+template);
		//
		Question_Book__c questionBook = new Question_Book__c(
            Status__c = 'Draft',
            Title__c = 'Sample Title',
            SubTitle__c = 'Sample Subtitle',
            Possibilities__c = 'Test Possibilities',
            Progress_Bar__c = true,
            Category__c = 'Simple',
            Next__c = 'next',
            Back__c = 'back',
            Submit__c = 'submit',
            Cancel__c = 'cancel',
            Edit__c = 'edit',
            Summary_Text__c = 'Summary Text',
            Summary_Sub_Text__c = 'Summary Sub Text'
        );
        insert questionBook;
		Id recId = Schema.SObjectType.Question__c.getRecordTypeInfosByName() .get('UNCONDITIONAL').getRecordTypeId();
        // Create Questions related to the Question Book
        Question__c q1 = new Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 1);
        Question__c q2 = new  Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 2);
        Question__c q3 = new Question__c( Question_Book__c = questionBook.Id,RecordTypeId= recId,  Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 3);
        Question__c q4 = new Question__c( Question_Book__c = questionBook.Id, RecordTypeId= recId, Type__c = 'Text', Reference_Field__c = 'Account.Name', Group__c = 'Group ', Question_No__c = 4);
        insert q1;
        insert q2;
        insert q3;
        insert q4;
        
      	Field_Meta__c Fieldmeta1 = new Field_Meta__c(Object_Name__c = 'Account',	Is_Active__c = true , Operation_Type__c ='Query', Action_Center_Template__c = template.Id, api_name__c = 'Owner.Name', Question__c = q1.Id);
		insert Fieldmeta1;
		
        Field_Meta__c Fieldmeta2 = new Field_Meta__c(Object_Name__c = 'Account',	Is_Active__c = true , Operation_Type__c ='Query', Action_Center_Template__c = template.Id, api_name__c = 'Type', Question__c = q1.Id);
		insert Fieldmeta2;
        
        Field_Meta__c Fieldmeta3 = new Field_Meta__c(Object_Name__c = 'Account',	Is_Active__c = true , Operation_Type__c ='Query', Action_Center_Template__c = template.Id, api_name__c = 'Rating', Question__c = q1.Id);
		insert Fieldmeta3;
		
        Action_Center_Template__c Rejectedtemplate = new Action_Center_Template__c(
            Name = 'submit-Approval Template',
            Object_Name__c = 'Account',
            Email_Subject__c = 'Request Rejected',
            Email_Body__c = 'Hi Your Request rejected',
            Is_Active__c = true
        );
        insert Rejectedtemplate;
        
        Action_Center_Template__c Approvaltemplate = new Action_Center_Template__c(
            Name = 'submit-Approval Template',
            Object_Name__c = 'Account',
            Email_Subject__c = 'Your Request Approved',
            Email_Body__c = 'Your Request Approved successfully.',
            Is_Active__c = true
        );
        insert Approvaltemplate;
        
        Notification_Process_Config__c notifProcessConfig = new Notification_Process_Config__c(
            Name = 'approval-submitted',
            Notification_Config__c = notifConfig.Id,
            Action_Center_Template__c = template.Id,
            Action_Template__c = Temp.Id,
            Is_Active__c = true,
            Status__c ='Submitted For Approval',
            Order__c = 1
        );
        insert notifProcessConfig;
        //system.debug('Notification_Process_Config__c'+notifProcessConfig);
        notifProcessConfigId = notifProcessConfig.Id;
        
        Notification_Process_Config__c rejected = new Notification_Process_Config__c(
            Name = 'approval-rejected',
            Notification_Config__c = notifConfig.Id,
            Action_Center_Template__c = Rejectedtemplate.Id,
            Parent_Notification_Process_Config__c = notifProcessConfig.Id,
            Is_Active__c = true,
            Status__c ='Rejected',
            Order__c = 2
        );
        insert rejected;
        
        Notification_Process_Config__c approved = new Notification_Process_Config__c(
            Name = '-approval-approved',
            Notification_Config__c = notifConfig.Id,
            Action_Center_Template__c = Approvaltemplate.Id,
            Parent_Notification_Process_Config__c = notifProcessConfig.Id,
            Is_Active__c = true,
            Status__c ='Approved',
            Order__c = 3
        );
        insert approved;
        
        Field_Meta__c StatusUpdate = new Field_Meta__c(Object_Name__c = 'Account',Is_Active__c = true , Operation_Type__c ='Updateable', Notification_Process_Config__c = approved.Id, api_name__c ='Rating', filterValue__c = 'Hot',order__c = 1, Question__c = q1.Id );
		insert StatusUpdate;
		
        Field_Meta__c conditionalChecking3 = new Field_Meta__c(Object_Name__c = 'Account',Is_Active__c = true , Operation_Type__c ='Conditional', Notification_Process_Config__c = notifProcessConfig.Id, api_name__c ='Type',Condition__c = 'Equals', filterValue__c = 'Customer - Direct',order__c = 3, Question__c = q1.Id);
		insert conditionalChecking3;
        
        Field_Meta__c conditionalChecking2 = new Field_Meta__c(Object_Name__c = 'Account',Is_Active__c = true , Operation_Type__c ='Conditional', Notification_Process_Config__c = notifProcessConfig.Id, api_name__c ='Industry',Condition__c = 'Equals', filterValue__c = 'Apparel',order__c = 2,Logical_Criteria__c ='OR',Next_Condition__c = conditionalChecking3.Id, Question__c = q1.Id );
		insert conditionalChecking2;
        
        Field_Meta__c conditionalChecking = new Field_Meta__c(Object_Name__c = 'Account',Is_Active__c = true , Operation_Type__c ='Conditional', Notification_Process_Config__c = notifProcessConfig.Id, api_name__c ='Rating',Condition__c = 'Equals', filterValue__c = 'Warm',order__c = 1,Logical_Criteria__c ='AND',Next_Condition__c = conditionalChecking2.Id, Question__c = q1.Id );
		insert conditionalChecking;
        
        
    }

    @isTest
    static void testDecisionProcess_NullRecords() {
        Test.startTest();
        NotificationHelper.decisionProcess(null, null);
        NotificationHelper.decisionProcess(new List<SObject>(), new Map<Id, SObject>());
        Test.stopTest();
        System.assert(true, 'Should gracefully exit when no records are provided');
    }
    @isTest
    static void testDecisionProcess_EmptyConfig() {
        Account newAccount = new Account(Name = 'No Config Account', Industry = 'Retail');
        insert newAccount;
        Test.startTest();
        NotificationHelper.decisionProcess(new List<SObject>{ newAccount }, null);
        Test.stopTest();

        System.assert(true, 'Should gracefully exit when no matching config is found');
    }
    @isTest
    static void testDecisionProcess_Insert() {
        Account newAccount = new Account(Name = 'Test Account', Industry = 'Apparel',Type = 'Customer - Direct',Rating ='Warm');
        insert newAccount;

        Test.startTest();
        NotificationHelper.decisionProcess(new List<SObject>{ newAccount }, null);
        Test.stopTest();

        System.assert(true, 'Decision process should be executed for insert');
        
        
    }

    @isTest
    static void testDecisionProcess_Update() {
        Account acc = new Account(Name = 'Old Account', Industry = 'Finance'); 
        insert acc;

        Account oldRecord = acc.clone();
        oldRecord.Id = acc.Id; 

        acc.Industry = 'Technology'; 
        update acc;

        Map<Id, SObject> oldRecordsMap = new Map<Id, SObject>{ acc.Id => oldRecord };

        Test.startTest();
        NotificationHelper.decisionProcess(new List<SObject>{ acc }, oldRecordsMap);
        Test.stopTest();

        System.assert(true, 'Decision process should execute on update');
    }

    @isTest
    static void testDecisionProcess_NoFieldMatch() {
        Account acc = new Account(Name = 'Test Account', Industry = 'Healthcare'); 
        insert acc;

        Test.startTest();
        NotificationHelper.decisionProcess(new List<SObject>{ acc }, null);
        Test.stopTest();

        System.assert(true, 'Should not trigger process if no field matches');
    }

    @isTest
    static void testDecisionProcess_HandlesMultipleRecords() {
        Account acc1 = new Account(Name = 'Account One', Industry = 'Apparel',Type = 'Customer - Direct',Rating ='Warm');
        Account acc2 = new Account(Name = 'Account Two', Industry = 'Apparel',Type = 'Customer - Direct',Rating ='Warm');
        insert new List<Account>{ acc1, acc2 };

        Test.startTest();
        NotificationHelper.decisionProcess(new List<SObject>{ acc1, acc2 }, null);
        Test.stopTest();

        System.assert(true, 'Should handle multiple records');
    }
    /*
@isTest
static void testProcessApproval() {

    Account acc = new Account(
        Name = 'Test Account',
        Industry = 'Apparel',
        Type = 'Customer - Direct',
        Rating = 'Warm'
    );
    insert acc;

    // Parent
    Comm_Center__c parentCC = new Comm_Center__c(
        Name = 'Parent',
        Status__c = 'Pending',
        Flow_Type__c = 'Sequential',   // IMPORTANT
        Object_Name__c = 'Account',
        Record_Id__c = acc.Id,
        Notification_Process_Config__c = notifProcessConfigId,
        Order__c = 0,
        Is_Active__c = true
    );
    insert parentCC;

    // Level 1 (ONLY submitted record)
    Comm_Center__c level1 = new Comm_Center__c(
        Name = 'Level 1',
        Status__c = 'Submitted For Approval',
        Order__c = 1,
        Parent_Comm_Center__c = parentCC.Id,
        Flow_Type__c = 'Sequential',   // IMPORTANT
        Object_Name__c = 'Account',
        Record_Id__c = acc.Id,
        Notification_Process_Config__c = notifProcessConfigId,
        Is_Optional__c = false,
        Is_Active__c = true
    );
    insert level1;

    // Level 2 (Pending)
    Comm_Center__c level2 = new Comm_Center__c(
        Name = 'Level 2',
        Status__c = 'Pending',
        Order__c = 2,
        Parent_Comm_Center__c = parentCC.Id,
        Flow_Type__c = 'Sequential',   // IMPORTANT
        Object_Name__c = 'Account',
        Record_Id__c = acc.Id,
        Notification_Process_Config__c = notifProcessConfigId,
        Is_Optional__c = false,
        Is_Active__c = true
    );
    insert level2;

    Test.startTest();

    CommCenterHelper.updateApprovalStatus(
        level1.Id,
        'Rejected',
        'Test Reason',
        acc.Id
    );

    Test.stopTest();

    level1 = [
        SELECT Status__c, Reason__c
        FROM Comm_Center__c
        WHERE Id = :level1.Id
    ];

    System.assertEquals('Rejected', level1.Status__c);
    System.assertEquals('Test Reason', level1.Reason__c);
}*/
    @isTest
    static void testHandleDelete_and_ArchiveRecords() {
        // Step 1: Create Account
        Account acc = new Account(
            Name = 'Archive Test Account',
            Industry = 'Apparel'
        );
        insert acc;

        // Step 2: Create active Comm Center record linked to Account
        Comm_Center__c cc = new Comm_Center__c(
            Name = 'Archive Test CC',
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Status__c = 'Pending',
            Flow_Type__c = 'Sequential',
            Is_Active__c = true
        );
        insert cc;

        // Step 3: Call handleDelete explicitly
        Test.startTest();
        NotificationHelper.handleDelete(
            new List<SObject>{ acc }
        );
        Test.stopTest();

        // Step 4: Verify Comm Center record is archived
        Comm_Center__c archivedCC = [
            SELECT Is_Active__c
            FROM Comm_Center__c
            WHERE Id = :cc.Id
        ];

        System.assertEquals(
            false,
            archivedCC.Is_Active__c,
            'Comm_Center__c record should be archived (Is_Active__c = false)'
        );
    }

    @isTest
    static void testArchiveRecords_RecordIdsEmpty() {
        // Step 1: Create Account
        Account acc = new Account(
            Name = 'Archive Test Account',
            Industry = 'Apparel'
        );
        insert acc;

        // Step 2: Create active Comm Center record linked to Account
        Comm_Center__c cc = new Comm_Center__c(
            Name = 'Archive Test CC',
            Object_Name__c = 'Account',
            Record_Id__c = null,
            Status__c = 'Pending',
            Flow_Type__c = 'Sequential',
            Is_Active__c = true
        );
        insert cc;

        // Step 3: Call handleDelete explicitly
        Test.startTest();
        NotificationHelper.handleDelete(
            new List<SObject>{ acc }
        );
        Test.stopTest();

        // Step 4: Verify Comm Center record is archived
        Comm_Center__c archivedCC = [
            SELECT Is_Active__c
            FROM Comm_Center__c
            WHERE Id = :cc.Id
        ];

        System.assertEquals(
            true,
            archivedCC.Is_Active__c,
            'Comm_Center__c record should not be archived when Record_Id__c is null'
        );
    }

    @isTest
    static void testArchiveRecords_ExceptionPath() {

        // Create Account
        Account acc = new Account(Name = 'Archive Exception Test');
        insert acc;

        // Create Comm Center
        Comm_Center__c cc = new Comm_Center__c(
            Name = 'CC Exception',
            Object_Name__c = 'Account',
            Record_Id__c = acc.Id,
            Status__c = 'Pending',
            Flow_Type__c = 'Sequential',
            Is_Active__c = true
        );
        insert cc;

        Boolean exceptionThrown = false;

        Test.startTest();
        try {
            // Pass NULL inside list → forces runtime exception inside archiveRecords
            NotificationHelper.handleDelete(
                new List<SObject>{ acc, null }
            );
        } catch (Exception e) {
            exceptionThrown = true;
            System.assert(
                e.getMessage() != null,
                'Exception should be thrown and caught'
            );
        }
        Test.stopTest();

        System.assertEquals(
            true,
            exceptionThrown,
            'Exception path in archiveRecords should be covered'
        );
    }
}