public with sharing class RCustomLookupController {
  @AuraEnabled(cacheable=true)
  public static CustomLookupResult queryRecords(
    String strInput,
    String objectName,
    String fieldsWrapper,
    String filterQuery,
    Boolean isSearchBox
  ) {
    List<RCustomFieldMeta> inpFieldsList = (List<RCustomFieldMeta>) JSON.deserialize(
      fieldsWrapper,
      List<RCustomFieldMeta>.class
    );
    List<RCustomFieldMeta> fieldsList = new List<RCustomFieldMeta>();
    CustomLookupResult lookupResult = new CustomLookupResult();

    String str = strInput + '%';
    List<String> apiNames = new List<String>();
    List<String> srchFields = new List<String>();
    List<String> orderByFields = new List<String>();
    List<String> andFilters = new List<String>();
    List<String> orFilters = new List<String>();
    // VD 28FEB25 Child and grand child record read changes
    List<String> childQueries = new List<String>();

    // Store grandchild queries separately
    Map<String, List<String>> grandChildQueries = new Map<String, List<String>>();
    // VD 05MAR25 child data fix
    Map<String, Set<String>> childQueryMap = new Map<String, Set<String>>();
    Map<String, String> childFilterMap = new Map<String, String>();

    // RT 08SEP25 - CRUD Validation 
    for (RCustomFieldMeta fld : inpFieldsList) {
      if (String.isNotBlank(fld.apiName)) {

        Boolean accessible = false;
        
        try {
          List<String> parts = fld.apiName.split('\\.');
          Schema.SObjectType currentType = Schema.getGlobalDescribe().get(objectName);
          
          // Walk the relationship chain if dot notation
          for (Integer i = 0; i < parts.size(); i++) {
            if (currentType == null) break;
            Map<String, Schema.SObjectField> fieldMap = currentType.getDescribe().fields.getMap();
            
            String partName = parts[i];
            // For relationship fields, use __c for fieldMap and __r for reference traversal
            if (partName.endsWith('__r')) {
              partName = partName.replace('__r', '__c');
            }
            
            if (!fieldMap.containsKey(partName.toLowerCase())) {
              currentType = null;
              break;
            }
            
            Schema.DescribeFieldResult dfr = fieldMap.get(partName.toLowerCase()).getDescribe();
            
            if (i == parts.size() - 1) {
              accessible = dfr.isAccessible();
            } else {
              if (!dfr.getReferenceTo().isEmpty()) {
                currentType = dfr.getReferenceTo()[0];
              } else {
                currentType = null;
              }
            }
          }
        } catch (Exception e) {
            accessible = false;
        }

        if (!accessible) {
            fld.outputFlag = false;
            continue; // don’t add to apiNames
        }
        // VD 28FEB25 Child and grand child record read changes
        if (fld.isChild != null && fld.isChild) {
          String childFilter = String.isNotBlank(fld.childFilter) ? fld.childFilter : '';
          String childRelName = fld.childObjName;
          // Initialize if not already present
          if (!childQueryMap.containsKey(childRelName)) {
            // VD 05MAR25 child data fix
            childQueryMap.put(childRelName, new Set<String>());
          }
          // Add field to the existing child relationship query
          childQueryMap.get(childRelName).add(fld.childObjFldName);
          childFilterMap.put(childRelName, String.isNotBlank(fld.childFilter) ? fld.childFilter : '');
          
          if (fld.isGrandChild != null && fld.isGrandChild) {
            if (!grandChildQueries.containsKey(fld.grandChildObjName)) {
              grandChildQueries.put(fld.grandChildObjName, new List<String>());
            }
            grandChildQueries.get(fld.grandChildObjName).add(fld.grandChildObjFldName);
          }
        } else if (fld.apiName.contains('.')) {
          // Handle Lookup Field (e.g., Account.Name)
          String[] filterFldArray = fld.apiName.split('\\.');
          fld.childObjName = filterFldArray[0];
          fld.childObjFldName = filterFldArray[1];
          // fld.isChild = true;
          apiNames.add(fld.apiName);
        } else {
          apiNames.add(fld.apiName);
        }
      }

      if (fld.searchFlag != null && fld.searchFlag) {
        srchFields.add(fld.apiName + ' LIKE \'%' + str + '%\'');
      }

      if (fld.orderByFlag != null && fld.orderByFlag) {
        orderByFields.add(fld.apiName);
      }

      if (fld.filterFlag != null && fld.filterFlag) {
        String formattedValue = wrapValue(fld.fldType, fld.filterValue);
        if (fld.filterLogic == 'AND') {
          andFilters.add(fld.apiName + ' ' + fld.filterCondition + ' ' + formattedValue);
        } else {
          orFilters.add(fld.apiName + ' ' + fld.filterCondition + ' ' + formattedValue);
        }
      }

      fieldsList.add(fld);
    }

    for (String childRelName : childQueryMap.keySet()) {
      Set<String> childFieldsSet = childQueryMap.get(childRelName);
      List<String> childFields = new List<String>(childFieldsSet);
      String childFilter = childFilterMap.get(childRelName);
      String whereClause = String.isNotBlank(childFilter) ? ' WHERE ' + childFilter : '';
      String childQuery = '(SELECT ' + String.join(childFields, ', ') + ' FROM ' + childRelName + whereClause + ' ORDER BY CreatedDate DESC LIMIT 1)';
      childQueries.add(childQuery);
    }

    if (!apiNames.contains('Id')) {
      apiNames.add('Id');
    }
    
    if (!apiNames.contains('Name')) {
      apiNames.add('Name');
    }

    String strQueryField = String.join(apiNames, ', ');

    String whereClause = '';

    if (String.isBlank(filterQuery)) {
      filterQuery = '';
    } else {
      whereClause = ' WHERE ';
    }
    
    if (!andFilters.isEmpty()) {
      if (String.isBlank(whereClause)) {
        whereClause = ' WHERE ';
      }
      String andFilterStr = String.join(andFilters, ' AND ');
      if (String.isNotBlank(filterQuery)) {
        filterQuery += ' AND ';
      }
      filterQuery += andFilterStr;
    }

    if (!orFilters.isEmpty()) {
      if (String.isNotBlank(filterQuery)) {
        filterQuery += ' OR (' + String.join(orFilters, ' OR ') + ')';
      } else {
        whereClause = ' WHERE (' + String.join(orFilters, ' OR ') + ')';
      }
    }
    
    String searchQuery = '';
    if (srchFields.size() > 0 && String.isNotBlank(strInput)) {
      searchQuery = '(' + String.join(srchFields, ' OR ') + ')';
      if (String.isBlank(whereClause) && String.isBlank(filterQuery)) {
        whereClause = ' WHERE ';
      } else if (String.isNotBlank(filterQuery)) {
        searchQuery = ' AND ' + searchQuery;
      }
    }

    String orderByQuery = orderByFields.isEmpty() ? 'CreatedDate' : String.join(orderByFields, ', ');

    String limitCount = isSearchBox ? '10' : '1000';

    String strQuery = 'SELECT ' + strQueryField;
    if (!childQueries.isEmpty()) {
      strQuery += ', ' + String.join(childQueries, ', ');
    }

    strQuery += ' FROM ' + String.escapeSingleQuotes(objectName) + whereClause + filterQuery + searchQuery;
    strQuery += ' ORDER BY ' + orderByQuery + ' LIMIT ' + limitCount;

    lookupResult.queryStr = strQuery;

    List<SObject> lstResult = Database.query(strQuery);
    
    Set<Id> childIds = new Set<Id>();
    for (SObject s : lstResult) {
      for (RCustomFieldMeta fld : fieldsList) {
        if (fld.isGrandChild != null && fld.isGrandChild) {
          List<SObject> childRecs = s.getSObjects(fld.childObjName);
          if (childRecs != null && !childRecs.isEmpty()) {
            for (SObject child : childRecs) {
              childIds.add((Id) child.get('Id'));
            }
          }
        }
      }
    }

    Map<Id, SObject> grandChildData = new Map<Id, SObject>();
    if (!childIds.isEmpty()) {
      for (RCustomFieldMeta fld : fieldsList) {
        if (fld.isGrandChild != null && fld.isGrandChild) {
          String childRelName = fld.grandChildObjName;
          if (String.isNotBlank(childRelName)) {
            List<String> grandChildFields = grandChildQueries.get(fld.grandChildObjName);
            String parentField = String.isNotBlank(fld.grandChildParentField) ? fld.grandChildParentField : 'ParentId';
            String filterCondition = String.isNotBlank(fld.grandChildFilter) ? ' AND ' + fld.grandChildFilter : '';
            String grandChildQuery = 'SELECT Id, ' + String.join(grandChildFields, ', ') + ' FROM ' + fld.grandChildObjName + ' WHERE ' + parentField + ' IN :childIds ' + filterCondition + ' ORDER BY CreatedDate DESC LIMIT 1';

            List<SObject> grandChildResults = Database.query(grandChildQuery);
            for (SObject gc : grandChildResults) {
              grandChildData.put((Id) gc.get(parentField), gc);
            }
          }
        }
      }
    }
    
    for (SObject s : lstResult) {
      CustomLookupRecord result = new CustomLookupRecord();
      result.recordId = (String) s.get('Id');

      if (objectName != 'AccountContactRelation' && objectName != 'Case') {
        result.recordName = (String) s.get('Name');
      }

      for (RCustomFieldMeta fld : fieldsList) {
        String fldValue = '';
        try {
          if (fld.isChild != null && fld.isChild) {
            List<SObject> childRecords = s.getSObjects(fld.childObjName);
            if (childRecords != null && !childRecords.isEmpty()) {
              fldValue = (String) childRecords[0].get(fld.childObjFldName);
            }
            if (fld.isGrandChild != null && fld.isGrandChild) {
              if (!grandChildData.isEmpty() && childRecords != null && !childRecords.isEmpty()) {
                Id childId = (Id) childRecords[0].get('Id');
                SObject grandChildRecord = grandChildData.get(childId);
                if (grandChildRecord != null) {
                  fldValue = (String) grandChildRecord.get(fld.grandChildObjFldName);
                }
              }
            }
          } else if (fld.apiName.contains('.')) {
            String[] lookupFieldParts = fld.apiName.split('\\.');
            String parentObjName = lookupFieldParts[0];
            String lookupFieldName = lookupFieldParts[1];
            SObject lookupObj = (SObject) s.getSObject(parentObjName);
            if (lookupObj != null) {
                Object val = lookupObj.get(lookupFieldName);
                if (val != null) {
                  if (val instanceof String) {
                    fldValue = (String) val;
                  } else if (val instanceof Decimal) {
                    fldValue = String.valueOf((Decimal) val);
                  } else if (val instanceof Integer) {
                    fldValue = String.valueOf((Integer) val);
                  } else if (val instanceof Date) {
                    fldValue = String.valueOf((Date) val);
                  } else if (val instanceof DateTime) {
                    fldValue = String.valueOf((DateTime) val);
                  } else if (val instanceof Boolean) {
                    fldValue = String.valueOf((Boolean) val);
                  } else {
                    fldValue = String.valueOf(val);
                  }
                }
            }
          } else {
            Object val = s.get(fld.apiName);
            if (val != null) {
              fldValue = String.valueOf(val);
            }
          }
        } catch (TypeException te) {
          try {
            if (fld.fldType == 'Number') {
              fldValue = String.valueOf((Decimal) s.get(fld.apiName));
            } else if (fld.fldType == 'Date' || fld.fldType == 'DateTime') {
              Object dateVal = s.get(fld.apiName);
              if (dateVal instanceof Date) {
                fldValue = String.valueOf((Date) dateVal);
              } else if (dateVal instanceof DateTime) {
                fldValue = String.valueOf((DateTime) dateVal);
              }
            } else if (fld.fldType == 'Checkbox') {
              Boolean boolValue = (Boolean) s.get(fld.apiName);
              fldValue = (boolValue != null) ? String.valueOf(boolValue) : 'false';
            }
          } catch (Exception e) {
            fldValue = '';
          }
        } catch (Exception e) {
          fldValue = '';
        }

        if (fld.outputFlag && !fld.isFoot) {
          if (result.labelName == '') {
            result.labelName = fldValue;
          }
          FieldValueWrapper fldValueWrapper = new FieldValueWrapper();
          fldValueWrapper.fieldId = fld.name;
          fldValueWrapper.fieldName = fld.label;
          fldValueWrapper.fieldValue = fldValue;
          fldValueWrapper.fieldType = fld.fldType;
          fldValueWrapper.fieldStyle = fld.widthStyle;
          fldValueWrapper.tableDataStyle = fld.tableDataStyle;
          fldValueWrapper.tableHeadStyle = fld.tableHeadStyle;
          fldValueWrapper.fieldApiName = fld.apiName;
          fldValueWrapper.colspan = fld.colspan;
          result.filterFieldValueList.add(fldValueWrapper);
        }
        
        if (fld.resultantFlag != null && fld.resultantFlag) {
          result.addlFldMap.put(fld.apiName, fldValue);
        }

        if (fld.isFoot != null && fld.isFoot && fld.outputFlag) {
          Boolean found = false;
          for (FieldValueWrapper existing : lookupResult.footMap) {
            if (existing.fieldName == fld.label) {
              found = true;
              break;
            }
          }
          if (!found) {
            FieldValueWrapper fldValueWrapper = new FieldValueWrapper();
            fldValueWrapper.fieldId = fld.name;
            fldValueWrapper.fieldName = fld.label;
            fldValueWrapper.fieldValue = fldValue;
            fldValueWrapper.fieldType = fld.fldType;
            fldValueWrapper.fieldStyle = fld.widthStyle;
            fldValueWrapper.tableDataStyle = fld.tableDataStyle;
            fldValueWrapper.tableHeadStyle = fld.tableHeadStyle;
            fldValueWrapper.colspan = fld.colspan;
            fldValueWrapper.fieldApiName = fld.apiName;
            lookupResult.footMap.add(fldValueWrapper);
          }
        }
      }

      lookupResult.records.add(result);
    }

    return lookupResult;
  }
  
  private static String wrapValue(String fieldType, String value) {
    if (fieldType == 'String' && !value.startsWith('\'') && !value.endsWith('\'')) {
      return '\'' + String.escapeSingleQuotes(value) + '\'';
    }
    return value;
  }
  
  public class CustomLookupResult {
    @AuraEnabled
    public List<CustomLookupRecord> records;

    @AuraEnabled
    public String queryStr;

    @AuraEnabled
    public List<FieldValueWrapper> footMap;

    public CustomLookupResult() {
      this.records = new List<CustomLookupRecord>();
      this.footMap = new List<FieldValueWrapper>();
    }
  }

  public class CustomLookupRecord {
    @AuraEnabled
    public String recordId;

    @AuraEnabled
    public String recordName;

    @AuraEnabled
    public String labelName;

    @AuraEnabled
    public Map<String, Object> addlFldMap;

    @AuraEnabled
    public Map<String, Object> footMap;

    @AuraEnabled
    public List<FieldValueWrapper> filterFieldValueList;

    @AuraEnabled
    public Map<String, List<SObject>> childRecordsMap;

    public CustomLookupRecord() {
      this.labelName = '';
      this.filterFieldValueList = new List<FieldValueWrapper>();
      this.addlFldMap = new Map<String, Object>();
      this.footMap = new Map<String, Object>();
      this.childRecordsMap = new Map<String, List<SObject>>();
    }
  }

  public class SObjectQueryResult {
    @AuraEnabled
    public String recordId;

    @AuraEnabled
    public String recordName;

    @AuraEnabled
    public String labelName;

    @AuraEnabled
    public Map<String, Object> addlFldMap;

    @AuraEnabled
    public List<FieldValueWrapper> filterFieldValueList;

    @AuraEnabled
    public Map<String, Object> footMap;

    @AuraEnabled
    public Date recordPersonBirthdate;
  }

  public class FieldValueWrapper {
    @AuraEnabled
    public String fieldId;

    @AuraEnabled
    public String fieldName;

    @AuraEnabled
    public String fieldValue;

    @AuraEnabled
    public Boolean isFoot;

    @AuraEnabled
    public String fieldType;

    @AuraEnabled
    public String fieldStyle;
    
    @AuraEnabled
    public String tableDataStyle;

    @AuraEnabled
    public String tableHeadStyle;

    @AuraEnabled
    public Integer colspan;

    @AuraEnabled
    public String fieldApiName;
  }
  
  @AuraEnabled(cacheable=true)
  public static List<sObject> searchRecords(String searchKey, String objectApiName, String searchField) {
    Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
    Schema.SObjectType sot = gd.get(objectApiName);
    if (sot == null) {
      throw new AuraHandledException('Invalid object name: ' + objectApiName);
    }

    Map<String, Schema.SObjectField> fieldMap = sot.getDescribe().fields.getMap();
    if (!fieldMap.containsKey(searchField.toLowerCase())) {
      throw new AuraHandledException('Invalid field name: ' + searchField);
    }

    String query = 'SELECT Id, ' + String.escapeSingleQuotes(searchField) + ' FROM ' + String.escapeSingleQuotes(objectApiName) + ' WHERE ' + String.escapeSingleQuotes(searchField) + ' LIKE \'%' + String.escapeSingleQuotes(searchKey) + '%\' LIMIT 10';
    return Database.query(query);
  }

  @AuraEnabled(cacheable=true)
  public static String getqbId(Id formId) {
    List<SObject> forms = Database.query('SELECT Question_Book__c FROM Form__c WHERE Id = :formId WITH SECURITY_ENFORCED LIMIT 1');
    if (!forms.isEmpty()) {
      return (String) forms[0].get('Question_Book__c');
    }
    return null;
  }
}