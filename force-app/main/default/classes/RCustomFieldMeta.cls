// MR 22OCT23 - Added New Class for RCustomLookup Results handling
public with sharing class RCustomFieldMeta {
  // VD 18Jun25 field Meta Handling changes
  @AuraEnabled
  public String id;
  @AuraEnabled
  public String name;
  @AuraEnabled
  public String apiName;
  @AuraEnabled
  public String fldType;
  @AuraEnabled
  public Boolean searchFlag;
  @AuraEnabled
  public Boolean orderByFlag;
  @AuraEnabled
  public Boolean filterFlag;
  @AuraEnabled
  public String filterLogic;
  @AuraEnabled
  public String filterCondition;
  @AuraEnabled
  public String filterValue;
  @AuraEnabled
  public Boolean outputFlag;
  @AuraEnabled
  public String label;
  @AuraEnabled
  public String widthStyle;
  @AuraEnabled
  public String tableDataStyle;
  @AuraEnabled
  public String tableHeadStyle;
  @AuraEnabled
  public Integer order;
  @AuraEnabled
  public Boolean resultantFlag;
  @AuraEnabled
  public Boolean isChild;
  @AuraEnabled
  public Boolean isFoot;
  @AuraEnabled
  public Integer colspan;
  @AuraEnabled
  public String childObjName;
  @AuraEnabled
  public String childObjFldName;
  @AuraEnabled
  public String childFilter;
  @AuraEnabled
  public Boolean isGrandChild;
  @AuraEnabled
  public String grandChildObjName;
  @AuraEnabled
  public String grandChildObjFldName;
  @AuraEnabled
  public String grandChildFilter;
  @AuraEnabled
  public String grandChildParentField;
  // VD 18Jun25 field Meta Handling changes
  // VD 15July25 flag handling
  public static Field_Meta__c loadFieldMetaWrapper(RCustomFieldMeta fm) {
    Field_Meta__c fieldMeta = new Field_Meta__c();
    if (String.isNotEmpty(fm.id)) {
      fieldMeta.Id = fm.id;
    }
    fieldMeta.API_Name__c = fm.apiName;
    fieldMeta.fld_type__c = fm.fldType;
    fieldMeta.searchFlag__c = fm.searchFlag == true ? true : false;
    fieldMeta.orderByFlag__c = fm.orderByFlag == true ? true : false;
    fieldMeta.filterFlag__c = fm.filterFlag == true ? true : false;
    fieldMeta.filterLogic__c = fm.filterLogic;
    fieldMeta.filterCondition__c = fm.filterCondition;
    fieldMeta.filterValue__c = fm.filterValue;
    fieldMeta.Colspan__c = fm.colspan;
    fieldMeta.Output_Flag__c = fm.outputFlag == true ? true : false;
    fieldMeta.Is_Foot__c = fm.isFoot == true ? true : false;
    fieldMeta.Label__c = fm.label;
    fieldMeta.Width_Style__c = fm.widthStyle;
    fieldMeta.Table_Data_Style__c = fm.tableDataStyle;
    fieldMeta.Table_Head_Style__c = fm.tableHeadStyle;
    fieldMeta.Order__c = fm.order;
    fieldMeta.resultantFlag__c = fm.resultantFlag == true ? true : false;
    fieldMeta.isChild__c = fm.isChild == true ? true : false;
    fieldMeta.childObjName__c = fm.childObjName;
    fieldMeta.childObjFldName__c = fm.childObjFldName;
    fieldMeta.childFilter__c = fm.childFilter;
    fieldMeta.isGrandChild__c = fm.isGrandChild == true ? true : false;
    fieldMeta.grandChildObjName__c = fm.grandChildObjName;
    fieldMeta.grandChildParentField__c = fm.grandChildObjFldName;
    fieldMeta.grandChildFilter__c = fm.grandChildFilter;
    fieldMeta.grandChildParentField__c = fm.grandChildParentField;

    return fieldMeta;
  }
}