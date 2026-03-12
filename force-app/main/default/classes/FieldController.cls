public with sharing class FieldController {
  @AuraEnabled
  // VD 23jul24 - to get the required fields
  public static List<Map<String, Object>> getRequiredFields(
    String objectApiName
  ) {
    Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe()
      .get(objectApiName)
      .getDescribe()
      .fields.getMap();
    List<Map<String, Object>> requiredFields = new List<Map<String, Object>>();

    for (Schema.SObjectField field : fieldMap.values()) {
      Schema.DescribeFieldResult fieldResult = field.getDescribe();
      // VD 19Mar25  Skip Master-Detail fields
      if (
        fieldResult.getType() == Schema.DisplayType.REFERENCE &&
        fieldResult.getReferenceTo().size() > 0 &&
        fieldResult.isCreateable() &&
        !fieldResult.isNillable() &&
        !fieldResult.defaultedOnCreate
      ) {
        // Check if the field is a Master-Detail relationship
        if (fieldResult.getRelationshipOrder() != null) {
          System.debug('inisde master detaisl-->');
          continue; // Skip this field
        }
      }
      if (
        fieldResult.isCreateable() &&
        !fieldResult.isNillable() &&
        !fieldResult.defaultedOnCreate
      ) {
        Map<String, Object> fieldInfo = new Map<String, Object>();
        fieldInfo.put('label', fieldResult.getLabel());
        fieldInfo.put('name', fieldResult.getName());
        // fieldInfo.put('type', fieldResult.getType());
        requiredFields.add(fieldInfo);
      }
    }

    return requiredFields;
  }
}