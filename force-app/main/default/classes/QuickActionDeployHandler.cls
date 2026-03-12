public with sharing class QuickActionDeployHandler {
  @AuraEnabled
  public static String createQuickAction(String inputJson) {
    String result = QuickActionDeployer.deployQuickAction(inputJson);
    return result;
  }
  // VD 26May25 read custom/standard button details
  @AuraEnabled(cacheable=true)
  public static List<ButtonMetadataWrapper> getCustomAction(
    String objectApiName
  ) {
    List<ButtonMetadataWrapper> results = new List<ButtonMetadataWrapper>();
   // VD 10-Oct25 button Invoke changes
    for (WebLink wl : [
      SELECT
        Id,
        Name,
        Url,
        LinkType,
        OpenType,
        Description,
        DisplayType,
        PageOrSobjectType,
        CreatedDate
      FROM WebLink
      WHERE PageOrSobjectType = :objectApiName
      ORDER BY CreatedDate DESC
      LIMIT 50
    ]) {
      ButtonMetadataWrapper wrapper = new ButtonMetadataWrapper();
      wrapper.Id = wl.Id;
      wrapper.fullName = wl.Name;
      wrapper.objectApiName = wl.PageOrSobjectType;
      wrapper.comment = wl.Description;
      wrapper.buttonType = wl.LinkType;
      results.add(wrapper);
    }

    return results;
  }

  @AuraEnabled(cacheable=true)
  public static List<ButtonMetadataWrapper> getActionOverrides(
    String objectApiName
  ) {
    List<ButtonMetadataWrapper> resultList = new List<ButtonMetadataWrapper>();

    try {
      // Construct Metadata Service
      MetadataService.MetadataPort service = new MetadataService.MetadataPort();
      service.SessionHeader = new MetadataServiceHelper.SessionHeader_element();
      service.SessionHeader.sessionId = UserInfo.getSessionId();

      // Set endpoint dynamically
      String instanceUrl = System.Url.getOrgDomainUrl().toExternalForm();
      service.endpoint_x = instanceUrl + '/services/Soap/m/59.0';

      // Perform metadata read
      MetadataService.ReadOverrideResult result = service.readActionOverrideMeta(
        'CustomObject',
        new List<String>{ objectApiName }
      );

      if (result != null && result.getRecords().size() > 0) {
        MetadataService.CustomObject customObj = (MetadataService.CustomObject) result.getRecords()[0];
        System.debug('customObj.actionOverrides' + customObj.actionOverrides);
        resultList.addAll(
          parseActionOverrides(customObj.actionOverrides, objectApiName)
        );
      }
    } catch (Exception ex) {
      System.debug('Error while reading overrides: ' + ex.getMessage());
    }

    return resultList;
  }

  @TestVisible
  private static List<ButtonMetadataWrapper> parseActionOverrides(
    List<MetadataServiceHelper.ActionOverride> overrides,
    String objectApiName
  ) {
    List<ButtonMetadataWrapper> wrappers = new List<ButtonMetadataWrapper>();
    if (overrides != null) {
      for (MetadataServiceHelper.ActionOverride overrideBtn : overrides) {
        if (
          overrideBtn.formFactor == 'Large' &&
          overrideBtn.content != null &&
          (overrideBtn.actionName == 'New' ||
          overrideBtn.actionName == 'Edit')
        ) {
          ButtonMetadataWrapper wrapper = new ButtonMetadataWrapper();
          wrapper.objectApiName = objectApiName;
          wrapper.fullName = overrideBtn.actionName;
          wrapper.content = overrideBtn.content;
          wrapper.contentType = overrideBtn.type_x;
          wrapper.comment = overrideBtn.comment;
          wrappers.add(wrapper);
        }
      }
    }
    return wrappers;
  }

  public class ButtonMetadataWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String fullName;
    @AuraEnabled
    public String label;
    // @AuraEnabled public String url;
    @AuraEnabled
    public String objectApiName;
    @AuraEnabled
    public String buttonType;
    @AuraEnabled
    public String content;
    @AuraEnabled
    public String contentType;
    @AuraEnabled
    public String comment;
  }
}