public without sharing class DmlOpreationFormController {
  public class CustomException extends Exception {
  }

  public DmlOpreationFormController() {
    System.debug('DmlOpreationFormController const');
  }
  // VD-04JAN24  Removed Unused method
  // VD 01Mar25  pass the pageId for dynamic filter
  @AuraEnabled
  public static string saveRecord(string jsonData, string id, String pageId) {
    // VD 24jun25 Form ID Changes (in place of QB Id)
    String inpId = id;
    Id objectId = (Id) inpId;
    String namespace = Utility.nameSpace();
    String sObjName = objectId.getSObjectType().getDescribe().getName();
    if (sObjName == namespace + 'Form__c') {
      Form__c form = [
        SELECT Id, Name, Type__c, Anchor_Object__c, Question_Book__c
        FROM Form__c
        WHERE Id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      inpId = form.Question_Book__c;
    } else {
      inpId = id;
    }
    //   jsonData = '{"bookQuestionsMap": {"a033t00000pcQroAAE": {"attributes": {"type": "Question__c","url": "/services/data/v58.0/sobjects/Question__c/a043t000018b54oAAA"},"Id": "a043t000018b54oAAA","Name": "QN-02868", "Is_Date_Backward__c": false,"Is_Date_Forward__c": false,"Is_Optional__c": false,"Is_Title__c": false,"X24_Hours__c": false,"Question_Text__c": "<p>Patient Information</p>","Question__c": "Patient Information","Question_No__c": 1,"Question_Book__c": "a033t00000pcQroAAE","Size__c": 12,"Type__c": "Book","RecordTypeId": "0123t000000uQznAAE","Questions__r": {"totalSize": 1,"done": true,"records": [{"attributes": {"type": "Question__c","url": "/services/data/v58.0/sobjects/Question__c/a043t000018b54SAAQ"},"Question_Parent__c": "a043t000018b54oAAA","Id": "a043t000018b54SAAQ","Name": "QN-02853","Reference_Field__c": "Contact.FirstName","Is_Date_Backward__c": false,"Is_Date_Forward__c": false,"Is_Optional__c": false,"Is_Title__c": false,"X24_Hours__c": false,"Question_Text__c": "<p>First Name</p>","Question__c": "First Name", "Question_No__c": 1,"Question_Book__c": "a033t00000pcQroAAE","Size__c": 6,"Type__c": "Text","input": "Riyaz","error": null},{"attributes": {"type": "Question__c","url": "/services/data/v58.0/sobjects/Question__c/a043t000018b54cAAA"},"Question_Parent__c": "a043t000018b54oAAA","Id": "a043t000018b54cAAA","Name": "QN-02855","Reference_Field__c": "Contact.LastName","Question_No__c": 3,"Question_Book__c": "a033t00000pcQroAAE","input": "Ahamed1","error": null},{"attributes": {"type": "Question__c","url": "/services/data/v58.0/sobjects/Question__c/a043t000018b54cAAA"},"Question_Parent__c": "a043t000018b54oAAA","Id": "a043t000018b54cAAA","Name": "QN-02855","Reference_Field__c": "Contact.Email","Question_No__c": 3,"Question_Book__c": "a033t00000pcQroAAE","input": "riyaz@rangerinc.co","error": null}]}}}}';
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    Answer_Book__c retABUp = new Answer_Book__c();
    try {
      Boolean isFileCame = false;
      List<String> fileNames = new List<String>();
      List<Blob> fileBlobs = new List<Blob>();
      // Deserialize the JSON into a Map<String, Object>
      Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
        jsonData
      );

      // Extract the "bookQuestionsMap" record
      Map<String, Object> bookQuestionsMap = (Map<String, Object>) dataMap.get(
        'bookQuestionsMap'
      );
      // system.debug('bookQuestionsMap-->'+bookQuestionsMap);
      list<Answer_Book__c> retAB1 = [
        SELECT id, name, Question_Book__c
        FROM Answer_Book__c
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
      ];
      // Iterate through the records within "bookQuestionsMap"
      Answer_Book__c retAB = new Answer_Book__c();
      if (retAB1.size() > 0) {
        if (retAB1[0].id != null) {
          retAB = new Answer_Book__c(Id = retAB1[0].id);
          retAB.Question_Book__c = retAB1[0].Question_Book__c;
        }
      } else {
        retAB.Question_Book__c = inpId;
      }
      retAB.Status__c = 'Completed';
      if (
        Answer_Book__c.SObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Status__c.isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Answer_Long__c.isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Status__c.isUpdateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Answer_Long__c.isUpdateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isUpdateable()
      ) {
        upsert retAB;
      }
      // VD 19MAR25 multiple section duplicate record creation fix
      // RT 24JUN25 - Null Check if Serial Number is availed
      Map<String, List<SObject>> consolidatedRecords = new Map<String, List<SObject>>();
      for (String recordId : bookQuestionsMap.keySet()) {
        list<SObject> objList = new List<SObject>();
        Map<String, Object> record = (Map<String, Object>) bookQuestionsMap.get(
          recordId
        );
        string recId = (string) record.get('recordId');
        String objectName = '';
        List<Object> questionRecords = (List<Object>) record.get(
          'subQuestions'
        );
        Map<String, Object> fieldValues = new Map<String, Object>();
        for (Object questionRecordObj : questionRecords) {
          Map<String, Object> questionRecord = (Map<String, Object>) questionRecordObj;
          String questionId = (String) questionRecord.get('id');
          String questionName = (String) questionRecord.get('name');
          String referenceField = (String) questionRecord.get('referenceField');
          String questionText = (String) questionRecord.get('questionText');
          Integer questionNo = (Integer) questionRecord.get('questionNumber');
          String questionBook = (String) questionRecord.get('questionBookId');
          // VD 23jul24 - Table logic
          String tableObjName = (String) questionRecord.get('title');
          String filterCondition = (String) questionRecord.get('subTitle');
          Object questionError = questionRecord.get('error');
          String quesType = (String) questionRecord.get('type');
          String questionInput = '';
          // VD 28-jan-25 handle table types and other
          Date quesDateInput = null;
          // VD 8feb25 handle element changes
          // VD 01MAR25 Number type handling
          Decimal decimalField = null;
          Integer integerField = null;
          if (questionRecord.get('input') != null) {
            if (quesType == 'Table') {
              List<Object> tableDataList = (List<Object>) questionRecord.get(
                'input'
              );
              System.debug('input1--->' + tableDataList);
              Set<Id> questionIdsToUpdate = new Set<Id>();
              Map<Id, Map<String, object>> questionIdToFieldValuesMap = new Map<Id, Map<String, object>>();
              List<SObject> newQuestionsToCreate = new List<SObject>();
              Set<Id> existingQuestionIds = new Set<Id>();
              // VD 13May25 - delete logic changes
              Set<Id> recordsToDeleteIds = new Set<Id>();
              //  // VD 25FEB25 table type skip + list and date type fix
              for (Object tableRecord : tableDataList) {
                Map<String, Object> recordMap = (Map<String, Object>) tableRecord;
                List<Object> values = (List<Object>) recordMap.get('value');
                String quesIdString = (String) recordMap.get('recordId');
                // VD 13May25 - delete logic changes
                Boolean isDeleted = (Boolean) recordMap.get('isDeleted');
                Id quesId = !quesIdString.contains('newRow')
                  ? (Id) quesIdString
                  : null;
                // VD 13May25 - delete logic changes
                if (isDeleted == true && quesId != null) {
                  recordsToDeleteIds.add(quesId); // Mark for deletion
                  continue; // Skip processing this row
                }
                Map<String, Object> fieldValuesMap = new Map<String, Object>();
                Map<String, Boolean> SerialNoMap = new Map<String, Boolean>();
                for (Object value : values) {
                  Map<String, Object> valueMap = (Map<String, Object>) value;
                  List<Object> questions = (List<Object>) valueMap.get(
                    'questions'
                  );
                  Map<String, Object> questionMap = (Map<String, Object>) questions[0];

                  String field = (String) questionMap.get('referenceField');
                  Object fieldValueObj = questionMap.get('input');
                  Boolean isSerial = (Boolean) questionMap.get('isSerialNo');
                  SerialNoMap.put(field, isSerial);
                  String fieldValue = null;
                  // Date dateFieldValue = null;
                  // VD 01MAR25 Number type handling
                  Decimal decimalFieldValue = null;
                  Integer integerFieldValue = null;
                  String quesTypeRow = (String) questionMap.get('type');
                  if (
                    fieldValueObj != null &&
                    String.valueOf(fieldValueObj) != ''
                  ) {
                    if (quesTypeRow == 'List') {
                      Map<String, Object> searchRowInput = (Map<String, Object>) questionMap.get(
                        'input'
                      );
                      String currentRowRecId = searchRowInput != null
                        ? (String) searchRowInput.get('recordId')
                        : null;
                      fieldValue = currentRowRecId;
                    }
                    // VD 01Mar25 removed logic here handled below
                    else if (fieldValueObj instanceof String) {
                      fieldValue = (String) fieldValueObj;
                    } else {
                      System.debug('Unhandled input type: ' + fieldValueObj);
                    }

                    if (quesTypeRow == 'Date' || quesTypeRow == 'DateTime') {
                      // VD 01MAR25 Date/Time type handling
                      String dateRowInput = (String) questionMap.get('input');
                      if (dateRowInput != null) {
                        Date dateFieldValue = Date.valueOf(dateRowInput);
                        fieldValuesMap.put(field, dateFieldValue);
                      }
                    }
                    // VD 06MAR25 boolean type handling
                    else if (quesTypeRow == 'Checkbox') {
                      String flagIn = (String) fieldValueObj;
                      if (flagIn != null) {
                        Boolean flagVal = flagIn == 'true' ? true : false;
                        fieldValuesMap.put(field, flagVal);
                      }
                    }
                    // VD 01MAR25 Number type handling
                    else if (quesTypeRow == 'Number') {
                      String numberRowInput = (String) fieldValueObj;
                      try {
                        decimalFieldValue = Decimal.valueOf(numberRowInput);
                        fieldValuesMap.put(field, decimalFieldValue);
                      } catch (Exception e) {
                        System.debug(
                          'Error parsing as Decimal, trying as Integer: ' +
                          e.getMessage()
                        );
                        try {
                          integerFieldValue = Integer.valueOf(numberRowInput);
                          fieldValuesMap.put(field, integerFieldValue);
                        } catch (Exception ex) {
                          System.debug(
                            'Error parsing as Integer: ' + ex.getMessage()
                          );
                        }
                      }
                    } else {
                      fieldValuesMap.put(field, fieldValue);
                    }
                  }
                }

                if (filterCondition != null && filterCondition != '') {
                  Integer eqIndex = filterCondition.indexOf('=');
                  if (eqIndex != -1) {
                    String filterField = filterCondition.substring(0, eqIndex)
                      .trim();
                    String filterValue = filterCondition.substring(eqIndex + 1)
                      .trim()
                      .replace('\'', '');
                    // VD 01Mar25 for dynamic filter Replace {recordId} with the actual id parameter
                    if (filterValue == '{recordId}' && pageId != null) {
                      filterValue = pageId;
                      system.debug('filterValue1-->' + filterValue);
                    }
                    fieldValuesMap.put(filterField, filterValue);
                  }
                }

                if (quesId != null) {
                  questionIdsToUpdate.add(quesId);
                  questionIdToFieldValuesMap.put(quesId, fieldValuesMap);
                  existingQuestionIds.add(quesId);
                } else {
                  //RT 18JUN25 - Check if at least one field has a non-null value before creating new record
                  Boolean hasNonNullValue = false;
                  for (String fieldKey : fieldValuesMap.keySet()) {
                    if (fieldValuesMap.get(fieldKey) != null && SerialNoMap.get(fieldKey) == false) {
                      hasNonNullValue = true;
                      break;
                    }
                  }

                  if (hasNonNullValue) {
                    SObject newQuestion = (SObject) Type.forName(
                        'Schema.' + tableObjName
                      )
                      .newInstance();
                    for (String field : fieldValuesMap.keySet()) {
                      if (field != 'Id') {
                        newQuestion.put(field, fieldValuesMap.get(field));
                      }
                    }
                    newQuestionsToCreate.add(newQuestion);
                  }
                }
              }

              // Construct the dynamic SOQL query for existing records
              if (!questionIdsToUpdate.isEmpty()) {
                String fieldList = 'Id';
                if (!questionIdToFieldValuesMap.isEmpty()) {
                  Map<String, object> exampleFieldMap = questionIdToFieldValuesMap.values()[0];
                  for (String field : exampleFieldMap.keySet()) {
                    if (field != 'Id') {
                      fieldList += ', ' + field;
                      System.debug('inside Query: ' + field);
                    }
                  }
                }

                String query =
                  'SELECT ' +
                  fieldList +
                  ' FROM ' +
                  tableObjName +
                  ' WHERE Id IN :questionIdsToUpdate';
                List<SObject> questionsToUpdate = Database.query(query);
                // Update the questions with the extracted field names and values
                // VD 05Mar25 Get the object describe dynamically
                Schema.SObjectType objType = Schema.getGlobalDescribe()
                  .get(tableObjName);
                Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
                for (SObject question : questionsToUpdate) {
                  Id qId = (Id) question.get('Id');
                  if (questionIdToFieldValuesMap.containsKey(qId)) {
                    Map<String, object> fieldValuesMap = questionIdToFieldValuesMap.get(
                      qId
                    );
                    for (String field : fieldValuesMap.keySet()) {
                      System.debug('update inside: ' + field);
                      //  VD 05Mar25 Validate field existence before updating
                      if (objDescribe.fields.getMap().containsKey(field)) {
                        Schema.DescribeFieldResult fieldDesc = objDescribe.fields.getMap()
                          .get(field)
                          .getDescribe();
                        // Skip updating Master-Detail fields (not editable)
                        if (!fieldDesc.isUpdateable()) {
                          System.debug(
                            'Skipping non-updatable field: ' + field
                          );
                          continue;
                        }
                      } else {
                        System.debug('Field not found in schema: ' + field);
                        continue;
                      }
                      question.put(field, fieldValuesMap.get(field));
                    }
                  }
                }

                // Update existing records
                if (!questionsToUpdate.isEmpty()) {
                  System.debug('questionsToUpdate: ' + questionsToUpdate);
                  update questionsToUpdate;
                }
              }

              // Insert new records
              if (!newQuestionsToCreate.isEmpty()) {
                System.debug('newQuestionsToCreate: ' + newQuestionsToCreate);
                insert newQuestionsToCreate;
              }
              // VD 13May25 - delete logic changes
              // Delete records explicitly marked for deletion via isDeleted flag
              if (!recordsToDeleteIds.isEmpty()) {
                String deleteQuery =
                  'SELECT Id FROM ' +
                  tableObjName +
                  ' WHERE Id IN :recordsToDeleteIds';
                List<SObject> recordsToDelete = Database.query(deleteQuery);
                if (!recordsToDelete.isEmpty()) {
                  System.debug('recordsToDelete: ' + recordsToDelete);
                  delete recordsToDelete;
                }
              }
              // VD 28-jan-25 handle all the types elements
            } else if (quesType == 'List') {
              Map<String, Object> searchInput = (Map<String, Object>) questionRecord.get(
                'input'
              );
              String currentRecId = (String) searchInput.get('recordId');
              questionInput = currentRecId;
            }
            // VD 01Mar25 removed logic here handled below
            else if (quesType == 'File') {
              //RT 11FEB25 - Added file operation
              Object inputObj = questionRecord.get('input');
              List<Object> attachmentList;

              // Handle both possible input formats
              if (inputObj instanceof List<Object>) {
                attachmentList = (List<Object>) inputObj;
              } else if (inputObj instanceof Map<String, Object>) {
                Map<String, Object> inputMap = (Map<String, Object>) inputObj;
                attachmentList = (List<Object>) inputMap.get('attachmentValue');
              } else {
                System.debug('Unexpected input format for file: ' + inputObj);
                continue;
              }
              if (attachmentList != null && !attachmentList.isEmpty()) {
                isFileCame = true;

                for (Object attachmentObj : attachmentList) {
                  Map<String, Object> attachmentDetails = (Map<String, Object>) attachmentObj;
                  filenames.add((String) attachmentDetails.get('name'));
                  String base64 = (String) attachmentDetails.get(
                    'contentBodyId'
                  );
                  fileBlobs.add(EncodingUtil.base64Decode(base64));
                }
                continue;
              }
            } else {
              questionInput = (String) questionRecord.get('input');
            }
          }
          if (questionInput != null && referenceField != null) {
            String inputString = referenceField;
            String[] parts = inputString.split('\\.');
            objectName = parts[0];
            String fieldName = parts[1];
            if (quesType == 'Date' || quesType == 'DateTime') {
              // VD 01MAR25 Date/Time type handling
              String dateInput = (String) questionRecord.get('input');
              if (dateInput != null) {
                Date parsedDate = Date.valueOf(dateInput);
                fieldValues.put(fieldName, parsedDate);
              }
            } else if (quesType == 'Checkbox') {
              /// VD 06MAR25 boolean type handling
              String flagInput = (String) questionRecord.get('input');
              if (flagInput != null) {
                Boolean flagValue = flagInput == 'true' ? true : false;
                fieldValues.put(fieldName, flagValue);
              }
            } else if (quesType == 'Number') {
              // VD 01MAR25 Number type handling
              String numberInput = (String) questionRecord.get('input');
              try {
                decimalField = Decimal.valueOf(numberInput);
                fieldValues.put(fieldName, decimalField);
              } catch (Exception e) {
                System.debug(
                  'Error parsing as Decimal, trying as Integer: ' +
                  e.getMessage()
                );
                try {
                  integerField = Integer.valueOf(numberInput);
                  fieldValues.put(fieldName, integerField);
                } catch (Exception ex) {
                  System.debug('Error parsing as Integer: ' + ex.getMessage());
                }
              }
            } else {
              fieldValues.put(fieldName, questionInput);
            }
          }
        }
        // VD 19MAR25 multiple section duplicate record creation fix
        // note --> need to handle attachment correclty
        if (objectName != null && objectName.length() > 0) {
          Schema.SObjectType objectType = Schema.getGlobalDescribe()
            .get(objectName);
          sObject obj;

          // Check if we already have a record for this object
          if (consolidatedRecords.containsKey(objectName)) {
            obj = consolidatedRecords.get(objectName)[0]; // Use existing record
          } else {
            obj = objectType.newSObject();
            consolidatedRecords.put(objectName, new List<sObject>{ obj });
          }

          if (objectType != null && fieldValues != null) {
            for (String fieldName1 : fieldValues.keySet()) {
              obj.put(fieldName1, fieldValues.get(fieldName1));
            }

            // Handle ID for updates
            if (pageId != null && pageId.length() > 2) {
              obj.put('Id', pageId);
            } else if (recId != null && recId.length() > 2) {
              obj.put('Id', recId);
            }
          }
        }
        // Process Insert/Update after all sections are merged
        if (!consolidatedRecords.isEmpty()) {
          for (String objName : consolidatedRecords.keySet()) {
            List<sObject> recordsToProcess = consolidatedRecords.get(objName);
            List<sObject> insertList = new List<sObject>();
            List<sObject> updateList = new List<sObject>();

            for (sObject rec : recordsToProcess) {
              if (rec.get('Id') != null) {
                updateList.add(rec);
              } else {
                insertList.add(rec);
              }
            }
            // Perform Insert
            if (!insertList.isEmpty()) {
              insert insertList;
              recId = insertList[0].Id;
              record.put('recordId', recId);
              if (filenames.size() > 0) {
                System.debug('inside attachment -->' + filenames);
                if (Schema.sObjectType.Attachment.isCreateable()) {
                  List<Attachment> attachments = new List<Attachment>();
                  for (Integer i = 0; i < filenames.size(); i++) {
                    attachments.add(
                      new Attachment(
                        Name = filenames[i],
                        Body = fileBlobs[i],
                        ParentId = recId
                      )
                    );
                  }
                  insert attachments;
                }
                isFileCame = false;
                filenames.clear();
                fileBlobs.clear();
              }
            }
            // Perform Update
            if (!updateList.isEmpty()) {
              update updateList;
            }
          }
        }
      }

      // VD 25FEB25 table type skip ligic
      for (String recordId : bookQuestionsMap.keySet()) {
        Map<String, Object> record = (Map<String, Object>) bookQuestionsMap.get(
          recordId
        );
        List<Object> questionRecords = (List<Object>) record.get(
          'subQuestions'
        );
        List<Object> filteredQuestions = new List<Object>();
        for (Object questionRecordObj : questionRecords) {
          Map<String, Object> questionRecord = (Map<String, Object>) questionRecordObj;
          String quesType = (String) questionRecord.get('type');
          // If it's a Table question, check the value field
          if (quesType == 'Table' && questionRecord.containsKey('input')) {
            Object value = questionRecord.get('input');
            system.debug('insideTable-->' + value);
            // Check if value is an array and clear it
            if (value instanceof List<Object>) {
              questionRecord.put('input', new List<Object>());
              system.debug(
                'after table clear-->' + questionRecord.get('input')
              );
            }
          }
        }
      }

      retABUp.id = retAB.id;
      retABUp.Status__c = 'Completed';
      retABUp.Answer_Long__c = JSON.serializePretty(bookQuestionsMap);
      update retABUp;
      // VD 01Mar25 handling error
      jsonGen.writeObjectField('isError', false);
    } catch (exception e) {
      System.debug('Inside the exception section ' + e.getMessage());
      // VD 01Mar25 handling error
      String stackTrace = e.getStackTraceString();
      jsonGen.writeObjectField('isError', true);
      jsonGen.writeObjectField('error', e.getMessage());
      jsonGen.writeObjectField('stackTrace', stackTrace);
    }
    jsonGen.writeObjectField('status', retABUp);
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  // VD 8feb25 Questionnaire save changes
  @AuraEnabled
  public static String save(String questionsJson) {
    try {
      List<Object> questionsList = (List<Object>) JSON.deserializeUntyped(
        questionsJson
      );
      for (Object question : questionsList) {
        List<Object> singleQuestionList = new List<Object>();
        Map<String, Object> result = new Map<String, Object>();
        singleQuestionList.add(question);
        Map<String, Object> singleQuestionListMap = (Map<String, Object>) singleQuestionList[0];
        string bookId = (string) singleQuestionListMap.get('questionBookId');
        String recId1 = (string) singleQuestionListMap.get('recordId');
        if (
          singleQuestionListMap.get('type') == 'Book' &&
          singleQuestionListMap.containsKey('subQuestions')
        ) {
          List<Object> subQuestions = (List<Object>) singleQuestionListMap.get(
            'subQuestions'
          );
          if (subQuestions != null && !subQuestions.isEmpty()) {
            result = processQuestions(subQuestions);
          }
        } else {
          result = processQuestions(singleQuestionList);
        }
        List<SObject> objectList = new List<SObject>();
        String objName = (String) result.get('objName');
        Map<String, Object> fieldValuesMap = (Map<String, Object>) result.get(
          'fieldValuesMap'
        );
        if (objName != null && objName.length() > 0) {
          Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
          if (objType != null) {
            SObject obj1 = objType.newSObject();

            for (String fieldName : fieldValuesMap.keySet()) {
              obj1.put(fieldName, fieldValuesMap.get(fieldName));
            }

            if (recId1 != null && recId1.length() > 2) {
              obj1.put('Id', recId1);
            }

            objectList.add(obj1);
            String insertedRecId = insertOrUpdateRecords(
              objectList,
              objName,
              fieldValuesMap,
              recId1
            );
            // Fetch the most recent AnswerBook related to the QuestionBook
            Answer_Book__c answerBook = fetchRecentAnswerBook(bookId);
            // Set the inserted record ID back to the question map
            for (Object question1 : singleQuestionList) {
              Map<String, Object> questionMap1 = (Map<String, Object>) question1;
              String qId = '';
              String parentQuestion = (String) questionMap1.get(
                'parentQuestion'
              );
              if (parentQuestion != null) {
                qId = parentQuestion;
              } else {
                qId = (String) questionMap1.get('id');
              }
              if (questionMap1.get('recordId') == '0') {
                questionMap1.put('recordId', insertedRecId);
              }
              // Update the AnswerBook's Answers' recordId__c field
              updateAnswerRecords(answerBook, insertedRecId, qId);
            }
          }
        }
      }
    } catch (Exception e) {
      System.debug('Inside the exception section: ' + e.getMessage());
    }
    return 'success';
  }

  private static Map<String, Object> processQuestions(
    List<Object> questionsList
  ) {
    Map<String, Object> fieldValuesMap = new Map<String, Object>();
    String objName = '';
    // String recId1 = '0';
    for (Object question : questionsList) {
      Map<String, Object> questionMap = (Map<String, Object>) question;
      String qInput = '';
      Date qDateInput = null;
      Integer qNumberInput = null;
      Map<String, Object> listInput;

      String qType = (String) questionMap.get('type');
      String qReferenceField = (String) questionMap.get('referenceField');

      if (questionMap.get('input') != null) {
        if (qType == 'List') {
          listInput = (Map<String, Object>) questionMap.get('input');
          String currentRecId = (String) listInput.get('recordId');
          qInput = currentRecId;
        } else if (qType == 'Number') {
          try {
            String numInput = (String) questionMap.get('input');
            qNumberInput = Integer.valueOf(numInput);
          } catch (Exception e) {
            System.debug('Error parsing number: ' + e.getMessage());
          }
        } else if (qType == 'Date' || qType == 'DateTime') {
          String datInput = (String) questionMap.get('input');
          qDateInput = Date.valueOf(datInput);
        } else if (
          qType == 'Text' ||
          qType == 'TextArea' ||
          qType == 'Dropdown' ||
          qType == 'Email'
        ) {
          qInput = (String) questionMap.get('input');
        }
      }

      if (qInput != null && qReferenceField != null) {
        String[] partsOfFields = qReferenceField.split('\\.');
        objName = partsOfFields[0];
        String fieldApiName = partsOfFields[1];

        if (qType == 'Date' || qType == 'DateTime') {
          fieldValuesMap.put(fieldApiName, qDateInput);
        } else if (qType == 'Number') {
          fieldValuesMap.put(fieldApiName, qNumberInput);
        } else {
          fieldValuesMap.put(fieldApiName, qInput);
        }
      }
    }
    Map<String, Object> result = new Map<String, Object>();
    result.put('objName', objName);
    result.put('fieldValuesMap', fieldValuesMap);
    system.debug('test result-->' + result);
    return result;
  }

  // Fetches the most recent AnswerBook record related to the QuestionBook
  private static Answer_Book__c fetchRecentAnswerBook(String questionBookId) {
    return [
      SELECT Id
      FROM Answer_Book__c
      WHERE Question_Book__c = :questionBookId
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
  }

  // Updates the Answer records related to the AnswerBook
  private static void updateAnswerRecords(
    Answer_Book__c answerBook,
    String insertedRecordId,
    string quesId
  ) {
    Answer__c answer = [
      SELECT Id, recordId__c
      FROM Answer__c
      WHERE Answer_Book__c = :answerBook.Id AND Question_Ref__c = :quesId
    ];
    answer.recordId__c = insertedRecordId;
    update answer;
  }

  // 🔹 Helper method to insert or update records in Salesforce
  private static String insertOrUpdateRecords(
    List<SObject> objectList,
    String objName,
    Map<String, Object> fieldValuesMap,
    String recId1
  ) {
    system.debug('inside insertOrUpdateRecords');
    String insertedRecordId = null;
    if (!objectList.isEmpty()) {
      Boolean isAccess = true;
      Schema.DescribeSObjectResult objSchema = getSchema(objName);

      if (recId1 != null && recId1.length() > 2) {
        // Update record
        system.debug('inside update');
        if (objSchema.isUpdateable()) {
          for (String fieldName : fieldValuesMap.keySet()) {
            if (
              !(objSchema.fields.getMap().containsKey(fieldName) &&
              objSchema.fields.getMap()
                .get(fieldName)
                .getDescribe()
                .isUpdateable())
            ) {
              isAccess = false;
              break;
            }
          }
        }
        if (isAccess) {
          system.debug('inside update');
          update objectList;
          insertedRecordId = recId1; // Use the provided recordId
        }
      } else {
        // Insert new record
        system.debug('inside insert');
        if (objSchema.isCreateable()) {
          insert objectList;
          // Update the recId1 with the new recordId after insert
          insertedRecordId = ((SObject) objectList[0]).Id;
        }
      }
    }
    return insertedRecordId;
  }

  // VD 19Jan24 - clone booklet changes
  @AuraEnabled
  public static string cloneRecord(string inputId) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    Question_Book__c bookUpdate = new Question_Book__c();
    try {
      Question_Book__c booklet = [
        SELECT
          Id,
          Name,
          Parent_Booklet_QB__c,
          Unique_Identifier__c,
          Status__c,
          Title__c,
          isShengel__c,
          SubTitle__c,
          Last_Question__c,
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Edit__c,
          Possibilities__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          Progress_Bar__c
        FROM Question_Book__c
        WHERE Id = :inputId AND Category__c = 'Booklet'
        WITH SECURITY_ENFORCED
      ];
      Question_Book__c bookletCopy = booklet.clone(false, true);
      system.debug('check-->' + booklet.Id);
      if (
        Question_Book__c.SObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Parent_Booklet_QB__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Status__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Title__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.isShengel__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.SubTitle__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Last_Question__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Category__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Next__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Back__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Submit__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Cancel__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Edit__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Summary_Text__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Summary_Sub_Text__c.isCreateable() &&
        Schema.sObjectType.Question_Book__c.fields.Progress_Bar__c.isCreateable()
      ) {
        insert bookletCopy;
      }
      System.debug('boolet copy--->' + bookletCopy);
      List<Question_Book__c> questionBooks = [
        SELECT
          Id,
          Name,
          Parent_Booklet_QB__c,
          Status__c,
          Title__c,
          isShengel__c,
          SubTitle__c,
          Last_Question__c,
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Edit__c,
          Possibilities__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          Progress_Bar__c
        FROM Question_Book__c
        WHERE Parent_Booklet_QB__c = :booklet.Id
        WITH SECURITY_ENFORCED
      ];

      for (Question_Book__c qb : questionBooks) {
        Question_Book__c qbCopy = qb.clone(false, true);
        System.debug('qb.Id--->' + qb.Id);
        if (
          Question_Book__c.SObjectType.getDescribe().isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Parent_Booklet_QB__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Status__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Title__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.isShengel__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.SubTitle__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Last_Question__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Category__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Next__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Back__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Submit__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Cancel__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Edit__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Summary_Text__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Summary_Sub_Text__c.isCreateable() &&
          Schema.sObjectType.Question_Book__c.fields.Progress_Bar__c.isCreateable()
        ) {
          insert qbCopy;
        }
        System.debug('qbCopy--->' + qbCopy);
        Question__c fisrtQuestion = [
          SELECT
            Id,
            Name,
            Reference_Field__c,
            Additional_Rich__c,
            Group__c,
            Is_Date_Backward__c,
            Date_Text__c,
            Time_Text__c,
            Is_Date_Forward__c,
            Is_Optional__c,
            Is_Title__c,
            Next_Question__c,
            Question_Text__c,
            Question_Parent__c,
            Question__c,
            Question_No__c,
            Tracking_ID__c,
            Question_Book__c,
            Size__c,
            Type__c,
            Record_Id__c,
            Error_Message__c,
            X24_Hours__c,
            Allowed_File_Extensions__c,
            RecordType.Name,
            RecordTypeId,
            QB_Reference__c,
            Title__c,
            Element_Mode__c,
            SubTitle__c,
            Sub_Text__c
          FROM Question__c
          WHERE Question_Book__c = :qb.Id AND Question_No__c = 1
          WITH SECURITY_ENFORCED
        ];

        if (
          fisrtQuestion != null &&
          fisrtQuestion.Type__c == 'Book' &&
          fisrtQuestion.QB_Reference__c == null
        ) {
          Question__c firstQuestionCopy = fisrtQuestion.clone(false, true);
          firstQuestionCopy.Question_Book__c = qbCopy.Id;
          firstQuestionCopy.Question_No__c = 1;
          insert firstQuestionCopy;
          System.debug('firstQuestionCopy--->' + firstQuestionCopy);

          bookUpdate.Id = qbCopy.Id;
          bookUpdate.Parent_Booklet_QB__c = bookletCopy.Id;
          bookUpdate.First_Question__c = firstQuestionCopy.Id;
          if (
            Question_Book__c.SObjectType.getDescribe().isUpdateable() &&
            Schema.sObjectType.Question_Book__c.fields.First_Question__c.isUpdateable()
          ) {
            update bookUpdate;
          }
          List<Question__c> relatedQs = [
            SELECT
              Id,
              Name,
              Reference_Field__c,
              Additional_Rich__c,
              Group__c,
              Is_Date_Backward__c,
              Date_Text__c,
              Time_Text__c,
              Is_Date_Forward__c,
              Is_Optional__c,
              Is_Title__c,
              Next_Question__c,
              Question_Text__c,
              Question_Parent__c,
              Question__c,
              Question_No__c,
              Tracking_ID__c,
              Question_Book__c,
              Size__c,
              Record_Id__c,
              Type__c,
              Error_Message__c,
              X24_Hours__c,
              Allowed_File_Extensions__c,
              RecordType.Name,
              RecordTypeId,
              Title__c,
              SubTitle__c,
              Element_Mode__c,
              Sub_Text__c,
              QB_Reference__c,
              (
                SELECT
                  Id,
                  Name,
                  Value__c,
                  Next_Question__c,
                  Tracking_ID__c,
                  Is_Default__c,
                  Order__c
                FROM Question_Options__r
                ORDER BY Order__c
              )
            FROM Question__c
            WHERE
              Question_Parent__c = :fisrtQuestion.Id
              AND Question_Book__c = :qb.Id
            WITH SECURITY_ENFORCED
          ];
          for (Question__c q : relatedQs) {
            Question__c qCopy = q.clone(false, true);
            qCopy.Question_Book__c = qbCopy.Id;
            qCopy.Question_Parent__c = firstQuestionCopy.Id;
            if (
              Question__c.SObjectType.getDescribe().isCreateable() &&
              Schema.sObjectType.Question__c.fields.Reference_Field__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Additional_Rich__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Group__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Is_Date_Backward__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Date_Text__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Time_Text__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Is_Date_Forward__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Is_Optional__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Is_Title__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Next_Question__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Question__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Tracking_ID__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Size__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Error_Message__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.X24_Hours__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Allowed_File_Extensions__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.RecordTypeId.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Title__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.SubTitle__c.isCreateable() &&
              Schema.sObjectType.Question__c.fields.Sub_Text__c.isCreateable()
            ) {
              insert qCopy;
              System.debug('qCopy--->' + qCopy);
            }
            if (q.Type__c == 'Dropdown' || q.Type__c == 'Radio') {
              List<Option__c> opsList = new List<Option__c>();
              for (Option__c ops : q.Question_Options__r) {
                Option__c op = ops.clone(false, true);
                op.Question__c = qCopy.Id;
                opsList.add(op);
              }
              if (opsList.size() > 0) {
                // Boolean iscreate = CrudPermision.checkCurd('Select Id, Name, Value__c, Next_Question__c, Tracking_ID__c, Order__c from Option__c',CrudPermision.CURDOpration.CREATE);
                // if(iscreate){
                //     system.debug('inside create');
                //     insert opsList;
                // }
                if (
                  Option__c.SObjectType.getDescribe().isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Value__c.isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Next_Question__c.isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Tracking_ID__c.isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Tracking_ID__c.isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Question__c.isCreateable() &&
                  Schema.sObjectType.Option__c.fields.Order__c.isCreateable()
                ) {
                  insert opsList;
                }
              }
            }
          }
        }
      }
      jsonGen.writeObjectField('questionBooks', bookUpdate);
    } catch (exception e) {
      System.debug('Inside the exception section ' + e.getMessage());
      jsonGen.writeObjectField('Exception', e.getMessage());
      jsonGen.writeObjectField('line number', e.getLineNumber());
      jsonGen.writeObjectField('Exception Type', e.getTypeName());
      jsonGen.writeObjectField(
        'Exception Stack Tracer',
        e.getStackTraceString()
      );
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  // removed unused method

  //SA - 21Dec23 - clonning all the questions of questions book
  public static string cloneQuestions(
    List<question__c> orginalQuestionList,
    Question_Book__c parentQuestionBook
  ) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    // Map to get qb reference questionBook
    //DN -27-dec-24 query update
    Map<id, Question_Book__c> questionBookMap = new Map<id, Question_Book__c>(
      [
        SELECT
          Id,
          Name,
          Unique_Identifier__c,
          Parent_Booklet_QB__c,
          Status__c,
          Title__c,
          isShengel__c,
          SubTitle__c,
          Last_Question__c,
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Edit__c,
          Possibilities__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          Progress_Bar__c,
          (
            SELECT
              Id,
              Name,
              Reference_Field__c,
              Unique_Identifier__c,
              Additional_Rich__c,
              Group__c,
              Is_Date_Backward__c,
              Date_Text__c,
              Time_Text__c,
              Is_Date_Forward__c,
              Is_Optional__c,
              Is_Title__c,
              Next_Question__c,
              Question_Text__c,
              Question_Parent__c,
              Question__c,
              Question_No__c,
              Tracking_ID__c,
              Question_Book__c,
              Size__c,
              Type__c,
              Error_Message__c,
              Record_Id__c,
              X24_Hours__c,
              Allowed_File_Extensions__c,
              RecordType.Name,
              RecordTypeId,
              Title__c,
              Element_Mode__c,
              SubTitle__c,
              Sub_Text__c,
              QB_Reference__c
            FROM Questions__r
          )
        FROM Question_Book__c
      ]
    );

    //All question Map
    Map<id, Question__c> originalQuestionMap = new Map<id, Question__c>(
      [
        SELECT
          Id,
          Name,
          Reference_Field__c,
          Additional_Rich__c,
          Unique_Identifier__c,
          Group__c,
          Is_Date_Backward__c,
          Date_Text__c,
          Time_Text__c,
          Is_Date_Forward__c,
          Is_Optional__c,
          Is_Title__c,
          Next_Question__c,
          Question_Text__c,
          Question_Parent__c,
          Question__c,
          Question_No__c,
          Tracking_ID__c,
          Question_Book__c,
          Size__c,
          Type__c,
          Error_Message__c,
          X24_Hours__c,
          Allowed_File_Extensions__c,
          RecordType.Name,
          RecordTypeId,
          Record_Id__c,
          Title__c,
          Element_Mode__c,
          SubTitle__c,
          Sub_Text__c,
          QB_Reference__c,
          (
            SELECT
              Id,
              Name,
              Unique_Identifier__c,
              Value__c,
              Next_Question__c,
              Tracking_ID__c,
              Is_Default__c,
              Order__c
            FROM Question_Options__r
            ORDER BY Order__c
          ),
          (
            SELECT
              Id,
              Name,
              api_name__c,
              Unique_Identifier__c,
              orderByFlag__c,
              childObjFldName__c,
              filterFlag__c,
              //VD23May25 removed unused field
              output_flag__c,
              isChild__c,
              filterValue__c,
              childObjName__c,
              label__c,
              filterCondition__c,
              filterLogic__c,
              resultantFlag__c,
              searchFlag__c,
              width_style__c,
              order__c,
              Question__c,
              fld_type__c,
              Question_Reference__c,
              read_only__c,
              db_name__c
            FROM Reference_Metas__r
          )
        FROM Question__c
      ]
    );

    Map<map<question_book__c, question_book__c>, Question__c> getParentQbReferenceQuestionMap = new Map<map<question_book__c, question_book__c>, Question__c>();
    Map<question_book__c, Question__c> getQbReferenceQuesMap = new Map<question_book__c, Question__c>();

    List<Question__c> copyQuestionsList = new List<Question__c>();
    List<Question__c> copyQuestionsListWithQbReference = new List<Question__c>();
    List<Question_Book__c> copyQuestionBooksList = new List<Question_Book__c>();
    List<question_book__c> duplicateCopyQuestionsListWithQbReference = new List<Question_Book__c>();

    for (Question__c ques : orginalQuestionList) {
      if (ques.QB_Reference__c == null) {
        Question__c qCopy = ques.clone(false, true);
        qCopy.Question_Book__c = parentQuestionBook.Id;
        qCopy.Time_Text__c = ques.id;
        copyQuestionsList.add(qCopy);
      } else {
        Question__c CurrentQuesCopy = ques.clone(false, true);
        CurrentQuesCopy.Question_Book__c = parentQuestionBook.Id;
        CurrentQuesCopy.Time_Text__c = ques.id;

        question_book__c qbReferenceQb = questionBookMap.get(
          ques.QB_Reference__c
        );
        question_book__c qbReferenceQbCopy = qbReferenceQb.clone(false, true);
        qbReferenceQbCopy.Cancel_Tracking_ID__c =
          qbReferenceQb.id +
          '&&@@' +
          CurrentQuesCopy.Time_Text__c;
        //CurrentQuesCopy.QB_Reference__c = qbReferenceQbCopy.id;
        getQbReferenceQuesMap.put(qbReferenceQbCopy, CurrentQuesCopy);
        //getParentQbReferenceQuestionMap.put();

        copyQuestionBooksList.add(qbReferenceQbCopy);
        copyQuestionsListWithQbReference.add(CurrentQuesCopy);
        // for(Question__c qbReferencQues : qbReferenceQb.Questions__r){
        //         Question__c qCopy = qbReferencQues.clone(false,true);
        //         qCopy.Question_Book__c = qbReferenceQbCopy.Id; // no ID
        //         copyQuestionsList.add(qCopy);
        //         Question__c quesWithOps  = questionsMap.get(qbReferencQues.id);
        //         if(qbReferencQues.Type__c == 'Dropdown' || qbReferencQues.Type__c == 'Radio' ) {
        //             for(Option__c ops: quesWithOps.Question_Options__r){
        //                 Option__c op = ops.clone(false,true);
        //                 op.Question__c = quesWithOps.Id; // no ID
        //                 copyOptionsList.add(op);
        //             }
        //         }
        //         if (quesWithOps.Reference_Metas__r.size() > 0) {
        //             for (Field_Meta__c fieldMetas : quesWithOps.Reference_Metas__r) {
        //                 Field_Meta__c fieldMeta = fieldMetas.clone(false,true);
        //                 fieldMeta.Question_Reference__c = quesWithOps.id; // no ID
        //                 fieldMeta.Question__c = CurrentQuesCopy.id; // no ID
        //                 copyFieldMetaList.add(fieldMeta);
        //             }
        //         }

        //    System.debug(qbReferencQues);
        // }
      }
    }

    if (
      Question_Book__c.SObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Parent_Booklet_QB__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Status__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Title__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.isShengel__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.SubTitle__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Last_Question__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Category__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Next__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Back__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Submit__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Cancel__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Edit__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Summary_Text__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Summary_Sub_Text__c.isCreateable() &&
      Schema.sObjectType.Question_Book__c.fields.Progress_Bar__c.isCreateable() &&
      copyQuestionBooksList.size() > 0
    ) {
      duplicateCopyQuestionsListWithQbReference = copyQuestionBooksList;
      jsonGen.writeObjectField(
        'qb reference question book',
        copyQuestionBooksList
      );
      insert copyQuestionBooksList;
    }
    if (
      Question__c.SObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.Question__c.fields.Reference_Field__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Additional_Rich__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Group__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Backward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Date_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Time_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Forward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Optional__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Next_Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Tracking_ID__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Size__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Error_Message__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.X24_Hours__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Allowed_File_Extensions__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.RecordTypeId.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.SubTitle__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Sub_Text__c.isCreateable() &&
      copyQuestionsList.size() > 0
    ) {
      jsonGen.writeObjectField(
        'copyQuestionsList root without QB',
        copyQuestionsList
      );
      insert copyQuestionsList;
      //cloneOptions(copyQuestionsList,originalQuestionMap);
    }
    if (
      Question__c.SObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.Question__c.fields.Reference_Field__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Additional_Rich__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Group__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Backward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Date_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Time_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Forward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Optional__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Next_Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Tracking_ID__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Size__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Error_Message__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.X24_Hours__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Allowed_File_Extensions__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.RecordTypeId.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.SubTitle__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Sub_Text__c.isCreateable() &&
      copyQuestionsListWithQbReference.size() > 0
    ) {
      jsonGen.writeObjectField(
        'ccopyQuestionsList root with QB',
        copyQuestionsListWithQbReference
      );
      insert copyQuestionsListWithQbReference;
      //cloneQbReferenceQuestionsBook();
      //return copyQuestionsList;
    }
    List<Question__c> qbReferenceQuestionList = new List<Question__c>();
    for (question_book__c copyQbReferenceQb : copyQuestionBooksList) {
      String[] qbReferenceQuesBookAndQuestionId = copyQbReferenceQb.Cancel_Tracking_ID__c.split(
        '&&@@'
      );
      // String questionBookId = idArray[0];
      // String questionId = idArray[1];

      for (
        Question__c qbReferenceQuestions : copyQuestionsListWithQbReference
      ) {
        if (
          qbReferenceQuestions.Time_Text__c ==
          qbReferenceQuesBookAndQuestionId[1]
        ) {
          qbReferenceQuestions.QB_Reference__c = copyQbReferenceQb.id;
        }
      }

      question_book__c orginalQbReferenceQuestionBook = questionBookMap.get(
        qbReferenceQuesBookAndQuestionId[0]
      );
      if (orginalQbReferenceQuestionBook.Questions__r.size() > 0) {
        for (Question__c ques : orginalQbReferenceQuestionBook.Questions__r) {
          Question__c qCopy = ques.clone(false, true);
          qCopy.Question_Book__c = copyQbReferenceQb.Id;
          qCopy.Time_Text__c = ques.id;
          qbReferenceQuestionList.add(qCopy);
        }
      }
    }

    if (
      Question__c.SObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.Question__c.fields.Reference_Field__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Additional_Rich__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Group__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Backward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Date_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Time_Text__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Date_Forward__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Optional__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Is_Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Next_Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Tracking_ID__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Size__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Error_Message__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.X24_Hours__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Allowed_File_Extensions__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.RecordTypeId.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Title__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.SubTitle__c.isCreateable() &&
      Schema.sObjectType.Question__c.fields.Sub_Text__c.isCreateable() &&
      qbReferenceQuestionList.size() > 0
    ) {
      jsonGen.writeObjectField(
        'qbReferenceQuestionList',
        qbReferenceQuestionList
      );
      insert qbReferenceQuestionList;
      update copyQuestionsListWithQbReference;
      //cloneQbReferenceQuestionsBook();
      //return copyQuestionsList;
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  //SA - 21Dec23 - clonning all the questions of questions book
  //     public static Question_Book__c cloneQbReferenceQuestionsBook(List<question__c> qbReferenceNotNullQuestionList,map<id,question__c> originalQuestionMap){

  //          List<Question_Book__c> copyQuestionBooksList = new List<Question_Book__c>();
  //          List<Question__c> qbReferenceQuestionList = new List<Question__c>();
  //          Question_Book__c qbReferenceQuestionBook = new Question_Book__c();
  //             // Map to get qb reference questionBook
  //             Map<id,Question_Book__c> questionBookMap = new Map<id,Question_Book__c>([select  Id, Name, Parent_Booklet_QB__c, Status__c, Title__c, isShengel__c, SubTitle__c,
  //             Last_Question__c,  Category__c, Total_Questions__c, Next__c, Back__c, Submit__c,
  //             Cancel__c, Edit__c, Possibilities__c, Summary_Text__c, Summary_Sub_Text__c, Progress_Bar__c,(select  Id, Name,Reference_Field__c, Additional_Rich__c, Group__c, Is_Date_Backward__c,
  //             Date_Text__c, Time_Text__c,Is_Date_Forward__c, Is_Optional__c, Is_Title__c, Next_Question__c, Question_Text__c,
  //             Question_Parent__c,Question__c, Question_No__c, Tracking_ID__c, Question_Book__c, Size__c, Type__c,
  //             Error_Message__c,X24_Hours__c, Allowed_File_Extensions__c, RecordType.Name, RecordTypeId,
  //             Title__c, SubTitle__c, Sub_Text__c,QB_Reference__c FROM Questions__r ) from Question_Book__c ]);

  //             for (question__c cloneQuesWithQBReference : qbReferenceNotNullQuestionList) {
  //                 question__c orginalQuestion = originalQuestionMap.get(cloneQuesWithQBReference.Time_Text__c);
  //                 qbReferenceQuestionBook = questionBookMap.get(orginalQuestion.QB_Reference__c);
  //                 qbReferenceQuestionList.add(qbReferenceQuestionBook.Questions__r);
  //                 Question_Book__c qbReferenceQuestionBookCopy = qbReferenceQuestionBook.clone(false,true);
  //                 copyQuestionBooksList.add(qbReferenceQuestionBookCopy);
  //             }

  //         if (Question_Book__c.SObjectType.getDescribe().isCreateable() &&

  //         Schema.sObjectType.Question_Book__c.fields.Parent_Booklet_QB__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Status__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Title__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.isShengel__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.SubTitle__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Last_Question__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Category__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Next__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Back__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Submit__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Cancel__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Edit__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Summary_Text__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Summary_Sub_Text__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Progress_Bar__c.isCreateable() )
  //         {
  //             insert copyQuestionBooksList;
  //             cloneQuestions(qbReferenceQuestionList,copyQuestionBooksList);
  //             return copyQuestionBooksList;
  //         }
  // }

  //SA - 21Dec23 - clonning options for the questions(Dropdown & Radio)
  public static void cloneOptions(
    List<question__c> cloneQuestionList,
    map<id, question__c> originalQuestionMap
  ) {
    List<Option__c> copyOptionsList = new List<Option__c>();
    for (question__c cloneques : cloneQuestionList) {
      question__c orginalQuestion = originalQuestionMap.get(
        cloneques.Time_Text__c
      );
      if (
        orginalQuestion.Type__c == 'Dropdown' ||
        orginalQuestion.Type__c == 'Radio'
      ) {
        // List<Option__c> opsList = new List<Option__c>();
        if (orginalQuestion.Question_Options__r.size() > 0) {
          for (Option__c ops : orginalQuestion.Question_Options__r) {
            Option__c op = ops.clone(false, true);
            op.Question__c = cloneques.Id; // no ID
            copyOptionsList.add(op);
          }
        }
      }
    }
    if (
      Option__c.SObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.Option__c.fields.Value__c.isCreateable() &&
      Schema.sObjectType.Option__c.fields.Next_Question__c.isCreateable() &&
      Schema.sObjectType.Option__c.fields.Tracking_ID__c.isCreateable() &&
      Schema.sObjectType.Option__c.fields.Tracking_ID__c.isCreateable() &&
      Schema.sObjectType.Option__c.fields.Question__c.isCreateable() &&
      Schema.sObjectType.Option__c.fields.Order__c.isCreateable() &&
      copyOptionsList.size() > 0
    ) {
      insert copyOptionsList;
    }
  }

  //SA - 21Dec23 - clonning all the questions of questions book
  //     public static Question_Book__c cloneFieldMeta(List<Field_Meta__c> fieldMetaList){
  //           List<Question__c> copyQuestionsList = new List<Question__c>();
  //           Question_Book__c qbCopy = orginalQuestionBook.clone(false,true);
  //         if (Question_Book__c.SObjectType.getDescribe().isCreateable() &&

  //         Schema.sObjectType.Question_Book__c.fields.Parent_Booklet_QB__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Status__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Title__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.isShengel__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.SubTitle__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Last_Question__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Category__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Next__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Back__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Submit__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Cancel__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Edit__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Possibilities__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Summary_Text__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Summary_Sub_Text__c.isCreateable() &&
  //         Schema.sObjectType.Question_Book__c.fields.Progress_Bar__c.isCreateable() )
  //         {
  //             insert qbCopy;
  //             return qbCopy;
  //         }
  // }
  //return schema of object
  @TestVisible
  private static Schema.DescribeSObjectResult getSchema(String objectName) {
    try {
      system.debug('objectName-->' + objectName);
      Schema.DescribeSObjectResult[] descResult = Schema.describeSObjects(
        new List<String>{ objectName }
      );
      system.debug('descResult-->' + descResult);
      if (descResult.size() > 0) {
        return descResult[0];
      } else {
        return null;
      }
    } catch (exception e) {
      System.debug(e);
      return null;
    }
  }

  @AuraEnabled
  public static string formBuilder(string inputId, string formData) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    List<Question__c> qList = new List<Question__c>();
    List<Question__c> questionList = new List<Question__c>(); //SA- 12Dec23 - To store all the question related to the book
    List<Question__c> questionsToDelete = new List<Question__c>(); //SA- 12Dec23 - To store the delete question list
    // VD 09NOV23 - list declared outside the try catch
    List<Question__c> bookquesList = new List<Question__c>();
    try {
      System.debug('inputId -->' + inputId);
      Map<String, Object> dataMap = (Map<String, Object>) JSON.deserializeUntyped(
        formData
      );
      List<Object> dataArray = (List<Object>) dataMap.get('data');
      set<Id> questionIdList = new Set<Id>();
      Question_Book__c qb = [
        SELECT
          Id,
          Name,
          (SELECT Id, Name FROM Questions__r WHERE Type__c != 'Book')
        FROM Question_Book__c
        WHERE Id = :inputId
        WITH SECURITY_ENFORCED
      ];
      questionList = qb.Questions__r; //SA- 12Dec23 - updating all the question related to the book
      // VD 23FEB24  getting the RecordType using map
      // VD 23FEB24 - processing  the uniqueIdentifier from the questions
      Map<String, Id> recordTypeIdMap = new Map<String, Id>();
      // VD 27-jan-25 record type directly get in singl line and removed here
      for (Object item : dataArray) {
        System.debug('inside loop' + item);
        Map<String, Object> questionData = (Map<String, Object>) item;
        List<Object> optionsList = (List<Object>) questionData.get('options');
        String key = (String) questionData.get('key');
        String elementId = (String) questionData.get('Id');
        String element = (String) questionData.get('element');
        String placeholder = (String) questionData.get('placeholder');
        String helpText = (String) questionData.get('helpText');
        Decimal elementNo = (Decimal) questionData.get('fieldNo');
        String label = (String) questionData.get('label');
        // VD 09NOV23 - added more fields
        String referenceField = (String) questionData.get('referenceField');
        String uniqueIdentifier = (String) questionData.get('uniqueIdentifier');
        String subText = (String) questionData.get('subText');
        String elementMode = (String) questionData.get('elementMode');
        Decimal size = (Decimal) questionData.get('size');
        Boolean isOptional = (Boolean) questionData.get('isOptional');
        Boolean isHide = (Boolean) questionData.get('isHide');
        Boolean readOnly = (Boolean) questionData.get('readOnly');
        string imgSrc = (String) questionData.get('imgSrc'); // SA- 11Dec23 - getting the Image Scr url
        //SA - getting the current question book questions
        questionIdList.add(elementId);
        System.debug('size sec -->' + size);
        if (element == 'Book') {
          System.debug('inside bookques start -->');
          Question__c bookques = new Question__c();
          bookques.Id = elementId;
          bookques.Question_Book__c = qb.Id;
          bookques.Question_No__c = elementNo;
          // VD 27-jan-25 record type directly
          bookques.recordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
            .get('UNCONDITIONAL')
            .getRecordTypeId();
          bookques.Question_Text__c = label;
          bookques.Type__c = element;
          if (
            Question__c.SObjectType.getDescribe().isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_Text__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_No__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Question_Book__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Question_Text__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Type__c.isUpdateable()
          ) {
            System.debug('inside bookques sec -->' + bookques);
            upsert bookques;
            bookquesList.add(bookques);
          }
          // update the first question
          if (bookquesList.size() > 0) {
            Question_Book__c quesBookUpdate = new Question_Book__c();
            quesBookUpdate.Id = qb.Id;
            quesBookUpdate.First_Question__c = bookquesList[0].Id;
            if (
              Question_Book__c.SObjectType.getDescribe().isUpdateable() &&
              Schema.sObjectType.Question_Book__c.fields.First_Question__c.isUpdateable()
            ) {
              update quesBookUpdate;
            }
            // VD 09NOV23 - add bookques too
            qList.add(bookquesList[0]);
          }
        } else {
          Question__c ques = new Question__c();
          ques.Id = elementId;
          ques.Question_Book__c = qb.Id;
          ques.Question_No__c = elementNo;
          ques.Question_Text__c = label;
          ques.Question__c = placeholder;
          ques.Help_Text__c = helpText;
          ques.Read_Only__c = readOnly;
          ques.Is_Hide__c = isHide;
          // VD 09NOV23 - added more fields
          ques.Reference_Field__c = referenceField;
          ques.Sub_Text__c = subText;
          ques.Element_Mode__c = elementMode;
          if (size != null) {
            ques.Size__c = size;
          } else {
            ques.Size__c = 12;
          }
          System.debug('size ques -->' + ques);
          //  ques.Is_Optional__c = isOptional;
          ques.Question_Parent__c = bookquesList[0].Id;
          ques.Type__c = element;
          // VD 27-jan-25 record type directly
          if (element == 'Dropdown') {
            ques.RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
              .get('OPTIONONLY')
              .getRecordTypeId();
          } else if (element == 'Checkbox' || element == 'Radio') {
            ques.RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
              .get('CONDITIONAL')
              .getRecordTypeId();
          } else {
            ques.RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
              .get('UNCONDITIONAL')
              .getRecordTypeId();
          }
          ques.Title__c = imgSrc;
          if (
            Question__c.SObjectType.getDescribe().isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_No__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_Book__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question_Text__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Reference_Field__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Sub_Text__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Size__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Type__c.isCreateable() &&
            Schema.sObjectType.Question__c.fields.Question__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Question_No__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Reference_Field__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Sub_Text__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Size__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Question_Book__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Question_Text__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Type__c.isUpdateable() &&
            Schema.sObjectType.Question__c.fields.Type__c.isUpdateable()
          ) {
            System.debug('ques insert above -->337' + ques);
            upsert ques;
          }
          // VD 23FEB24 - processing checkbox type
          // VD 23FEB24 - processing  the uniqueIdentifier from the options
          if (
            element == 'Dropdown' ||
            element == 'Radio' ||
            element == 'Checkbox'
          ) {
            List<Option__c> opsList = new List<Option__c>();
            Integer optionNo = 1;
            for (Object ops : optionsList) {
              Map<String, Object> optionData = (Map<String, Object>) ops;
              String opValue = (String) optionData.get('value');
              String optId = (String) optionData.get('Id');
              Option__c op = new Option__c();
              op.Question__c = ques.Id;
              op.Id = optId;
              op.Value__c = opValue;
              op.Order__c = optionNo;
              opsList.add(op);

              optionNo++;
            }
            if (opsList.size() > 0) {
              upsert opsList;
            }
          }
          qList.add(ques);
        }
      }
      //SA -12Dec23 - deleting the removed question from UI
      for (question__c ques : questionList) {
        if (!questionIdList.contains(ques.Id)) {
          questionsToDelete.add(ques);
        }
      }
      if (questionsToDelete.size() > 0) {
        delete questionsToDelete;
      }
      jsonGen.writeObjectField('questionsToDelete list', questionsToDelete);
      jsonGen.writeObjectField('question book all question list', questionList);
      jsonGen.writeObjectField('current question set id', questionIdList);
    } catch (exception e) {
      System.debug('Inside the exception section ' + e.getMessage());
    }
    jsonGen.writeObjectField('ques', qList);
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  // Removed unused method
}