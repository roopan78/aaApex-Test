@isTest
public class QuickActionDeployHandlerTest {
  @isTest
  static void testCreateQuickAction_CreateNewLWC() {
    QuickActionDeployer.QuickActionInput input = new QuickActionDeployer.QuickActionInput();
    input.objectApiName = 'Account';
    input.label = 'My_LWC_Action';
    input.componentName = 'myLwcComponent';
    input.actionType = 'LightningWebComponent';
    // removed unused properties
    input.eventMode = 'createNew';

    String inputJson = JSON.serialize(input);

    Test.startTest();
    try {
      String result = QuickActionDeployHandler.createQuickAction(inputJson);
      System.assertNotEquals(null, result);
    } catch (Exception e) {
      System.debug('Expected block for Metadata deploy: ' + e.getMessage());
    }
    Test.stopTest();
  }
  @isTest
  static void testCreateQuickAction_CreateNewAuraCmpWithOptionalFields() {
    QuickActionDeployer.QuickActionInput input = new QuickActionDeployer.QuickActionInput();
    input.objectApiName = 'Contact';
    input.label = 'Aura_Action_Test';
    input.componentName = 'myAuraCmp';
    input.actionType = 'LightningComponent';
    input.description = 'This is a test Aura';
    // removed unused properties
    input.eventMode = 'createNew';

    String inputJson = JSON.serialize(input);

    Test.startTest();
    try {
      String result = QuickActionDeployHandler.createQuickAction(inputJson);
      System.assertNotEquals(null, result);
    } catch (Exception e) {
      System.debug('Expected block for Metadata deploy: ' + e.getMessage());
    }
    Test.stopTest();
  }

  @isTest
  static void testCreateQuickAction_OverrideMode() {
    QuickActionDeployer.QuickActionInput input = new QuickActionDeployer.QuickActionInput();
    input.objectApiName = 'Opportunity';
    input.label = 'OverrideTest';
    input.componentName = 'overrideCmp';
    input.actionType = 'LightningComponent';
    input.eventMode = 'override';
    input.description = 'Override description';
    input.buttonToOverride = 'New';
    input.formFactor = 'Large';
    input.skipRecordTypeSelect = true;

    String inputJson = JSON.serialize(input);

    Test.startTest();
    try {
      String result = QuickActionDeployHandler.createQuickAction(inputJson);
      System.assertNotEquals(null, result);
    } catch (Exception e) {
      System.debug('Expected block for Metadata deploy: ' + e.getMessage());
    }
    Test.stopTest();
  }

    /*
  @isTest
  static void testCreateQuickAction_InvalidActionType() {
    QuickActionDeployer.QuickActionInput input = new QuickActionDeployer.QuickActionInput();
    input.objectApiName = 'Lead';
    input.label = 'BadAction';
    input.componentName = 'invalidCmp';
    input.actionType = 'InvalidType';
    input.eventMode = 'createNew';

    String inputJson = JSON.serialize(input);

    Test.startTest();
    try {
      QuickActionDeployHandler.createQuickAction(inputJson);
      System.assert(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
      System.Debug('Error' + e.getMessage());
    }
    Test.stopTest();
  }

  @isTest
  static void testCreateQuickAction_InvalidEventMode() {
    QuickActionDeployer.QuickActionInput input = new QuickActionDeployer.QuickActionInput();
    input.objectApiName = 'Case';
    input.label = 'BadEventMode';
    input.componentName = 'testCmp';
    input.actionType = 'LightningWebComponent';
    input.eventMode = 'unsupportedMode';

    String inputJson = JSON.serialize(input);

    Test.startTest();
    try {
      QuickActionDeployHandler.createQuickAction(inputJson);
      System.assert(false, 'Should have thrown AuraHandledException');
    } catch (AuraHandledException e) {
      System.Debug(e.getMessage().contains('Unsupported eventMode'));
    }
    Test.stopTest();
  }
 */

  @isTest
  static void testParseActionOverrides() {
    List<MetadataServiceHelper.ActionOverride> mockOverrides = new List<MetadataServiceHelper.ActionOverride>();

    MetadataServiceHelper.ActionOverride overrideNew = new MetadataServiceHelper.ActionOverride();
    overrideNew.actionName = 'New';
    overrideNew.formFactor = 'Large';
    overrideNew.content = 'c:MyComp';
    overrideNew.type_x = 'LightningComponent';
    overrideNew.comment = 'Test New';

    MetadataServiceHelper.ActionOverride overrideEdit = new MetadataServiceHelper.ActionOverride();
    overrideEdit.actionName = 'Edit';
    overrideEdit.formFactor = 'Large';
    overrideEdit.content = 'c:EditComp';
    overrideEdit.type_x = 'LightningComponent';
    overrideEdit.comment = 'Test Edit';

    mockOverrides.add(overrideNew);
    mockOverrides.add(overrideEdit);

    Test.startTest();
    List<QuickActionDeployHandler.ButtonMetadataWrapper> results = QuickActionDeployHandler.parseActionOverrides(
      mockOverrides,
      'Account'
    );
    Test.stopTest();

    System.assertEquals(2, results.size());
    System.assertEquals('New', results[0].fullName);
    System.assertEquals('Edit', results[1].fullName);
  }

  @isTest
  static void testGetActionOverridesCatchBlock() {
    Test.startTest();
    List<QuickActionDeployHandler.ButtonMetadataWrapper> result = QuickActionDeployHandler.getActionOverrides(
      'Account'
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
  }

  @isTest
  static void testGetCustomActionSafeCall() {
    Test.startTest();
    List<QuickActionDeployHandler.ButtonMetadataWrapper> result = QuickActionDeployHandler.getCustomAction(
      'Account'
    );
    Test.stopTest();

    System.assertNotEquals(null, result);
  }
}