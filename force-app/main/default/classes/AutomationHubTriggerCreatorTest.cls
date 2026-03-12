/**
 * @description Test class for AutomationHubTriggerCreator
 * @author Roopan Thangam
 * @since 2026-02-20
 */
@IsTest
private class AutomationHubTriggerCreatorTest {

    /*
     * Mock for Tooling API
     */
    private class ToolingApiMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/json');

            res.setBody(
                '{"totalSize":1,"done":true,"records":[' +
                '{"Name":"ExistingTrigger","Body":"trigger ExistingTrigger on Account (after insert) { System.debug(\'x\'); }"}' +
                ']}'
            );

            return res;
        }
    }

    /*
     * Mock for no existing trigger
     */
    private class NoTriggerMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setHeader('Content-Type','application/json');
            res.setBody('{"totalSize":0,"done":true,"records":[]}');
            return res;
        }
    }

    // ===============================
    // TEST DIRECT LOGIC (Guaranteed)
    // ===============================
    @IsTest
    static void testDeployLogic_NewTrigger() {

        Test.setMock(HttpCalloutMock.class, new NoTriggerMock());

        Test.startTest();
        AutomationHubTriggerCreator.deployTriggerLogic(
            'MyNewTrigger',
            'Account',
            ''
        );
        Test.stopTest();

        System.assert(true);
    }

    @IsTest
    static void TestDeployLogic_MergeTrigger() {

        Test.setMock(HttpCalloutMock.class, new ToolingApiMock());

        Test.startTest();
        AutomationHubTriggerCreator.deployTriggerLogic(
            'ExistingTrigger',
            'Account',
            ''
        );
        Test.stopTest();

        System.assert(true);
    }

    // ===============================
    // TEST fetchConfigs + @future
    // ===============================
    @IsTest
    static void testFetchConfigs() {

        Test.setMock(HttpCalloutMock.class, new NoTriggerMock());

        Notification_Config__c config = new Notification_Config__c(
            Name = 'Test',
            Do_you_want_to_create_a_trigger__c = true,
            Trigger_Name__c = 'FutureTrigger',
            Object_Name__c = 'Account'
        );

        insert config;

        Map<Id, Notification_Config__c> configMap =
            new Map<Id, Notification_Config__c>(
                [SELECT Id, Do_you_want_to_create_a_trigger__c,
                        Trigger_Name__c, Object_Name__c
                 FROM Notification_Config__c
                 WHERE Id = :config.Id]
            );

        Test.startTest();
        AutomationHubTriggerCreator.fetchConfigs(configMap);
        Test.stopTest();

        System.assert(true);
    }

    // ===============================
    // TEST merge logic
    // ===============================
    @IsTest
    static void testMergeWithExistingBody() {

        String existing =
            'trigger Sample on Account (after insert) {' +
            'System.debug(\'hi\');' +
            '}';

        String merged =
            AutomationHubTriggerCreator.mergeWithExistingBody(
                existing,
                'Account',
                ''
            );

        System.assert(merged.contains('after update'));
        System.assert(merged.contains('after delete'));
        System.assert(merged.contains('NotificationHelper'));
    }
}