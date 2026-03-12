public with sharing class ConfigProcessWrapper {
  @AuraEnabled
  public List<ProcessConfigWrapper> processConfig;

  public class ProcessConfigWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String status;
      @AuraEnabled public String configName;
      @AuraEnabled public String flowType;
      @AuraEnabled public String parentActionTemplateId;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public Decimal order;
      @AuraEnabled public String actionTemplateId;
      @AuraEnabled public String actionCenterTemplateId;

      @AuraEnabled public List<FieldMetaWrapper> fieldMetas;

      // Nested Template Config for this process
      @AuraEnabled public TemplateConfigWrapper templateConfig;
  }

  public class FieldMetaWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String apiName;
      @AuraEnabled public String objectApiName;
      @AuraEnabled public Decimal order;
      @AuraEnabled public String type;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public String operationalType;
      @AuraEnabled public String logicalCriteria;
      @AuraEnabled public String condition;
      @AuraEnabled public String recordType;
      @AuraEnabled public String filterValue;
      @AuraEnabled public String question;
  }

  // === Template Config (merged) ===
  public class TemplateConfigWrapper {
      @AuraEnabled public ActionTemplateWrapper actionTemplate;
      @AuraEnabled public ActionCenterTemplateWrapper actionCenterTemplate;
  }

  public class ActionTemplateWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String name;
      @AuraEnabled public String flowType;
      @AuraEnabled public List<TemplateWrapper> templates;
  }

  public class TemplateWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String name;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public Boolean isOptional;
      @AuraEnabled public Integer order;
      @AuraEnabled public String actionOwnerType;
      @AuraEnabled public String actionOwnerName;
      @AuraEnabled public String parentActionTemplateId;
  }

  public class ActionCenterTemplateWrapper {
      @AuraEnabled public String id;
      @AuraEnabled public String name;
      @AuraEnabled public String objectApiName;
      @AuraEnabled public Boolean isActive;
      @AuraEnabled public String taskSubject;
      @AuraEnabled public String taskComments;
      @AuraEnabled public Boolean isPostChatterEmail;
      @AuraEnabled public Boolean isPostChatterPushNotification;
      @AuraEnabled public String emailBody;
      @AuraEnabled public String emailSubject;
      @AuraEnabled public String notificationTitle;
      @AuraEnabled public String notificationBody;
      @AuraEnabled public String postBody;
      @AuraEnabled public String orgWideEmailAddress; // RT 20JAN26 - Org-Wide Email Address for verified sender
      @AuraEnabled public List<FieldMetaWrapper> fieldMetas;
  }
}


// previous verison 
// public with sharing class ConfigProcessWrapper {
//   @AuraEnabled
//   public List<ProcessConfigWrapper> processConfig;
//     public class ProcessConfigWrapper {
//       @AuraEnabled  public String id;
//       @AuraEnabled public String status;
//       @AuraEnabled public String configName;
//       @AuraEnabled public String flowType;
//       @AuraEnabled public String parentActionTemplateId;
//       @AuraEnabled public Boolean isActive;
//       @AuraEnabled public Decimal order;
//       @AuraEnabled public String actionTemplateId;
//       @AuraEnabled public String actionCenterTemplateId;
//       @AuraEnabled public List<FieldMetaWrapper> fieldMetas;

//   }

//   public class FieldMetaWrapper {
//     @AuraEnabled public String id;
//     @AuraEnabled public String apiName;
//     @AuraEnabled public String objectApiName;
//     @AuraEnabled public Decimal order;
//     @AuraEnabled public String type;
//     @AuraEnabled public Boolean isActive;
//     @AuraEnabled public String operationalType;
//     @AuraEnabled public String logicalCriteria;
//     @AuraEnabled public String condition;
//     @AuraEnabled public String recordType;
//     @AuraEnabled public String filterValue;
//     @AuraEnabled public String question;
// }
  
// }