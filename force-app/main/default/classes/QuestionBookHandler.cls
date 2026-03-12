public with sharing class QuestionBookHandler implements DataHandler {
  @testvisible
  private Boolean createAnswerBookFlag = false;
  @testvisible
  private Map<String, Object> paramMap = new Map<String, Object>();
  public QuestionBookHandler(Boolean answerFlag) {
    this.createAnswerBookFlag = answerFlag;
  }
  public QuestionBookHandler() {
  }
  // MR 22OCT23 - SetContext Changes
  public void setContext(String fieldName, Object fieldValue) {
    this.paramMap.put(fieldName, fieldValue);
    if (fieldName == 'createAnswerBookFlag') {
      this.createAnswerBookFlag = (Boolean) fieldValue;
    }
  }
  //getting the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }
  // VD 12Jun24 - translation changes
  //read the records of the user by passing the json input
  // RT 29MAY25 - Style for QB Builder
  // RT 10JUN25 - Width and Height added
  // RT 17JUN25 - Namespace Handling
  public String readRecords(String inputJSON, String languageCode) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    Id inpId = (Id) inputJSON;
    String ansId = inputJSON;
    String sObjName = inpId.getSObjectType().getDescribe().getName();
    jsonGen.writeStringField('objName', sObjName);

    Question_Book__c retQB = new Question_Book__c();
    Answer_Book__c retAB = new Answer_Book__c();
    Map<String, Object> styleMap = new Map<String, Object>();
    //VD 26Sep25 signPad changes
    Map<String, List<Map<String, Object>>> signatureMap = new Map<String, List<Map<String, Object>>>();
    String currentRecordId = '';
    // VD 22Jul25 Actions handling changes
    Map<Id, List<ActionWrapper>> questionBookActions = new Map<Id, List<ActionWrapper>>();
    String namespace = Utility.nameSpace();

    if (sObjName == namespace + 'Answer_Book__c') {
      // Input param is AnswerBook Id
      //VD -27-dec-24 query update
      retAB = [
        SELECT
          Id,
          Question_Book__c,
          Name,
          Status__c,
          RecordId__c,
          Answer_Long__c,
          (
            SELECT
              Id,
              Number__c,
              Answer_Book__c,
              Question_Rich_Text__c,
              Answer_Long__c,
              Question_Ref__c,
              Question_Type__c,
              recordId__c, // VD 08feb25 recordId added
              Question_Group_Text__c,
              Question_Text__c
            FROM Answers__r
          )
        FROM Answer_Book__c
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ][0];
      // MR 05FEB24
      List<AnswerWrapper> answers = new List<AnswerWrapper>();
      for (Answer__c aRec : retAB.Answers__r) {
        answers.add(AnswerWrapper.convert(aRec));
      }
      jsonGen.writeObjectField('answers', answers);
      retQB = [
        SELECT
          Id,
          Name,
          Parent_Booklet_QB__c, //AP 09DEC24 -added parent booklet field in the query
          Status__c,
          Title__c,
          isShengel__c,
          Version__c,
          Version_Status__c, //VD 20Jun25 version control changes
          SubTitle__c,
          First_Question__c,
          First_Question__r.Type__c,
          Last_Question__c,
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Api_Key__c, //AP 09DEC24 -added apikey field in the query
          Edit__c,
          Actions__c,
          Order__c,
          Possibilities__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          Progress_Bar__c,
          Next_Tracking_ID__c,
          Back_Tracking_ID__c,
          Cancel_Tracking_ID__c,
          Submit_Tracking_ID__c,
          Unique_Identifier__c,
          Query__c,
          Style__c, //SA- 2Dec23 - updated the field Style__c to get label alignment type from QB
          Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
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
              Is_Hide__c,
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Is_Rich_Text__c, // VD 29jun24 richText Support
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Value__c, // VD 29Jul25 default value handling
              Is_ReadJSONFromAttachment__c, // // VD 12Jun25 handle JSON from attachment
              Print_Mode__c,
              IsDeleteRowAction__c,
              Help_Text__c, //AP 09DEC24 -added help text field in the query
              Read_Only__c,
              Next_Question__c,
              Error_Message__c,
              X24_Hours__c,
              Allowed_File_Extensions__c,
              Question_Text__c,
              Question__c,
              Question_No__c,
              Question_Book__c,
              Question_Parent__c, //AP 09DEC24 -added parent qusetion field in the query
              Size__c,
              Type__c,
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              RecordType.Name,
              RecordTypeId,
              Tracking_ID__c,
              Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
              Maximum_Fraction_Digits__c,
              Currency_Code__c, // RT 06OCT25 - Currency Format
              Locale__c,
              Sno_Title__c,
              Enable_Signature_Drawing__c,
              Sign_URL_Reference__c,
              Sign_DateTime_Reference__c,
              Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
              Location_DateTime_Reference__c,
              Longitude_Reference__c,
              Latitude_Reference__c,
              Enable_Name_Signing__c,
              Enable_Default_Location__c,
              Date_Text__c,
              Time_Text__c,
              Record_Id__c,
              Question_Book__r.SubTitle__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Edit__c,
              Style__c, //SA- 2Dec23 - updated the field Style__c to get label alignment type from Question
              Is_Dependent__c
            FROM Questions__r
            ORDER BY Question_No__c
          )
        FROM Question_Book__c
        WHERE id = :retAB.Question_Book__c
        WITH SECURITY_ENFORCED
        LIMIT 1
      ][0];
    } else if (sObjName == namespace + 'Question_Book__c') {
      // MR 22OCT23 - Additional Fields
      // MR 20NOV23 Print Mode Changes
      // VD 22NOV23 Table Handling
      for (Question_Book__c qb : [
        SELECT
          Id,
          Name,
          Parent_Booklet_QB__c,
          Version__c,
          Version_Status__c, //VD 20Jun25 version control changes
          Status__c,
          Title__c,
          isShengel__c,
          SubTitle__c,
          First_Question__c,
          First_Question__r.Type__c,
          Last_Question__c,
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Api_Key__c,
          Cancel__c,
          Edit__c,
          Actions__c,
          Order__c,
          Possibilities__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          Progress_Bar__c,
          Next_Tracking_ID__c,
          Back_Tracking_ID__c,
          Cancel_Tracking_ID__c,
          Submit_Tracking_ID__c,
          Query__c,
          Unique_Identifier__c,
          Style__c, //SA- 2Dec23 - updated the field Style__c to get label alignment type from QB
          Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
          (SELECT Id, Name, API_Name__c, Value_Field__c, Question__c, Hidden__c, Source_Question_Id__c, Logics__c, Question_Book__c, Type__c FROM Inputs__r), // RT 31MAY25 - Name field added for querying , RT 14AUG25 - Value Field for Input JSON
          (
            SELECT Id, Name, Order__c, Style__c, IsActive__c, Event_to_Emit__c, Question_Book__r.Anchor_Object__c  // RT 08SEP25 - Anchor object added for field viisbility
            FROM Actions__r
            ORDER BY Order__c
          ), // MR 17MAY25 QB Builder
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
              Is_Hide__c,
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              Print_Mode__c,
              isSno__c,
              Is_Row_Draggable__c,
              Is_Rich_Text__c, // VD 29jun24 richText Support
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Value__c, // VD 29Jul25 default value handling
              Is_ReadJSONFromAttachment__c,
              IsDeleteRowAction__c,
              Help_Text__c,
              Read_Only__c,
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
              Record_Id__c,
              Type__c,
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              RecordType.Name,
              RecordTypeId,
              Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
              Maximum_Fraction_Digits__c,
              Currency_Code__c, // RT 06OCT25 - Currency Format
              Locale__c,
              Sno_Title__c, // RT 13OCT25 - Sno Title
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
              Question_Book__r.SubTitle__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Edit__c,
              Style__c, //SA- 2Dec23 - updated the field Style__c to get label alignment type from Question
              Is_Dependent__c
            FROM Questions__r
            ORDER BY Question_No__c
          ) // // VD 12Jun25 remved unwanted query
        FROM Question_Book__c
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]) {
        // jsonGen.writeObjectField('QB', qb);
        if (qb.Id != null) {
          retQB = qb;
        }
      }
      Set<Id> allQIds = new Set<Id>();
      if (
        retQB.Id != null &&
        retQB.Questions__r != null &&
        retQB.Questions__r.size() > 0
      ) {
        for (Question__c q : retQB.Questions__r) {
          allQIds.add(q.Id);
        }
      }
      // VD 22Jul25 Actions handling changes
      for (Actions__c action : [
        SELECT
          Id,
          Name,
          Event_to_Emit__c,
          Question_Book__r.Anchor_Object__c, // RT 08SEP25 - Anchor object retrieval for accessibility check
          IsActive__c,
          Question_Book__c,
          Order__c,
          (
            SELECT
              Id,
              Name,
              Label_Class__c,
              Label_Style__c,
              Input_Class__c,
              external_id__c, // missing field added
              Input_Style__c, Input_Align__c,
              showLabel__c,
              classHeadFoot__c,
              Sno_Data_Style__c,// RT 08OCT25 - Sno style handling
              Sno_Head_Style__c,
              headerSpaceStyle__c,
              footerSpaceStyle__c,
              isHead__c,
              isFoot__c,
              bookStyle__c,
              Label_Color__c,
              label_font_size__c,
              Field_Border_Color__c,
              Field_Input_Color__c,
              Field_Input_Size__c,
              Heading_Font_Color__c,
              Heading_Size__c,
              labelValueStyle__c,
              ElementStyle__c,
              CheckboxStyle__c,
              headingStyle__c,
              Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
              Style_Class__c,
              Button_Style_Class__c,
              Button_Style__c,
              width__c,
              height__c,
              Font__c,
              Stroke_Thickness__c,
              Pad_Color__c,
              Pen_Color__c
            FROM Styles__r
          )
        FROM Actions__c
        WHERE Question_Book__c = :inpId
        WITH SECURITY_ENFORCED
        ORDER BY Order__c ASC
      ]) {
        if (!questionBookActions.containsKey(action.Question_Book__c)) {
          questionBookActions.put(
            action.Question_Book__c,
            new List<ActionWrapper>()
          );
        }
        questionBookActions.get(action.Question_Book__c)
          .add(new ActionWrapper(action));
      }

      for (Style__c q : [
        SELECT
          Id,
          Name,
          Label_Class__c,
          Label_Style__c,
          Input_Class__c,
          Input_Style__c, 
          Input_Align__c,
          showLabel__c,
          classHeadFoot__c,
          Sno_Data_Style__c,// RT 08OCT25 - Sno style handling
          Sno_Head_Style__c,
          headerSpaceStyle__c,
          footerSpaceStyle__c,
          isHead__c,
          isFoot__c,
          bookStyle__c,
          Label_Color__c,
          label_font_size__c,
          Field_Border_Color__c,
          Field_Input_Color__c,
          Field_Input_Size__c,
          Heading_Font_Color__c,
          Heading_Size__c,
          labelValueStyle__c,
          ElementStyle__c,
          CheckboxStyle__c,
          headingStyle__c,
          external_id__c,
          Question__c,
          Size__c,
          Style_Class__c,
          Button_Style_Class__c,
          Button_Style__c,
          width__c,
          height__c,
          Font__c,
          Stroke_Thickness__c,
          Pad_Color__c,
          Pen_Color__c
        FROM Style__c
        WHERE Question__c IN :allQIds
      ]) {
        Map<String, Object> questionData = new Map<String, Object>();
        // questionData.put('Name', q.Name);
        List<StyleWrapper> stylesList = new List<StyleWrapper>();
        if (q != null) {
          stylesList.add(new StyleWrapper(q));
        }
        styleMap.put(q.Question__c, stylesList[0]);
      }

      // Apply styles to Questions
      // if (retQB.Questions__r != null) {
      //   for (Question__c styleQ : retQB.Questions__r) {
      //     if (styleQ.Id != null) {
      //   if (styleMap.containsKey(styleQ.Id)) {
      //     Map<String, Object> styleData = (Map<String, Object>) styleMap.get(styleQ.Id);
      //     if (styleData != null && styleData.containsKey('Styles')) {
      //       List<StyleWrapper> stylesList = (List<StyleWrapper>) styleData.get('Styles');
      //       if (stylesList != null && stylesList.size() > 0) {
      //     styleQ.Styles__r = stylesList[0].getStyle();
      //       }
      //     }
      //   }
      //     }
      //   }
      // }

      List<Input__c> inq = retQB.Inputs__r;
      if (inq != null && inq.size() > 0) {
        for (Input__c i : inq) {
          System.debug('inq::' + i);
        }
      }

      // MR 22OCT23 - Added Condition to avoid unnecessary record creation
      if (this.createAnswerBookFlag == true) {
        retAB.Question_Book__c = inpId;
        retAB.Status__c = 'Pending';
        SObjectAccessDecision createAcces = Security.stripInaccessible(
          AccessType.CREATABLE,
          new List<Answer_Book__c>{ retAB }
        );
        if (createAcces.getRecords().size() > 0) {
          if (
            Answer_Book__c.SObjectType.getDescribe().isCreateable() &&
            Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isCreateable() &&
            Schema.sObjectType.Answer_Book__c.fields.Status__c.isCreateable()
          ) {
            Database.insert(retAB);
          } else {
            // MR 30JAN24 - Testing
            jsonGen.writeStringField(
              'error',
              'No Access to create Answer_Book__c with Question Book and Status'
            );
          }
        } else {
          // MR 30JAN24 - Testing
          jsonGen.writeStringField(
            'error',
            'No Access to create Answer_Book__c'
          );
        }
      } else {
        // MR 30JAN24 - Testing
        jsonGen.writeStringField(
          'error',
          'createAnswerBookFlag is ' + createAnswerBookFlag + ' and ' + inpId
        );
      }
    } else {
      //invalid id
    }
    // Process the Query for reading the data from DB
    if (String.isNotBlank(retQB.Query__c)) {
      // MR 29NOV23 Process the input params
      String qStr = retQB.Query__c;
      for (Input__c inp : retQB.Inputs__r) {
        if (
          inp.Type__c == 'String' && this.paramMap.containsKey(inp.API_Name__c)
        ) {
          currentRecordId = (String) this.paramMap.get(inp.API_Name__c);
          qStr = qStr.replace(
            '{' + inp.API_Name__c + '}',
            '\'' + (String) this.paramMap.get(inp.API_Name__c) + '\''
          );
        }
      }
      retQB.Query__c = qStr;
      try {
        List<SObject> lstResult = database.query(qStr);
        jsonGen.writeObjectField('qbQueryResult', lstResult);
      } catch (Exception e) {
        jsonGen.writeObjectField('qbQueryResult', new List<SObject>());
        jsonGen.writeStringField('exception', e.getMessage());
        jsonGen.writeObjectField('line number', e.getLineNumber());
        jsonGen.writeStringField('stackTrace', e.getStackTraceString());
      }
    } else {
      jsonGen.writeObjectField('qbQueryResult', new List<SObject>());
    }
