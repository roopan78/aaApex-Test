global with sharing class Utility {
  public static Integer minQuestions = 0;
  public static Integer maxQuestions = 0;
  public static List<List<String>> possibilities = new List<List<String>>();

  @AuraEnabled
  public static void updatePossibilities(string qId) {
    List<String> qList = new List<String>();

    Question_Book__c qb = [
      SELECT Id, First_Question__c, Possibilities__c
      FROM Question_Book__c
      WHERE id = :qId
      WITH SECURITY_ENFORCED
    ];

    Utility.possibleQuestions(qb.First_Question__c, qList);
    // Format the structure
    PossibilityWrapper outputWrap = new PossibilityWrapper();
    outputWrap.minQuestions = Utility.minQuestions;
    outputWrap.maxQuestions = Utility.maxQuestions;
    outputWrap.total = Utility.possibilities.size();

    // Traverse the path
    for (List<String> qpList : Utility.possibilities) {
      PossibilityWrapper.PathWrapper path = new PossibilityWrapper.PathWrapper();
      path.count = qpList.size();
      path.questions = qpList;
      outputWrap.paths.add(path);
    }

    qb.Possibilities__c = JSON.serialize(outputWrap);
    if (
      Question_Book__c.SObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isUpdateable()
    ) {
      update qb;
    }
  }

  // Function to return list of questions
  public static List<String> possibleQuestions(
    String qId,
    List<String> parentQuestions
  ) {
    List<String> qList = new List<String>();
    qList.addAll(parentQuestions);

    // Read the Next Question from Question and Options
    Question__c q = [
      SELECT
        Id,
        Name,
        Next_Question__c,
        (SELECT Id, Next_Question__c FROM Question_Options__r)
      FROM Question__c
      WHERE Id = :qId
      WITH SECURITY_ENFORCED
    ];
    qList.add(q.Name);
    // System.debug('Inside PossibleQuestions for ' + q.Name + '. NxtQ: ' + q.Next_Question__c + ', Options ' + q.Next_Question__r.size());

    if (q.Next_Question__c != null) {
      // Have value in Next Question
      // System.debug('Calling Next Question Recursion');
      possibleQuestions(q.Next_Question__c, qList);
    } else if (q.Question_Options__r.size() > 0) {
      // System.debug('Calling Option Next Question Recursion ' + q.Question_Options__r.size());
      for (Option__c opt : q.Question_Options__r) {
        possibleQuestions(opt.Next_Question__c, qList);
      }
    } else {
      // No Next Question and Options - Last Question
      // System.debug('Stopping Recursion');

      System.debug('Path Possibility ' + qList.toString());

      // Store the min
      if (minQuestions == 0 || qList.size() < minQuestions) {
        minQuestions = qList.size();
      }

      // Store the max
      if (maxQuestions == 0 || qList.size() > maxQuestions) {
        maxQuestions = qList.size();
      }

      // Store the possibilities
      possibilities.add(qList);
    }

    /*
        if(qList.size() > 0) {
            System.debug('Total Next Questions found for ' + q.Name + ' is ' + qList.size());
        }
        */
    //

    return qList;
  }

  // VD 05Mar24 Updated the funtion
  // Uses replaceAll('(?i)rnxt__', '') → Removes rnxt__ case-insensitively.
  // Ensures first letter stays intact (childObjName stays correct)
  @AuraEnabled
  public static String jsName(String apiName) {
    if (String.isBlank(apiName)) {
      return '';
    }
    // Remove namespace and '__c' suffix
    // VD 30jun25 - handle api name with no namespace
    String cleanApiName = apiName.replaceAll('(?i)^rnxt__', '')
      .replace('__c', '');

    List<String> parts = cleanApiName.split('_');
    if (parts.size() == 1) {
      //return parts[0];
      String first = parts[0];
      if (
        first.length() > 0 &&
        !first.substring(0, 1).equals(first.substring(0, 1).toLowerCase())
      ) {
        // Lowercase only the first letter, keep rest as-is
        System.debug('inside caps --> ' + first);
        return first.substring(0, 1).toLowerCase() + first.substring(1);
      } else {
        System.debug('outside caps --> ' + first);
        return first;
      }
    }

    // Ensure the first character is not incorrectly removed (e.g., 'childObjName' should stay intact)
    Integer wi = 0;
    String jsName = '';

    for (String x : cleanApiName.split('_')) {
      if (wi == 0) {
        jsName = x.toLowerCase(); // First word remains lowercase
      } else {
        jsName += x.capitalize(); // Convert remaining words to camelCase
      }
      wi++;
    }

    return jsName;
  }

    // RT 08SEP25 - CRUD Validation for Object
    // RT 15SEP25 - Added printMode to check for read-only fields
    // RT 16SEP25 - Updated to handle relationship fields (e.g., Invoice__r.Quantity__c)
    // RT 05MAR26 - Robust handling of check accessibility
    @AuraEnabled(cacheable=true)
    public static List<String> checkAccessibility(String objectApiName, List<String> fieldList, Boolean printMode) {
        List<String> accessibleFields = new List<String>();
        Boolean isPrintMode = (printMode == true);

        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
        if (objType == null || fieldList == null || fieldList.isEmpty()) {
            return accessibleFields;
        }

        Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();

        for (String fieldName : fieldList) {
            if (String.isBlank(fieldName)) {
                continue;
            }
            // Check if this is a relationship field (contains __r.)
            if (fieldName.contains('__r.')) {
                if (checkRelationshipFieldAccess(objectApiName, fieldName, isPrintMode)) {
                    accessibleFields.add(fieldName);
                }
            } else {
                // Original logic for direct fields
                if (fieldsMap.containsKey(fieldName)) {
                    Schema.DescribeFieldResult f = fieldsMap.get(fieldName).getDescribe();

                    if (fieldName == 'Name'){
                        accessibleFields.add(fieldName);
                    } else if (f.isAccessible() && f.isCreateable() && f.isUpdateable()) {
                        accessibleFields.add(fieldName);
                    } else if (isPrintMode && f.isAccessible()) {
                        accessibleFields.add(fieldName);
                    } else if (f.isCalculated() && f.isAccessible()) {
                        accessibleFields.add(fieldName);
                    }
                }
            }
        }
        return accessibleFields;
    }

    // RT 16SEP25 - Helper method to check relationship field accessibility
    private static Boolean checkRelationshipFieldAccess(String objectApiName, String relationshipFieldName, Boolean printMode) {
        try {
            // Split the relationship field (e.g., "Invoice__r.Quantity__c" -> ["Invoice__r", "Quantity__c"])
            String[] parts = relationshipFieldName.split('\\.');
            if (parts.size() != 2) {
                return false;
            }
            
            String relationshipName = parts[0]; // Invoice__r
            String targetFieldName = parts[1];  // Quantity__c
            
            // Get the source object's field map
            Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
            Map<String, Schema.SObjectField> fieldsMap = objType.getDescribe().fields.getMap();
            
            // Convert relationship name to field name (Invoice__r -> Invoice__c)
            String relationshipFieldApiName = relationshipName.replace('__r', '__c');
            
            // Check if the relationship field exists and is accessible
            if (!fieldsMap.containsKey(relationshipFieldApiName)) {
                return false;
            }
            
            Schema.DescribeFieldResult relationshipField = fieldsMap.get(relationshipFieldApiName).getDescribe();
            if (!relationshipField.isAccessible()) {
                return false;
            }
            
            // Get the target object type from the relationship
            List<Schema.sObjectType> referenceTo = relationshipField.getReferenceTo();
            if (referenceTo.isEmpty()) {
                return false;
            }
            
            Schema.SObjectType targetObjectType = referenceTo[0];
            Map<String, Schema.SObjectField> targetFieldsMap = targetObjectType.getDescribe().fields.getMap();
            
            // Check if the target field exists and is accessible
            if (!targetFieldsMap.containsKey(targetFieldName)) {
                return false;
            }
            
            Schema.DescribeFieldResult targetField = targetFieldsMap.get(targetFieldName).getDescribe();
            
            // Apply the same accessibility logic as the main method
            if (targetFieldName == 'Name') {
                return true;
            } else if (targetField.isAccessible() && targetField.isCreateable() && targetField.isUpdateable()) {
                return true;
            } else if (printMode && targetField.isAccessible()) {
                return true;
            } else if (targetField.isCalculated() && targetField.isAccessible()) {
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            System.debug('Error checking relationship field access: ' + e.getMessage());
            return false;
        }
    }


  // VD 13May25 Salesforce ID validation
  @AuraEnabled
  public static Boolean isSalesforceId(String extId) {
    try {
      Id sfid = Id.valueOf(extId);
      return true;
    } catch (Exception e) {
      return false;
    }
  }
  
 
 
  // VD 12Jun25 handle table type JSON from attachment
  @AuraEnabled(cacheable=true)
  public static Map<String, String> getFieldMetaJson(Id questionId) {
    Map<String, String> resultMap = new Map<String, String>();
    List<Attachment> atts = [
      SELECT Name, Body
      FROM Attachment
      WHERE ParentId = :questionId
      LIMIT 5
    ];
    if (atts.isEmpty()) {
      throw new AuraHandledException(
        'No table data found for this question. Please contact the admin.'
      );
    }
    for (Attachment att : atts) {
      resultMap.put(att.Name, EncodingUtil.base64Encode(att.Body));
    }
    return resultMap;
  }

  // RT 16JUN25 - Namespace handling
  // RT 27JUN25 - Return restructured
  @AuraEnabled(cacheable=true)
  public static String nameSpace() {
    try {
      String namespace = [
        SELECT NamespacePrefix
        FROM ApexClass
        WHERE Name = 'InputWrapper'
        LIMIT 1
      ]
      .NamespacePrefix;
      String ns = String.isBlank(namespace) ? '' : namespace + '__';
      return ns;
    } catch (Exception ex) {
      System.debug('Exception in Namespace: ' + ex.getMessage());
      return null;
    }
  }

    @AuraEnabled(cacheable=true)
    public static List<PicklistOption> getOwners(String ownerType) {
        List<PicklistOption> results = new List<PicklistOption>();

        if (ownerType == 'User') {
            for (User u : [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 200]) {
                results.add(new PicklistOption(u.Name, u.Name));
            }
        } else if (ownerType == 'Role') {
            for (UserRole r : [SELECT Id, Name FROM UserRole LIMIT 200]) {
                results.add(new PicklistOption(r.Name, r.Name));
            }
        } else if (ownerType == 'Group') {
            for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Regular' LIMIT 200]) {
                results.add(new PicklistOption(g.Name, g.Name));
            }
        } else if (ownerType == 'Queue') {
            for (Group g : [SELECT Id, Name FROM Group WHERE Type = 'Queue' LIMIT 200]) {
                results.add(new PicklistOption(g.Name, g.Name));
            }
        }

        return results;
    }

    public class PicklistOption {
        @AuraEnabled public String value;
        @AuraEnabled public String label;

        public PicklistOption(String v, String l) {
            value = v;
            label = l;
        }
    }
}