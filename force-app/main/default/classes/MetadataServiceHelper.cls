/**
* Created by: Mohamed Abdul Kadher N 
* Description: To avoid size and large script issue in apex class created new MetadataServiceHelper which will contain some content of MetadaService.cls
* Created on (DD/MM/YYYY): 26/02/2025.
*/
public class MetadataServiceHelper {

  public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';

  public class ReportTypeColumnTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class LightningBoltFeatures {
      public String description;
      public Integer order;
      public String title;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] order_type_info = new String[]{'order',SOAP_M_URI,null,'1','1','false'};
      private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','order','title'};
  }

  public class ReportFilterItem {
      public String column;
      public Boolean columnToColumn;
      public Boolean isUnlocked;
      public String operator;
      public String snapshot;
      public String value;
      private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
      private String[] columnToColumn_type_info = new String[]{'columnToColumn',SOAP_M_URI,null,'0','1','false'};
      private String[] isUnlocked_type_info = new String[]{'isUnlocked',SOAP_M_URI,null,'0','1','false'};
      private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
      private String[] snapshot_type_info = new String[]{'snapshot',SOAP_M_URI,null,'0','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'column','columnToColumn','isUnlocked','operator','snapshot','value'};
  }

  public class SessionSettings {
      public Boolean disableTimeoutWarning;
      public Boolean enableCSPOnEmail;
      public Boolean enableCSRFOnGet;
      public Boolean enableCSRFOnPost;
      public Boolean enableCacheAndAutocomplete;
      public Boolean enableClickjackNonsetupSFDC;
      public Boolean enableClickjackNonsetupUser;
      public Boolean enableClickjackNonsetupUserHeaderless;
      public Boolean enableClickjackSetup;
      public Boolean enableContentSniffingProtection;
      public Boolean enablePostForSessions;
      public Boolean enableSMSIdentity;
      public Boolean enableUpgradeInsecureRequests;
      public Boolean enableXssProtection;
      public Boolean enforceIpRangesEveryRequest;
      public Boolean forceLogoutOnSessionTimeout;
      public Boolean forceRelogin;
      public Boolean hstsOnForcecomSites;
      public Boolean identityConfirmationOnEmailChange;
      public Boolean identityConfirmationOnTwoFactorRegistrationEnabled;
      public Boolean lockSessionsToDomain;
      public Boolean lockSessionsToIp;
      public String logoutURL;
      public Boolean redirectionWarning;
      public Boolean referrerPolicy;
      public Boolean requireHttpOnly;
      public Boolean requireHttps;
      public Boolean securityCentralKillSession;
      public String sessionTimeout;
      private String[] disableTimeoutWarning_type_info = new String[]{'disableTimeoutWarning',SOAP_M_URI,null,'0','1','false'};
      private String[] enableCSPOnEmail_type_info = new String[]{'enableCSPOnEmail',SOAP_M_URI,null,'0','1','false'};
      private String[] enableCSRFOnGet_type_info = new String[]{'enableCSRFOnGet',SOAP_M_URI,null,'0','1','false'};
      private String[] enableCSRFOnPost_type_info = new String[]{'enableCSRFOnPost',SOAP_M_URI,null,'0','1','false'};
      private String[] enableCacheAndAutocomplete_type_info = new String[]{'enableCacheAndAutocomplete',SOAP_M_URI,null,'0','1','false'};
      private String[] enableClickjackNonsetupSFDC_type_info = new String[]{'enableClickjackNonsetupSFDC',SOAP_M_URI,null,'0','1','false'};
      private String[] enableClickjackNonsetupUser_type_info = new String[]{'enableClickjackNonsetupUser',SOAP_M_URI,null,'0','1','false'};
      private String[] enableClickjackNonsetupUserHeaderless_type_info = new String[]{'enableClickjackNonsetupUserHeaderless',SOAP_M_URI,null,'0','1','false'};
      private String[] enableClickjackSetup_type_info = new String[]{'enableClickjackSetup',SOAP_M_URI,null,'0','1','false'};
      private String[] enableContentSniffingProtection_type_info = new String[]{'enableContentSniffingProtection',SOAP_M_URI,null,'0','1','false'};
      private String[] enablePostForSessions_type_info = new String[]{'enablePostForSessions',SOAP_M_URI,null,'0','1','false'};
      private String[] enableSMSIdentity_type_info = new String[]{'enableSMSIdentity',SOAP_M_URI,null,'0','1','false'};
      private String[] enableUpgradeInsecureRequests_type_info = new String[]{'enableUpgradeInsecureRequests',SOAP_M_URI,null,'0','1','false'};
      private String[] enableXssProtection_type_info = new String[]{'enableXssProtection',SOAP_M_URI,null,'0','1','false'};
      private String[] enforceIpRangesEveryRequest_type_info = new String[]{'enforceIpRangesEveryRequest',SOAP_M_URI,null,'0','1','false'};
      private String[] forceLogoutOnSessionTimeout_type_info = new String[]{'forceLogoutOnSessionTimeout',SOAP_M_URI,null,'0','1','false'};
      private String[] forceRelogin_type_info = new String[]{'forceRelogin',SOAP_M_URI,null,'0','1','false'};
      private String[] hstsOnForcecomSites_type_info = new String[]{'hstsOnForcecomSites',SOAP_M_URI,null,'0','1','false'};
      private String[] identityConfirmationOnEmailChange_type_info = new String[]{'identityConfirmationOnEmailChange',SOAP_M_URI,null,'0','1','false'};
      private String[] identityConfirmationOnTwoFactorRegistrationEnabled_type_info = new String[]{'identityConfirmationOnTwoFactorRegistrationEnabled',SOAP_M_URI,null,'0','1','false'};
      private String[] lockSessionsToDomain_type_info = new String[]{'lockSessionsToDomain',SOAP_M_URI,null,'0','1','false'};
      private String[] lockSessionsToIp_type_info = new String[]{'lockSessionsToIp',SOAP_M_URI,null,'0','1','false'};
      private String[] logoutURL_type_info = new String[]{'logoutURL',SOAP_M_URI,null,'0','1','false'};
      private String[] redirectionWarning_type_info = new String[]{'redirectionWarning',SOAP_M_URI,null,'0','1','false'};
      private String[] referrerPolicy_type_info = new String[]{'referrerPolicy',SOAP_M_URI,null,'0','1','false'};
      private String[] requireHttpOnly_type_info = new String[]{'requireHttpOnly',SOAP_M_URI,null,'0','1','false'};
      private String[] requireHttps_type_info = new String[]{'requireHttps',SOAP_M_URI,null,'0','1','false'};
      private String[] securityCentralKillSession_type_info = new String[]{'securityCentralKillSession',SOAP_M_URI,null,'0','1','false'};
      private String[] sessionTimeout_type_info = new String[]{'sessionTimeout',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'disableTimeoutWarning','enableCSPOnEmail','enableCSRFOnGet','enableCSRFOnPost','enableCacheAndAutocomplete','enableClickjackNonsetupSFDC','enableClickjackNonsetupUser','enableClickjackNonsetupUserHeaderless','enableClickjackSetup','enableContentSniffingProtection','enablePostForSessions','enableSMSIdentity','enableUpgradeInsecureRequests','enableXssProtection','enforceIpRangesEveryRequest','forceLogoutOnSessionTimeout','forceRelogin','hstsOnForcecomSites','identityConfirmationOnEmailChange','identityConfirmationOnTwoFactorRegistrationEnabled','lockSessionsToDomain','lockSessionsToIp','logoutURL','redirectionWarning','referrerPolicy','requireHttpOnly','requireHttps','securityCentralKillSession','sessionTimeout'};
  }

  public class ExtendedErrorDetails {
      public String extendedErrorCode;
      private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'extendedErrorCode'};
  }

  public class CustomExperienceTabSet {
      public String[] customTab;
      public String defaultTab;
      public String[] standardTab;
      private String[] customTab_type_info = new String[]{'customTab',SOAP_M_URI,null,'0','-1','false'};
      private String[] defaultTab_type_info = new String[]{'defaultTab',SOAP_M_URI,null,'1','1','false'};
      private String[] standardTab_type_info = new String[]{'standardTab',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customTab','defaultTab','standardTab'};
  }

  public class FieldMappingField {
      public String dataServiceField;
      public String dataServiceObjectName;
      public Integer priority;
      private String[] dataServiceField_type_info = new String[]{'dataServiceField',SOAP_M_URI,null,'1','1','false'};
      private String[] dataServiceObjectName_type_info = new String[]{'dataServiceObjectName',SOAP_M_URI,null,'1','1','false'};
      private String[] priority_type_info = new String[]{'priority',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dataServiceField','dataServiceObjectName','priority'};
  }

  public class FieldValue {
      public String name;
      public String value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','value'};
  }

  public class LicensedCustomPermissions {
      public String customPermission;
      public String licenseDefinition;
      private String[] customPermission_type_info = new String[]{'customPermission',SOAP_M_URI,null,'1','1','false'};
      private String[] licenseDefinition_type_info = new String[]{'licenseDefinition',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customPermission','licenseDefinition'};
  }

  public class ValueSettings {
      public String[] controllingFieldValue;
      public String valueName;
      private String[] controllingFieldValue_type_info = new String[]{'controllingFieldValue',SOAP_M_URI,null,'0','-1','false'};
      private String[] valueName_type_info = new String[]{'valueName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'controllingFieldValue','valueName'};
  }

  public class LiveChatButtonDeployments {
      public String[] deployment;
      private String[] deployment_type_info = new String[]{'deployment',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'deployment'};
  }

  public class CustomDataTypeComponent {
      public String developerSuffix;
      public Boolean enforceFieldRequiredness;
      public String label;
      public Integer length;
      public Integer precision;
      public Integer scale;
      public String sortOrder;
      public Integer sortPriority;
      public String type_x;
      private String[] developerSuffix_type_info = new String[]{'developerSuffix',SOAP_M_URI,null,'1','1','false'};
      private String[] enforceFieldRequiredness_type_info = new String[]{'enforceFieldRequiredness',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] length_type_info = new String[]{'length',SOAP_M_URI,null,'0','1','false'};
      private String[] precision_type_info = new String[]{'precision',SOAP_M_URI,null,'0','1','false'};
      private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
      private String[] sortPriority_type_info = new String[]{'sortPriority',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'developerSuffix','enforceFieldRequiredness','label','length','precision','scale','sortOrder','sortPriority','type_x'};
  }

  public class KnowledgeSitesSettings {
      public String[] site;
      private String[] site_type_info = new String[]{'site',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'site'};
  }

  public class LightningBoltImages {
      public String image;
      public Integer order;
      private String[] image_type_info = new String[]{'image',SOAP_M_URI,null,'1','1','false'};
      private String[] order_type_info = new String[]{'order',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'image','order'};
  }

  public class SearchLayouts {
      public String[] customTabListAdditionalFields;
      public String[] excludedStandardButtons;
      public String[] listViewButtons;
      public String[] lookupDialogsAdditionalFields;
      public String[] lookupFilterFields;
      public String[] lookupPhoneDialogsAdditionalFields;
      public String[] searchFilterFields;
      public String[] searchResultsAdditionalFields;
      public String[] searchResultsCustomButtons;
      private String[] customTabListAdditionalFields_type_info = new String[]{'customTabListAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] excludedStandardButtons_type_info = new String[]{'excludedStandardButtons',SOAP_M_URI,null,'0','-1','false'};
      private String[] listViewButtons_type_info = new String[]{'listViewButtons',SOAP_M_URI,null,'0','-1','false'};
      private String[] lookupDialogsAdditionalFields_type_info = new String[]{'lookupDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] lookupFilterFields_type_info = new String[]{'lookupFilterFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] lookupPhoneDialogsAdditionalFields_type_info = new String[]{'lookupPhoneDialogsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] searchFilterFields_type_info = new String[]{'searchFilterFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] searchResultsAdditionalFields_type_info = new String[]{'searchResultsAdditionalFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] searchResultsCustomButtons_type_info = new String[]{'searchResultsCustomButtons',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customTabListAdditionalFields','excludedStandardButtons','listViewButtons','lookupDialogsAdditionalFields','lookupFilterFields','lookupPhoneDialogsAdditionalFields','searchFilterFields','searchResultsAdditionalFields','searchResultsCustomButtons'};
  }

  public class PackageTypeMembers {
      public String[] members;
      public String name;
      private String[] members_type_info = new String[]{'members',SOAP_M_URI,null,'0','-1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'members','name'};
  }

  public class ProfileApplicationVisibility {
      public String application;
      public Boolean default_x;
      public Boolean visible;
      private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
      private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
      private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'application','default_x','visible'};
  }

  public class ReportParam {
      public String name;
      public String value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','value'};
  }

  public class RelatedListItem {
      public String[] customButtons;
      public String[] excludeButtons;
      public String[] fields;
      public String relatedList;
      public String sortField;
      public String sortOrder;
      private String[] customButtons_type_info = new String[]{'customButtons',SOAP_M_URI,null,'0','-1','false'};
      private String[] excludeButtons_type_info = new String[]{'excludeButtons',SOAP_M_URI,null,'0','-1','false'};
      private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
      private String[] relatedList_type_info = new String[]{'relatedList',SOAP_M_URI,null,'1','1','false'};
      private String[] sortField_type_info = new String[]{'sortField',SOAP_M_URI,null,'0','1','false'};
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customButtons','excludeButtons','fields','relatedList','sortField','sortOrder'};
  }

  public class WebLinkTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class ProfileCategoryGroupVisibility {
      public String[] dataCategories;
      public String dataCategoryGroup;
      public String visibility;
      private String[] dataCategories_type_info = new String[]{'dataCategories',SOAP_M_URI,null,'0','-1','false'};
      private String[] dataCategoryGroup_type_info = new String[]{'dataCategoryGroup',SOAP_M_URI,null,'1','1','false'};
      private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dataCategories','dataCategoryGroup','visibility'};
  }

  public class CustomTabTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class PackageVersion {
      public Integer majorNumber;
      public Integer minorNumber;
      public String namespace;
      private String[] majorNumber_type_info = new String[]{'majorNumber',SOAP_M_URI,null,'1','1','false'};
      private String[] minorNumber_type_info = new String[]{'minorNumber',SOAP_M_URI,null,'1','1','false'};
      private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'majorNumber','minorNumber','namespace'};
  }

  public class DescribeMetadataObject {
      public String[] childXmlNames;
      public String directoryName;
      public Boolean inFolder;
      public Boolean metaFile;
      public String suffix;
      public String xmlName;
      private String[] childXmlNames_type_info = new String[]{'childXmlNames',SOAP_M_URI,null,'0','-1','false'};
      private String[] directoryName_type_info = new String[]{'directoryName',SOAP_M_URI,null,'1','1','false'};
      private String[] inFolder_type_info = new String[]{'inFolder',SOAP_M_URI,null,'1','1','false'};
      private String[] metaFile_type_info = new String[]{'metaFile',SOAP_M_URI,null,'1','1','false'};
      private String[] suffix_type_info = new String[]{'suffix',SOAP_M_URI,null,'0','1','false'};
      private String[] xmlName_type_info = new String[]{'xmlName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'childXmlNames','directoryName','inFolder','metaFile','suffix','xmlName'};
  }

  public class AllOrNoneHeader_element {
      public Boolean allOrNone;
      private String[] allOrNone_type_info = new String[]{'allOrNone',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allOrNone'};
  }

  public class WorkflowTaskTranslation {
      public String description;
      public String name;
      public String subject;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] subject_type_info = new String[]{'subject',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','name','subject'};
  }

  public class QuickActionSendEmailOptions {
      public String defaultEmailTemplateName;
      public Boolean ignoreDefaultEmailTemplateSubject;
      private String[] defaultEmailTemplateName_type_info = new String[]{'defaultEmailTemplateName',SOAP_M_URI,null,'0','1','false'};
      private String[] ignoreDefaultEmailTemplateSubject_type_info = new String[]{'ignoreDefaultEmailTemplateSubject',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'defaultEmailTemplateName','ignoreDefaultEmailTemplateSubject'};
  }

  public class FlowCategoryItems {
      public String flow;
      private String[] flow_type_info = new String[]{'flow',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'flow'};
  }

  public class AppPreferences {
      public Boolean enableCustomizeMyTabs;
      public Boolean enableKeyboardShortcuts;
      public Boolean enableListViewHover;
      public Boolean enableListViewReskin;
      public Boolean enableMultiMonitorComponents;
      public Boolean enablePinTabs;
      public Boolean enableTabHover;
      public Boolean enableTabLimits;
      public Boolean saveUserSessions;
      private String[] enableCustomizeMyTabs_type_info = new String[]{'enableCustomizeMyTabs',SOAP_M_URI,null,'1','1','false'};
      private String[] enableKeyboardShortcuts_type_info = new String[]{'enableKeyboardShortcuts',SOAP_M_URI,null,'1','1','false'};
      private String[] enableListViewHover_type_info = new String[]{'enableListViewHover',SOAP_M_URI,null,'1','1','false'};
      private String[] enableListViewReskin_type_info = new String[]{'enableListViewReskin',SOAP_M_URI,null,'1','1','false'};
      private String[] enableMultiMonitorComponents_type_info = new String[]{'enableMultiMonitorComponents',SOAP_M_URI,null,'1','1','false'};
      private String[] enablePinTabs_type_info = new String[]{'enablePinTabs',SOAP_M_URI,null,'1','1','false'};
      private String[] enableTabHover_type_info = new String[]{'enableTabHover',SOAP_M_URI,null,'1','1','false'};
      private String[] enableTabLimits_type_info = new String[]{'enableTabLimits',SOAP_M_URI,null,'1','1','false'};
      private String[] saveUserSessions_type_info = new String[]{'saveUserSessions',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableCustomizeMyTabs','enableKeyboardShortcuts','enableListViewHover','enableListViewReskin','enableMultiMonitorComponents','enablePinTabs','enableTabHover','enableTabLimits','saveUserSessions'};
  }

  public class WeightedSourceCategory {
      public String sourceCategoryApiName;
      public Double weight;
      private String[] sourceCategoryApiName_type_info = new String[]{'sourceCategoryApiName',SOAP_M_URI,null,'1','1','false'};
      private String[] weight_type_info = new String[]{'weight',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'sourceCategoryApiName','weight'};
  }

  public class EmbeddedServiceQuickAction {
      public String embeddedServiceLiveAgent;
      public Integer order;
      public String quickActionDefinition;
      private String[] embeddedServiceLiveAgent_type_info = new String[]{'embeddedServiceLiveAgent',SOAP_M_URI,null,'1','1','false'};
      private String[] order_type_info = new String[]{'order',SOAP_M_URI,null,'1','1','false'};
      private String[] quickActionDefinition_type_info = new String[]{'quickActionDefinition',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'embeddedServiceLiveAgent','order','quickActionDefinition'};
  }

  public class GlobalQuickActionTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class Holiday {
      public Date activityDate;
      public String[] businessHours;
      public String description;
      public DateTime endTime;
      public Boolean isRecurring;
      public String name;
      public Integer recurrenceDayOfMonth;
      public String[] recurrenceDayOfWeek;
      public Integer recurrenceDayOfWeekMask;
      public Date recurrenceEndDate;
      public String recurrenceInstance;
      public Integer recurrenceInterval;
      public String recurrenceMonthOfYear;
      public Date recurrenceStartDate;
      public String recurrenceType;
      public DateTime startTime;
      private String[] activityDate_type_info = new String[]{'activityDate',SOAP_M_URI,null,'0','1','false'};
      private String[] businessHours_type_info = new String[]{'businessHours',SOAP_M_URI,null,'0','-1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] endTime_type_info = new String[]{'endTime',SOAP_M_URI,null,'0','1','false'};
      private String[] isRecurring_type_info = new String[]{'isRecurring',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceDayOfMonth_type_info = new String[]{'recurrenceDayOfMonth',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceDayOfWeek_type_info = new String[]{'recurrenceDayOfWeek',SOAP_M_URI,null,'0','-1','false'};
      private String[] recurrenceDayOfWeekMask_type_info = new String[]{'recurrenceDayOfWeekMask',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceEndDate_type_info = new String[]{'recurrenceEndDate',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceInstance_type_info = new String[]{'recurrenceInstance',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceInterval_type_info = new String[]{'recurrenceInterval',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceMonthOfYear_type_info = new String[]{'recurrenceMonthOfYear',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceStartDate_type_info = new String[]{'recurrenceStartDate',SOAP_M_URI,null,'0','1','false'};
      private String[] recurrenceType_type_info = new String[]{'recurrenceType',SOAP_M_URI,null,'0','1','false'};
      private String[] startTime_type_info = new String[]{'startTime',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'activityDate','businessHours','description','endTime','isRecurring','name','recurrenceDayOfMonth','recurrenceDayOfWeek','recurrenceDayOfWeekMask','recurrenceEndDate','recurrenceInstance','recurrenceInterval','recurrenceMonthOfYear','recurrenceStartDate','recurrenceType','startTime'};
  }

  public class Territory2SettingsOpportunityFilter {
      public String apexClassName;
      public Boolean enableFilter;
      public Boolean runOnCreate;
      private String[] apexClassName_type_info = new String[]{'apexClassName',SOAP_M_URI,null,'1','1','true'};
      private String[] enableFilter_type_info = new String[]{'enableFilter',SOAP_M_URI,null,'1','1','false'};
      private String[] runOnCreate_type_info = new String[]{'runOnCreate',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apexClassName','enableFilter','runOnCreate'};
  }

  public class StrategyNode {
      public String definition;
      public String description;
      public String name;
      public String parentNode;
      public Integer type_x;
      private String[] definition_type_info = new String[]{'definition',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] parentNode_type_info = new String[]{'parentNode',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'definition','description','name','parentNode','type_x'};
  }

  public class Attachment {
      public String content;
      public String name;
      private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'content','name'};
  }

  public class PathAssistantStep {
      public String[] fieldNames;
      public String info;
      public String picklistValueName;
      private String[] fieldNames_type_info = new String[]{'fieldNames',SOAP_M_URI,null,'0','-1','false'};
      private String[] info_type_info = new String[]{'info',SOAP_M_URI,null,'0','1','false'};
      private String[] picklistValueName_type_info = new String[]{'picklistValueName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fieldNames','info','picklistValueName'};
  }

  public class ChannelLayoutItem {
      public String field;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field'};
  }

  public class CustomApplicationTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class FiscalYearSettings {
      public String fiscalYearNameBasedOn;
      public String startMonth;
      private String[] fiscalYearNameBasedOn_type_info = new String[]{'fiscalYearNameBasedOn',SOAP_M_URI,null,'0','1','false'};
      private String[] startMonth_type_info = new String[]{'startMonth',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fiscalYearNameBasedOn','startMonth'};
  }

  public class Approver {
      public String name;
      public String type_x;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','type_x'};
  }

  public class ObjectNameCaseValue {
      public String article;
      public String caseType;
      public Boolean plural;
      public String possessive;
      public String value;
      private String[] article_type_info = new String[]{'article',SOAP_M_URI,null,'0','1','false'};
      private String[] caseType_type_info = new String[]{'caseType',SOAP_M_URI,null,'0','1','false'};
      private String[] plural_type_info = new String[]{'plural',SOAP_M_URI,null,'0','1','false'};
      private String[] possessive_type_info = new String[]{'possessive',SOAP_M_URI,null,'0','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'article','caseType','plural','possessive','value'};
  }

  public class SiteWebAddress {
      public String certificate;
      public String domainName;
      public Boolean primary;
      private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
      private String[] domainName_type_info = new String[]{'domainName',SOAP_M_URI,null,'1','1','false'};
      private String[] primary_type_info = new String[]{'primary',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'certificate','domainName','primary'};
  }

  public class FlowInputValidationRule {
      public String errorMessage;
      public String formulaExpression;
      private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
      private String[] formulaExpression_type_info = new String[]{'formulaExpression',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'errorMessage','formulaExpression'};
  }

  public class LookupFilterTranslation {
      public String errorMessage;
      public String informationalMessage;
      private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
      private String[] informationalMessage_type_info = new String[]{'informationalMessage',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'errorMessage','informationalMessage'};
  }

  public class LetterheadLine {
      public String color;
      public Integer height;
      private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'1','1','false'};
      private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'color','height'};
  }

  public class ChatterAnswersReputationLevel {
      public String name;
      public Integer value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','value'};
  }

  public class WaveXmdDate {
      public String alias;
      public Boolean compact;
      public String dateFieldDay;
      public String dateFieldEpochDay;
      public String dateFieldEpochSecond;
      public String dateFieldFiscalMonth;
      public String dateFieldFiscalQuarter;
      public String dateFieldFiscalWeek;
      public String dateFieldFiscalYear;
      public String dateFieldFullYear;
      public String dateFieldHour;
      public String dateFieldMinute;
      public String dateFieldMonth;
      public String dateFieldQuarter;
      public String dateFieldSecond;
      public String dateFieldWeek;
      public String dateFieldYear;
      public String description;
      public Integer firstDayOfWeek;
      public Integer fiscalMonthOffset;
      public Boolean isYearEndFiscalYear;
      public String label;
      public Boolean showInExplorer;
      public Integer sortIndex;
      private String[] alias_type_info = new String[]{'alias',SOAP_M_URI,null,'1','1','false'};
      private String[] compact_type_info = new String[]{'compact',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldDay_type_info = new String[]{'dateFieldDay',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldEpochDay_type_info = new String[]{'dateFieldEpochDay',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldEpochSecond_type_info = new String[]{'dateFieldEpochSecond',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldFiscalMonth_type_info = new String[]{'dateFieldFiscalMonth',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldFiscalQuarter_type_info = new String[]{'dateFieldFiscalQuarter',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldFiscalWeek_type_info = new String[]{'dateFieldFiscalWeek',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldFiscalYear_type_info = new String[]{'dateFieldFiscalYear',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldFullYear_type_info = new String[]{'dateFieldFullYear',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldHour_type_info = new String[]{'dateFieldHour',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldMinute_type_info = new String[]{'dateFieldMinute',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldMonth_type_info = new String[]{'dateFieldMonth',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldQuarter_type_info = new String[]{'dateFieldQuarter',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldSecond_type_info = new String[]{'dateFieldSecond',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldWeek_type_info = new String[]{'dateFieldWeek',SOAP_M_URI,null,'0','1','false'};
      private String[] dateFieldYear_type_info = new String[]{'dateFieldYear',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] firstDayOfWeek_type_info = new String[]{'firstDayOfWeek',SOAP_M_URI,null,'1','1','false'};
      private String[] fiscalMonthOffset_type_info = new String[]{'fiscalMonthOffset',SOAP_M_URI,null,'1','1','false'};
      private String[] isYearEndFiscalYear_type_info = new String[]{'isYearEndFiscalYear',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] showInExplorer_type_info = new String[]{'showInExplorer',SOAP_M_URI,null,'0','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'alias','compact','dateFieldDay','dateFieldEpochDay','dateFieldEpochSecond','dateFieldFiscalMonth','dateFieldFiscalQuarter','dateFieldFiscalWeek','dateFieldFiscalYear','dateFieldFullYear','dateFieldHour','dateFieldMinute','dateFieldMonth','dateFieldQuarter','dateFieldSecond','dateFieldWeek','dateFieldYear','description','firstDayOfWeek','fiscalMonthOffset','isYearEndFiscalYear','label','showInExplorer','sortIndex'};
  }

  public class PublicGroups {
      public String[] publicGroup;
      private String[] publicGroup_type_info = new String[]{'publicGroup',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'publicGroup'};
  }

  public class FeedLayoutFilter {
      public String feedFilterName;
      public String feedFilterType;
      public String feedItemType;
      private String[] feedFilterName_type_info = new String[]{'feedFilterName',SOAP_M_URI,null,'0','1','false'};
      private String[] feedFilterType_type_info = new String[]{'feedFilterType',SOAP_M_URI,null,'1','1','false'};
      private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'feedFilterName','feedFilterType','feedItemType'};
  }

  public class State {
      public Boolean active;
      public String integrationValue;
      public String isoCode;
      public String label;
      public Boolean standard;
      public Boolean visible;
      private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
      private String[] integrationValue_type_info = new String[]{'integrationValue',SOAP_M_URI,null,'1','1','false'};
      private String[] isoCode_type_info = new String[]{'isoCode',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] standard_type_info = new String[]{'standard',SOAP_M_URI,null,'1','1','false'};
      private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'active','integrationValue','isoCode','label','standard','visible'};
  }

  public class SupervisorAgentConfigSkills {
      public String[] skill;
      private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'skill'};
  }

  public class ActionOverride {
      public String actionName;
      public String comment;
      public String content;
      public String formFactor;
      // VD 26May25 standard button override changes
      public String pageOrSobjectType;
      public Boolean skipRecordTypeSelect;
      public String type_x;
      private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'0','1','false'};
      private String[] comment_type_info = new String[]{'comment',SOAP_M_URI,null,'0','1','false'};
      private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
      private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'0','1','false'};
      private String[] skipRecordTypeSelect_type_info = new String[]{'skipRecordTypeSelect',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'actionName','comment','content','formFactor','skipRecordTypeSelect','type_x'};
  }

  public class WebToCaseSettings {
      public String caseOrigin;
      public String defaultResponseTemplate;
      public Boolean enableWebToCase;
      private String[] caseOrigin_type_info = new String[]{'caseOrigin',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultResponseTemplate_type_info = new String[]{'defaultResponseTemplate',SOAP_M_URI,null,'0','1','false'};
      private String[] enableWebToCase_type_info = new String[]{'enableWebToCase',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'caseOrigin','defaultResponseTemplate','enableWebToCase'};
  }

  public class FileProperties {
      public String createdById;
      public String createdByName;
      public DateTime createdDate;
      public String fileName;
      public String fullName;
      public String id;
      public String lastModifiedById;
      public String lastModifiedByName;
      public DateTime lastModifiedDate;
      public String manageableState;
      public String namespacePrefix;
      public String type_x;
      private String[] createdById_type_info = new String[]{'createdById',SOAP_M_URI,null,'1','1','false'};
      private String[] createdByName_type_info = new String[]{'createdByName',SOAP_M_URI,null,'1','1','false'};
      private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
      private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
      private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] lastModifiedById_type_info = new String[]{'lastModifiedById',SOAP_M_URI,null,'1','1','false'};
      private String[] lastModifiedByName_type_info = new String[]{'lastModifiedByName',SOAP_M_URI,null,'1','1','false'};
      private String[] lastModifiedDate_type_info = new String[]{'lastModifiedDate',SOAP_M_URI,null,'1','1','false'};
      private String[] manageableState_type_info = new String[]{'manageableState',SOAP_M_URI,null,'0','1','false'};
      private String[] namespacePrefix_type_info = new String[]{'namespacePrefix',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'createdById','createdByName','createdDate','fileName','fullName','id','lastModifiedById','lastModifiedByName','lastModifiedDate','manageableState','namespacePrefix','type_x'};
  }

  public class ReportTimeFrameFilter {
      public String dateColumn;
      public Date endDate;
      public String interval;
      public Date startDate;
      private String[] dateColumn_type_info = new String[]{'dateColumn',SOAP_M_URI,null,'1','1','false'};
      private String[] endDate_type_info = new String[]{'endDate',SOAP_M_URI,null,'0','1','false'};
      private String[] interval_type_info = new String[]{'interval',SOAP_M_URI,null,'1','1','false'};
      private String[] startDate_type_info = new String[]{'startDate',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dateColumn','endDate','interval','startDate'};
  }

  public class ContentAssetLink {
      public String access;
      public Boolean isManagingWorkspace;
      public String name;
      private String[] access_type_info = new String[]{'access',SOAP_M_URI,null,'1','1','false'};
      private String[] isManagingWorkspace_type_info = new String[]{'isManagingWorkspace',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'access','isManagingWorkspace','name'};
  }

  public class FeedItemSettings {
      public Integer characterLimit;
      public Boolean collapseThread;
      public String displayFormat;
      public String feedItemType;
      private String[] characterLimit_type_info = new String[]{'characterLimit',SOAP_M_URI,null,'0','1','false'};
      private String[] collapseThread_type_info = new String[]{'collapseThread',SOAP_M_URI,null,'0','1','false'};
      private String[] displayFormat_type_info = new String[]{'displayFormat',SOAP_M_URI,null,'0','1','false'};
      private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'characterLimit','collapseThread','displayFormat','feedItemType'};
  }

  public class TouchMobileSettings {
      public Boolean enableTouchAppIPad;
      public Boolean enableTouchAppIPhone;
      public Boolean enableTouchBrowserIPad;
      public Boolean enableTouchIosPhone;
      public Boolean enableVisualforceInTouch;
      private String[] enableTouchAppIPad_type_info = new String[]{'enableTouchAppIPad',SOAP_M_URI,null,'0','1','false'};
      private String[] enableTouchAppIPhone_type_info = new String[]{'enableTouchAppIPhone',SOAP_M_URI,null,'0','1','false'};
      private String[] enableTouchBrowserIPad_type_info = new String[]{'enableTouchBrowserIPad',SOAP_M_URI,null,'0','1','false'};
      private String[] enableTouchIosPhone_type_info = new String[]{'enableTouchIosPhone',SOAP_M_URI,null,'0','1','false'};
      private String[] enableVisualforceInTouch_type_info = new String[]{'enableVisualforceInTouch',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableTouchAppIPad','enableTouchAppIPhone','enableTouchBrowserIPad','enableTouchIosPhone','enableVisualforceInTouch'};
  }

  public class DebuggingInfo_element {
      public String debugLog;
      private String[] debugLog_type_info = new String[]{'debugLog',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'debugLog'};
  }

  public class ReportTypeColumn {
      public Boolean checkedByDefault;
      public String displayNameOverride;
      public String field;
      public String table;
      private String[] checkedByDefault_type_info = new String[]{'checkedByDefault',SOAP_M_URI,null,'1','1','false'};
      private String[] displayNameOverride_type_info = new String[]{'displayNameOverride',SOAP_M_URI,null,'0','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] table_type_info = new String[]{'table',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'checkedByDefault','displayNameOverride','field','table'};
  }

  public class RecordTypeTranslation {
      public String description;
      public String label;
      public String name;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','label','name'};
  }

  public class WorkflowActionReference {
      public String name;
      public String type_x;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','type_x'};
  }

  public class FilterItem {
      public String field;
      public String operation;
      public String value;
      public String valueField;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] valueField_type_info = new String[]{'valueField',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','operation','value','valueField'};
  }

  public class OpportunityListFieldsUnselectedSettings {
      public String[] field;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field'};
  }

  public class ReportChartComponentLayoutItem {
      public Boolean cacheData;
      public String contextFilterableField;
      public String error;
      public Boolean hideOnError;
      public Boolean includeContext;
      public String reportName;
      public Boolean showTitle;
      public String size;
      private String[] cacheData_type_info = new String[]{'cacheData',SOAP_M_URI,null,'0','1','false'};
      private String[] contextFilterableField_type_info = new String[]{'contextFilterableField',SOAP_M_URI,null,'0','1','false'};
      private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
      private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
      private String[] includeContext_type_info = new String[]{'includeContext',SOAP_M_URI,null,'0','1','false'};
      private String[] reportName_type_info = new String[]{'reportName',SOAP_M_URI,null,'1','1','false'};
      private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
      private String[] size_type_info = new String[]{'size',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'cacheData','contextFilterableField','error','hideOnError','includeContext','reportName','showTitle','size'};
  }

  public class ConnectedAppCanvasConfig {
      public String accessMethod;
      public String canvasUrl;
      public String lifecycleClass;
      public String[] locations;
      public String[] options;
      public String samlInitiationMethod;
      private String[] accessMethod_type_info = new String[]{'accessMethod',SOAP_M_URI,null,'1','1','false'};
      private String[] canvasUrl_type_info = new String[]{'canvasUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] lifecycleClass_type_info = new String[]{'lifecycleClass',SOAP_M_URI,null,'0','1','false'};
      private String[] locations_type_info = new String[]{'locations',SOAP_M_URI,null,'0','-1','false'};
      private String[] options_type_info = new String[]{'options',SOAP_M_URI,null,'0','-1','false'};
      private String[] samlInitiationMethod_type_info = new String[]{'samlInitiationMethod',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'accessMethod','canvasUrl','lifecycleClass','locations','options','samlInitiationMethod'};
  }

  public class QuotasSettings {
      public Boolean showQuotas;
      private String[] showQuotas_type_info = new String[]{'showQuotas',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'showQuotas'};
  }

  public class EmailToCaseRoutingAddress {
      public String addressType;
      public String authorizedSenders;
      public String caseOrigin;
      public String caseOwner;
      public String caseOwnerType;
      public String casePriority;
      public Boolean createTask;
      public String emailAddress;
      public String emailServicesAddress;
      public Boolean isVerified;
      public String routingName;
      public Boolean saveEmailHeaders;
      public String taskStatus;
      private String[] addressType_type_info = new String[]{'addressType',SOAP_M_URI,null,'0','1','false'};
      private String[] authorizedSenders_type_info = new String[]{'authorizedSenders',SOAP_M_URI,null,'0','1','false'};
      private String[] caseOrigin_type_info = new String[]{'caseOrigin',SOAP_M_URI,null,'0','1','false'};
      private String[] caseOwner_type_info = new String[]{'caseOwner',SOAP_M_URI,null,'0','1','false'};
      private String[] caseOwnerType_type_info = new String[]{'caseOwnerType',SOAP_M_URI,null,'0','1','false'};
      private String[] casePriority_type_info = new String[]{'casePriority',SOAP_M_URI,null,'0','1','false'};
      private String[] createTask_type_info = new String[]{'createTask',SOAP_M_URI,null,'0','1','false'};
      private String[] emailAddress_type_info = new String[]{'emailAddress',SOAP_M_URI,null,'0','1','false'};
      private String[] emailServicesAddress_type_info = new String[]{'emailServicesAddress',SOAP_M_URI,null,'0','1','false'};
      private String[] isVerified_type_info = new String[]{'isVerified',SOAP_M_URI,null,'0','1','false'};
      private String[] routingName_type_info = new String[]{'routingName',SOAP_M_URI,null,'0','1','false'};
      private String[] saveEmailHeaders_type_info = new String[]{'saveEmailHeaders',SOAP_M_URI,null,'0','1','false'};
      private String[] taskStatus_type_info = new String[]{'taskStatus',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'addressType','authorizedSenders','caseOrigin','caseOwner','caseOwnerType','casePriority','createTask','emailAddress','emailServicesAddress','isVerified','routingName','saveEmailHeaders','taskStatus'};
  }

  public class PermissionSetTabSetting {
      public String tab;
      public String visibility;
      private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
      private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'tab','visibility'};
  }

  public class ReportHistoricalSelector {
      public String[] snapshot;
      private String[] snapshot_type_info = new String[]{'snapshot',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'snapshot'};
  }

  public class Users {
      public String[] user_x;
      private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'user_x'};
  }

  public class PermissionSetUserPermission {
      public Boolean enabled;
      public String name;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','name'};
  }

  public class SharingRecalculation {
      public String className;
      private String[] className_type_info = new String[]{'className',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'className'};
  }

  public class FieldSetTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class LiveAgentConfig {
      public Boolean enableLiveChat;
      public Boolean openNewAccountSubtab;
      public Boolean openNewCaseSubtab;
      public Boolean openNewContactSubtab;
      public Boolean openNewLeadSubtab;
      public Boolean openNewVFPageSubtab;
      public String[] pageNamesToOpen;
      public Boolean showKnowledgeArticles;
      private String[] enableLiveChat_type_info = new String[]{'enableLiveChat',SOAP_M_URI,null,'0','1','false'};
      private String[] openNewAccountSubtab_type_info = new String[]{'openNewAccountSubtab',SOAP_M_URI,null,'0','1','false'};
      private String[] openNewCaseSubtab_type_info = new String[]{'openNewCaseSubtab',SOAP_M_URI,null,'0','1','false'};
      private String[] openNewContactSubtab_type_info = new String[]{'openNewContactSubtab',SOAP_M_URI,null,'0','1','false'};
      private String[] openNewLeadSubtab_type_info = new String[]{'openNewLeadSubtab',SOAP_M_URI,null,'0','1','false'};
      private String[] openNewVFPageSubtab_type_info = new String[]{'openNewVFPageSubtab',SOAP_M_URI,null,'0','1','false'};
      private String[] pageNamesToOpen_type_info = new String[]{'pageNamesToOpen',SOAP_M_URI,null,'0','-1','false'};
      private String[] showKnowledgeArticles_type_info = new String[]{'showKnowledgeArticles',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableLiveChat','openNewAccountSubtab','openNewCaseSubtab','openNewContactSubtab','openNewLeadSubtab','openNewVFPageSubtab','pageNamesToOpen','showKnowledgeArticles'};
  }

  public class AdjustmentsSettings {
      public Boolean enableAdjustments;
      public Boolean enableOwnerAdjustments;
      private String[] enableAdjustments_type_info = new String[]{'enableAdjustments',SOAP_M_URI,null,'1','1','false'};
      private String[] enableOwnerAdjustments_type_info = new String[]{'enableOwnerAdjustments',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableAdjustments','enableOwnerAdjustments'};
  }

  public class SummaryLayoutItem {
      public String customLink;
      public String field;
      public Integer posX;
      public Integer posY;
      public Integer posZ;
      private String[] customLink_type_info = new String[]{'customLink',SOAP_M_URI,null,'0','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
      private String[] posX_type_info = new String[]{'posX',SOAP_M_URI,null,'1','1','false'};
      private String[] posY_type_info = new String[]{'posY',SOAP_M_URI,null,'0','1','false'};
      private String[] posZ_type_info = new String[]{'posZ',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customLink','field','posX','posY','posZ'};
  }

  public class QuickActionLayoutItem {
      public Boolean emptySpace;
      public String field;
      public String uiBehavior;
      private String[] emptySpace_type_info = new String[]{'emptySpace',SOAP_M_URI,null,'0','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
      private String[] uiBehavior_type_info = new String[]{'uiBehavior',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'emptySpace','field','uiBehavior'};
  }

  public class CommunityTemplateBundleInfo {
      public String description;
      public String image;
      public Integer order;
      public String title;
      public String type_x;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] image_type_info = new String[]{'image',SOAP_M_URI,null,'0','1','false'};
      private String[] order_type_info = new String[]{'order',SOAP_M_URI,null,'1','1','false'};
      private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','image','order','title','type_x'};
  }

  public class UiFormulaCriterion {
      public String leftValue;
      public String operator;
      public String rightValue;
      private String[] leftValue_type_info = new String[]{'leftValue',SOAP_M_URI,null,'1','1','false'};
      private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
      private String[] rightValue_type_info = new String[]{'rightValue',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'leftValue','operator','rightValue'};
  }

  public class AccountSharingRuleSettings {
      public String caseAccessLevel;
      public String contactAccessLevel;
      public String opportunityAccessLevel;
      private String[] caseAccessLevel_type_info = new String[]{'caseAccessLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] contactAccessLevel_type_info = new String[]{'contactAccessLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] opportunityAccessLevel_type_info = new String[]{'opportunityAccessLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'caseAccessLevel','contactAccessLevel','opportunityAccessLevel'};
  }

  public class AgentConfigButtons {
      public String[] button;
      private String[] button_type_info = new String[]{'button',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'button'};
  }

  public class CustomShortcut {
      public String description;
      public String eventName;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] eventName_type_info = new String[]{'eventName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','eventName'};
  }

  public class SessionHeader_element {
      public String sessionId;
      private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'sessionId'};
  }

  public class ProfileCustomPermissions {
      public Boolean enabled;
      public String name;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','name'};
  }

  public class deployRecentValidationResponse_element {
      public String result;
      private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'result'};
  }

  public class IpRange {
      public String description;
      public String end_x;
      public String start;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] end_x_type_info = new String[]{'end',SOAP_M_URI,null,'0','1','false'};
      private String[] start_type_info = new String[]{'start',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','end_x','start'};
  }

  public class deployRecentValidation_element {
      public String validationId;
      private String[] validationId_type_info = new String[]{'validationId',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'validationId'};
  }

  public class FeedFilterCriterion {
      public String feedItemType;
      public String feedItemVisibility;
      public String relatedSObjectType;
      private String[] feedItemType_type_info = new String[]{'feedItemType',SOAP_M_URI,null,'1','1','false'};
      private String[] feedItemVisibility_type_info = new String[]{'feedItemVisibility',SOAP_M_URI,null,'0','1','false'};
      private String[] relatedSObjectType_type_info = new String[]{'relatedSObjectType',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'feedItemType','feedItemVisibility','relatedSObjectType'};
  }

  public class KnowledgeLanguage {
      public Boolean active;
      public String defaultAssignee;
      public String defaultAssigneeType;
      public String defaultReviewer;
      public String defaultReviewerType;
      public String name;
      private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultAssignee_type_info = new String[]{'defaultAssignee',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultAssigneeType_type_info = new String[]{'defaultAssigneeType',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultReviewer_type_info = new String[]{'defaultReviewer',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultReviewerType_type_info = new String[]{'defaultReviewerType',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'active','defaultAssignee','defaultAssigneeType','defaultReviewer','defaultReviewerType','name'};
  }

  public class DeployOptions {
      public Boolean allowMissingFiles;
      public Boolean autoUpdatePackage;
      public Boolean checkOnly;
      public Boolean ignoreWarnings;
      public Boolean performRetrieve;
      public Boolean purgeOnDelete;
      public Boolean rollbackOnError;
      public String[] runTests;
      public Boolean singlePackage;
      public String testLevel;
      private String[] allowMissingFiles_type_info = new String[]{'allowMissingFiles',SOAP_M_URI,null,'1','1','false'};
      private String[] autoUpdatePackage_type_info = new String[]{'autoUpdatePackage',SOAP_M_URI,null,'1','1','false'};
      private String[] checkOnly_type_info = new String[]{'checkOnly',SOAP_M_URI,null,'1','1','false'};
      private String[] ignoreWarnings_type_info = new String[]{'ignoreWarnings',SOAP_M_URI,null,'1','1','false'};
      private String[] performRetrieve_type_info = new String[]{'performRetrieve',SOAP_M_URI,null,'1','1','false'};
      private String[] purgeOnDelete_type_info = new String[]{'purgeOnDelete',SOAP_M_URI,null,'1','1','false'};
      private String[] rollbackOnError_type_info = new String[]{'rollbackOnError',SOAP_M_URI,null,'1','1','false'};
      private String[] runTests_type_info = new String[]{'runTests',SOAP_M_URI,null,'0','-1','false'};
      private String[] singlePackage_type_info = new String[]{'singlePackage',SOAP_M_URI,null,'1','1','false'};
      private String[] testLevel_type_info = new String[]{'testLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allowMissingFiles','autoUpdatePackage','checkOnly','ignoreWarnings','performRetrieve','purgeOnDelete','rollbackOnError','runTests','singlePackage','testLevel'};
  }

  public class ProfileLoginHours {
      public String fridayEnd;
      public String fridayStart;
      public String mondayEnd;
      public String mondayStart;
      public String saturdayEnd;
      public String saturdayStart;
      public String sundayEnd;
      public String sundayStart;
      public String thursdayEnd;
      public String thursdayStart;
      public String tuesdayEnd;
      public String tuesdayStart;
      public String wednesdayEnd;
      public String wednesdayStart;
      private String[] fridayEnd_type_info = new String[]{'fridayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] fridayStart_type_info = new String[]{'fridayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] mondayEnd_type_info = new String[]{'mondayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] mondayStart_type_info = new String[]{'mondayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] saturdayEnd_type_info = new String[]{'saturdayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] saturdayStart_type_info = new String[]{'saturdayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] sundayEnd_type_info = new String[]{'sundayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] sundayStart_type_info = new String[]{'sundayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] thursdayEnd_type_info = new String[]{'thursdayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] thursdayStart_type_info = new String[]{'thursdayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] tuesdayEnd_type_info = new String[]{'tuesdayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] tuesdayStart_type_info = new String[]{'tuesdayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] wednesdayEnd_type_info = new String[]{'wednesdayEnd',SOAP_M_URI,null,'0','1','false'};
      private String[] wednesdayStart_type_info = new String[]{'wednesdayStart',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fridayEnd','fridayStart','mondayEnd','mondayStart','saturdayEnd','saturdayStart','sundayEnd','sundayStart','thursdayEnd','thursdayStart','tuesdayEnd','tuesdayStart','wednesdayEnd','wednesdayStart'};
  }

  public class PermissionSetFieldPermissions {
      public Boolean editable;
      public String field;
      public Boolean readable;
      private String[] editable_type_info = new String[]{'editable',SOAP_M_URI,null,'1','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] readable_type_info = new String[]{'readable',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'editable','field','readable'};
  }

  public class VisualizationType {
      public String description;
      public String developerName;
      public String icon;
      public String masterLabel;
      public String scriptBootstrapMethod;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
      private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'1','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] scriptBootstrapMethod_type_info = new String[]{'scriptBootstrapMethod',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','developerName','icon','masterLabel','scriptBootstrapMethod'};
  }

  public class CustomMetadataValue {
      public String field;
      public String value;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','true'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','value'};
  }

  public class ArticleTypeTemplate {
      public String channel;
      public String page_x;
      public String template;
      private String[] channel_type_info = new String[]{'channel',SOAP_M_URI,null,'1','1','false'};
      private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
      private String[] template_type_info = new String[]{'template',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'channel','page_x','template'};
  }

  public class LetterheadHeaderFooter {
      public String backgroundColor;
      public Integer height;
      public String horizontalAlignment;
      public String logo;
      public String verticalAlignment;
      private String[] backgroundColor_type_info = new String[]{'backgroundColor',SOAP_M_URI,null,'1','1','false'};
      private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'1','1','false'};
      private String[] horizontalAlignment_type_info = new String[]{'horizontalAlignment',SOAP_M_URI,null,'0','1','false'};
      private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
      private String[] verticalAlignment_type_info = new String[]{'verticalAlignment',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'backgroundColor','height','horizontalAlignment','logo','verticalAlignment'};
  }

  public class PicklistValueTranslation {
      public String masterLabel;
      public String translation;
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] translation_type_info = new String[]{'translation',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'masterLabel','translation'};
  }

  public class AsyncResult {
      public Boolean done;
      public String id;
      public String message;
      public String state;
      public String statusCode;
      private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'0','1','false'};
      private String[] state_type_info = new String[]{'state',SOAP_M_URI,null,'1','1','false'};
      private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'done','id','message','state','statusCode'};
  }

  public class LightningBoltItems {
      public String name;
      public String type_x;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','type_x'};
  }

  public class ConnectedAppIpRange {
      public String description;
      public String end_x;
      public String start;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] end_x_type_info = new String[]{'end',SOAP_M_URI,null,'1','1','false'};
      private String[] start_type_info = new String[]{'start',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','end_x','start'};
  }

  public class LayoutSectionTranslation {
      public String label;
      public String section;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] section_type_info = new String[]{'section',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','section'};
  }

  public class ApprovalSubmitter {
      public String submitter;
      public String type_x;
      private String[] submitter_type_info = new String[]{'submitter',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'submitter','type_x'};
  }

  public class LiveChatDeploymentDomainWhitelist {
      public String[] domain;
      private String[] domain_type_info = new String[]{'domain',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'domain'};
  }

  public class PermissionSetRecordTypeVisibility {
      public String recordType;
      public Boolean visible;
      private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
      private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'recordType','visible'};
  }

  public class WaveXmdOrganization {
      public String instanceUrl;
      public String label;
      public String organizationIdentifier;
      public Integer sortIndex;
      private String[] instanceUrl_type_info = new String[]{'instanceUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] organizationIdentifier_type_info = new String[]{'organizationIdentifier',SOAP_M_URI,null,'1','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'instanceUrl','label','organizationIdentifier','sortIndex'};
  }

  public class cancelDeploy_element {
      public String String_x;
      private String[] String_x_type_info = new String[]{'String',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'String_x'};
  }

  public class RunTestFailure {
      public String id;
      public String message;
      public String methodName;
      public String name;
      public String namespace;
      public String packageName;
      public Boolean seeAllData;
      public String stackTrace;
      public Double time_x;
      public String type_x;
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
      private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','true'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
      private String[] packageName_type_info = new String[]{'packageName',SOAP_M_URI,null,'1','1','false'};
      private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
      private String[] stackTrace_type_info = new String[]{'stackTrace',SOAP_M_URI,null,'1','1','true'};
      private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'id','message','methodName','name','namespace','packageName','seeAllData','stackTrace','time_x','type_x'};
  }

  public class ConnectedAppMobileDetailConfig {
      public String applicationBinaryFile;
      public String applicationBinaryFileName;
      public String applicationBundleIdentifier;
      public Integer applicationFileLength;
      public String applicationIconFile;
      public String applicationIconFileName;
      public String applicationInstallUrl;
      public String devicePlatform;
      public String deviceType;
      public String minimumOsVersion;
      public Boolean privateApp;
      public String version;
      private String[] applicationBinaryFile_type_info = new String[]{'applicationBinaryFile',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationBinaryFileName_type_info = new String[]{'applicationBinaryFileName',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationBundleIdentifier_type_info = new String[]{'applicationBundleIdentifier',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationFileLength_type_info = new String[]{'applicationFileLength',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationIconFile_type_info = new String[]{'applicationIconFile',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationIconFileName_type_info = new String[]{'applicationIconFileName',SOAP_M_URI,null,'0','1','false'};
      private String[] applicationInstallUrl_type_info = new String[]{'applicationInstallUrl',SOAP_M_URI,null,'0','1','false'};
      private String[] devicePlatform_type_info = new String[]{'devicePlatform',SOAP_M_URI,null,'1','1','false'};
      private String[] deviceType_type_info = new String[]{'deviceType',SOAP_M_URI,null,'0','1','false'};
      private String[] minimumOsVersion_type_info = new String[]{'minimumOsVersion',SOAP_M_URI,null,'0','1','false'};
      private String[] privateApp_type_info = new String[]{'privateApp',SOAP_M_URI,null,'0','1','false'};
      private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'applicationBinaryFile','applicationBinaryFileName','applicationBundleIdentifier','applicationFileLength','applicationIconFile','applicationIconFileName','applicationInstallUrl','devicePlatform','deviceType','minimumOsVersion','privateApp','version'};
  }

  public class NetworkPageOverride {
      public String changePasswordPageOverrideSetting;
      public String forgotPasswordPageOverrideSetting;
      public String homePageOverrideSetting;
      public String loginPageOverrideSetting;
      public String selfRegProfilePageOverrideSetting;
      private String[] changePasswordPageOverrideSetting_type_info = new String[]{'changePasswordPageOverrideSetting',SOAP_M_URI,null,'0','1','false'};
      private String[] forgotPasswordPageOverrideSetting_type_info = new String[]{'forgotPasswordPageOverrideSetting',SOAP_M_URI,null,'0','1','false'};
      private String[] homePageOverrideSetting_type_info = new String[]{'homePageOverrideSetting',SOAP_M_URI,null,'0','1','false'};
      private String[] loginPageOverrideSetting_type_info = new String[]{'loginPageOverrideSetting',SOAP_M_URI,null,'0','1','false'};
      private String[] selfRegProfilePageOverrideSetting_type_info = new String[]{'selfRegProfilePageOverrideSetting',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'changePasswordPageOverrideSetting','forgotPasswordPageOverrideSetting','homePageOverrideSetting','loginPageOverrideSetting','selfRegProfilePageOverrideSetting'};
  }

  public class ValueTranslation {
      public String masterLabel;
      public String translation;
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] translation_type_info = new String[]{'translation',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'masterLabel','translation'};
  }

  public class KnowledgeWorkOrderField {
      public String name;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name'};
  }

  public class PermissionSetApexClassAccess {
      public String apexClass;
      public Boolean enabled;
      private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apexClass','enabled'};
  }

  public class OrchestrationContextEvent {
      public String eventType;
      public String orchestrationEvent;
      public String platformEvent;
      public String platformEventPrimaryKey;
      private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'1','1','false'};
      private String[] orchestrationEvent_type_info = new String[]{'orchestrationEvent',SOAP_M_URI,null,'1','1','false'};
      private String[] platformEvent_type_info = new String[]{'platformEvent',SOAP_M_URI,null,'1','1','false'};
      private String[] platformEventPrimaryKey_type_info = new String[]{'platformEventPrimaryKey',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'eventType','orchestrationEvent','platformEvent','platformEventPrimaryKey'};
  }

  public class CommunityRoles {
      public String customerUserRole;
      public String employeeUserRole;
      public String partnerUserRole;
      private String[] customerUserRole_type_info = new String[]{'customerUserRole',SOAP_M_URI,null,'0','1','false'};
      private String[] employeeUserRole_type_info = new String[]{'employeeUserRole',SOAP_M_URI,null,'0','1','false'};
      private String[] partnerUserRole_type_info = new String[]{'partnerUserRole',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customerUserRole','employeeUserRole','partnerUserRole'};
  }

  public class RoleAndSubordinatesInternal {
      public String[] roleAndSubordinateInternal;
      private String[] roleAndSubordinateInternal_type_info = new String[]{'roleAndSubordinateInternal',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'roleAndSubordinateInternal'};
  }

  public class AppMenuItem {
      public String name;
      public String type_x;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','type_x'};
  }

  public class TabLimitConfig {
      public String maxNumberOfPrimaryTabs;
      public String maxNumberOfSubTabs;
      private String[] maxNumberOfPrimaryTabs_type_info = new String[]{'maxNumberOfPrimaryTabs',SOAP_M_URI,null,'0','1','false'};
      private String[] maxNumberOfSubTabs_type_info = new String[]{'maxNumberOfSubTabs',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'maxNumberOfPrimaryTabs','maxNumberOfSubTabs'};
  }

  public class ModeratedEntityField {
      public String entityName;
      public String fieldName;
      public String keywordList;
      private String[] entityName_type_info = new String[]{'entityName',SOAP_M_URI,null,'1','1','false'};
      private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'0','1','false'};
      private String[] keywordList_type_info = new String[]{'keywordList',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'entityName','fieldName','keywordList'};
  }

  public class FieldOverride {
      public String field;
      public String formula;
      public String literalValue;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] formula_type_info = new String[]{'formula',SOAP_M_URI,null,'0','1','false'};
      private String[] literalValue_type_info = new String[]{'literalValue',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','formula','literalValue'};
  }

  public class ProfileTabVisibility {
      public String tab;
      public String visibility;
      private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
      private String[] visibility_type_info = new String[]{'visibility',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'tab','visibility'};
  }

  public class AppBrand {
      public String footerColor;
      public String headerColor;
      public String logo;
      public Integer logoVersion;
      public Boolean shouldOverrideOrgTheme;
      private String[] footerColor_type_info = new String[]{'footerColor',SOAP_M_URI,null,'0','1','false'};
      private String[] headerColor_type_info = new String[]{'headerColor',SOAP_M_URI,null,'0','1','false'};
      private String[] logo_type_info = new String[]{'logo',SOAP_M_URI,null,'0','1','false'};
      private String[] logoVersion_type_info = new String[]{'logoVersion',SOAP_M_URI,null,'0','1','false'};
      private String[] shouldOverrideOrgTheme_type_info = new String[]{'shouldOverrideOrgTheme',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'footerColor','headerColor','logo','logoVersion','shouldOverrideOrgTheme'};
  }

  public class CommunityThemeSetting {
      public String customThemeLayoutType;
      public String themeLayout;
      public String themeLayoutType;
      private String[] customThemeLayoutType_type_info = new String[]{'customThemeLayoutType',SOAP_M_URI,null,'0','1','false'};
      private String[] themeLayout_type_info = new String[]{'themeLayout',SOAP_M_URI,null,'1','1','false'};
      private String[] themeLayoutType_type_info = new String[]{'themeLayoutType',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customThemeLayoutType','themeLayout','themeLayoutType'};
  }

  public class Territory2RuleItem {
      public String field;
      public String operation;
      public String value;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','operation','value'};
  }

  public class ContentAssetVersion {
      public String number_x;
      public String pathOnClient;
      public String zipEntry;
      private String[] number_x_type_info = new String[]{'number',SOAP_M_URI,null,'1','1','false'};
      private String[] pathOnClient_type_info = new String[]{'pathOnClient',SOAP_M_URI,null,'1','1','false'};
      private String[] zipEntry_type_info = new String[]{'zipEntry',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'number_x','pathOnClient','zipEntry'};
  }

  public class CancelDeployResult {
      public Boolean done;
      public String id;
      private String[] done_type_info = new String[]{'done',SOAP_M_URI,null,'1','1','false'};
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'done','id'};
  }

  public class AgentConfigUserAssignments {
      public String[] user_x;
      private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'user_x'};
  }

  public class EventParameterMap {
      public String parameterName;
      public String parameterValue;
      private String[] parameterName_type_info = new String[]{'parameterName',SOAP_M_URI,null,'1','1','false'};
      private String[] parameterValue_type_info = new String[]{'parameterValue',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'parameterName','parameterValue'};
  }

  public class KnowledgeWorkOrderLineItemField {
      public String name;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name'};
  }

  public class DashboardFilterColumn {
      public String column;
      private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'column'};
  }

  public class WorkflowFlowActionParameter {
      public String name;
      public String value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','value'};
  }    

  public class ScontrolTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class PlatformActionListItem {
      public String actionName;
      public String actionType;
      public Integer sortOrder;
      public String subtype;
      private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
      private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,null,'1','1','false'};
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
      private String[] subtype_type_info = new String[]{'subtype',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'actionName','actionType','sortOrder','subtype'};
  }
      
  public class CallOptions_element {
      public String client;
      private String[] client_type_info = new String[]{'client',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'client'};
  }


  public class CallCenterItem {
      public String label;
      public String name;
      public String value;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name','value'};
  }

  public class ProfileExternalDataSourceAccess {
      public Boolean enabled;
      public String externalDataSource;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
  }

  public class renameMetadata_element {
      public String type_x;
      public String oldFullName;
      public String newFullName;
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] oldFullName_type_info = new String[]{'oldFullName',SOAP_M_URI,null,'1','1','false'};
      private String[] newFullName_type_info = new String[]{'newFullName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'type_x','oldFullName','newFullName'};
  }

  public class SkillProfileAssignments {
      public String[] profile;
      private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'profile'};
  }

  public class EscalationAction {
      public String assignedTo;
      public String assignedToTemplate;
      public String assignedToType;
      public Integer minutesToEscalation;
      public Boolean notifyCaseOwner;
      public String[] notifyEmail;
      public String notifyTo;
      public String notifyToTemplate;
      private String[] assignedTo_type_info = new String[]{'assignedTo',SOAP_M_URI,null,'0','1','false'};
      private String[] assignedToTemplate_type_info = new String[]{'assignedToTemplate',SOAP_M_URI,null,'0','1','false'};
      private String[] assignedToType_type_info = new String[]{'assignedToType',SOAP_M_URI,null,'0','1','false'};
      private String[] minutesToEscalation_type_info = new String[]{'minutesToEscalation',SOAP_M_URI,null,'0','1','false'};
      private String[] notifyCaseOwner_type_info = new String[]{'notifyCaseOwner',SOAP_M_URI,null,'0','1','false'};
      private String[] notifyEmail_type_info = new String[]{'notifyEmail',SOAP_M_URI,null,'0','-1','false'};
      private String[] notifyTo_type_info = new String[]{'notifyTo',SOAP_M_URI,null,'0','1','false'};
      private String[] notifyToTemplate_type_info = new String[]{'notifyToTemplate',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'assignedTo','assignedToTemplate','assignedToType','minutesToEscalation','notifyCaseOwner','notifyEmail','notifyTo','notifyToTemplate'};
  }

  public class WaveXmdDimensionSalesforceAction {
      public Boolean enabled;
      public String salesforceActionName;
      public Integer sortIndex;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] salesforceActionName_type_info = new String[]{'salesforceActionName',SOAP_M_URI,null,'1','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','salesforceActionName','sortIndex'};
  }

  public class Roles {
      public String[] role;
      private String[] role_type_info = new String[]{'role',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'role'};
  }

  public class FileTypeDispositionAssignmentBean {
      public String behavior;
      public String fileType;
      public Boolean securityRiskFileType;
      private String[] behavior_type_info = new String[]{'behavior',SOAP_M_URI,null,'1','1','false'};
      private String[] fileType_type_info = new String[]{'fileType',SOAP_M_URI,null,'1','1','false'};
      private String[] securityRiskFileType_type_info = new String[]{'securityRiskFileType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'behavior','fileType','securityRiskFileType'};
  }

  public class ScheduledRecommendationDetail {
      public String channel;
      public Boolean enabled;
      public Integer rank;
      public String recommendationAudience;
      private String[] channel_type_info = new String[]{'channel',SOAP_M_URI,null,'0','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'0','1','false'};
      private String[] rank_type_info = new String[]{'rank',SOAP_M_URI,null,'0','1','false'};
      private String[] recommendationAudience_type_info = new String[]{'recommendationAudience',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'channel','enabled','rank','recommendationAudience'};
  }

  public class QueueSobject {
      public String sobjectType;
      private String[] sobjectType_type_info = new String[]{'sobjectType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'sobjectType'};
  }

  public class WaveXmdRecordDisplayLookup {
      public String recordDisplayField;
      private String[] recordDisplayField_type_info = new String[]{'recordDisplayField',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'recordDisplayField'};
  }

  public class KnowledgeCaseField {
      public String name;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name'};
  }

  public class ApprovalPageField {
      public String[] field;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field'};
  }

  public class PermissionSetApexPageAccess {
      public String apexPage;
      public Boolean enabled;
      private String[] apexPage_type_info = new String[]{'apexPage',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apexPage','enabled'};
  }

  public class WaveXmdDimensionMember {
      public String color;
      public String label;
      public String member;
      public Integer sortIndex;
      private String[] color_type_info = new String[]{'color',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] member_type_info = new String[]{'member',SOAP_M_URI,null,'1','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'color','label','member','sortIndex'};
  }

  public class describeMetadata_element {
      public Double asOfVersion;
      private String[] asOfVersion_type_info = new String[]{'asOfVersion',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'asOfVersion'};
  }

  public class RunTestSuccess {
      public String id;
      public String methodName;
      public String name;
      public String namespace;
      public Boolean seeAllData;
      public Double time_x;
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] methodName_type_info = new String[]{'methodName',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
      private String[] seeAllData_type_info = new String[]{'seeAllData',SOAP_M_URI,null,'0','1','false'};
      private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'id','methodName','name','namespace','seeAllData','time_x'};
  }

  public class PermissionSetExternalDataSourceAccess {
      public Boolean enabled;
      public String externalDataSource;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] externalDataSource_type_info = new String[]{'externalDataSource',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','externalDataSource'};
  }

  public class ListMetadataQuery {
      public String folder;
      public String type_x;
      private String[] folder_type_info = new String[]{'folder',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'folder','type_x'};
  }

  public class LogInfo {
      public String category;
      public String level;
      private String[] category_type_info = new String[]{'category',SOAP_M_URI,null,'1','1','false'};
      private String[] level_type_info = new String[]{'level',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'category','level'};
  }

  public class SharedTo {
      public String allCustomerPortalUsers;
      public String allInternalUsers;
      public String allPartnerUsers;
      public String[] channelProgramGroup;
      public String[] channelProgramGroups;
      public String[] group_x;
      public String[] groups;
      public String[] managerSubordinates;
      public String[] managers;
      public String[] portalRole;
      public String[] portalRoleAndSubordinates;
      public String[] queue;
      public String[] role;
      public String[] roleAndSubordinates;
      public String[] roleAndSubordinatesInternal;
      public String[] roles;
      public String[] rolesAndSubordinates;
      public String[] territories;
      public String[] territoriesAndSubordinates;
      public String[] territory;
      public String[] territoryAndSubordinates;
      private String[] allCustomerPortalUsers_type_info = new String[]{'allCustomerPortalUsers',SOAP_M_URI,null,'0','1','false'};
      private String[] allInternalUsers_type_info = new String[]{'allInternalUsers',SOAP_M_URI,null,'0','1','false'};
      private String[] allPartnerUsers_type_info = new String[]{'allPartnerUsers',SOAP_M_URI,null,'0','1','false'};
      private String[] channelProgramGroup_type_info = new String[]{'channelProgramGroup',SOAP_M_URI,null,'0','-1','false'};
      private String[] channelProgramGroups_type_info = new String[]{'channelProgramGroups',SOAP_M_URI,null,'0','-1','false'};
      private String[] group_x_type_info = new String[]{'group',SOAP_M_URI,null,'0','-1','false'};
      private String[] groups_type_info = new String[]{'groups',SOAP_M_URI,null,'0','-1','false'};
      private String[] managerSubordinates_type_info = new String[]{'managerSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] managers_type_info = new String[]{'managers',SOAP_M_URI,null,'0','-1','false'};
      private String[] portalRole_type_info = new String[]{'portalRole',SOAP_M_URI,null,'0','-1','false'};
      private String[] portalRoleAndSubordinates_type_info = new String[]{'portalRoleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] queue_type_info = new String[]{'queue',SOAP_M_URI,null,'0','-1','false'};
      private String[] role_type_info = new String[]{'role',SOAP_M_URI,null,'0','-1','false'};
      private String[] roleAndSubordinates_type_info = new String[]{'roleAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] roleAndSubordinatesInternal_type_info = new String[]{'roleAndSubordinatesInternal',SOAP_M_URI,null,'0','-1','false'};
      private String[] roles_type_info = new String[]{'roles',SOAP_M_URI,null,'0','-1','false'};
      private String[] rolesAndSubordinates_type_info = new String[]{'rolesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] territories_type_info = new String[]{'territories',SOAP_M_URI,null,'0','-1','false'};
      private String[] territoriesAndSubordinates_type_info = new String[]{'territoriesAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] territory_type_info = new String[]{'territory',SOAP_M_URI,null,'0','-1','false'};
      private String[] territoryAndSubordinates_type_info = new String[]{'territoryAndSubordinates',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allCustomerPortalUsers','allInternalUsers','allPartnerUsers','channelProgramGroup','channelProgramGroups','group_x','groups','managerSubordinates','managers','portalRole','portalRoleAndSubordinates','queue','role','roleAndSubordinates','roleAndSubordinatesInternal','roles','rolesAndSubordinates','territories','territoriesAndSubordinates','territory','territoryAndSubordinates'};
  }

  public class PlatformCachePartitionType {
      public Integer allocatedCapacity;
      public Integer allocatedPurchasedCapacity;
      public Integer allocatedTrialCapacity;
      public String cacheType;
      private String[] allocatedCapacity_type_info = new String[]{'allocatedCapacity',SOAP_M_URI,null,'1','1','false'};
      private String[] allocatedPurchasedCapacity_type_info = new String[]{'allocatedPurchasedCapacity',SOAP_M_URI,null,'1','1','false'};
      private String[] allocatedTrialCapacity_type_info = new String[]{'allocatedTrialCapacity',SOAP_M_URI,null,'1','1','false'};
      private String[] cacheType_type_info = new String[]{'cacheType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allocatedCapacity','allocatedPurchasedCapacity','allocatedTrialCapacity','cacheType'};
  }

  public class ReputationPointsRule {
      public String eventType;
      public Integer points;
      private String[] eventType_type_info = new String[]{'eventType',SOAP_M_URI,null,'1','1','false'};
      private String[] points_type_info = new String[]{'points',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'eventType','points'};
  }

  public class ForecastingDisplayedFamilySettings {
      public String productFamily;
      private String[] productFamily_type_info = new String[]{'productFamily',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'productFamily'};
  }

  public class ReputationBranding {
      public String smallImage;
      private String[] smallImage_type_info = new String[]{'smallImage',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'smallImage'};
  }

  public class ProfileLayoutAssignment {
      public String layout;
      public String recordType;
      private String[] layout_type_info = new String[]{'layout',SOAP_M_URI,null,'1','1','false'};
      private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'layout','recordType'};
  }


  public class QuickActionTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class ReportDataCategoryFilter {
      public String dataCategory;
      public String dataCategoryGroup;
      public String operator;
      private String[] dataCategory_type_info = new String[]{'dataCategory',SOAP_M_URI,null,'1','1','false'};
      private String[] dataCategoryGroup_type_info = new String[]{'dataCategoryGroup',SOAP_M_URI,null,'1','1','false'};
      private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dataCategory','dataCategoryGroup','operator'};
  }

  public class ReportBucketFieldSourceValue {
      public String from_x;
      public String sourceValue;
      public String to;
      private String[] from_x_type_info = new String[]{'from',SOAP_M_URI,null,'0','1','false'};
      private String[] sourceValue_type_info = new String[]{'sourceValue',SOAP_M_URI,null,'0','1','false'};
      private String[] to_type_info = new String[]{'to',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'from_x','sourceValue','to'};
  }

  public class ValidationRuleTranslation {
      public String errorMessage;
      public String name;
      private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'errorMessage','name'};
  }

  public class ManagedTopic {
      public String managedTopicType;
      public String name;
      public String parentName;
      public Integer position;
      public String topicDescription;
      private String[] managedTopicType_type_info = new String[]{'managedTopicType',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] parentName_type_info = new String[]{'parentName',SOAP_M_URI,null,'1','1','false'};
      private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
      private String[] topicDescription_type_info = new String[]{'topicDescription',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'managedTopicType','name','parentName','position','topicDescription'};
  }

  public class WorkflowEmailRecipient {
      public String field;
      public String recipient;
      public String type_x;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
      private String[] recipient_type_info = new String[]{'recipient',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','recipient','type_x'};
  }

  public class ProfileActionOverride {
      public String actionName;
      public String content;
      public String formFactor;
      public String pageOrSobjectType;
      public String recordType;
      public String type_x;
      private String[] actionName_type_info = new String[]{'actionName',SOAP_M_URI,null,'1','1','false'};
      private String[] content_type_info = new String[]{'content',SOAP_M_URI,null,'0','1','false'};
      private String[] formFactor_type_info = new String[]{'formFactor',SOAP_M_URI,null,'1','1','false'};
      private String[] pageOrSobjectType_type_info = new String[]{'pageOrSobjectType',SOAP_M_URI,null,'1','1','false'};
      private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'actionName','content','formFactor','pageOrSobjectType','recordType','type_x'};
  }

  public class readMetadata_element {
      public String type_x;
      public String[] fullNames;
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'type_x','fullNames'};
  }

  public class IndexField {
      public String name;
      public String sortDirection;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] sortDirection_type_info = new String[]{'sortDirection',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','sortDirection'};
  }

  public class FolderShare {
      public String accessLevel;
      public String sharedTo;
      public String sharedToType;
      private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] sharedTo_type_info = new String[]{'sharedTo',SOAP_M_URI,null,'1','1','false'};
      private String[] sharedToType_type_info = new String[]{'sharedToType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'accessLevel','sharedTo','sharedToType'};
  }

  public class QuickActionListItem {
      public String quickActionName;
      private String[] quickActionName_type_info = new String[]{'quickActionName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'quickActionName'};
  }

  public class ObjectMappingField {
      public String inputField;
      public String outputField;
      private String[] inputField_type_info = new String[]{'inputField',SOAP_M_URI,null,'1','1','false'};
      private String[] outputField_type_info = new String[]{'outputField',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'inputField','outputField'};
  }

  public class Territory2RuleAssociation {
      public Boolean inherited;
      public String ruleName;
      private String[] inherited_type_info = new String[]{'inherited',SOAP_M_URI,null,'1','1','false'};
      private String[] ruleName_type_info = new String[]{'ruleName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'inherited','ruleName'};
  }

  public class PermissionSetCustomPermissions {
      public Boolean enabled;
      public String name;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','name'};
  }

  public class ComponentInstanceProperty {
      public String name;
      public String type_x;
      public String value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'0','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','type_x','value'};
  }

  public class ChatterMobileSettings {
      public Boolean enablePushNotifications;
      private String[] enablePushNotifications_type_info = new String[]{'enablePushNotifications',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enablePushNotifications'};
  }

  public class PushNotification {
      public String[] fieldNames;
      public String objectName;
      private String[] fieldNames_type_info = new String[]{'fieldNames',SOAP_M_URI,null,'0','-1','false'};
      private String[] objectName_type_info = new String[]{'objectName',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fieldNames','objectName'};
  }

  public class OpportunityListFieldsSelectedSettings {
      public String[] field;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field'};
  }

  public class WaveXmdDimensionCustomAction {
      public String customActionName;
      public Boolean enabled;
      public String icon;
      public String method;
      public Integer sortIndex;
      public String target;
      public String tooltip;
      public String url;
      private String[] customActionName_type_info = new String[]{'customActionName',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'0','1','false'};
      private String[] method_type_info = new String[]{'method',SOAP_M_URI,null,'0','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] target_type_info = new String[]{'target',SOAP_M_URI,null,'0','1','false'};
      private String[] tooltip_type_info = new String[]{'tooltip',SOAP_M_URI,null,'0','1','false'};
      private String[] url_type_info = new String[]{'url',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customActionName','enabled','icon','method','sortIndex','target','tooltip','url'};
  }

  public class AccessMapping {
      public String accessLevel;
      public String object_x;
      public String objectField;
      public String userField;
      private String[] accessLevel_type_info = new String[]{'accessLevel',SOAP_M_URI,null,'1','1','false'};
      private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
      private String[] objectField_type_info = new String[]{'objectField',SOAP_M_URI,null,'1','1','false'};
      private String[] userField_type_info = new String[]{'userField',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'accessLevel','object_x','objectField','userField'};
  }

  public class AnalyticSnapshotMapping {
      public String aggregateType;
      public String sourceField;
      public String sourceType;
      public String targetField;
      private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
      private String[] sourceField_type_info = new String[]{'sourceField',SOAP_M_URI,null,'1','1','false'};
      private String[] sourceType_type_info = new String[]{'sourceType',SOAP_M_URI,null,'1','1','false'};
      private String[] targetField_type_info = new String[]{'targetField',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregateType','sourceField','sourceType','targetField'};
  }

  public class DefaultShortcut {
      public String action;
      public Boolean active;
      public String keyCommand;
      private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
      private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
      private String[] keyCommand_type_info = new String[]{'keyCommand',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'action','active','keyCommand'};
  }

  public class WorkspaceMapping {
      public String fieldName;
      public String tab;
      private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'0','1','false'};
      private String[] tab_type_info = new String[]{'tab',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fieldName','tab'};
  }

  public class deleteMetadata_element {
      public String type_x;
      public String[] fullNames;
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'type_x','fullNames'};
  }

  public class ForecastRangeSettings {
      public Integer beginning;
      public Integer displaying;
      public String periodType;
      private String[] beginning_type_info = new String[]{'beginning',SOAP_M_URI,null,'1','1','false'};
      private String[] displaying_type_info = new String[]{'displaying',SOAP_M_URI,null,'1','1','false'};
      private String[] periodType_type_info = new String[]{'periodType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'beginning','displaying','periodType'};
  }

  public class ListViewFilter {
      public String field;
      public String operation;
      public String value;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] operation_type_info = new String[]{'operation',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','operation','value'};
  }

  public class DashboardTableColumn {
      public String aggregateType;
      public Boolean calculatePercent;
      public String column;
      public Integer decimalPlaces;
      public Boolean showTotal;
      public String sortBy;
      private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
      private String[] calculatePercent_type_info = new String[]{'calculatePercent',SOAP_M_URI,null,'0','1','false'};
      private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
      private String[] decimalPlaces_type_info = new String[]{'decimalPlaces',SOAP_M_URI,null,'0','1','false'};
      private String[] showTotal_type_info = new String[]{'showTotal',SOAP_M_URI,null,'0','1','false'};
      private String[] sortBy_type_info = new String[]{'sortBy',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregateType','calculatePercent','column','decimalPlaces','showTotal','sortBy'};
  }

  public class ListPlacement {
      public Integer height;
      public String location;
      public String units;
      public Integer width;
      private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
      private String[] location_type_info = new String[]{'location',SOAP_M_URI,null,'1','1','false'};
      private String[] units_type_info = new String[]{'units',SOAP_M_URI,null,'0','1','false'};
      private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'height','location','units','width'};
  }

  public class PicklistEntry {
      public Boolean active;
      public Boolean defaultValue;
      public String label;
      public String validFor;
      public String value;
      private String[] active_type_info = new String[]{'active',SOAP_M_URI,null,'1','1','false'};
      private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] validFor_type_info = new String[]{'validFor',SOAP_M_URI,null,'0','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'active','defaultValue','label','validFor','value'};
  }

  public class KnowledgeCommunitiesSettings {
      public String[] community;
      private String[] community_type_info = new String[]{'community',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'community'};
  }

  public class AppComponentList {
      public String alignment;
      public String[] components;
      private String[] alignment_type_info = new String[]{'alignment',SOAP_M_URI,null,'1','1','false'};
      private String[] components_type_info = new String[]{'components',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'alignment','components'};
  }

  public class CodeCoverageWarning {
      public String id;
      public String message;
      public String name;
      public String namespace;
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'1','1','false'};
      private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','true'};
      private String[] namespace_type_info = new String[]{'namespace',SOAP_M_URI,null,'1','1','true'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'id','message','name','namespace'};
  }
      
  public class CustomLabelTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class KnowledgeAnswerSettings {
      public String assignTo;
      public String defaultArticleType;
      public Boolean enableArticleCreation;
      private String[] assignTo_type_info = new String[]{'assignTo',SOAP_M_URI,null,'0','1','false'};
      private String[] defaultArticleType_type_info = new String[]{'defaultArticleType',SOAP_M_URI,null,'0','1','false'};
      private String[] enableArticleCreation_type_info = new String[]{'enableArticleCreation',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'assignTo','defaultArticleType','enableArticleCreation'};
  }

  public class EventTypeParameter {
      public String defaultValue;
      public String description;
      public String label;
      public Integer maxOccurs;
      public Integer minOccurs;
      public String name;
      public String sObjectType;
      public String type_x;
      private String[] defaultValue_type_info = new String[]{'defaultValue',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] maxOccurs_type_info = new String[]{'maxOccurs',SOAP_M_URI,null,'0','1','false'};
      private String[] minOccurs_type_info = new String[]{'minOccurs',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] sObjectType_type_info = new String[]{'sObjectType',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'defaultValue','description','label','maxOccurs','minOccurs','name','sObjectType','type_x'};
  }

  public class CustomExperienceBranding {
      public String loginFooterText;
      public String loginLogo;
      public String pageFooter;
      public String pageHeader;
      public String primaryColor;
      public String primaryComplementColor;
      public String quaternaryColor;
      public String quaternaryComplementColor;
      public String secondaryColor;
      public String tertiaryColor;
      public String tertiaryComplementColor;
      public String zeronaryColor;
      public String zeronaryComplementColor;
      private String[] loginFooterText_type_info = new String[]{'loginFooterText',SOAP_M_URI,null,'0','1','false'};
      private String[] loginLogo_type_info = new String[]{'loginLogo',SOAP_M_URI,null,'0','1','false'};
      private String[] pageFooter_type_info = new String[]{'pageFooter',SOAP_M_URI,null,'0','1','false'};
      private String[] pageHeader_type_info = new String[]{'pageHeader',SOAP_M_URI,null,'0','1','false'};
      private String[] primaryColor_type_info = new String[]{'primaryColor',SOAP_M_URI,null,'1','1','false'};
      private String[] primaryComplementColor_type_info = new String[]{'primaryComplementColor',SOAP_M_URI,null,'1','1','false'};
      private String[] quaternaryColor_type_info = new String[]{'quaternaryColor',SOAP_M_URI,null,'1','1','false'};
      private String[] quaternaryComplementColor_type_info = new String[]{'quaternaryComplementColor',SOAP_M_URI,null,'1','1','false'};
      private String[] secondaryColor_type_info = new String[]{'secondaryColor',SOAP_M_URI,null,'1','1','false'};
      private String[] tertiaryColor_type_info = new String[]{'tertiaryColor',SOAP_M_URI,null,'1','1','false'};
      private String[] tertiaryComplementColor_type_info = new String[]{'tertiaryComplementColor',SOAP_M_URI,null,'1','1','false'};
      private String[] zeronaryColor_type_info = new String[]{'zeronaryColor',SOAP_M_URI,null,'1','1','false'};
      private String[] zeronaryComplementColor_type_info = new String[]{'zeronaryComplementColor',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'loginFooterText','loginLogo','pageFooter','pageHeader','primaryColor','primaryComplementColor','quaternaryColor','quaternaryComplementColor','secondaryColor','tertiaryColor','tertiaryComplementColor','zeronaryColor','zeronaryComplementColor'};
  }

  public class NetworkMemberGroup {
      public String[] permissionSet;
      public String[] profile;
      private String[] permissionSet_type_info = new String[]{'permissionSet',SOAP_M_URI,null,'0','-1','false'};
      private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'permissionSet','profile'};
  }

  public class RelatedList {
      public Boolean hideOnDetail;
      public String name;
      private String[] hideOnDetail_type_info = new String[]{'hideOnDetail',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'hideOnDetail','name'};
  }

  public class SynonymGroup {
      public String[] languages;
      public String[] terms;
      private String[] languages_type_info = new String[]{'languages',SOAP_M_URI,null,'0','-1','false'};
      private String[] terms_type_info = new String[]{'terms',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'languages','terms'};
  }

  public class PasswordPolicies {
      public String apiOnlyUserHomePageURL;
      public String complexity;
      public String expiration;
      public String historyRestriction;
      public String lockoutInterval;
      public String maxLoginAttempts;
      public String minimumPasswordLength;
      public Boolean minimumPasswordLifetime;
      public Boolean obscureSecretAnswer;
      public String passwordAssistanceMessage;
      public String passwordAssistanceURL;
      public String questionRestriction;
      private String[] apiOnlyUserHomePageURL_type_info = new String[]{'apiOnlyUserHomePageURL',SOAP_M_URI,null,'0','1','false'};
      private String[] complexity_type_info = new String[]{'complexity',SOAP_M_URI,null,'0','1','false'};
      private String[] expiration_type_info = new String[]{'expiration',SOAP_M_URI,null,'0','1','false'};
      private String[] historyRestriction_type_info = new String[]{'historyRestriction',SOAP_M_URI,null,'0','1','false'};
      private String[] lockoutInterval_type_info = new String[]{'lockoutInterval',SOAP_M_URI,null,'0','1','false'};
      private String[] maxLoginAttempts_type_info = new String[]{'maxLoginAttempts',SOAP_M_URI,null,'0','1','false'};
      private String[] minimumPasswordLength_type_info = new String[]{'minimumPasswordLength',SOAP_M_URI,null,'0','1','false'};
      private String[] minimumPasswordLifetime_type_info = new String[]{'minimumPasswordLifetime',SOAP_M_URI,null,'0','1','false'};
      private String[] obscureSecretAnswer_type_info = new String[]{'obscureSecretAnswer',SOAP_M_URI,null,'0','1','false'};
      private String[] passwordAssistanceMessage_type_info = new String[]{'passwordAssistanceMessage',SOAP_M_URI,null,'0','1','false'};
      private String[] passwordAssistanceURL_type_info = new String[]{'passwordAssistanceURL',SOAP_M_URI,null,'0','1','false'};
      private String[] questionRestriction_type_info = new String[]{'questionRestriction',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apiOnlyUserHomePageURL','complexity','expiration','historyRestriction','lockoutInterval','maxLoginAttempts','minimumPasswordLength','minimumPasswordLifetime','obscureSecretAnswer','passwordAssistanceMessage','passwordAssistanceURL','questionRestriction'};
  }

  public class AnalyticsCloudComponentLayoutItem {
      public String assetType;
      public String devName;
      public String error;
      public String filter;
      public Integer height;
      public Boolean hideOnError;
      public Boolean showHeader;
      public Boolean showSharing;
      public Boolean showTitle;
      public String width;
      private String[] assetType_type_info = new String[]{'assetType',SOAP_M_URI,null,'1','1','false'};
      private String[] devName_type_info = new String[]{'devName',SOAP_M_URI,null,'1','1','false'};
      private String[] error_type_info = new String[]{'error',SOAP_M_URI,null,'0','1','false'};
      private String[] filter_type_info = new String[]{'filter',SOAP_M_URI,null,'0','1','false'};
      private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
      private String[] hideOnError_type_info = new String[]{'hideOnError',SOAP_M_URI,null,'0','1','false'};
      private String[] showHeader_type_info = new String[]{'showHeader',SOAP_M_URI,null,'0','1','false'};
      private String[] showSharing_type_info = new String[]{'showSharing',SOAP_M_URI,null,'0','1','false'};
      private String[] showTitle_type_info = new String[]{'showTitle',SOAP_M_URI,null,'0','1','false'};
      private String[] width_type_info = new String[]{'width',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'assetType','devName','error','filter','height','hideOnError','showHeader','showSharing','showTitle','width'};
  }

  public class SFDCMobileSettings {
      public Boolean enableMobileLite;
      public Boolean enableUserToDeviceLinking;
      private String[] enableMobileLite_type_info = new String[]{'enableMobileLite',SOAP_M_URI,null,'0','1','false'};
      private String[] enableUserToDeviceLinking_type_info = new String[]{'enableUserToDeviceLinking',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableMobileLite','enableUserToDeviceLinking'};
  }

  public class ProfileRecordTypeVisibility {
      public Boolean default_x;
      public Boolean personAccountDefault;
      public String recordType;
      public Boolean visible;
      private String[] default_x_type_info = new String[]{'default',SOAP_M_URI,null,'1','1','false'};
      private String[] personAccountDefault_type_info = new String[]{'personAccountDefault',SOAP_M_URI,null,'0','1','false'};
      private String[] recordType_type_info = new String[]{'recordType',SOAP_M_URI,null,'1','1','false'};
      private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'default_x','personAccountDefault','recordType','visible'};
  }

  public class DashboardMobileSettings {
      public Boolean enableDashboardIPadApp;
      private String[] enableDashboardIPadApp_type_info = new String[]{'enableDashboardIPadApp',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableDashboardIPadApp'};
  }

  public class SiteRedirectMapping {
      public String action;
      public Boolean isActive;
      public String source;
      public String target;
      private String[] action_type_info = new String[]{'action',SOAP_M_URI,null,'1','1','false'};
      private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
      private String[] source_type_info = new String[]{'source',SOAP_M_URI,null,'1','1','false'};
      private String[] target_type_info = new String[]{'target',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'action','isActive','source','target'};
  }

  public class AgentConfigProfileAssignments {
      public String[] profile;
      private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'profile'};
  }
 
  public class BrandingSetProperty {
      public String propertyName;
      public String propertyValue;
      private String[] propertyName_type_info = new String[]{'propertyName',SOAP_M_URI,null,'1','1','false'};
      private String[] propertyValue_type_info = new String[]{'propertyValue',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'propertyName','propertyValue'};
  }

  public class ProfileApexPageAccess {
      public String apexPage;
      public Boolean enabled;
      private String[] apexPage_type_info = new String[]{'apexPage',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apexPage','enabled'};
  }

  public class ActionLinkTemplate {
      public String actionUrl;
      public String headers;
      public Boolean isConfirmationRequired;
      public Boolean isGroupDefault;
      public String label;
      public String labelKey;
      public String linkType;
      public String method;
      public Integer position;
      public String requestBody;
      public String userAlias;
      public String userVisibility;
      private String[] actionUrl_type_info = new String[]{'actionUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] headers_type_info = new String[]{'headers',SOAP_M_URI,null,'0','1','false'};
      private String[] isConfirmationRequired_type_info = new String[]{'isConfirmationRequired',SOAP_M_URI,null,'1','1','false'};
      private String[] isGroupDefault_type_info = new String[]{'isGroupDefault',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] labelKey_type_info = new String[]{'labelKey',SOAP_M_URI,null,'1','1','false'};
      private String[] linkType_type_info = new String[]{'linkType',SOAP_M_URI,null,'1','1','false'};
      private String[] method_type_info = new String[]{'method',SOAP_M_URI,null,'1','1','false'};
      private String[] position_type_info = new String[]{'position',SOAP_M_URI,null,'1','1','false'};
      private String[] requestBody_type_info = new String[]{'requestBody',SOAP_M_URI,null,'0','1','false'};
      private String[] userAlias_type_info = new String[]{'userAlias',SOAP_M_URI,null,'0','1','false'};
      private String[] userVisibility_type_info = new String[]{'userVisibility',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'actionUrl','headers','isConfirmationRequired','isGroupDefault','label','labelKey','linkType','method','position','requestBody','userAlias','userVisibility'};
  }

  public class ProfileObjectPermissions {
      public Boolean allowCreate;
      public Boolean allowDelete;
      public Boolean allowEdit;
      public Boolean allowRead;
      public Boolean modifyAllRecords;
      public String object_x;
      public Boolean viewAllRecords;
      private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'0','1','false'};
      private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'0','1','false'};
      private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'0','1','false'};
      private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'0','1','false'};
      private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'0','1','false'};
      private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
      private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
  }

  public class ReportGrouping {
      public String aggregateType;
      public String dateGranularity;
      public String field;
      public String sortByName;
      public String sortOrder;
      public String sortType;
      private String[] aggregateType_type_info = new String[]{'aggregateType',SOAP_M_URI,null,'0','1','false'};
      private String[] dateGranularity_type_info = new String[]{'dateGranularity',SOAP_M_URI,null,'0','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] sortByName_type_info = new String[]{'sortByName',SOAP_M_URI,null,'0','1','false'};
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
      private String[] sortType_type_info = new String[]{'sortType',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregateType','dateGranularity','field','sortByName','sortOrder','sortType'};
  }

  public class DeployMessage {
      public Boolean changed;
      public Integer columnNumber;
      public String componentType;
      public Boolean created;
      public DateTime createdDate;
      public Boolean deleted;
      public String fileName;
      public String fullName;
      public String id;
      public Integer lineNumber;
      public String problem;
      public String problemType;
      public Boolean success;
      private String[] changed_type_info = new String[]{'changed',SOAP_M_URI,null,'1','1','false'};
      private String[] columnNumber_type_info = new String[]{'columnNumber',SOAP_M_URI,null,'0','1','false'};
      private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'0','1','false'};
      private String[] created_type_info = new String[]{'created',SOAP_M_URI,null,'1','1','false'};
      private String[] createdDate_type_info = new String[]{'createdDate',SOAP_M_URI,null,'1','1','false'};
      private String[] deleted_type_info = new String[]{'deleted',SOAP_M_URI,null,'1','1','false'};
      private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
      private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
      private String[] id_type_info = new String[]{'id',SOAP_M_URI,null,'0','1','false'};
      private String[] lineNumber_type_info = new String[]{'lineNumber',SOAP_M_URI,null,'0','1','false'};
      private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'0','1','false'};
      private String[] problemType_type_info = new String[]{'problemType',SOAP_M_URI,null,'0','1','false'};
      private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'changed','columnNumber','componentType','created','createdDate','deleted','fileName','fullName','id','lineNumber','problem','problemType','success'};
  }

  public class EmailServicesAddress {
      public String authorizedSenders;
      public String developerName;
      public Boolean isActive;
      public String localPart;
      public String runAsUser;
      private String[] authorizedSenders_type_info = new String[]{'authorizedSenders',SOAP_M_URI,null,'0','1','false'};
      private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
      private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
      private String[] localPart_type_info = new String[]{'localPart',SOAP_M_URI,null,'1','1','false'};
      private String[] runAsUser_type_info = new String[]{'runAsUser',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'authorizedSenders','developerName','isActive','localPart','runAsUser'};
  }

  public class PermissionSetObjectPermissions {
      public Boolean allowCreate;
      public Boolean allowDelete;
      public Boolean allowEdit;
      public Boolean allowRead;
      public Boolean modifyAllRecords;
      public String object_x;
      public Boolean viewAllRecords;
      private String[] allowCreate_type_info = new String[]{'allowCreate',SOAP_M_URI,null,'1','1','false'};
      private String[] allowDelete_type_info = new String[]{'allowDelete',SOAP_M_URI,null,'1','1','false'};
      private String[] allowEdit_type_info = new String[]{'allowEdit',SOAP_M_URI,null,'1','1','false'};
      private String[] allowRead_type_info = new String[]{'allowRead',SOAP_M_URI,null,'1','1','false'};
      private String[] modifyAllRecords_type_info = new String[]{'modifyAllRecords',SOAP_M_URI,null,'1','1','false'};
      private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'1','1','false'};
      private String[] viewAllRecords_type_info = new String[]{'viewAllRecords',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'allowCreate','allowDelete','allowEdit','allowRead','modifyAllRecords','object_x','viewAllRecords'};
  }

  public class ProfileApexClassAccess {
      public String apexClass;
      public Boolean enabled;
      private String[] apexClass_type_info = new String[]{'apexClass',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apexClass','enabled'};
  }

  public class ProfileLoginIpRange {
      public String description;
      public String endAddress;
      public String startAddress;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] endAddress_type_info = new String[]{'endAddress',SOAP_M_URI,null,'1','1','false'};
      private String[] startAddress_type_info = new String[]{'startAddress',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','endAddress','startAddress'};
  }

  public class DashboardComponentColumn {
      public Double breakPoint1;
      public Double breakPoint2;
      public Integer breakPointOrder;
      public Integer highRangeColor;
      public Integer lowRangeColor;
      public Integer midRangeColor;
      public String reportColumn;
      public Boolean showTotal;
      public String type_x;
      private String[] breakPoint1_type_info = new String[]{'breakPoint1',SOAP_M_URI,null,'0','1','false'};
      private String[] breakPoint2_type_info = new String[]{'breakPoint2',SOAP_M_URI,null,'0','1','false'};
      private String[] breakPointOrder_type_info = new String[]{'breakPointOrder',SOAP_M_URI,null,'0','1','false'};
      private String[] highRangeColor_type_info = new String[]{'highRangeColor',SOAP_M_URI,null,'0','1','false'};
      private String[] lowRangeColor_type_info = new String[]{'lowRangeColor',SOAP_M_URI,null,'0','1','false'};
      private String[] midRangeColor_type_info = new String[]{'midRangeColor',SOAP_M_URI,null,'0','1','false'};
      private String[] reportColumn_type_info = new String[]{'reportColumn',SOAP_M_URI,null,'1','1','false'};
      private String[] showTotal_type_info = new String[]{'showTotal',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'breakPoint1','breakPoint2','breakPointOrder','highRangeColor','lowRangeColor','midRangeColor','reportColumn','showTotal','type_x'};
  }

  public class FlowStage {
      public Boolean isActive;
      public String label;
      public Integer stageOrder;
      private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] stageOrder_type_info = new String[]{'stageOrder',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'isActive','label','stageOrder'};
  }

  public class ChartSummary {
      public String aggregate;
      public String axisBinding;
      public String column;
      private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'0','1','false'};
      private String[] axisBinding_type_info = new String[]{'axisBinding',SOAP_M_URI,null,'0','1','false'};
      private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregate','axisBinding','column'};
  }

  public class checkRetrieveStatus_element {
      public String asyncProcessId;
      public Boolean includeZip;
      private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
      private String[] includeZip_type_info = new String[]{'includeZip',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'asyncProcessId','includeZip'};
  }

  public class ObjectUsage {
      public String[] object_x;
      private String[] object_x_type_info = new String[]{'object',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'object_x'};
  }

  public class SharingReasonTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class CustomDataTypeComponentTranslation {
      public String developerSuffix;
      public String label;
      private String[] developerSuffix_type_info = new String[]{'developerSuffix',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'developerSuffix','label'};
  }

  public class FeedLayoutComponent {
      public String componentType;
      public Integer height;
      public String page_x;
      private String[] componentType_type_info = new String[]{'componentType',SOAP_M_URI,null,'1','1','false'};
      private String[] height_type_info = new String[]{'height',SOAP_M_URI,null,'0','1','false'};
      private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'componentType','height','page_x'};
  }

  public class OpportunityListFieldsLabelMapping {
      public String field;
      public String label;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','label'};
  }

  public class CodeLocation {
      public Integer column;
      public Integer line;
      public Integer numExecutions;
      public Double time_x;
      private String[] column_type_info = new String[]{'column',SOAP_M_URI,null,'1','1','false'};
      private String[] line_type_info = new String[]{'line',SOAP_M_URI,null,'1','1','false'};
      private String[] numExecutions_type_info = new String[]{'numExecutions',SOAP_M_URI,null,'1','1','false'};
      private String[] time_x_type_info = new String[]{'time',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'column','line','numExecutions','time_x'};
  }

  public class Keyword {
      public String keyword;
      private String[] keyword_type_info = new String[]{'keyword',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'keyword'};
  }

  public class PermissionSetApplicationVisibility {
      public String application;
      public Boolean visible;
      private String[] application_type_info = new String[]{'application',SOAP_M_URI,null,'1','1','false'};
      private String[] visible_type_info = new String[]{'visible',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'application','visible'};
  }

  public class AppActionOverride {
      public String pageOrSobjectType;
      private String[] pageOrSobjectType_type_info = new String[]{'pageOrSobjectType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'pageOrSobjectType'};
  }

  public class RoleAndSubordinates {
      public String[] roleAndSubordinate;
      private String[] roleAndSubordinate_type_info = new String[]{'roleAndSubordinate',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'roleAndSubordinate'};
  }

  public class StandardFieldTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class RecommendationAudienceDetail {
      public String audienceCriteriaType;
      public String audienceCriteriaValue;
      public String setupName;
      private String[] audienceCriteriaType_type_info = new String[]{'audienceCriteriaType',SOAP_M_URI,null,'0','1','false'};
      private String[] audienceCriteriaValue_type_info = new String[]{'audienceCriteriaValue',SOAP_M_URI,null,'0','1','false'};
      private String[] setupName_type_info = new String[]{'setupName',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'audienceCriteriaType','audienceCriteriaValue','setupName'};
  }

  public class LiveChatButtonSkills {
      public String[] skill;
      private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'skill'};
  }

  public class ConnectedAppOauthConfig {
      public String callbackUrl;
      public String certificate;
      public String consumerKey;
      public String consumerSecret;
      public String[] scopes;
      public String singleLogoutUrl;
      private String[] callbackUrl_type_info = new String[]{'callbackUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
      private String[] consumerKey_type_info = new String[]{'consumerKey',SOAP_M_URI,null,'0','1','false'};
      private String[] consumerSecret_type_info = new String[]{'consumerSecret',SOAP_M_URI,null,'0','1','false'};
      private String[] scopes_type_info = new String[]{'scopes',SOAP_M_URI,null,'0','-1','false'};
      private String[] singleLogoutUrl_type_info = new String[]{'singleLogoutUrl',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'callbackUrl','certificate','consumerKey','consumerSecret','scopes','singleLogoutUrl'};
  }

  public class ObjectSearchSetting {
      public Boolean enhancedLookupEnabled;
      public Boolean lookupAutoCompleteEnabled;
      public String name;
      public Integer resultsPerPageCount;
      private String[] enhancedLookupEnabled_type_info = new String[]{'enhancedLookupEnabled',SOAP_M_URI,null,'1','1','false'};
      private String[] lookupAutoCompleteEnabled_type_info = new String[]{'lookupAutoCompleteEnabled',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] resultsPerPageCount_type_info = new String[]{'resultsPerPageCount',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enhancedLookupEnabled','lookupAutoCompleteEnabled','name','resultsPerPageCount'};
  }

  public class VisualizationResource {
      public String description;
      public String file;
      public Integer rank;
      public String type_x;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] file_type_info = new String[]{'file',SOAP_M_URI,null,'1','1','false'};
      private String[] rank_type_info = new String[]{'rank',SOAP_M_URI,null,'0','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','file','rank','type_x'};
  }

  public class NextAutomatedApprover {
      public Boolean useApproverFieldOfRecordOwner;
      public String userHierarchyField;
      private String[] useApproverFieldOfRecordOwner_type_info = new String[]{'useApproverFieldOfRecordOwner',SOAP_M_URI,null,'0','1','false'};
      private String[] userHierarchyField_type_info = new String[]{'userHierarchyField',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'useApproverFieldOfRecordOwner','userHierarchyField'};
  }

  public class RetrieveMessage {
      public String fileName;
      public String problem;
      private String[] fileName_type_info = new String[]{'fileName',SOAP_M_URI,null,'1','1','false'};
      private String[] problem_type_info = new String[]{'problem',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fileName','problem'};
  }

  public class EclairMap {
      public Double boundingBoxBottom;
      public Double boundingBoxLeft;
      public Double boundingBoxRight;
      public Double boundingBoxTop;
      public String mapLabel;
      public String mapName;
      public String projection;
      private String[] boundingBoxBottom_type_info = new String[]{'boundingBoxBottom',SOAP_M_URI,null,'0','1','false'};
      private String[] boundingBoxLeft_type_info = new String[]{'boundingBoxLeft',SOAP_M_URI,null,'0','1','false'};
      private String[] boundingBoxRight_type_info = new String[]{'boundingBoxRight',SOAP_M_URI,null,'0','1','false'};
      private String[] boundingBoxTop_type_info = new String[]{'boundingBoxTop',SOAP_M_URI,null,'0','1','false'};
      private String[] mapLabel_type_info = new String[]{'mapLabel',SOAP_M_URI,null,'0','1','false'};
      private String[] mapName_type_info = new String[]{'mapName',SOAP_M_URI,null,'1','1','false'};
      private String[] projection_type_info = new String[]{'projection',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'boundingBoxBottom','boundingBoxLeft','boundingBoxRight','boundingBoxTop','mapLabel','mapName','projection'};
  }

  public class HistoryRetentionPolicy {
      public Integer archiveAfterMonths;
      public Integer archiveRetentionYears;
      public String description;
      public Integer gracePeriodDays;
      private String[] archiveAfterMonths_type_info = new String[]{'archiveAfterMonths',SOAP_M_URI,null,'1','1','false'};
      private String[] archiveRetentionYears_type_info = new String[]{'archiveRetentionYears',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] gracePeriodDays_type_info = new String[]{'gracePeriodDays',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'archiveAfterMonths','archiveRetentionYears','description','gracePeriodDays'};
  }

  public class AppProfileActionOverride {
      public String profile;
      private String[] profile_type_info = new String[]{'profile',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'profile'};
  }

  public class FlowScreenFieldOutputParameter {
      public String assignToReference;
      public String name;
      private String[] assignToReference_type_info = new String[]{'assignToReference',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'assignToReference','name'};
  }

  public class AgentConfigSkills {
      public String[] skill;
      private String[] skill_type_info = new String[]{'skill',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'skill'};
  }

  public class IdeaReputationLevel {
      public String name;
      public Integer value;
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] value_type_info = new String[]{'value',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'name','value'};
  }

  public class ReportAggregateReference {
      public String aggregate;
      private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregate'};
  }

  public class DashboardFilterOption {
      public String operator;
      public String[] values;
      private String[] operator_type_info = new String[]{'operator',SOAP_M_URI,null,'1','1','false'};
      private String[] values_type_info = new String[]{'values',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'operator','values'};
  }

  public class ConnectedAppSamlConfig {
      public String acsUrl;
      public String certificate;
      public String encryptionCertificate;
      public String encryptionType;
      public String entityUrl;
      public String issuer;
      public String samlIdpSLOBindingEnum;
      public String samlNameIdFormat;
      public String samlSloUrl;
      public String samlSubjectCustomAttr;
      public String samlSubjectType;
      private String[] acsUrl_type_info = new String[]{'acsUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
      private String[] encryptionCertificate_type_info = new String[]{'encryptionCertificate',SOAP_M_URI,null,'0','1','false'};
      private String[] encryptionType_type_info = new String[]{'encryptionType',SOAP_M_URI,null,'0','1','false'};
      private String[] entityUrl_type_info = new String[]{'entityUrl',SOAP_M_URI,null,'1','1','false'};
      private String[] issuer_type_info = new String[]{'issuer',SOAP_M_URI,null,'0','1','false'};
      private String[] samlIdpSLOBindingEnum_type_info = new String[]{'samlIdpSLOBindingEnum',SOAP_M_URI,null,'0','1','false'};
      private String[] samlNameIdFormat_type_info = new String[]{'samlNameIdFormat',SOAP_M_URI,null,'0','1','false'};
      private String[] samlSloUrl_type_info = new String[]{'samlSloUrl',SOAP_M_URI,null,'0','1','false'};
      private String[] samlSubjectCustomAttr_type_info = new String[]{'samlSubjectCustomAttr',SOAP_M_URI,null,'0','1','false'};
      private String[] samlSubjectType_type_info = new String[]{'samlSubjectType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'acsUrl','certificate','encryptionCertificate','encryptionType','entityUrl','issuer','samlIdpSLOBindingEnum','samlNameIdFormat','samlSloUrl','samlSubjectCustomAttr','samlSubjectType'};
  }

  public class ApprovalStepRejectBehavior {
      public String type_x;
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'type_x'};
  }

  public class XOrgHubSharedObject {
      public String[] fields;
      public String name;
      private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fields','name'};
  }

  public class DuplicateRuleFilterItem {
      public Integer sortOrder;
      public String table;
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'1','1','false'};
      private String[] table_type_info = new String[]{'table',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'sortOrder','table'};
  }

  public class CustomPageWebLinkTranslation {
      public String label;
      public String name;
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'label','name'};
  }

  public class CustomPermissionDependencyRequired {
      public String customPermission;
      public Boolean dependency;
      private String[] customPermission_type_info = new String[]{'customPermission',SOAP_M_URI,null,'1','1','false'};
      private String[] dependency_type_info = new String[]{'dependency',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customPermission','dependency'};
  }

  public class ProfileFieldLevelSecurity {
      public Boolean editable;
      public String field;
      public Boolean readable;
      private String[] editable_type_info = new String[]{'editable',SOAP_M_URI,null,'1','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] readable_type_info = new String[]{'readable',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'editable','field','readable'};
  }

  public class checkDeployStatus_element {
      public String asyncProcessId;
      public Boolean includeDetails;
      private String[] asyncProcessId_type_info = new String[]{'asyncProcessId',SOAP_M_URI,null,'1','1','false'};
      private String[] includeDetails_type_info = new String[]{'includeDetails',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'asyncProcessId','includeDetails'};
  }

  public class SkillUserAssignments {
      public String[] user_x;
      private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'user_x'};
  }

  public class FlowInputValidationRuleTranslation {
      public String errorMessage;
      private String[] errorMessage_type_info = new String[]{'errorMessage',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'errorMessage'};
  }

  public class ReportColorRange {
      public String aggregate;
      public String columnName;
      public Double highBreakpoint;
      public String highColor;
      public Double lowBreakpoint;
      public String lowColor;
      public String midColor;
      private String[] aggregate_type_info = new String[]{'aggregate',SOAP_M_URI,null,'0','1','false'};
      private String[] columnName_type_info = new String[]{'columnName',SOAP_M_URI,null,'1','1','false'};
      private String[] highBreakpoint_type_info = new String[]{'highBreakpoint',SOAP_M_URI,null,'0','1','false'};
      private String[] highColor_type_info = new String[]{'highColor',SOAP_M_URI,null,'1','1','false'};
      private String[] lowBreakpoint_type_info = new String[]{'lowBreakpoint',SOAP_M_URI,null,'0','1','false'};
      private String[] lowColor_type_info = new String[]{'lowColor',SOAP_M_URI,null,'1','1','false'};
      private String[] midColor_type_info = new String[]{'midColor',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregate','columnName','highBreakpoint','highColor','lowBreakpoint','lowColor','midColor'};
  }

  public class OrganizationSettingsDetail {
      public String settingName;
      public Boolean settingValue;
      private String[] settingName_type_info = new String[]{'settingName',SOAP_M_URI,null,'1','1','false'};
      private String[] settingValue_type_info = new String[]{'settingValue',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'settingName','settingValue'};
  }

  public class CommunityCustomThemeLayoutType {
      public String description;
      public String label;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','label'};
  }

  public class CommunityTemplatePageSetting {
      public String page_x;
      public String themeLayout;
      private String[] page_x_type_info = new String[]{'page',SOAP_M_URI,null,'1','1','false'};
      private String[] themeLayout_type_info = new String[]{'themeLayout',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'page_x','themeLayout'};
  }

  public class describeValueType_element {
      public String type_x;
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'type_x'};
  }

  public class WaveXmdMeasure {
      public String dateFormat;
      public String description;
      public String field;
      public String formatCustomFormat;
      public Integer formatDecimalDigits;
      public Boolean formatIsNegativeParens;
      public String formatPrefix;
      public String formatSuffix;
      public String formatUnit;
      public Double formatUnitMultiplier;
      public String fullyQualifiedName;
      public Boolean isDerived;
      public String label;
      public String origin;
      public Integer showDetailsDefaultFieldIndex;
      public Boolean showInExplorer;
      public Integer sortIndex;
      private String[] dateFormat_type_info = new String[]{'dateFormat',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] formatCustomFormat_type_info = new String[]{'formatCustomFormat',SOAP_M_URI,null,'0','1','false'};
      private String[] formatDecimalDigits_type_info = new String[]{'formatDecimalDigits',SOAP_M_URI,null,'0','1','false'};
      private String[] formatIsNegativeParens_type_info = new String[]{'formatIsNegativeParens',SOAP_M_URI,null,'0','1','false'};
      private String[] formatPrefix_type_info = new String[]{'formatPrefix',SOAP_M_URI,null,'0','1','false'};
      private String[] formatSuffix_type_info = new String[]{'formatSuffix',SOAP_M_URI,null,'0','1','false'};
      private String[] formatUnit_type_info = new String[]{'formatUnit',SOAP_M_URI,null,'0','1','false'};
      private String[] formatUnitMultiplier_type_info = new String[]{'formatUnitMultiplier',SOAP_M_URI,null,'0','1','false'};
      private String[] fullyQualifiedName_type_info = new String[]{'fullyQualifiedName',SOAP_M_URI,null,'0','1','false'};
      private String[] isDerived_type_info = new String[]{'isDerived',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'0','1','false'};
      private String[] origin_type_info = new String[]{'origin',SOAP_M_URI,null,'0','1','false'};
      private String[] showDetailsDefaultFieldIndex_type_info = new String[]{'showDetailsDefaultFieldIndex',SOAP_M_URI,null,'0','1','false'};
      private String[] showInExplorer_type_info = new String[]{'showInExplorer',SOAP_M_URI,null,'0','1','false'};
      private String[] sortIndex_type_info = new String[]{'sortIndex',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dateFormat','description','field','formatCustomFormat','formatDecimalDigits','formatIsNegativeParens','formatPrefix','formatSuffix','formatUnit','formatUnitMultiplier','fullyQualifiedName','isDerived','label','origin','showDetailsDefaultFieldIndex','showInExplorer','sortIndex'};
  }

  public class TransactionSecurityNotification {
      public Boolean inApp;
      public Boolean sendEmail;
      public String user_x;
      private String[] inApp_type_info = new String[]{'inApp',SOAP_M_URI,null,'1','1','false'};
      private String[] sendEmail_type_info = new String[]{'sendEmail',SOAP_M_URI,null,'1','1','false'};
      private String[] user_x_type_info = new String[]{'user',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'inApp','sendEmail','user_x'};
  }

  public class ReportColumn {
      public String[] aggregateTypes;
      public String field;
      public Boolean reverseColors;
      public Boolean showChanges;
      private String[] aggregateTypes_type_info = new String[]{'aggregateTypes',SOAP_M_URI,null,'0','-1','false'};
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'1','1','false'};
      private String[] reverseColors_type_info = new String[]{'reverseColors',SOAP_M_URI,null,'0','1','false'};
      private String[] showChanges_type_info = new String[]{'showChanges',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'aggregateTypes','field','reverseColors','showChanges'};
  }

  public class FieldSetItem {
      public String field;
      public Boolean isFieldManaged;
      public Boolean isRequired;
      private String[] field_type_info = new String[]{'field',SOAP_M_URI,null,'0','1','false'};
      private String[] isFieldManaged_type_info = new String[]{'isFieldManaged',SOAP_M_URI,null,'0','1','false'};
      private String[] isRequired_type_info = new String[]{'isRequired',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'field','isFieldManaged','isRequired'};
  }

  public class ProfileUserPermission {
      public Boolean enabled;
      public String name;
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enabled','name'};
  }

  public class FindSimilarOppFilter {
      public String[] similarOpportunitiesDisplayColumns;
      public String[] similarOpportunitiesMatchFields;
      private String[] similarOpportunitiesDisplayColumns_type_info = new String[]{'similarOpportunitiesDisplayColumns',SOAP_M_URI,null,'0','-1','false'};
      private String[] similarOpportunitiesMatchFields_type_info = new String[]{'similarOpportunitiesMatchFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'similarOpportunitiesDisplayColumns','similarOpportunitiesMatchFields'};
  }

  public class ReportAggregate {
      public String acrossGroupingContext;
      public String calculatedFormula;
      public String datatype;
      public String description;
      public String developerName;
      public String downGroupingContext;
      public Boolean isActive;
      public Boolean isCrossBlock;
      public String masterLabel;
      public String reportType;
      public Integer scale;
      private String[] acrossGroupingContext_type_info = new String[]{'acrossGroupingContext',SOAP_M_URI,null,'0','1','false'};
      private String[] calculatedFormula_type_info = new String[]{'calculatedFormula',SOAP_M_URI,null,'1','1','false'};
      private String[] datatype_type_info = new String[]{'datatype',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] developerName_type_info = new String[]{'developerName',SOAP_M_URI,null,'1','1','false'};
      private String[] downGroupingContext_type_info = new String[]{'downGroupingContext',SOAP_M_URI,null,'0','1','false'};
      private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'1','1','false'};
      private String[] isCrossBlock_type_info = new String[]{'isCrossBlock',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] reportType_type_info = new String[]{'reportType',SOAP_M_URI,null,'0','1','false'};
      private String[] scale_type_info = new String[]{'scale',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'acrossGroupingContext','calculatedFormula','datatype','description','developerName','downGroupingContext','isActive','isCrossBlock','masterLabel','reportType','scale'};
  }

  public class NetworkTabSet {
      public String[] customTab;
      public String defaultTab;
      public String[] standardTab;
      private String[] customTab_type_info = new String[]{'customTab',SOAP_M_URI,null,'0','-1','false'};
      private String[] defaultTab_type_info = new String[]{'defaultTab',SOAP_M_URI,null,'1','1','false'};
      private String[] standardTab_type_info = new String[]{'standardTab',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customTab','defaultTab','standardTab'};
  }

  public class MatchingRuleItem {
      public String blankValueBehavior;
      public String fieldName;
      public String matchingMethod;
      private String[] blankValueBehavior_type_info = new String[]{'blankValueBehavior',SOAP_M_URI,null,'0','1','false'};
      private String[] fieldName_type_info = new String[]{'fieldName',SOAP_M_URI,null,'1','1','false'};
      private String[] matchingMethod_type_info = new String[]{'matchingMethod',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'blankValueBehavior','fieldName','matchingMethod'};
  }

  public class DashboardComponentSortInfo {
      public String sortColumn;
      public String sortOrder;
      private String[] sortColumn_type_info = new String[]{'sortColumn',SOAP_M_URI,null,'0','1','false'};
      private String[] sortOrder_type_info = new String[]{'sortOrder',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'sortColumn','sortOrder'};
  }

  //Not invoked in other classes
  public class PermissionSetGroup {
      public String description;
      public Boolean isCalculatingChanges;
      public String label;
      public String[] permissionSets;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] isCalculatingChanges_type_info = new String[]{'isCalculatingChanges',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] permissionSets_type_info = new String[]{'permissionSets',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','isCalculatingChanges','label','permissionSets'};
  }

  public class LiveChatSensitiveDataRule {
      public String actionType;
      public String description;
      public Integer enforceOn;
      public Boolean isEnabled;
      public String pattern;
      public String replacement;
      private String[] actionType_type_info = new String[]{'actionType',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] enforceOn_type_info = new String[]{'enforceOn',SOAP_M_URI,null,'1','1','false'};
      private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'1','1','false'};
      private String[] pattern_type_info = new String[]{'pattern',SOAP_M_URI,null,'1','1','false'};
      private String[] replacement_type_info = new String[]{'replacement',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'actionType','description','enforceOn','isEnabled','pattern','replacement'};
  }

  public class FieldServiceSettings {
      public Boolean fieldServiceNotificationsOrgPref;
      public Boolean fieldServiceOrgPref;
      public Integer serviceAppointmentsDueDateOffsetOrgValue;
      public String[] workOrderLineItemSearchFields;
      public String[] workOrderSearchFields;
      private String[] fieldServiceNotificationsOrgPref_type_info = new String[]{'fieldServiceNotificationsOrgPref',SOAP_M_URI,null,'0','1','false'};
      private String[] fieldServiceOrgPref_type_info = new String[]{'fieldServiceOrgPref',SOAP_M_URI,null,'0','1','false'};
      private String[] serviceAppointmentsDueDateOffsetOrgValue_type_info = new String[]{'serviceAppointmentsDueDateOffsetOrgValue',SOAP_M_URI,null,'0','1','false'};
      private String[] workOrderLineItemSearchFields_type_info = new String[]{'workOrderLineItemSearchFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] workOrderSearchFields_type_info = new String[]{'workOrderSearchFields',SOAP_M_URI,null,'0','-1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'fieldServiceNotificationsOrgPref','fieldServiceOrgPref','serviceAppointmentsDueDateOffsetOrgValue','workOrderLineItemSearchFields','workOrderSearchFields'};
  }

  public class CustomNotificationType {
      public String customNotifTypeName;
      public String description;
      public Boolean desktop;
      public Boolean email;
      public String masterLabel;
      public Boolean mobile;
      private String[] customNotifTypeName_type_info = new String[]{'customNotifTypeName',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] desktop_type_info = new String[]{'desktop',SOAP_M_URI,null,'1','1','false'};
      private String[] email_type_info = new String[]{'email',SOAP_M_URI,null,'1','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] mobile_type_info = new String[]{'mobile',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'customNotifTypeName','description','desktop','email','masterLabel','mobile'};
  }

  public class WaveRecipe {
      public String dataflow;
      public String masterLabel;
      public String securityPredicate;
      public String targetDatasetAlias;
      private String[] dataflow_type_info = new String[]{'dataflow',SOAP_M_URI,null,'1','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] securityPredicate_type_info = new String[]{'securityPredicate',SOAP_M_URI,null,'0','1','false'};
      private String[] targetDatasetAlias_type_info = new String[]{'targetDatasetAlias',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'dataflow','masterLabel','securityPredicate','targetDatasetAlias'};
  }

  public class PathAssistantSettings {
      public Boolean pathAssistantEnabled;
      private String[] pathAssistantEnabled_type_info = new String[]{'pathAssistantEnabled',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'pathAssistantEnabled'};
  }

  public class Territory {
      public String accountAccessLevel;
      public String parentTerritory;
      private String[] accountAccessLevel_type_info = new String[]{'accountAccessLevel',SOAP_M_URI,null,'0','1','false'};
      private String[] parentTerritory_type_info = new String[]{'parentTerritory',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'accountAccessLevel','parentTerritory'};
  }

  public class PersonListSettings {
      public Boolean enablePersonList;
      private String[] enablePersonList_type_info = new String[]{'enablePersonList',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enablePersonList'};
  }
  public class LiveMessageSettings {
      public Boolean enableLiveMessage;
      private String[] enableLiveMessage_type_info = new String[]{'enableLiveMessage',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableLiveMessage'};
  }

  public class IntegrationHubSettingsType {
      public String canonicalName;
      public String canonicalNameBindingChar;
      public String description;
      public Boolean isEnabled;
      public Boolean isProtected;
      public String masterLabel;
      public String setupNamespace;
      public String setupSimpleName;
      public String uUID;
      public String version;
      public Integer versionBuild;
      public Integer versionMajor;
      public Integer versionMinor;
      private String[] canonicalName_type_info = new String[]{'canonicalName',SOAP_M_URI,null,'0','1','false'};
      private String[] canonicalNameBindingChar_type_info = new String[]{'canonicalNameBindingChar',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'0','1','false'};
      private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] setupNamespace_type_info = new String[]{'setupNamespace',SOAP_M_URI,null,'0','1','false'};
      private String[] setupSimpleName_type_info = new String[]{'setupSimpleName',SOAP_M_URI,null,'1','1','false'};
      private String[] uUID_type_info = new String[]{'uUID',SOAP_M_URI,null,'0','1','false'};
      private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'0','1','false'};
      private String[] versionBuild_type_info = new String[]{'versionBuild',SOAP_M_URI,null,'0','1','false'};
      private String[] versionMajor_type_info = new String[]{'versionMajor',SOAP_M_URI,null,'0','1','false'};
      private String[] versionMinor_type_info = new String[]{'versionMinor',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'canonicalName','canonicalNameBindingChar','description','isEnabled','isProtected','masterLabel','setupNamespace','setupSimpleName','uUID','version','versionBuild','versionMajor','versionMinor'};
  }

  public class DataPipeline {
      public Double apiVersion;
      public String label;
      public String scriptType;
      private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'1','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] scriptType_type_info = new String[]{'scriptType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apiVersion','label','scriptType'};
  }

  public class WaveTemplateBundle {
      public String assetIcon;
      public Double assetVersion;
      public String description;
      public String label;
      public String templateBadgeIcon;
      public String templateDetailIcon;
      public String templateType;
      private String[] assetIcon_type_info = new String[]{'assetIcon',SOAP_M_URI,null,'0','1','false'};
      private String[] assetVersion_type_info = new String[]{'assetVersion',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
      private String[] templateBadgeIcon_type_info = new String[]{'templateBadgeIcon',SOAP_M_URI,null,'0','1','false'};
      private String[] templateDetailIcon_type_info = new String[]{'templateDetailIcon',SOAP_M_URI,null,'0','1','false'};
      private String[] templateType_type_info = new String[]{'templateType',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'assetIcon','assetVersion','description','label','templateBadgeIcon','templateDetailIcon','templateType'};
  }

  public class LightningExperienceTheme {
      public String defaultBrandingSet;
      public String description;
      public String masterLabel;
      public Boolean shouldOverrideLoadingImage;
      private String[] defaultBrandingSet_type_info = new String[]{'defaultBrandingSet',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] shouldOverrideLoadingImage_type_info = new String[]{'shouldOverrideLoadingImage',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'defaultBrandingSet','description','masterLabel','shouldOverrideLoadingImage'};
  }

  public class MacroSettings {
      public Boolean enableAdvancedSearch;
      private String[] enableAdvancedSearch_type_info = new String[]{'enableAdvancedSearch',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'enableAdvancedSearch'};
  }

  public class EmbeddedServiceFieldService {
      public String appointmentBookingFlowName;
      public String cancelApptBookingFlowName;
      public String embeddedServiceConfig;
      public Boolean enabled;
      public String fieldServiceConfirmCardImg;
      public String fieldServiceHomeImg;
      public String fieldServiceLogoImg;
      public String masterLabel;
      public String modifyApptBookingFlowName;
      public Boolean shouldShowExistingAppointment;
      public Boolean shouldShowNewAppointment;
      private String[] appointmentBookingFlowName_type_info = new String[]{'appointmentBookingFlowName',SOAP_M_URI,null,'0','1','false'};
      private String[] cancelApptBookingFlowName_type_info = new String[]{'cancelApptBookingFlowName',SOAP_M_URI,null,'0','1','false'};
      private String[] embeddedServiceConfig_type_info = new String[]{'embeddedServiceConfig',SOAP_M_URI,null,'1','1','false'};
      private String[] enabled_type_info = new String[]{'enabled',SOAP_M_URI,null,'1','1','false'};
      private String[] fieldServiceConfirmCardImg_type_info = new String[]{'fieldServiceConfirmCardImg',SOAP_M_URI,null,'0','1','false'};
      private String[] fieldServiceHomeImg_type_info = new String[]{'fieldServiceHomeImg',SOAP_M_URI,null,'0','1','false'};
      private String[] fieldServiceLogoImg_type_info = new String[]{'fieldServiceLogoImg',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] modifyApptBookingFlowName_type_info = new String[]{'modifyApptBookingFlowName',SOAP_M_URI,null,'0','1','false'};
      private String[] shouldShowExistingAppointment_type_info = new String[]{'shouldShowExistingAppointment',SOAP_M_URI,null,'0','1','false'};
      private String[] shouldShowNewAppointment_type_info = new String[]{'shouldShowNewAppointment',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'appointmentBookingFlowName','cancelApptBookingFlowName','embeddedServiceConfig','enabled','fieldServiceConfirmCardImg','fieldServiceHomeImg','fieldServiceLogoImg','masterLabel','modifyApptBookingFlowName','shouldShowExistingAppointment','shouldShowNewAppointment'};
  }

  public class LightningComponentBundle {
      public Double apiVersion;
      public Boolean isExposed;
      private String[] apiVersion_type_info = new String[]{'apiVersion',SOAP_M_URI,null,'0','1','false'};
      private String[] isExposed_type_info = new String[]{'isExposed',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'apiVersion','isExposed'};
  }

  public class Orchestration {
      public String context;
      public String masterLabel;
      private String[] context_type_info = new String[]{'context',SOAP_M_URI,null,'1','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'context','masterLabel'};
  }

  public class InsightType {
      public String defaultTrendType;
      public String description;
      public Boolean isProtected;
      public String masterLabel;
      public String parentType;
      public String title;
      private String[] defaultTrendType_type_info = new String[]{'defaultTrendType',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
      private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] parentType_type_info = new String[]{'parentType',SOAP_M_URI,null,'1','1','false'};
      private String[] title_type_info = new String[]{'title',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'defaultTrendType','description','isProtected','masterLabel','parentType','title'};
  }

  public class ChatterExtension {
      public String compositionComponent;
      public String description;
      public String extensionName;
      public String headerText;
      public String hoverText;
      public String icon;
      public Boolean isProtected;
      public String masterLabel;
      public String renderComponent;
      public String type_x;
      private String[] compositionComponent_type_info = new String[]{'compositionComponent',SOAP_M_URI,null,'1','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'1','1','false'};
      private String[] extensionName_type_info = new String[]{'extensionName',SOAP_M_URI,null,'1','1','false'};
      private String[] headerText_type_info = new String[]{'headerText',SOAP_M_URI,null,'0','1','false'};
      private String[] hoverText_type_info = new String[]{'hoverText',SOAP_M_URI,null,'0','1','false'};
      private String[] icon_type_info = new String[]{'icon',SOAP_M_URI,null,'1','1','false'};
      private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] renderComponent_type_info = new String[]{'renderComponent',SOAP_M_URI,null,'1','1','false'};
      private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'compositionComponent','description','extensionName','headerText','hoverText','icon','isProtected','masterLabel','renderComponent','type_x'};
  }

  public class CampaignInfluenceModel {
      public Boolean isActive;
      public Boolean isDefaultModel;
      public Boolean isModelLocked;
      public String modelDescription;
      public String name;
      public String recordPreference;
      private String[] isActive_type_info = new String[]{'isActive',SOAP_M_URI,null,'0','1','false'};
      private String[] isDefaultModel_type_info = new String[]{'isDefaultModel',SOAP_M_URI,null,'1','1','false'};
      private String[] isModelLocked_type_info = new String[]{'isModelLocked',SOAP_M_URI,null,'1','1','false'};
      private String[] modelDescription_type_info = new String[]{'modelDescription',SOAP_M_URI,null,'0','1','false'};
      private String[] name_type_info = new String[]{'name',SOAP_M_URI,null,'1','1','false'};
      private String[] recordPreference_type_info = new String[]{'recordPreference',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'isActive','isDefaultModel','isModelLocked','modelDescription','name','recordPreference'};
  }

  public class UiPlugin {
      public String description;
      public String extensionPointIdentifier;
      public Boolean isEnabled;
      public String language;
      public String masterLabel;
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] extensionPointIdentifier_type_info = new String[]{'extensionPointIdentifier',SOAP_M_URI,null,'1','1','false'};
      private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'1','1','false'};
      private String[] language_type_info = new String[]{'language',SOAP_M_URI,null,'1','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'description','extensionPointIdentifier','isEnabled','language','masterLabel'};
  }

  public class FlowDefinition {
      public Integer activeVersionNumber;
      public String description;
      public String masterLabel;
      private String[] activeVersionNumber_type_info = new String[]{'activeVersionNumber',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'activeVersionNumber','description','masterLabel'};
  }

  public class IntegrationHubSettings {
      public String canonicalName;
      public String canonicalNameBindingChar;
      public String description;
      public Boolean isEnabled;
      public Boolean isProtected;
      public String masterLabel;
      public String setupData;
      public String setupDefinition;
      public String setupNamespace;
      public String setupSimpleName;
      public String uUID;
      public String version;
      public Integer versionBuild;
      public Integer versionMajor;
      public Integer versionMinor;
      private String[] canonicalName_type_info = new String[]{'canonicalName',SOAP_M_URI,null,'0','1','false'};
      private String[] canonicalNameBindingChar_type_info = new String[]{'canonicalNameBindingChar',SOAP_M_URI,null,'0','1','false'};
      private String[] description_type_info = new String[]{'description',SOAP_M_URI,null,'0','1','false'};
      private String[] isEnabled_type_info = new String[]{'isEnabled',SOAP_M_URI,null,'0','1','false'};
      private String[] isProtected_type_info = new String[]{'isProtected',SOAP_M_URI,null,'0','1','false'};
      private String[] masterLabel_type_info = new String[]{'masterLabel',SOAP_M_URI,null,'1','1','false'};
      private String[] setupData_type_info = new String[]{'setupData',SOAP_M_URI,null,'0','1','false'};
      private String[] setupDefinition_type_info = new String[]{'setupDefinition',SOAP_M_URI,null,'0','1','false'};
      private String[] setupNamespace_type_info = new String[]{'setupNamespace',SOAP_M_URI,null,'0','1','false'};
      private String[] setupSimpleName_type_info = new String[]{'setupSimpleName',SOAP_M_URI,null,'1','1','false'};
      private String[] uUID_type_info = new String[]{'uUID',SOAP_M_URI,null,'0','1','false'};
      private String[] version_type_info = new String[]{'version',SOAP_M_URI,null,'0','1','false'};
      private String[] versionBuild_type_info = new String[]{'versionBuild',SOAP_M_URI,null,'0','1','false'};
      private String[] versionMajor_type_info = new String[]{'versionMajor',SOAP_M_URI,null,'0','1','false'};
      private String[] versionMinor_type_info = new String[]{'versionMinor',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'canonicalName','canonicalNameBindingChar','description','isEnabled','isProtected','masterLabel','setupData','setupDefinition','setupNamespace','setupSimpleName','uUID','version','versionBuild','versionMajor','versionMinor'};
  }

  public class Role {
      public String parentRole;
      private String[] parentRole_type_info = new String[]{'parentRole',SOAP_M_URI,null,'0','1','false'};
      private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
      private String[] field_order_type_info = new String[]{'parentRole'};
  }

}