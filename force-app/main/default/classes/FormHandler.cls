public without sharing class FormHandler implements DataHandler {
  @testvisible
  private String contactId = '';
  // VD 24jun25 Form ID Changes (in place of QB Id)
  @testvisible
  private Boolean createAnswerBookFlag = false;
  @testvisible
  private Map<String, Object> paramMap = new Map<String, Object>();
  //constructor with one parameter to set the contact id
  public FormHandler(String contact) {
    this.contactId = contact;
  }
  public FormHandler() {
  }

  // MR 22OCT23 - SetContext Changes
  public void setContext(String field, Object value) {
    // VD 24jun25 Form ID Changes (in place of QB Id)
    this.paramMap.put(field, value);
    if (field == 'contactId') {
      this.contactId = (String) value;
    }
    // VD 24jun25 Form ID Changes (in place of QB Id)
    if (field == 'createAnswerBookFlag') {
      this.createAnswerBookFlag = (Boolean) value;
    }
  }

  //getting the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }
  // 12Jun24 - translation changes
  //read the records of the user by passing the json input
  // RT 17JUN25 - Namespace Handling
  // RT 08SEP25 - anchor object added for accessibility check 
  public String readRecords(String inputJSON, String languageCode) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject(); // Start main JSON Object

    String ansId = inputJSON;

    // MR 18MAY25 QB Editor Changes to accept Form Id and QB Id
    // RT 26MAY25 - Style Key Added
    // RT 29MAY25 - Label Class, Label Style, Input Class, Input Style replaced
    Id inpId = (Id) inputJSON;
    String sObjName = inpId.getSObjectType().getDescribe().getName();
    // 11Jun24 - translation changes
    String language = languageCode;

    // Initialize the wrapper class to store the response
    Question_Book__c retQB = new Question_Book__c();
    list<Answer_Book__c> retABList = new List<Answer_Book__c>();
    Answer_Book__c retAB = new Answer_Book__c();
    Map<Id, QuestionWrapper> bookQuestionsMap = new Map<Id, QuestionWrapper>();
    Map<Id, QuestionBookWrapper> qbMap = new Map<Id, QuestionBookWrapper>();
    Map<Id, QuestionWrapper> sqOptMap = new Map<Id, QuestionWrapper>();
    map<Id, QuestionWrapper> qMap = new Map<Id, QuestionWrapper>();
    Map<Id, List<TranslationWrapper>> translationMap = new Map<Id, List<TranslationWrapper>>();
    Map<Id, List<Actions__c>> sectionActions = new Map<Id, List<Actions__c>>();
    String namespace = Utility.nameSpace();

    jsonGen.writeFieldName('form');
    jsonGen.writeStartObject(); // Start form object

    // MR 18MAY25 QB Editor Changes to accept Form Id and QB Id
    Form__c form = new Form__c();
    if (sObjName == namespace + 'Question_Book__c') {
      // Fetch the QuestionBook
      Question_Book__c qb = [
        SELECT Id, Name
        FROM Question_Book__c
        WHERE Id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      form.Name = 'dummy';
      form.Type__c = 'QuestionBook';
      // VD 29may25  removed default anchor object
      form.Anchor_Object__c = '';
      form.Question_Book__c = qb.Id;
      jsonGen.writeStringField('id', qb.Id);
    } else {
      // Fetch the form
      form = [
        SELECT Id, Name, Type__c, Anchor_Object__c, Question_Book__c
        FROM Form__c
        WHERE Id = :inputJSON
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      jsonGen.writeStringField('id', form.Id);
    }

    FormWrapper formWrapper = new FormWrapper(form);
    jsonGen.writeStringField('name', form.Name);
    if (form.Anchor_Object__c != null) {
      jsonGen.writeStringField('anchorObj', form.Anchor_Object__c);
    }
    // MR 16MAY25 QB Builder Changes
    // VD 22Jul25 SPA handling changes
    if (form.Type__c == 'QuestionBook' || form.Type__c == 'SPA') {
      formWrapper.qbId = form.Question_Book__c;
      // Return QBWrapper
      QuestionBookHandler qh = new QuestionBookHandler();
      // VD 24jun25 Form ID Changes (in place of QB Id)
      if (this.paramMap.containsKey('c__record_id')) {
        qh.setContext('c__record_id', this.paramMap.get('c__record_id'));
      }
      if (this.createAnswerBookFlag != null) {
        qh.setContext('createAnswerBookFlag', this.createAnswerBookFlag);
      }
      formWrapper.qhResponse = qh.readRecords(form.Question_Book__c, '');

      // MR 17MAY25 updating the wrapper with question actions, styles and reference questions
      FormWrapper qbfw = QuestionBookService.getQuestions(
        retQB.Id,
        languageCode
      );
      formWrapper.qbMap = qbfw.qbMap;
      formWrapper.oMap = qbfw.oMap;
      formWrapper.qMap = qbfw.qMap;
      formWrapper.tMap = qbfw.tMap;
    } else if (form.Type__c == 'Form') {
      // Fetch actions related to Form
      List<Actions__c> formActions = [
        SELECT Id, Name, Event_to_Emit__c, Question_Book__r.Anchor_Object__c, IsActive__c, Order__c, Style__c
        FROM Actions__c
        WHERE Form__c = :inputJSON
        WITH SECURITY_ENFORCED
        ORDER BY Order__c ASC
      ];
      formWrapper.actions = ActionWrapper.createList(formActions);
      // Fetch booklets related to the form
      List<Question_Book__c> retBookLets = [
        SELECT Id, Name, Form__c, Order__c
        FROM Question_Book__c
        WHERE Id = :form.Question_Book__c AND Category__c = 'Booklet'
        WITH SECURITY_ENFORCED
        ORDER BY Order__c ASC
      ];
      jsonGen.writeFieldName('pages');
      jsonGen.writeStartArray();
      // Fetch actions related to Question Books
      Map<Id, List<ActionWrapper>> questionBookActions = new Map<Id, List<ActionWrapper>>();
      for (Actions__c action : [
        SELECT
          Id,
          Name,
          Event_to_Emit__c,
          Question_Book__r.Anchor_Object__c,
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
              Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
              Font__c,  // VD 10-Oct25 added missing stlye fields
              Pad_Color__c,
              Pen_Color__c,
              Stroke_Thickness__c,
              Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
              Style_Class__c,
              Button_Style_Class__c,
              Button_Style__c,
              width__c,
              height__c
            FROM Styles__r
          )
        FROM Actions__c
        WHERE Question_Book__c IN :retBookLets
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
      for (Question_Book__c qbr : retBookLets) {
        jsonGen.writeStartObject();
        ResponseWrapper responseWrapper = new ResponseWrapper();
        List<QuestionBookWrapper> booklet = new List<QuestionBookWrapper>();
        // Assign actions for the current booklet
        if (questionBookActions.containsKey(qbr.Id)) {
          ResponseWrapper.actions = questionBookActions.get(qbr.Id);
        }
        // Step 1: Query the Question_Book__c records
        Set<Id> questionBookIds = new Set<Id>();
        for (Question_Book__c qb : [
          SELECT Id, First_Question__c
          FROM Question_Book__c
          WHERE Parent_Booklet_QB__c = :qbr.Id
        ]) {
          questionBookIds.add(qb.Id);
          questionBookIds.add(qb.First_Question__c);
        }
        // VD 20Jan24 - translation changes
        // Fetch related translations

        // Read all QB related to the booklet
        // Get all First Questions
        Set<Id> firstQIds = new Set<Id>();
        list<Question_Book__c> retQB1 = new List<Question_Book__c>();
        retQB1 = [
          SELECT Id, Name, Parent_Booklet_QB__c
          FROM Question_Book__c
          WHERE Parent_Booklet_QB__c = :qbr.Id
          WITH SECURITY_ENFORCED
        ];
        // MR 20NOV23 Print Mode Changes
        // MR 18DEC23 Including Style on the response

        // VD 25Feb24 -added Unique Identifer field in the query
        //AP 09DEC24 -added action field in the query
        if (retQB1.size() > 0) {
          // Actions2/19May25/Thangarasu-Get the QB in a list
          List<Question_Book__c> qbList = [
            SELECT
              Id,
              Name,
              Parent_Booklet_QB__c,
              Status__c,
              Title__c,
              isShengel__c,
              SubTitle__c,
              First_Question__c,
              Last_Question__c,
              Category__c,
              Version__c,
              Version_Status__c, //VD 20Jun25 removed boolean and created picklist
              Total_Questions__c,
              Query__c,
              Unique_Identifier__c,
              Api_Key__c,
              Actions__c,
              Order__c, // // VD 28Mar25 page order handling
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Edit__c,
              Possibilities__c,
              Summary_Text__c,
              Summary_Sub_Text__c,
              Progress_Bar__c,
              Style__c,
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
                  Read_Only__c,
                  Is_Hide__c,
                  IsAddRowAction__c,
                  IsDeleteRowAction__c,
                  isSno__c,
                  Is_Row_Draggable__c,
                  Value__c, // VD 29jul defaul value handling
                  Is_Rich_Text__c, // VD 29jun24 richText Support
                  Date_Format__c, // RT 19SEP25 - Date Format
                  Input_JSON__c,
                  Is_Serial_No__c,
                  Is_ReadJSONFromAttachment__c,
                  Help_Text__c,
                  Next_Question__c,
                  Error_Message__c,
                  X24_Hours__c,
                  Allowed_File_Extensions__c,
                  Question_Text__c,
                  Question__c,
                  Question_No__c,
                  Question_Book__c,
                  Size__c,
                  Type__c,
                  Question_Parent__c,
                  Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
                  Maximum_Fraction_Digits__c,
                  Currency_Code__c, // RT 06OCT25 - Currency Format
                  Locale__c,
                  Sno_Title__c, // RT 13OCT25 - S.no Title
                  Enable_Signature_Drawing__c, //VD 26Sep25 signPad changes
                  Sign_URL_Reference__c,
                  Sign_DateTime_Reference__c,
                  Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
                  Location_DateTime_Reference__c,
                  Longitude_Reference__c,
                  Latitude_Reference__c,
                  Enable_Name_Signing__c,
                  Enable_Default_Location__c,
                  Sub_Text__c,
                  Element_Mode__c,
                  Fields_Meta__c,
                  RecordType.Name,
                  RecordTypeId,
                  Record_Id__c,
                  Tracking_ID__c,
                  Date_Text__c,
                  Time_Text__c,
                  Question_Book__r.SubTitle__c,
                  QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                  QB_Reference__c,
                  QB_Reference_Questions__c,
                  Style__c,
                  Is_Dependent__c
                FROM Questions__r
                WHERE Type__c = 'Book' AND Question_No__c = 1
              ),
              (
                SELECT
                  Id,
                  Name,
                  Order__c,
                  Style__c,
                  IsActive__c,
                  Event_to_Emit__c,
                  Question_Book__r.Anchor_Object__c
                FROM Actions__r
                ORDER BY Order__c
              ) // Actions/23Apr25/Thangarasu- Add Actions in the query
            FROM Question_Book__c
            WHERE Parent_Booklet_QB__c = :qbr.Id
            WITH SECURITY_ENFORCED
          ];

          // Actions2/19May25/Thangarasu-Get related Styles for every Actions
          Set<Id> actionIds = new Set<Id>();
          for (Question_Book__c qb : qbList) {
            if (qb.Actions__r != null && !qb.Actions__r.isEmpty()) {
              for (Actions__c action : qb.Actions__r) {
                actionIds.add(action.Id);
              }
            }
          }
          Map<Id, List<ActionWrapper>> secActionsWithStyles = new Map<Id, List<ActionWrapper>>();
          for (Actions__c action : [
            SELECT
              Id,
              Name,
              Event_to_Emit__c,
              IsActive__c,
              Question_Book__r.Anchor_Object__c,
              Question_Book__c,
              Order__c,
              (
                SELECT
                  Id,
                  Name,
                  Label_Class__c,
                  Label_Style__c,
                  external_id__c, // missing field added
                  Input_Class__c,
                  Input_Style__c, Input_Align__c,
                  showLabel__c,
                  classHeadFoot__c,
                  Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                  Font__c,
                  Pad_Color__c,
                  Pen_Color__c,
                  Stroke_Thickness__c,
                  Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                  Style_Class__c,
                  Button_Style_Class__c,
                  Button_Style__c,
                  width__c,
                  height__c
                FROM Styles__r
              )
            FROM Actions__c
            WHERE Id IN :actionIds
            WITH SECURITY_ENFORCED
            ORDER BY Order__c ASC
          ]) {
            if (!secActionsWithStyles.containsKey(action.Question_Book__c)) {
              secActionsWithStyles.put(
                action.Question_Book__c,
                new List<ActionWrapper>()
              );
            }
            secActionsWithStyles.get(action.Question_Book__c)
              .add(new ActionWrapper(action));
          }

          for (Question_Book__c qb : qbList) {
            QuestionBookWrapper bookWrapper = new QuestionBookWrapper(qb);
            bookWrapper.actions = secActionsWithStyles.get(qb.Id); // Actions2/19May25/Thangarasu-to update secAction with styles
            booklet.add(bookWrapper);
            firstQIds.add(qb.First_Question__c);
            System.debug(questionBookActions);
            qbMap.put(qb.Id, new QuestionBookWrapper(qb));
          }
        } else {
          for (Question_Book__c qb : [
            SELECT
              Id,
              Name,
              Parent_Booklet_QB__c,
              Unique_Identifier__c,
              Status__c,
              Title__c,
              isShengel__c,
              SubTitle__c,
              Query__c,
              First_Question__c,
              Last_Question__c,
              Category__c,
              Version__c,
              Version_Status__c, //VD 20Jun25 removed boolean and created picklist
              Total_Questions__c,
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Api_Key__c,
              Actions__c,
              Order__c,
              Edit__c,
              Possibilities__c,
              Summary_Text__c,
              Summary_Sub_Text__c,
              Progress_Bar__c,
              Style__c,
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
                  Read_Only__c,
                  Is_Hide__c,
                  IsAddRowAction__c,
                  IsDeleteRowAction__c,
                  isSno__c,
                  Is_Row_Draggable__c,
                  Value__c,
                  Is_Rich_Text__c,
                  Date_Format__c, // RT 19SEP25 - Date Format
                  Input_JSON__c,
                  Is_Serial_No__c,
                  Is_ReadJSONFromAttachment__c,
                  Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
                  Maximum_Fraction_Digits__c,
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
                  Help_Text__c,
                  Next_Question__c,
                  Error_Message__c,
                  X24_Hours__c,
                  Allowed_File_Extensions__c,
                  Question_Text__c,
                  Question__c,
                  Question_No__c,
                  Question_Book__c,
                  Size__c,
                  Type__c,
                  Question_Parent__c,
                  Sub_Text__c,
                  Element_Mode__c,
                  Fields_Meta__c,
                  RecordType.Name,
                  RecordTypeId,
                  Record_Id__c,
                  Tracking_ID__c,
                  Date_Text__c,
                  Time_Text__c,
                  Question_Book__r.SubTitle__c,
                  QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                  QB_Reference__c,
                  QB_Reference_Questions__c,
                  Style__c,
                  Is_Dependent__c
                FROM Questions__r
                WHERE Type__c = 'Book' AND Question_No__c = 1
              )
            FROM Question_Book__c
            WHERE id = :qbr.Id
            WITH SECURITY_ENFORCED
          ]) {
            QuestionBookWrapper bookWrapper = new QuestionBookWrapper(qb);
            booklet.add(bookWrapper);
            firstQIds.add(qb.First_Question__c);
            System.debug(questionBookActions);
            qbMap.put(qb.Id, new QuestionBookWrapper(qb));
          }
        }

        // MR - 13AUG23 - START
        // Get the Questions & its related options
        Set<Id> qoIds = new Set<Id>();
        Set<Id> qIds = new Set<Id>();
        for (Question__c q : [
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
            Is_Hide__c,
            IsAddRowAction__c,
            IsDeleteRowAction__c,
            isSno__c,
            Is_Row_Draggable__c,
            Value__c,
            Is_Rich_Text__c,
            Date_Format__c, // RT 19SEP25 - Date Format
            Input_JSON__c,
            Is_Serial_No__c,
            Is_ReadJSONFromAttachment__c,
            Minimum_Fraction_Digits__c, // VD builder loading fix
            Maximum_Fraction_Digits__c, // VD builder loading fix
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
            Help_Text__c,
            Next_Question__c,
            Error_Message__c,
            X24_Hours__c,
            Allowed_File_Extensions__c,
            Question_Text__c,
            Question__c,
            Question_No__c,
            Question_Book__c,
            Size__c,
            Type__c,
            Question_Parent__c,
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
            QB_Reference__c,
            QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
            QB_Reference_Questions__c,
            Style__c,
            Is_Dependent__c,
            (
              SELECT
                Id,
                Name,
                Value__c,
                Unique_Identifier__c,
                Next_Question__c,
                Question__c,
                Order__c,
                Is_Default__c,
                Tracking_ID__c
              FROM Question_Options__r
              ORDER BY Order__c
            ),
            (
              SELECT Id, Name, Order__c, Style__c, IsActive__c, Event_to_Emit__c, Question_Book__r.Anchor_Object__c
              FROM Actions__r
              ORDER BY Order__c
            ),
            (
              SELECT
                Id,
                Name,
                Label_Class__c,
                Label_Style__c,
                Input_Class__c,
                Input_Style__c, Input_Align__c,
                showLabel__c,
                classHeadFoot__c,
                Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                Font__c,
                Pad_Color__c,
                Pen_Color__c,
                Stroke_Thickness__c,
                Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                Style_Class__c,
                Button_Style_Class__c,
                Button_Style__c,
                width__c,
                height__c
              FROM Styles__r
            ),
            (
              SELECT
                Id,
                Name,
                Group__c,
                Sub_Text__c,
                Element_Mode__c,
                Fields_Meta__c,
                Reference_Field__c,
                Additional_Rich__c,
                Unique_Identifier__c,
                Is_Date_Backward__c,
                Date_Text__c,
                Time_Text__c,
                Title__c,
                Read_Only__c,
                Is_Hide__c,
                IsAddRowAction__c,
                IsDeleteRowAction__c,
                isSno__c,
                Is_Row_Draggable__c,
                Value__c,
                Is_Rich_Text__c,
                Date_Format__c, // RT 19SEP25 - Date Format
                Input_JSON__c,
                Is_Serial_No__c,
                Is_ReadJSONFromAttachment__c,
                Help_Text__c,
                SubTitle__c,
                Is_Date_Forward__c,
                Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
                Maximum_Fraction_Digits__c,
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
                Is_Optional__c,
                Is_Title__c,
                Next_Question__c,
                Error_Message__c,
                X24_Hours__c,
                Allowed_File_Extensions__c,
                Question_Text__c,
                Question__c,
                Question_No__c,
                Tracking_ID__c,
                Question_Book__c,
                Size__c,
                Record_Id__c,
                RecordType.Name,
                RecordTypeId,
                Type__c,
                Question_Parent__c,
                Question_Book__r.SubTitle__c,
                QB_Reference__c,
                QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                QB_Reference_Questions__c,
                Style__c,
                Is_Dependent__c
              FROM Questions__r
              ORDER BY Question_No__c
            )
          FROM Question__c
          WHERE Id IN :firstQIds
          WITH SECURITY_ENFORCED
        ]) {
          bookQuestionsMap.put(q.Question_Book__c, new QuestionWrapper(q));
          // 11Jun24 - translation changes
          // VD 20Jan24 - translation changes
          List<Translation__c> translation = new List<Translation__c>();
          List<object> translatedText = new List<object>();
          if (language == 'All') {
            translation = [
              SELECT Unique_Identifier__c, Language__c, Translated_Text__c
              FROM Translation__c
              WHERE Question_Book__c = :q.Question_Book__c
            ];
          } else {
            translation = [
              SELECT Unique_Identifier__c, Language__c, Translated_Text__c
              FROM Translation__c
              WHERE
                Question_Book__c = :q.Question_Book__c
                AND Language__c = :language
            ];
          }

          if (translation.size() > 0) {
            List<TranslationWrapper> wrappedTranslations = new List<TranslationWrapper>();
            for (Translation__c tr : translation) {
              if (tr.Translated_Text__c != null) {
                wrappedTranslations.add(new TranslationWrapper(tr));
              }
            }
            if (wrappedTranslations.size() > 0) {
              translationMap.put(q.Question_Book__c, wrappedTranslations);
            }
          }

          if (q.Questions__r.size() > 0) {
            // Get all question options
            for (Question__c qo : q.Questions__r) {
              // get all question Ids
              qIds.add(qo.Id);
              if (
                qo.Type__c == 'Dropdown' ||
                qo.Type__c == 'Radio' ||
                qo.Type__c == 'Checkbox'
              ) {
                qoIds.add(qo.Id);
              }
            }
          }
        }

        if (qoIds.size() > 0) {
          // Read all the question with options
          for (Question__c q : [
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
              Read_Only__c,
              Is_Hide__c,
              IsAddRowAction__c,
              IsDeleteRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Value__c,
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
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Help_Text__c,
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
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              Question_Book__r.SubTitle__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Style__c,
              Is_Dependent__c,
              (
                SELECT
                  Id,
                  Name,
                  Order__c,
                  Style__c,
                  IsActive__c,
                  Question_Book__r.Anchor_Object__c,
                  Event_to_Emit__c
                FROM Actions__r
                ORDER BY Order__c
              ),
              (
                SELECT
                  Id,
                  Name,
                  Label_Class__c,
                  Label_Style__c,
                  Input_Class__c,
                  Input_Style__c, Input_Align__c,
                  showLabel__c,
                  classHeadFoot__c,
                  Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                  Font__c,
                  Pad_Color__c,
                  Pen_Color__c,
                  Stroke_Thickness__c,
                  Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                  Style_Class__c,
                  Button_Style_Class__c,
                  Button_Style__c,
                  width__c,
                  height__c
                FROM Styles__r
              ),
              (
                SELECT
                  Id,
                  Name,
                  Value__c,
                  Unique_Identifier__c,
                  Next_Question__c,
                  Tracking_ID__c,
                  Order__c,
                  Is_Default__c,
                  Question__c
                FROM Question_Options__r
                ORDER BY Order__c
              )
            FROM Question__c
            WHERE id IN :qoIds
            WITH SECURITY_ENFORCED
          ]) {
            sqOptMap.put(q.Id, new QuestionWrapper(q));
          }
        }
        if (qIds.size() > 0) {
          // Read all the questions for qmap
          for (Question__c q : [
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
              Read_Only__c,
              Is_Hide__c,
              IsAddRowAction__c,
              IsDeleteRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Value__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Help_Text__c,
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
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              Question_Book__r.SubTitle__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              QB_Reference__c,
              QB_Reference_Questions__c,
              Style__c,
              Is_Dependent__c,
              (
                SELECT
                  Id,
                  Name,
                  Order__c,
                  Style__c,
                  IsActive__c,
                  Question_Book__r.Anchor_Object__c,
                  Event_to_Emit__c
                FROM Actions__r
                ORDER BY Order__c
              ),
              (
                SELECT
                  Id,
                  Name,
                  Label_Class__c,
                  Label_Style__c,
                  Input_Class__c,
                  Input_Style__c, Input_Align__c,
                  showLabel__c,
                  classHeadFoot__c,
                  Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                  Font__c,
                  Pad_Color__c,
                  Pen_Color__c,
                  Stroke_Thickness__c,
                  Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                  Style_Class__c,
                  Button_Style_Class__c,
                  Button_Style__c,
                  width__c,
                  height__c
                FROM Styles__r
              ),
              (
                SELECT
                  Id,
                  Name,
                  Value__c,
                  Unique_Identifier__c,
                  Next_Question__c,
                  Tracking_ID__c,
                  Order__c,
                  Is_Default__c,
                  Question__c
                FROM Question_Options__r
                ORDER BY Order__c
              )
            FROM Question__c
            WHERE id IN :qIds
            WITH SECURITY_ENFORCED
          ]) {
            qMap.put(q.Id, new QuestionWrapper(q));
          }
        }
        // 11Jun24 - translation changes
        for (QuestionBookWrapper qbw : qbMap.values()) {
          qbw.actions = questionBookActions.get(qbw.id);
        }
        formWrapper.qbMap = qbMap;
        formWrapper.oMap = sqOptMap;
        formWrapper.qMap = qMap;
        formWrapper.tMap = translationMap;
        jsonGen.writeObjectField('tMap', formWrapper.tMap);
        jsonGen.writeObjectField('qbMap', formWrapper.qbMap);
        jsonGen.writeObjectField('oMap', formWrapper.oMap);
        // MR - 13AUG23 - END
        try {
          retQB = [
            SELECT
              Id,
              Name,
              Status__c,
              Title__c,
              isShengel__c,
              Parent_Booklet_QB__c,
              Unique_Identifier__c,
              SubTitle__c,
              First_Question__c,
              Last_Question__c,
              Query__c,
              Category__c,
              Version__c,
              Version_Status__c, //VD 20Jun25 removed boolean and created picklist
              Total_Questions__c,
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Edit__c,
              Actions__c,
              Order__c,
              Possibilities__c,
              Api_Key__c,
              Summary_Text__c,
              Summary_Sub_Text__c,
              Progress_Bar__c,
              Next_Tracking_ID__c,
              Back_Tracking_ID__c,
              Cancel_Tracking_ID__c,
              Submit_Tracking_ID__c,
              Style__c,
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
                  Read_Only__c,
                  Is_Hide__c,
                  IsAddRowAction__c,
                  IsDeleteRowAction__c,
                  isSno__c,
                  Is_Row_Draggable__c,
                  Value__c,
                  Is_Rich_Text__c,
                  Date_Format__c, // RT 19SEP25 - Date Format
                  Input_JSON__c,
                  Is_Serial_No__c,
                  Is_ReadJSONFromAttachment__c,
                  Help_Text__c,
                  Next_Question__c,
                  Error_Message__c,
                  X24_Hours__c,
                  Allowed_File_Extensions__c,
                  Question_Text__c,
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
                  Question__c,
                  Question_No__c,
                  Question_Book__c,
                  Size__c,
                  Record_Id__c,
                  Type__c,
                  Question_Parent__c,
                  Sub_Text__c,
                  Element_Mode__c,
                  Fields_Meta__c,
                  RecordType.Name,
                  RecordTypeId,
                  Tracking_ID__c,
                  Date_Text__c,
                  Time_Text__c,
                  Question_Book__r.SubTitle__c,
                  QB_Reference__c,
                  QB_Reference_Questions__c,
                  QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                  Style__c,
                  Is_Dependent__c
                FROM Questions__r
              )
            FROM Question_Book__c
            WHERE id = :qbr.Id
            WITH SECURITY_ENFORCED
            LIMIT 1
          ][0];

          // create the answerbook
          retAB.Question_Book__c = qbr.Id;
          retAB.Status__c = 'Pending';
          retABList.add(retAB);

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
              if (retQB.Status__c == 'Approved') {
                //  Database.insert(retAB);
              }
            }
          }
        } catch (Exception qbE) {
          // Input param is AnswerBook Id
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
                  Question_Rich_Text__c,
                  Answer_Long__c,
                  Question_Ref__c,
                  Question_Type__c,
                  recordId__c, // VD 8feb25 save changes
                  Question_Group_Text__c,
                  Question_Text__c
                FROM Answers__r
              )
            FROM Answer_Book__c
            WHERE id = :qbr.Id
            LIMIT 1
          ][0];
          // VD 21NOV23 - Answer book changes
          list<Question_Book__c> retAnswersQb = new List<Question_Book__c>();
          retAnswersQb = [
            SELECT Id, Name, Parent_Booklet_QB__c
            FROM Question_Book__c
            WHERE Parent_Booklet_QB__c = :retAB.Question_Book__c
            WITH SECURITY_ENFORCED
          ];
          //system.debug('retAB'+retAB);
          if (retAnswersQb.size() > 0) {
            for (Question_Book__c qb : [
              SELECT
                Id,
                Name,
                Parent_Booklet_QB__c,
                Status__c,
                Title__c,
                isShengel__c,
                SubTitle__c,
                First_Question__c,
                Last_Question__c,
                Category__c,
                Version__c,
                Version_Status__c, //VD 20Jun25 removed boolean and created picklist
                Api_Key__c,
                Actions__c,
                Order__c,
                Total_Questions__c,
                Unique_Identifier__c,
                Next__c,
                Back__c,
                Query__c,
                Submit__c,
                Cancel__c,
                Edit__c,
                Possibilities__c,
                Summary_Text__c,
                Summary_Sub_Text__c,
                Progress_Bar__c,
                Style__c,
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
                    Read_Only__c,
                    Is_Hide__c,
                    IsAddRowAction__c,
                    IsDeleteRowAction__c,
                    isSno__c,
                    Is_Row_Draggable__c,
                    Value__c,
                    Is_Rich_Text__c,
                    Date_Format__c, // RT 19SEP25 - Date Format
                    Input_JSON__c,
                    Is_Serial_No__c,
                    Is_ReadJSONFromAttachment__c,
                    Help_Text__c,
                    Next_Question__c,
                    Error_Message__c,
                    X24_Hours__c,
                    Allowed_File_Extensions__c,
                    Question_Text__c,
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
                    Question__c,
                    Question_No__c,
                    Question_Book__c,
                    Size__c,
                    Type__c,
                    Question_Parent__c,
                    Sub_Text__c,
                    Element_Mode__c,
                    Fields_Meta__c,
                    RecordType.Name,
                    RecordTypeId,
                    Record_Id__c,
                    Tracking_ID__c,
                    Date_Text__c,
                    Time_Text__c,
                    Question_Book__r.SubTitle__c,
                    QB_Reference__c,
                    QB_Reference_Questions__c,
                    QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                    Style__c,
                    Is_Dependent__c
                  FROM Questions__r
                  WHERE Type__c = 'Book' AND Question_No__c = 1
                )
              FROM Question_Book__c
              WHERE Parent_Booklet_QB__c = :retAB.Question_Book__c
              WITH SECURITY_ENFORCED
            ]) {
              QuestionBookWrapper bookWrapper = new QuestionBookWrapper(qb);
              booklet.add(bookWrapper);
              firstQIds.add(qb.First_Question__c);
              System.debug(questionBookActions);
              qbMap.put(qb.Id, new QuestionBookWrapper(qb));
            }
          } else {
            for (Question_Book__c qb : [
              SELECT
                Id,
                Name,
                Parent_Booklet_QB__c,
                Status__c,
                Title__c,
                isShengel__c,
                SubTitle__c,
                First_Question__c,
                Query__c,
                Unique_Identifier__c,
                Last_Question__c,
                Category__c,
                Version__c,
                Version_Status__c, //VD 20Jun25 removed boolean and created picklist
                Total_Questions__c,
                Next__c,
                Back__c,
                Submit__c,
                Api_Key__c,
                Actions__c,
                Order__c,
                Cancel__c,
                Edit__c,
                Possibilities__c,
                Summary_Text__c,
                Summary_Sub_Text__c,
                Progress_Bar__c,
                Style__c,
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
                    Read_Only__c,
                    Is_Hide__c,
                    IsAddRowAction__c,
                    IsDeleteRowAction__c,
                    isSno__c,
                    Is_Row_Draggable__c,
                    Value__c,
                    Is_Rich_Text__c,
                    Date_Format__c, // RT 19SEP25 - Date Format
                    Input_JSON__c,
                    Is_Serial_No__c,
                    Is_ReadJSONFromAttachment__c,
                    Help_Text__c,
                    Next_Question__c,
                    Error_Message__c,
                    X24_Hours__c,
                    Allowed_File_Extensions__c,
                    Question_Text__c,
                    Question__c,
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
                    Question_No__c,
                    Question_Book__c,
                    Size__c,
                    Type__c,
                    Question_Parent__c,
                    Sub_Text__c,
                    Element_Mode__c,
                    Fields_Meta__c,
                    RecordType.Name,
                    RecordTypeId,
                    Record_Id__c,
                    Tracking_ID__c,
                    Date_Text__c,
                    Time_Text__c,
                    Question_Book__r.SubTitle__c,
                    QB_Reference__c,
                    QB_Reference_Questions__c,
                    QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                    Style__c,
                    Is_Dependent__c
                  FROM Questions__r
                  WHERE Type__c = 'Book' AND Question_No__c = 1
                )
              FROM Question_Book__c
              WHERE id = :retAB.Question_Book__c
              WITH SECURITY_ENFORCED
            ]) {
              QuestionBookWrapper bookWrapper = new QuestionBookWrapper(qb);
              booklet.add(bookWrapper);
              firstQIds.add(qb.First_Question__c);
              System.debug(questionBookActions);
              qbMap.put(qb.Id, new QuestionBookWrapper(qb));
            }
          }
          for (Question__c q : [
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
              Is_Hide__c,
              IsAddRowAction__c,
              IsDeleteRowAction__c,
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
              isSno__c,
              Is_Row_Draggable__c,
              Value__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Help_Text__c,
              Next_Question__c,
              Error_Message__c,
              X24_Hours__c,
              Allowed_File_Extensions__c,
              Question_Text__c,
              Question__c,
              Question_No__c,
              Question_Book__c,
              Size__c,
              Type__c,
              Question_Parent__c,
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              RecordType.Name,
              RecordTypeId,
              Tracking_ID__c,
              Date_Text__c,
              Time_Text__c,
              Record_Id__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              Question_Book__r.SubTitle__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Style__c,
              Is_Dependent__c,
              (
                SELECT
                  Id,
                  Name,
                  Value__c,
                  Unique_Identifier__c,
                  Next_Question__c,
                  Question__c,
                  Order__c,
                  Is_Default__c,
                  Tracking_ID__c
                FROM Question_Options__r
                ORDER BY Order__c
              ),
              (
                SELECT
                  Id,
                  Name,
                  Order__c,
                  Style__c,
                  IsActive__c,
                  Question_Book__r.Anchor_Object__c,
                  Event_to_Emit__c
                FROM Actions__r
                ORDER BY Order__c
              ),
              (
                SELECT
                  Id,
                  Name,
                  Label_Class__c,
                  Label_Style__c,
                  Input_Class__c,
                  Input_Style__c, Input_Align__c,
                  showLabel__c,
                  classHeadFoot__c,
                  Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                  Font__c,
                  Pad_Color__c,
                  Pen_Color__c,
                  Stroke_Thickness__c,
                  Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                  Style_Class__c,
                  Button_Style_Class__c,
                  Button_Style__c,
                  width__c,
                  height__c
                FROM Styles__r
              ),
              (
                SELECT
                  Id,
                  Name,
                  Group__c,
                  Sub_Text__c,
                  Element_Mode__c,
                  Fields_Meta__c,
                  Reference_Field__c,
                  Unique_Identifier__c,
                  Additional_Rich__c,
                  Is_Date_Backward__c,
                  Date_Text__c,
                  Time_Text__c,
                  Title__c,
                  SubTitle__c,
                  Is_Date_Forward__c,
                  Is_Optional__c,
                  Is_Title__c,
                  Read_Only__c,
                  Record_Id__c,
                  Is_Hide__c,
                  IsAddRowAction__c,
                  IsDeleteRowAction__c,
                  isSno__c,
                  Is_Row_Draggable__c,
                  Value__c,
                  Is_Rich_Text__c,
                  Date_Format__c, // RT 19SEP25 - Date Format
                  Input_JSON__c,
                  Is_Serial_No__c,
                  Is_ReadJSONFromAttachment__c,
                  Help_Text__c,
                  Next_Question__c,
                  Error_Message__c,
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
                  X24_Hours__c,
                  Allowed_File_Extensions__c,
                  Question_Text__c,
                  Question__c,
                  Question_No__c,
                  Tracking_ID__c,
                  Question_Book__c,
                  Size__c,
                  Type__c,
                  Question_Parent__c,
                  RecordType.Name,
                  RecordTypeId,
                  QB_Reference__c,
                  QB_Reference_Questions__c,
                  Question_Book__r.SubTitle__c,
                  QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                  Style__c,
                  Is_Dependent__c
                FROM Questions__r
                ORDER BY Question_No__c
              )
            FROM Question__c
            WHERE Id IN :firstQIds
            WITH SECURITY_ENFORCED
          ]) {
            bookQuestionsMap.put(q.Question_Book__c, new QuestionWrapper(q));
            if (q.Questions__r.size() > 0) {
              // Get all question options
              for (Question__c qo : q.Questions__r) {
                // get the questions Id
                qIds.add(qo.Id);
                if (
                  qo.Type__c == 'Dropdown' ||
                  qo.Type__c == 'Radio' ||
                  qo.Type__c == 'Checkbox'
                ) {
                  qoIds.add(qo.Id);
                }
              }
            }
          }
          if (qIds.size() > 0) {
            for (Question__c q : [
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
                X24_Hours__c,
                Record_Id__c,
                Allowed_File_Extensions__c,
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
                RecordType.Name,
                RecordTypeId,
                Title__c,
                Read_Only__c,
                Is_Hide__c,
                IsAddRowAction__c,
                IsDeleteRowAction__c,
                isSno__c,
                Is_Row_Draggable__c,
                Value__c,
                Is_Rich_Text__c,
                Date_Format__c, // RT 19SEP25 - Date Format
                Input_JSON__c,
                Is_Serial_No__c,
                Is_ReadJSONFromAttachment__c,
                Help_Text__c,
                SubTitle__c,
                Sub_Text__c,
                Element_Mode__c,
                Fields_Meta__c,
                QB_Reference__c,
                QB_Reference_Questions__c,
                Question_Book__r.SubTitle__c,
                QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                Style__c,
                Is_Dependent__c,
                (
                  SELECT
                    Id,
                    Name,
                    Order__c,
                    Style__c,
                    IsActive__c,
                    Event_to_Emit__c,
                    Question_Book__r.Anchor_Object__c
                  FROM Actions__r
                  ORDER BY Order__c
                ),
                (
                  SELECT
                    Id,
                    Name,
                    Label_Class__c,
                    Label_Style__c,
                    Input_Class__c,
                    Input_Style__c, Input_Align__c,
                    showLabel__c,
                    classHeadFoot__c,
                    Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                    Font__c,
                    Pad_Color__c,
                    Pen_Color__c,
                    Stroke_Thickness__c,
                    Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                    Style_Class__c,
                    Button_Style_Class__c,
                    Button_Style__c,
                    width__c,
                    height__c
                  FROM Styles__r
                ),
                (
                  SELECT
                    Id,
                    Name,
                    Value__c,
                    Unique_Identifier__c,
                    Next_Question__c,
                    Question__c,
                    Order__c,
                    Is_Default__c,
                    Tracking_ID__c
                  FROM Question_Options__r
                  ORDER BY Order__c
                )
              FROM Question__c
              WHERE id IN :qIds
              WITH SECURITY_ENFORCED
            ]) {
              qMap.put(q.Id, new QuestionWrapper(q));
            }
          }
          if (qoIds.size() > 0) {
            // Read all the question with options
            for (Question__c q : [
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
                X24_Hours__c,
                Record_Id__c,
                Allowed_File_Extensions__c,
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
                RecordType.Name,
                RecordTypeId,
                Title__c,
                Read_Only__c,
                Is_Hide__c,
                IsAddRowAction__c,
                IsDeleteRowAction__c,
                isSno__c,
                Is_Row_Draggable__c,
                Value__c,
                Is_Rich_Text__c,
                Date_Format__c, // RT 19SEP25 - Date Format
                Input_JSON__c,
                Is_Serial_No__c,
                Is_ReadJSONFromAttachment__c,
                Help_Text__c,
                SubTitle__c,
                Sub_Text__c,
                Element_Mode__c,
                Fields_Meta__c,
                QB_Reference__c,
                QB_Reference_Questions__c,
                Question_Book__r.SubTitle__c,
                QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                Style__c,
                Is_Dependent__c,
                (
                  SELECT
                    Id,
                    Name,
                    Order__c,
                    Style__c,
                    IsActive__c,
                    Event_to_Emit__c,
                    Question_Book__r.Anchor_Object__c
                  FROM Actions__r
                  ORDER BY Order__c
                ),
                (
                  SELECT
                    Id,
                    Name,
                    Label_Class__c,
                    Label_Style__c,
                    Input_Class__c,
                    Input_Style__c, Input_Align__c,
                    showLabel__c,
                    classHeadFoot__c,
                    Sno_Data_Style__c, // RT 08OCT25 - Sno style handling
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
                    Font__c,
                    Pad_Color__c,
                    Pen_Color__c,
                    Stroke_Thickness__c,
                    Size__c, // Actions2/19May25/Thangarasu-Include Style obj all fields
                    Style_Class__c,
                    Button_Style_Class__c,
                    Button_Style__c,
                    width__c,
                    height__c
                  FROM Styles__r
                ),
                (
                  SELECT
                    Id,
                    Name,
                    Value__c,
                    Unique_Identifier__c,
                    Next_Question__c,
                    Question__c,
                    Order__c,
                    Is_Default__c,
                    Tracking_ID__c
                  FROM Question_Options__r
                  ORDER BY Order__c
                )
              FROM Question__c
              WHERE id IN :qoIds
              WITH SECURITY_ENFORCED
            ]) {
              sqOptMap.put(q.Id, new QuestionWrapper(q));
            }
          }

          for (QuestionBookWrapper qbw : qbMap.values()) {
            qbw.actions = questionBookActions.get(qbw.id);
          }
          formWrapper.qbMap = qbMap;
          formWrapper.qMap = qMap;
          responseWrapper.records = booklet;
          formWrapper.oMap = sqOptMap;
          jsonGen.writeObjectField('qbMap', formWrapper.qbMap);
          jsonGen.writeObjectField('oMap', formWrapper.oMap);
          jsonGen.writeObjectField('records', responseWrapper.records);
          //VD -27-dec-24  query update
          retQB = [
            SELECT
              Id,
              Name,
              Status__c,
              Title__c,
              isShengel__c,
              SubTitle__c,
              First_Question__c,
              Parent_Booklet_QB__c,
              Unique_Identifier__c,
              Last_Question__c,
              Category__c,
              Version__c,
              Version_Status__c, //VD 20Jun25 removed boolean and created picklist
              Total_Questions__c,
              Next__c,
              Back__c,
              Submit__c,
              Cancel__c,
              Api_Key__c,
              Edit__c,
              Actions__c,
              Order__c,
              Possibilities__c,
              Summary_Text__c,
              Summary_Sub_Text__c,
              Query__c,
              Progress_Bar__c,
              Next_Tracking_ID__c,
              Back_Tracking_ID__c,
              Cancel_Tracking_ID__c,
              Submit_Tracking_ID__c,
              Style__c,
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
                  Date_Text__c,
                  Time_Text__c,
                  Is_Date_Forward__c,
                  Is_Optional__c,
                  Is_Title__c,
                  Next_Question__c,
                  Question_Text__c,
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
                  Title__c,
                  Read_Only__c,
                  Is_Hide__c,
                  IsAddRowAction__c,
                  IsDeleteRowAction__c,
                  isSno__c,
                  Is_Row_Draggable__c,
                  Value__c,
                  Is_Rich_Text__c,
                  Date_Format__c, // RT 19SEP25 - Date Format
                  Input_JSON__c,
                  Is_Serial_No__c,
                  Is_ReadJSONFromAttachment__c,
                  Help_Text__c,
                  SubTitle__c,
                  Sub_Text__c,
                  Element_Mode__c,
                  Fields_Meta__c,
                  QB_Reference__c,
                  QB_Reference_Questions__c,
                  Question_Book__r.SubTitle__c,
                  QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
                  Style__c,
                  Is_Dependent__c
                FROM Questions__r
              )
            FROM Question_Book__c
            WHERE id = :retAB.Question_Book__c
            WITH SECURITY_ENFORCED
            LIMIT 1
          ][0];
        }
        responseWrapper.records = booklet;
        responseWrapper.questionBook = new QuestionBookWrapper(retQB);
        responseWrapper.answerbook = new AnswerBookWrapper(retAB);
        responseWrapper.order = qbr.Order__c;
        // Add booklet to FormWrapper
        formWrapper.pages.add(responseWrapper);
        jsonGen.writeObjectField('questionbook', responseWrapper.questionBook);
        jsonGen.writeObjectField('answerbook', responseWrapper.answerbook);
        jsonGen.writeObjectField('records', responseWrapper.records);
        jsonGen.writeEndObject();
      }

      jsonGen.writeEndArray(); // End booklets array
    }

    jsonGen.writeEndObject(); // End form object
    jsonGen.writeEndObject(); // End main JSON object
    //return jsonGen.getAsString();
    return JSON.serialize(formWrapper, true);
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