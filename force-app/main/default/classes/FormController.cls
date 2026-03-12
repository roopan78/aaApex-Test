public with sharing class FormController {
  public class CreateRecordResult {
    @AuraEnabled
    public Form__c form;
    @AuraEnabled
    public Question_Book__c simpleQuestionBook;
    // MR 16MAY25 QB Builder Changes
    @AuraEnabled
    public String editor;
  }

  // MR 16MAY25 QB Builder Changes - Modified the method to return PLEWrapper instead of String
  @AuraEnabled(cacheable=true)
  public static List<PLEWrapper> getPicklistValues() {
    List<PLEWrapper> picklistOptions = new List<PLEWrapper>();
    Schema.DescribeFieldResult fieldResult = Form__c.Type__c.getDescribe();
    List<Schema.PicklistEntry> picklistValues = fieldResult.getPicklistValues();

    for (Schema.PicklistEntry entry : picklistValues) {
      picklistOptions.add(new PLEWrapper(entry.getLabel(), entry.getValue()));
    }
    return picklistOptions;
  }

  // Wrapper class to send Type Options to LWC
  // public class PLEWrapper {
  //     @AuraEnabled
  //     public String l;
  //     @AuraEnabled
  //     public String v;

  //     public PLEWrapper(String l, String v) {
  //         this.l = l;
  //         this.v = v;
  //     }
  // }

  @AuraEnabled
  public static CreateRecordResult createFormWithQuestionBook(
    String formName,
    String formType,
    Boolean submit,
    Boolean cancel,
    String anchorObj
  ) {
    CreateRecordResult result = new CreateRecordResult();
    try {
      // Create Form record
      String ns = Utility.nameSpace(); // RT 04FEB26 - Get namespace for dynamic component referencing
      Form__c newForm = new Form__c();
      newForm.Name = formName;
      newForm.Type__c = formType;
      if (anchorObj != null) {
        newForm.Anchor_Object__c = anchorObj;
      }
      // VD 05Jun25 Version Control changes
      Question_Book__c qb = new Question_Book__c();
      // MR 16MAY25 QB Builder Changes
      // VD 22Jul25 SPA handling changes
      if (formType == 'QuestionBook' || formType == 'SPA') {
        // Create QB first and use it in the Form
        qb.Title__c = formType + ' ' + formName;
        qb.Order__c = 1;
        qb.Version__c = 1;
        qb.Category__c = 'Simple';
        qb.Anchor_Object__c = anchorObj; // RT 12JUN25 - Anchor Object for QB

        insert qb;
        // VD 22Jul25 SPA handling changes
        if (formType == 'QuestionBook') {
          result.editor = ns + 'QB_Builder';
        } else {
          result.editor = ns + 'SPA_Builder';
        }
        result.simpleQuestionBook = qb;
        newForm.Question_Book__c = qb.Id;
      }

      insert newForm;
      // VD 05Jun25 Version Control changes
      // After insert, update QB with the form Id
      if (formType == 'QuestionBook' || formType == 'SPA') {
        qb.Form__c = newForm.Id;
        update qb;
      }

      if (formType == 'Form') {
        result.editor = ns + 'Form_Builder';
        // Create primary Question Book record with Booklet category
        // VD 28Mar25 order handling
        Question_Book__c bookletQB = new Question_Book__c(
          Title__c = 'New Page',
          Form__c = newForm.Id,
          Order__c = 1,
          Category__c = 'Booklet'
        );
        insert bookletQB;
        // VD 24jun25 update the Book on the form
        newForm.Question_Book__c = bookletQB.Id;
        update newForm;

        // Create secondary Question Book record with Simple category
        // VD 28Mar25 page order handling
        Question_Book__c simpleQB = new Question_Book__c(
          Title__c = 'New Section',
          // Form__c = newForm.Id,
          Order__c = 1,
          Category__c = 'Simple',
          Parent_Booklet_QB__c = bookletQB.Id
        );
        insert simpleQB;

        Question__c section = new Question__c(
          RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
            .get('UNCONDITIONAL')
            .getRecordTypeId(),
          Question_Book__c = simpleQB.Id,
          Type__c = 'Book',
          Question_No__c = 1,
          Question_Text__c = 'New Section' // RT 28MAR25 - Pre-entered Heading when creating a new form
        );
        insert section;
      }

      if (submit == true) {
        Actions__c action = new Actions__c(
          Name = 'Submit',
          Event_to_Emit__c = 'submit',
          Form__c = newForm.Id,
          IsActive__c = true
        );
        insert action;
      }

      if (cancel == true) {
        Actions__c action1 = new Actions__c(
          Name = 'Cancel',
          Event_to_Emit__c = 'cancel',
          Form__c = newForm.Id,
          IsActive__c = true
        );
        insert action1;
      }

      result.form = newForm;
      return result;
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error creating records: ' + e.getMessage()
      );
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<FormWrapper> getForms() {
    try {
      List<FormWrapper> forms = new List<FormWrapper>();
      String ns = Utility.nameSpace();
      for (Form__c form : [
        SELECT Id, Name, Type__c, Anchor_Object__c, Question_Book__c
        FROM Form__c
        WITH SECURITY_ENFORCED
        ORDER BY CreatedDate DESC
      ]) {
        forms.add(new FormWrapper(form, ns));
      }
      return forms;
    } catch (Exception e) {
      throw new AuraHandledException('Error fetching forms: ' + e.getMessage());
    }
  }

  // Wrapper class to send form data to LWC
  public class FormWrapper {
    @AuraEnabled
    public String id;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String type;
    @AuraEnabled
    public String anchorObj; // MR 16MAY25 QB Editor
    @AuraEnabled
    public String editor; // MR 16MAY25 QB Editor
    @AuraEnabled
    public String qbId; // MR 16MAY25 QB Editor

    public FormWrapper(Form__c form, String namespace) {
      this.id = form.Id;
      this.name = form.Name;
      this.type = form.Type__c;
      this.editor = namespace + 'Form_Builder';

      // MR 16MAY25 QB Editor
      this.anchorObj = form.Anchor_Object__c;
      if (form.Question_Book__c != null) {
        this.qbId = form.Question_Book__c;
      }
      if (form.Type__c == 'QuestionBook') {
        this.editor = nameSpace + 'QB_Builder';
      } else if (form.Type__c == 'SPA') {
        // // VD 22Jul25 SPA handling changes
        this.editor = nameSpace +  'SPA_Builder';
      }
    }
  }
  // VD 29may25 objects api name with search by name
  @AuraEnabled(cacheable=true)
  public static List<ObjectOption> getObjectsByName(String searchKey) {
    List<ObjectOption> objectOptions = new List<ObjectOption>();

    Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
    Integer count = 0;
    for (String objectApiName : globalDescribe.keySet()) {
      if (count >= 10)
        break;
      Schema.SObjectType objType = globalDescribe.get(objectApiName);
      DescribeSObjectResult describe = objType.getDescribe();

      if (isRelevantObject(describe)) {
        if (
          String.isBlank(searchKey) ||
          objectApiName.toLowerCase().contains(searchKey.toLowerCase())
        ) {
          objectOptions.add(
            new ObjectOption(describe.getLabel(), describe.getName())
          );
          count++;
        }
      }
    }
    return objectOptions;
  }

  // VD 29may25 removed older method which is unused

  // Inner class for returning Object data (Object Option)
  public class ObjectOption {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String apiName;

    public ObjectOption(String label, String apiName) {
      this.label = label;
      this.apiName = apiName;
    }
  }

  // Inner class for returning Field data (Field Option)
  public class FieldOption {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String apiName;
    @AuraEnabled
    public Boolean isReference;
    @AuraEnabled
    public String relatedObjectName;
    @AuraEnabled
    public String fieldType; // RT 24OCT25 - Added field type

    public FieldOption(String label, String apiName, Boolean isReference, String relatedObjectName, String fieldType) {
      this.label = label;
      this.apiName = apiName;
      this.isReference = isReference;
      this.relatedObjectName = relatedObjectName;
      this.fieldType = fieldType; 
    }
  }

  // Helper method to dynamically filter out unwanted objects
  private static Boolean isRelevantObject(
    Schema.DescribeSObjectResult describeResult
  ) {
    // Exclude system or platform objects based on naming patterns
    String objectName = describeResult.getName();
    // system.debug(objectName);
    // Check if the object is a standard Salesforce platform object or UI-invisible
    // !describeResult.isCustom() ||
    if (!describeResult.isQueryable() || !describeResult.isUpdateable()) {
      return false;
    }

    // Exclude objects based on naming patterns (e.g., those related to processes, feeds, attachments, etc.)
    if (
      objectName.startsWith('Process') ||
      objectName.startsWith('Flow') ||
      objectName.startsWith('Feed') ||
      objectName.startsWith('Attachment') ||
      objectName.startsWith('Content') ||
      objectName.startsWith('Activity') ||
      objectName.startsWith('Task') ||
      objectName.startsWith('Event') ||
      objectName.startsWith('Agent')
    ) {
      return false;
    }
    return true; // Include object if it meets all conditions
  }
  // Fetch fields for the selected object
  // RT 24JUN25 - Updated method to include Lookup and Master-Detail fields
  // RT 21AUG25 - Updated method to show Api Name
  // RT 24OCT25 - Added field type
  @AuraEnabled(cacheable=true)
  public static List<FieldOption> getFieldsForObject(String objectApiName) {
    List<FieldOption> fieldOptions = new List<FieldOption>();
    if (String.isNotBlank(objectApiName)) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe()
            .get(objectApiName)
            .getDescribe()
            .fields.getMap();

        for (String fieldName : fields.keySet()) {
            DescribeFieldResult describeField = fields.get(fieldName).getDescribe();

            if (shouldIncludeField(describeField)) {
                Boolean isRef = describeField.getType() == Schema.DisplayType.REFERENCE;
                String relatedObj = null;
                
                if (isRef && describeField.getReferenceTo() != null && !describeField.getReferenceTo().isEmpty()) {
                    // Get the first related object (usually there's only one)
                    relatedObj = describeField.getReferenceTo()[0].getDescribe().getName();
                }

                String fieldType = String.valueOf(describeField.getType());

                fieldOptions.add(
                    new FieldOption(
                        describeField.getLabel() + ' - ' + describeField.getName(), 
                        describeField.getName(),
                        isRef,
                        relatedObj,
                        fieldType
                    )
                );
            }
        }

        fieldOptions.sort(new FieldOptionComparator());
    }
    return fieldOptions;
  }

  private static Boolean shouldIncludeField(DescribeFieldResult fieldDescribe) {
    // Always exclude non-accessible fields
    if (!fieldDescribe.isAccessible()) {
      return false;
    }

    // Get field type
    Schema.DisplayType fieldType = fieldDescribe.getType();
    String fieldName = fieldDescribe.getName();

    // RT 27JUN25 - Always include Name field
    if (fieldName.equalsIgnoreCase('Name')) {
      return true;
    }

    // Include reference fields (Lookup and Master-Detail)
    if (fieldType == Schema.DisplayType.REFERENCE) {
      // // Exclude common system reference fields that are not useful for forms
      // if (
      //   fieldName.equalsIgnoreCase('OwnerId') ||
      //   fieldName.equalsIgnoreCase('CreatedById') ||
      //   fieldName.equalsIgnoreCase('LastModifiedById') ||
      //   fieldName.equalsIgnoreCase('RecordTypeId')
      // ) {
      //   return false;
      // }
      return true; // Include all other reference fields
    }

    // For non-reference fields, check if they're updateable
    // VD 15jul25 - formula field should also be included
    if (!fieldDescribe.isUpdateable() && !fieldDescribe.isCalculated()) {
      return false;
    }

    // Exclude system audit fields
    if (
      fieldName.equalsIgnoreCase('Id') ||
      fieldName.equalsIgnoreCase('CreatedDate') ||
      fieldName.equalsIgnoreCase('LastModifiedDate') ||
      fieldName.equalsIgnoreCase('SystemModstamp') ||
      fieldName.equalsIgnoreCase('IsDeleted')
    ) {
      return false;
    }

    return true;
  }

  // Comparator class for sorting FieldOptions
  private class FieldOptionComparator implements Comparator<FieldOption> {
    public Integer compare(FieldOption a, FieldOption b) {
      return a.label.compareTo(b.label);
    }
  }

  // RT 22JAN26 - Get picklist values for a specific field on an object
  @AuraEnabled(cacheable=true)
  public static List<PLEWrapper> getPicklistValuesForField(String objectApiName, String fieldApiName) {
    List<PLEWrapper> picklistOptions = new List<PLEWrapper>();

    if (String.isBlank(objectApiName) || String.isBlank(fieldApiName)) {
      return picklistOptions;
    }

    try {
      Schema.SObjectType objType = Schema.getGlobalDescribe().get(objectApiName);
      if (objType == null) {
        return picklistOptions;
      }

      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
      Map<String, Schema.SObjectField> fieldMap = objDescribe.fields.getMap();

      Schema.SObjectField field = fieldMap.get(fieldApiName);
      if (field == null) {
        return picklistOptions;
      }

      Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
      Schema.DisplayType fieldType = fieldDescribe.getType();

      // Only process picklist and multipicklist fields
      if (fieldType == Schema.DisplayType.PICKLIST || fieldType == Schema.DisplayType.MULTIPICKLIST) {
        List<Schema.PicklistEntry> picklistEntries = fieldDescribe.getPicklistValues();

        for (Schema.PicklistEntry entry : picklistEntries) {
          if (entry.isActive()) {
            picklistOptions.add(new PLEWrapper(entry.getLabel(), entry.getValue()));
          }
        }
      }
    } catch (Exception e) {
      System.debug('Error fetching picklist values: ' + e.getMessage());
    }

    return picklistOptions;
  }

  @AuraEnabled(cacheable=true)
  public static List<ObjectOption> getRelatedObjectOptions(
    String objectApiName
  ) {
    // System.debug(objectApiName);
    List<ObjectOption> relatedObjectOptions = new List<ObjectOption>();
    Set<String> addedObjects = new Set<String>(); // Track added objects to prevent duplicates

    try {
      // Get the describe information for the given object
      Schema.SObjectType objType = Schema.getGlobalDescribe()
        .get(objectApiName);
      Schema.DescribeSObjectResult objDescribe = objType.getDescribe();

      // Add the parent object itself as the first option
      if (
        isRelevantObject(objDescribe) && !addedObjects.contains(objectApiName)
      ) {
        ObjectOption parentOption = new ObjectOption(
          objDescribe.getLabel(),
          objectApiName
        );
        relatedObjectOptions.add(parentOption);
        addedObjects.add(objectApiName);
      }

      // Get all child relationships of the object
      for (
        Schema.ChildRelationship childRel : objDescribe.getChildRelationships()
      ) {
        Schema.DescribeSObjectResult childDescribe = childRel.getChildSObject()
          .getDescribe();
        String childObjectName = childDescribe.getName();

        // Skip if we've already added this object
        if (addedObjects.contains(childObjectName)) {
          continue;
        }

        // Dynamically filter objects
        if (isRelevantObject(childDescribe)) {
          ObjectOption option = new ObjectOption(
            childDescribe.getLabel(),
            childObjectName
          );
          relatedObjectOptions.add(option);
          addedObjects.add(childObjectName); // Mark this object as added
        }
      }
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage());
    }
    System.debug(relatedObjectOptions);
    return relatedObjectOptions;
  }

  @AuraEnabled
  public static String retrieveAndMergeJsonFromAttachments(String jsonString) {
      try {
          // Parse the incoming JSON string
          Map<String, Object> jsonMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
          Map<String, Object> questionbook = (Map<String, Object>) jsonMap.get('questionbook');
          
          if (questionbook == null || !questionbook.containsKey('subQuestions')) {
              return jsonString; // Return original if no subQuestions found
          }
          
          List<Object> subQuestions = (List<Object>) questionbook.get('subQuestions');
          if (subQuestions == null || subQuestions.isEmpty()) {
              return jsonString; // Return original if no subQuestions
          }
          
          // Collect question IDs that have type = 'Table'
          Set<Id> tableQuestionIds = new Set<Id>();
          Map<Id, Integer> questionIndexMap = new Map<Id, Integer>();
          
          for (Integer i = 0; i < subQuestions.size(); i++) {
              Map<String, Object> subQuestion = (Map<String, Object>) subQuestions[i];
              
              // Check if type is 'Table'
              if (subQuestion.containsKey('type') && 
                  'Table'.equals(subQuestion.get('type')) &&
                  subQuestion.containsKey('id') && 
                  subQuestion.get('id') != null) {
                  
                  String idStr = String.valueOf(subQuestion.get('id'));
                  if (idStr.length() == 18 || idStr.length() == 15) {
                      Id questionId = (Id) subQuestion.get('id');
                      tableQuestionIds.add(questionId);
                      questionIndexMap.put(questionId, i);
                  }
              }
          }
          
          // If no Table type questions found, return original JSON
          if (tableQuestionIds.isEmpty()) {
              return jsonString;
          }
          
          // Query for all attachments related to these Table questions
          // Look for both qbReferenceQuestions and fieldsMeta patterns
          List<Attachment> attachments = [
              SELECT Id, Name, ParentId, Body
              FROM Attachment
              WHERE ParentId IN :tableQuestionIds 
              AND (Name LIKE '%Reference_Questions_%' OR Name LIKE '%FieldsMeta_%')
              AND Name LIKE '%.json'
          ];
          
          // Group attachments by ParentId for easier processing
          Map<Id, List<Attachment>> attachmentsByParent = new Map<Id, List<Attachment>>();
          for (Attachment att : attachments) {
              if (!attachmentsByParent.containsKey(att.ParentId)) {
                  attachmentsByParent.put(att.ParentId, new List<Attachment>());
              }
              attachmentsByParent.get(att.ParentId).add(att);
          }
          
          // Process each Table type question
          for (Id questionId : tableQuestionIds) {
              Integer questionIndex = questionIndexMap.get(questionId);
              Map<String, Object> subQuestion = (Map<String, Object>) subQuestions[questionIndex];
              
              if (attachmentsByParent.containsKey(questionId)) {
                  for (Attachment att : attachmentsByParent.get(questionId)) {
                      try {
                          String jsonContent = att.Body.toString();
                          Object retrievedJsonData = JSON.deserializeUntyped(jsonContent);
                          
                          // Determine field to update based on attachment name
                          if (att.Name.contains('Reference_Questions_')) {
                              // Replace the blob reference with actual JSON data
                              subQuestion.put('qbReferenceQuestions', retrievedJsonData);
                          } else if (att.Name.contains('FieldsMeta_')) {
                              // Replace the blob reference with actual JSON data
                              subQuestion.put('fieldsMeta', retrievedJsonData);
                          }
                          
                      } catch (Exception e) {
                          System.debug('Error parsing JSON for attachment ' + att.Name + ': ' + e.getMessage());
                          // Continue processing other attachments
                      }
                  }
                  
                  // Update the subQuestion in the list
                  subQuestions[questionIndex] = subQuestion;
              }
          }
          
          // Update the subQuestions in questionbook
          questionbook.put('subQuestions', subQuestions);
          
          // Update the questionbook in the main JSON
          jsonMap.put('questionbook', questionbook);
          
          // Return the updated JSON as string
          return JSON.serialize(jsonMap);
          
      } catch (Exception e) {
          System.debug('Error in retrieveAndMergeJsonFromAttachments: ' + e.getMessage());
          throw new AuraHandledException('Error processing JSON data: ' + e.getMessage());
      }
  }
}