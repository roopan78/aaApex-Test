@IsTest
public class CommCenterControllerTest {
    
    @TestSetup
    static void setupData() {
        // 1. Create Notification Config (master)
        Notification_Config__c notifConfig = new Notification_Config__c(
            Is_Active__c = true,
            Do_you_want_to_create_a_trigger__c = false,
            Object_Name__c = 'Account',
            Trigger_Name__c = 'TestTrigger',
            Approval_Step__c = 'Step1'
        );
        insert notifConfig;
        
        // 2. Create Notification Process Configs (detail)
        List<Notification_Process_Config__c> procConfigs = new List<Notification_Process_Config__c>();
        for (Integer i = 0; i < 2; i++) {
            procConfigs.add(new Notification_Process_Config__c(
                Name = 'Proc Config ' + i,
                Status__c = 'Submitted for Approval',
                Is_Active__c = true,
                Order__c = i,
                Notification_Config__c = notifConfig.Id // master-detail reference
            ));
        }
        insert procConfigs;
        
        // 3. Create Comm Center records (lookup to process configs)
        List<Comm_Center__c> ccList = new List<Comm_Center__c>();
        for (Integer i = 0; i < procConfigs.size(); i++) {
            ccList.add(new Comm_Center__c(
                Name = 'Comm Center ' + i,
                Status__c = 'Submitted for Approval',
                Action_Center_Name__c = 'Action ' + i,
                Action_Owner_Email_ID__c = 'owner' + i + '@test.com',
                Action_Owner_Name__c = 'Owner ' + i,
                Description__c = 'Description ' + i,
                Flow_Type__c = 'FlowType ' + i,
                Is_Email_Sent__c = false,
                Is_Optional__c = true,
                Object_Name__c = 'Account',
                Order__c = i,
                Reason__c = 'Reason ' + i,
                Record_Id__c = '00100000000000' + i, // dummy reference string
                User_Mail_ID__c = 'user' + i + '@test.com',
                User_Name__c = 'User ' + i,
                Notification_Process_Config__c = procConfigs[i].Id // proper lookup
            ));
        }
        insert ccList;
    }
    
    @IsTest
    static void testGetCommCenterList_NoConfig() {
        Test.startTest();
        List<CommCenterWrapper> results = CommCenterController.getCommCenterList();
        Test.stopTest();
        
        System.assertNotEquals(0, results.size(), 'Should return CommCenter records when no config is provided');
    }
    
    @IsTest
    static void testGetCommCenterList_WithConfig() {
        // Fetch a valid Notification_Process_Config__c Id
        List<Notification_Process_Config__c> config = [SELECT Id FROM Notification_Process_Config__c];
        
        List<Id> configId = new List<Id>();
        for (Notification_Process_Config__c no : config) {
            configId.add(no.Id);
        }
        
        Test.startTest();
        List<CommCenterWrapper> results = CommCenterController.getCommCenterList();
        Test.stopTest();
        
        System.assert(results.size() > 0, 'Should return CommCenter records for given config');
    }
}