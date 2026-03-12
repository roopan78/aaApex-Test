/** Date            version       Author                Modifiedby                      Description
                    1.0
    28-Mar-2025     1.1                                 Mohamed Abdul Kadher             In previous version code logic support single record. so now it code logic was changed to handle bulkified logic.
 
 */
public with sharing class QuestionService {
  // MR 23NOV23 Function to update Field Meta to Fields_Meta__c on Question
  // RT 17JUN25 - Namespace Handling

  public static void updateFieldMeta(Set<Id> qIds) {
    if (qIds == null || qIds.isEmpty()) {
      return;
    }

    // **Bulk Query to get Field Meta Records**
    String selectedObject = Field_Meta__c.sObjectType.getDescribe().getName();
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType objectSchema = schemaMap.get(selectedObject);
    Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe()
      .fields.getMap();

    Map<String, String> fieldNameTypeMap = new Map<String, String>();
    Map<String, String> fieldApiJsonNameMap = new Map<String, String>();

    for (String fieldName : fieldMap.keySet()) {
      fieldApiJsonNameMap.put(fieldName, Utility.jsName(fieldName));
      fieldNameTypeMap.put(
        fieldName,
        '' + fieldMap.get(fieldName).getDescribe().getType()
      );
    }

    // **Bulk Query to Fetch Records**
    List<Question__c> questionsToUpdate = new List<Question__c>();
    // VD 12Jun25 handle JSON from attachment
    Map<Id, String> attachmentsToUpsert = new Map<Id, String>(); // Map<QuestionId, jsonString>

    Map<Id, Question__c> quesMap = new Map<Id, Question__c>(
      [
        SELECT Id, Type__c, Is_ReadJSONFromAttachment__c
        FROM Question__c
        WHERE Id IN :qIds
      ]
    );
    String queryStr =
      'SELECT ' +
      String.join(fieldNameTypeMap.keySet(), ', ') +
      ' FROM ' +
      selectedObject +
      ' WHERE Question__c IN :qIds' +
      ' ORDER BY order__c';

    // **Bulk Query Execution**
    List<Field_Meta__c> allFieldMetaRecords = Database.query(queryStr);

    // VD 24Apr25 changes Collect all referenced question IDs
    Set<Id> referencedQuestionIds = new Set<Id>();
    for (Field_Meta__c fm : allFieldMetaRecords) {
      if (fm.question_reference__c != null) {
        referencedQuestionIds.add(fm.question_reference__c);
      }
    }
    Map<Id, String> referencedJSONMap = getReferenceQuestion(
      referencedQuestionIds
    );
    String namespace = Utility.nameSpace();
    String referenceName = namespace + 'question_reference__c';

    Map<Id, List<Field_Meta__c>> fieldMetaRecordsMap = new Map<Id, List<Field_Meta__c>>();
    for (Field_Meta__c fm : allFieldMetaRecords) {
      if (!fieldMetaRecordsMap.containsKey(fm.Question__c)) {
        fieldMetaRecordsMap.put(fm.Question__c, new List<Field_Meta__c>());
      }
      fieldMetaRecordsMap.get(fm.Question__c).add(fm);
    }
    for (Id qId : qIds) {
      if (!fieldMetaRecordsMap.containsKey(qId))
        continue;
      QuestionHandler qh = new QuestionHandler();
      JSONGenerator jsonGen = JSON.createGenerator(true);
      jsonGen.writeStartArray();

      for (Field_Meta__c fm : fieldMetaRecordsMap.get(qId)) {
        jsonGen.writeStartObject();
        for (String field : fieldNameTypeMap.keySet()) {
          if (fm.get(field) != null) {
            switch on fieldNameTypeMap.get(field) {
              when 'BOOLEAN' {
                jsonGen.writeBooleanField(
                  fieldApiJsonNameMap.get(field),
                  (Boolean) fm.get(field)
                );
              }
              when 'STRING' {
                jsonGen.writeStringField(
                  fieldApiJsonNameMap.get(field),
                  (String) fm.get(field)
                );
              }
              when 'ID' {
                jsonGen.writeStringField(
                  fieldApiJsonNameMap.get(field),
                  (Id) fm.get(field)
                );
              }
              when 'PICKLIST' {
                jsonGen.writeStringField(
                  fieldApiJsonNameMap.get(field),
                  (String) fm.get(field)
                );
              }
              when 'MULTIPICKLIST' {
                String multiPicklistValue = (String) fm.get(field);
                multiPicklistValue = multiPicklistValue
                  ?.replaceAll('\\s*;\\s*', ',');
                jsonGen.writeStringField(
                  fieldApiJsonNameMap.get(field),
                  multiPicklistValue
                );
              }
              when 'DOUBLE' {
                jsonGen.writeNumberField(
                  fieldApiJsonNameMap.get(field),
                  (Decimal) fm.get(field)
                );
              }
              when 'REFERENCE' {
                if (field == referenceName) {
                  // VD24Apr25 rmove inside query to avoid too many SOQL
                  // remove the unwanted multiple slashes on question object json
                  String rawJson = referencedJSONMap.get((Id) fm.get(field));
                  if (rawJson != null) {
                    try {
                      // VD 26Apr25 json read changes
                      Map<String, Object> parsed = (Map<String, Object>) JSON.deserializeUntyped(
                        rawJson
                      );
                      if (parsed != null) {
                        // Serialize the full parsed object properly (without manually replacing backslashes!)
                        String cleanJson = JSON.serialize(parsed);
                        jsonGen.writeStringField(
                          fieldApiJsonNameMap.get(field),
                          cleanJson
                        );
                      }
                    } catch (Exception e) {
                      System.debug(
                        LoggingLevel.ERROR,
                        'Error parsing question JSON: ' + e.getMessage()
                      );
                    }
                  }
                }
              }
              when else {
                //jsonGen.writeStringField(field, fm.get(field));
              }
            }
          }
        }
        jsonGen.writeEndObject();
      }
      jsonGen.writeEndArray();
      // VD 12Jun25 handle JSON from attachment
      String jsonString = jsonGen.getAsString();
      Integer LONG_TEXT_LIMIT = 130000;
      Question__c ques = quesMap.get(qId);
      Question__c qObj = new Question__c(Id = qId);
      if (
        ques.Type__c == 'Table' &&
        (jsonString.length() > LONG_TEXT_LIMIT ||
        ques.Is_ReadJSONFromAttachment__c)
      ) {
        qObj.Fields_Meta__c = 'FieldsMeta_' + qId + '.json';
        qObj.Is_ReadJSONFromAttachment__c = true;
        attachmentsToUpsert.put(qId, jsonString); // add to map
      } else {
        qObj.Fields_Meta__c = jsonString;
        qObj.Is_ReadJSONFromAttachment__c = false;
      }
      // **Prepare bulk update list**
      questionsToUpdate.add(qObj);
    }

    // **Bulk Update**
    if (!questionsToUpdate.isEmpty()) {
      update questionsToUpdate;
    }
    if (!attachmentsToUpsert.isEmpty()) {
      upsertJsonAttachment(attachmentsToUpsert, 'FieldsMeta');
    }
  }
  // VD 12Jun25 handle JSON from attachment
  public static void upsertJsonAttachment(
    Map<Id, String> jsonMap,
    String fieldPrefix
  ) {
    Set<String> names = new Set<String>();
    for (Id qId : jsonMap.keySet()) {
      names.add(fieldPrefix + '_' + qId + '.json');
    }

    Map<String, Attachment> existingAttachmentsMap = new Map<String, Attachment>();
    for (Attachment att : [
      SELECT Id, Name, ParentId
      FROM Attachment
      WHERE Name IN :names AND ParentId IN :jsonMap.keySet()
    ]) {
      existingAttachmentsMap.put(att.ParentId + ':' + att.Name, att);
    }

    List<Attachment> attachmentsToInsert = new List<Attachment>();
    List<Attachment> attachmentsToUpdate = new List<Attachment>();

    for (Id qId : jsonMap.keySet()) {
      String name = fieldPrefix + '_' + qId + '.json';
      String key = qId + ':' + name;

      Attachment attach = new Attachment(
        Name = name,
        Body = Blob.valueOf(jsonMap.get(qId)),
        ContentType = 'application/json',
        ParentId = qId
      );

      if (existingAttachmentsMap.containsKey(key)) {
        attach.Id = existingAttachmentsMap.get(key).Id;
        attachmentsToUpdate.add(attach);
      } else {
        attachmentsToInsert.add(attach);
      }
    }

    if (!attachmentsToInsert.isEmpty()) {
      insert attachmentsToInsert;
    }
    if (!attachmentsToUpdate.isEmpty()) {
      update attachmentsToUpdate;
    }
  }
  // VD 04jul25 -and added used dynamic method

  // MR 24NOV23 Fuction to store the questions of a QB Reference in the Question QB_Reference_Questions__c
  public static void updateQuestionMeta(
    Set<String> qIds,
    Map<String, String> qbRefMap
  ) {
    if (qIds == null || qIds.isEmpty()) {
      return; // Prevent unnecessary execution
    }

    List<Question__c> questionsToUpdate = new List<Question__c>();
    // VD 12Jun25 handle JSON from attachment
    Map<Id, String> attachmentsUpsert = new Map<Id, String>(); // Map<QuestionId, jsonString>

    Map<Id, Question__c> quesMap = new Map<Id, Question__c>(
      [
        SELECT Id, Is_ReadJSONFromAttachment__c, Type__c
        FROM Question__c
        WHERE Id IN :qIds
      ]
    );

    for (String qId : qIds) {
      QuestionBookHandler qbh = new QuestionBookHandler();
      Question__c ques = quesMap.get(qId); // VD 12Jun25 handle JSON from attachment
      qbh.setContext('createAnswerBookFlag', false);
      Question__c qObj = new Question__c();
      qObj.Id = qId;
      // VD 12Jun25 handle JSON from attachment
      String jsonString = qbh.readRecords(qbRefMap.get(qId), '');
      Integer LONG_TEXT_LIMIT = 130000;
      if (
        ques.Type__c == 'Table' &&
        (jsonString.length() > LONG_TEXT_LIMIT ||
        ques.Is_ReadJSONFromAttachment__c)
      ) {
        qObj.QB_Reference_Questions__c =
          'QB_Reference_Questions_' +
          qId +
          '.json';
        attachmentsUpsert.put(qId, qbh.readRecords(qbRefMap.get(qId), '')); // add to map
        qObj.Is_ReadJSONFromAttachment__c = true;
      } else {
        qObj.QB_Reference_Questions__c = jsonString;
        qObj.Is_ReadJSONFromAttachment__c = false;
      }
      questionsToUpdate.add(qObj);
    }
    // VD 12Jun25 handle JSON from attachment
    if (!questionsToUpdate.isEmpty()) {
            update questionsToUpdate;
        }
    if (!attachmentsUpsert.isEmpty()) {
      upsertJsonAttachment(attachmentsUpsert, 'QB_Reference_Questions');
    }
  }

  // VD 24APRL25 method to get the reference question
  private static Map<Id, String> getReferenceQuestion(
    Set<Id> referencedQuestionIds
  ) {
    Map<Id, String> referencedJSONMap = new Map<Id, String>();

    if (referencedQuestionIds.isEmpty())
      return referencedJSONMap;

    Map<Id, Question__c> referencedQuestions = new Map<Id, Question__c>(
      [
        SELECT
          Id,
          Name,
          Reference_Field__c,
          Unique_Identifier__c,
          Additional_Rich__c,
          Group__c,
          Is_Date_Backward__c,
          Title__c,
          SubTitle__c,
          Is_Date_Forward__c,
          Is_Optional__c,
          Is_Title__c,
          Read_Only__c,
          IsAddRowAction__c,
          isSno__c,
          Is_Row_Draggable__c,
          Is_Rich_Text__c, // VD 29jun24 richText Support
          Date_Format__c, // RT 19SEP25 - Date Format
          Input_JSON__c, // VD 04jul25 - input handling changes
          Is_Serial_No__c,
          Value__c, // VD 29Jul25 default value handling
          Is_ReadJSONFromAttachment__c,
          Print_Mode__c,
          IsDeleteRowAction__c,
          Is_Hide__c,
          Help_Text__c,
          Next_Question__c,
          Error_Message__c,
          X24_Hours__c,
          Allowed_File_Extensions__c,
          Question_Text__c,
          Question__c,
          Question_No__c,
          Question_Book__c,
          Question_Parent__c,
          Size__c,
          Type__c,
          Sub_Text__c,
          Element_Mode__c,
          Fields_Meta__c,
          RecordType.Name,
          RecordTypeId,
          Tracking_ID__c,
          Date_Text__c,
          Time_Text__c,
          Record_Id__c,
          Question_Book__r.SubTitle__c,
          Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
          Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
          Currency_Code__c, // RT 06OCT25 - Currency Format
          Locale__c,
          Sno_Title__c, // RT 13OCT25 - S.no Title
          Enable_Signature_Drawing__c,
          Sign_URL_Reference__c,// VD 29Sep25 signpad datetime/url update changes
          Sign_DateTime_Reference__c,
          Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
          Location_DateTime_Reference__c,
          Longitude_Reference__c,
          Latitude_Reference__c,
          Enable_Name_Signing__c,
          Enable_Default_Location__c,
          QB_Reference__c,
          QB_Reference_Questions__c,
          QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
          Style__c,
          Is_Dependent__c,
          (
            SELECT
              Id,
              Name,
              Value__c,
              Order__c, // VD 29Jul25 default value handling
              Unique_Identifier__c,
              Next_Question__c,
              Question__c,
              Is_Default__c,
              Tracking_ID__c
            FROM Question_Options__r
            ORDER BY Order__c
          ),
          (
            SELECT
              Id,
              Name,
              Reference_Field__c,
              Unique_Identifier__c,
              Additional_Rich__c,
              Group__c,
              Is_Date_Backward__c,
              Title__c,
              SubTitle__c,
              Is_Date_Forward__c,
              Is_Optional__c,
              Is_Title__c,
              Read_Only__c,
              IsAddRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Is_Serial_No__c,
              Value__c, // VD 29Jul25 default value handling
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
              Is_Hide__c,
              Help_Text__c,
              Next_Question__c,
              Error_Message__c,
              X24_Hours__c,
              Allowed_File_Extensions__c,
              Question_Text__c,
              Question__c,
              Question_No__c,
              Question_Book__c,
              Question_Parent__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c, //  VD 04jul25 - input handling changes
              Size__c,
              Type__c,
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              RecordType.Name,
              RecordTypeId,
              Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
              Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
              Currency_Code__c, // RT 06OCT25 - Currency Format
              Locale__c,
              Sno_Title__c, // RT 13OCT25 - S.no Title
              Enable_Signature_Drawing__c,
              Sign_URL_Reference__c,
              Sign_DateTime_Reference__c,
              Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
              Location_DateTime_Reference__c,
              Longitude_Reference__c,
              Latitude_Reference__c,
              Enable_Name_Signing__c,
              Enable_Default_Location__c,
              Tracking_ID__c,
              Date_Text__c,
              Time_Text__c,
              Record_Id__c,
              Question_Book__r.SubTitle__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Style__c,
              Is_Dependent__c
            FROM Questions__r
            ORDER BY Question_No__c
          )
        FROM Question__c
        WHERE Id IN :referencedQuestionIds
      ]
    );

    Set<Id> subQuestionIds = new Set<Id>();
    for (Question__c q : referencedQuestions.values()) {
      // VD 12Jun25 avoid unused refrences
      // VD 18SEP20 - Need to read refrence book's field meta
      if (q.Questions__r != null) {
        for (Question__c subQ : q.Questions__r) {
          subQuestionIds.add(subQ.Id);
        }
      }
    }

    Map<Id, List<Option__c>> subQOptionsMap = new Map<Id, List<Option__c>>();
    if (!subQuestionIds.isEmpty()) {
      for (Option__c opt : [
        SELECT
          Id,
          Name,
          Value__c,
          Unique_Identifier__c,
          Next_Question__c,
          Order__c,
          Is_Default__c,
          Question__c
        FROM Option__c
        WHERE Question__c IN :subQuestionIds
        ORDER BY Order__c
      ]) {
        if (!subQOptionsMap.containsKey(opt.Question__c)) {
          subQOptionsMap.put(opt.Question__c, new List<Option__c>());
        }
        subQOptionsMap.get(opt.Question__c).add(opt);
      }
    }

    for (Id refId : referencedQuestions.keySet()) {
      JSONGenerator jsonGen = JSON.createGenerator(true);
      jsonGen.writeStartObject();

      QuestionWrapper wrapper = new QuestionWrapper(
        referencedQuestions.get(refId)
      );

      if (wrapper.subQuestions != null) {
        for (QuestionWrapper sub : wrapper.subQuestions) {
          if (subQOptionsMap.containsKey(sub.id)) {
            sub.options = new List<OptionWrapper>();
            for (Option__c o : subQOptionsMap.get(sub.id)) {
              sub.options.add(new OptionWrapper(o));
            }
          }
        }
      }

      jsonGen.writeStringField('status', 'success');
      jsonGen.writeObjectField('question', wrapper);
      jsonGen.writeEndObject();

      referencedJSONMap.put(refId, jsonGen.getAsString());
    }

    return referencedJSONMap;
  }
  // VD 04jul25  Dynamic method to to update parent Object
  public static void updateParentObject(
    Set<Id> qIds,
    String relatedObjectApi,
    String lookupFieldName,
    String targetFieldName,
    String parentObjectApi
  ) {
    if (
      qIds == null ||
      qIds.isEmpty() ||
      String.isBlank(relatedObjectApi) ||
      String.isBlank(lookupFieldName) ||
      String.isBlank(targetFieldName)
    ) {
      return;
    }

    // Get schema describe for related object
    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
    Schema.SObjectType objectSchema = schemaMap.get(relatedObjectApi);
    if (objectSchema == null)
      return;

    Map<String, Schema.SObjectField> fieldMap = objectSchema.getDescribe()
      .fields.getMap();

    Map<String, String> fieldNameTypeMap = new Map<String, String>();
    Map<String, String> fieldApiJsonNameMap = new Map<String, String>();

    // Build maps for JSON generation
    for (Schema.SObjectField field : fieldMap.values()) {
      String originalApiName = field.getDescribe().getName();
      fieldApiJsonNameMap.put(originalApiName, Utility.jsName(originalApiName));
      fieldNameTypeMap.put(
        originalApiName,
        String.valueOf(field.getDescribe().getType())
      );
    }

    // Construct dynamic SOQL
    String queryStr =
      'SELECT ' +
      String.join(fieldNameTypeMap.keySet(), ', ') +
      ' FROM ' +
      relatedObjectApi +
      ' WHERE ' +
      lookupFieldName +
      ' IN :qIds';

    List<SObject> relatedRecords = Database.query(queryStr);

    // Group by lookup field (e.g., Question__c)
    Map<Id, List<SObject>> groupedRecords = new Map<Id, List<SObject>>();
    for (SObject record : relatedRecords) {
      Id parentId = (Id) record.get(lookupFieldName);
      if (!groupedRecords.containsKey(parentId)) {
        groupedRecords.put(parentId, new List<SObject>());
      }
      groupedRecords.get(parentId).add(record);
    }

    List<SObject> updates = new List<SObject>();

    for (Id qId : qIds) {
      // if (!groupedRecords.containsKey(qId)) continue;
      List<SObject> childRecords = groupedRecords.get(qId);
      JSONGenerator jsonGen = JSON.createGenerator(true);
      jsonGen.writeStartArray();
      if (childRecords != null) {
        for (SObject rec : childRecords) {
          jsonGen.writeStartObject();

          for (String field : fieldNameTypeMap.keySet()) {
            Object val = rec.get(field);
            if (val != null) {
              String type = fieldNameTypeMap.get(field);
              String jsonField = fieldApiJsonNameMap.get(field);
              System.debug('typetype-->' + type);
              switch on type {
                when 'BOOLEAN' {
                  jsonGen.writeBooleanField(jsonField, (Boolean) val);
                }
                when 'STRING' {
                  jsonGen.writeStringField(jsonField, (String) val);
                }
                when 'ID' {
                  jsonGen.writeStringField(jsonField, (Id) val);
                }
                when 'TEXTAREA' {
                  jsonGen.writeStringField(jsonField, (String) val);
                }
                when 'PICKLIST' {
                  jsonGen.writeStringField(jsonField, (String) val);
                }
                when 'MULTIPICKLIST' {
                  String multiPicklistValue = (String) val;
                  multiPicklistValue = multiPicklistValue
                    ?.replaceAll('\\s*;\\s*', ',');
                  jsonGen.writeStringField(jsonField, multiPicklistValue);
                }
                when else {
                  // Optionally handle more types
                }
              }
            }
          }

          jsonGen.writeEndObject();
        }
      }

      jsonGen.writeEndArray();
      List<Object> jsonList = (List<Object>) JSON.deserializeUntyped(
        jsonGen.getAsString()
      );

      // Dynamically create the object for update
      SObject parentRecord = Schema.getGlobalDescribe()
        .get(parentObjectApi)
        .newSObject(qId);
      parentRecord.put(
        targetFieldName,
        jsonList.isEmpty() ? null : JSON.serialize(jsonList[0])
      );
      updates.add(parentRecord);
    }

    if (!updates.isEmpty()) {
      update updates;
    }
  }
}