// VD 26Sep25 signPad changes
    if (retQB.Id != null) {
      // Collect all Unique Identifiers from Questions
      Set<String> allUniqueIds = new Set<String>();
      if (retQB.Questions__r != null) {
          for (Question__c q : retQB.Questions__r) {
              if (String.isNotBlank(q.Unique_Identifier__c)) {
                  allUniqueIds.add(q.Unique_Identifier__c);
              }
          }
      }
  
      if (!allUniqueIds.isEmpty() && currentRecordId != null) {
          // Fetch Content linked to this QB parent
          List<ContentDocumentLink> links = [
              SELECT ContentDocumentId, LinkedEntityId,
                     ContentDocument.Title,
                     ContentDocument.LatestPublishedVersionId
              FROM ContentDocumentLink
              WHERE LinkedEntityId = :currentRecordId
              ORDER BY ContentDocument.CreatedDate DESC
          ];
  
          // Fetch all ContentVersions in one go
          Set<Id> versionIds = new Set<Id>();
          for (ContentDocumentLink cdl : links) {
              versionIds.add(cdl.ContentDocument.LatestPublishedVersionId);
          }
  
          Map<Id, ContentVersion> cvMap = new Map<Id, ContentVersion>(
              [SELECT Id, Title, VersionData, ContentDocumentId
               FROM ContentVersion
               WHERE Id IN :versionIds]
          );
  
          for (ContentDocumentLink cdl : links) {
              String fileName = cdl.ContentDocument.Title;
              String qId;
              String withoutPrefix = fileName.substringAfter('Signature_'); 
              String withoutExt = withoutPrefix.endsWith('.png') 
                  ? withoutPrefix.substring(0, withoutPrefix.length() - 4) 
                  : withoutPrefix;
              
              // Now split into parts: [vijay, QB-03794-Q-3e193464-636a-4d16-b297-13bbda2da572]
              List<String> parts = withoutExt.split('_');
              if (parts.size() > 1) {
                  qId = parts[1];  // ✅ your unique Id
              }
              // if (fileName != null && fileName.startsWith('Signature_')) {
              //     qId = fileName.substringAfter('Signature_').substringBefore('.');
              // }
  
              if (String.isNotBlank(qId) && allUniqueIds.contains(qId)) {
                  if (!signatureMap.containsKey(qId)) {
                      signatureMap.put(qId, new List<Map<String, Object>>());
                  }
  
                  ContentVersion cv = cvMap.get(cdl.ContentDocument.LatestPublishedVersionId);
  
                  Map<String, Object> fileData = new Map<String, Object>();
                  fileData.put('fileId', cdl.ContentDocumentId);
                  fileData.put('fileName', cv.Title);
                  fileData.put('base64', EncodingUtil.base64Encode(cv.VersionData));
  
                  signatureMap.get(qId).add(fileData);
              }
          }
      }
  }

    QuestionBookWrapper wrapper = new QuestionBookWrapper(retQB);
    // VD 22Jul25 Actions handling changes
    if (questionBookActions.containsKey(inpId)) {
      wrapper.actions = questionBookActions.get(inpId);
    }
    AnswerBookwrapper wraper = new AnswerBookwrapper(retAB);
    jsonGen.writeObjectField('questionbook', wrapper);
    jsonGen.writeObjectField('answerbook', wraper);

    // Process the Dropdown Options - MR - 22OCT23
    Map<Id, Object> sqOptMap = new Map<Id, Object>();
    if (retQB.Questions__r != null && retQB.Questions__r.size() > 0) {
      Set<Id> qoIds = new Set<Id>();
      Set<Id> allqIds = new Set<Id>();
      for (Question__c qo : retQB.Questions__r) {
        // VD 29Jul25 options handling changes
        if (
          qo.Type__c == 'Dropdown' ||
          qo.Type__c == 'Radio' ||
          qo.Type__c == 'Checkbox'
        ) {
          qoIds.add(qo.Id);
        }
        allqIds.add(qo.Id);
      }
      if (qoIds.size() > 0) {
        for (Question__c q : [
          SELECT
            Id,
            Name,
            (
              SELECT
                Id,
                Name,
                Value__c,
                order__c,
                Unique_Identifier__c,
                Question__c,
                Is_Default__c,
                Next_Question__c
              FROM Question_Options__r
              ORDER BY Order__c
            )
          FROM Question__c
          WHERE Id IN :qoIds
          WITH SECURITY_ENFORCED
        ]) {
          // Transform the Question__c object
          //AP 09DEC24 -connect the option wrapper in qusetion book handler class
          Map<String, Object> questionData = new Map<String, Object>();
          questionData.put('Id', q.Id);
          questionData.put('Name', q.Name);
          List<OptionWrapper> optionsList = new List<OptionWrapper>();
          if (q.Question_Options__r != null) {
            for (Option__c opt : q.Question_Options__r) {
              optionsList.add(new OptionWrapper(opt));
            }
          }
          // VD 29Jul25 options handling changes
          questionData.put('options', optionsList);
          sqOptMap.put(q.Id, questionData);
        }
      }
    }
    jsonGen.writeObjectField('sqOptions', sqOptMap);
    jsonGen.writeObjectField('styleMap', styleMap);
    // VD 26Sep25 signPad changes
    jsonGen.writeObjectField('signatures', signatureMap);
    System.debug('QuestionBookHandler.readRecords() - styleMap: ' + styleMap);
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  //creation of records by passing the json as a parameter
  public String createRecords(String inputJSON) {
    return '{"status":"failure","message":"Create operation is not supported"}';
  }
  //updating records of the user who have already exists by passing the json as a parameter
  public String updateRecords(String inputJSON) {
    return '{"status":"failure","message":"Update operation is not supported"}';
  }
  //deleting records of the user who have already exists, by passing the json as a parameter
  public String deleteRecords(String inputJSON) {
    return '{"status":"failure","message":"Delete operation is not supported"}';
  }
}