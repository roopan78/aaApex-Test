public without sharing class BookletHandler implements DataHandler {
  @testvisible
  private String contactId = '';
  // VD 09jul25 - query optimization changes
  @testvisible
  private Map<String, Object> paramMap = new Map<String, Object>();
  //constructor with one parameter to set the contact id
  public BookletHandler(String contact) {
    this.contactId = contact;
  }
  public BookletHandler() {
  }

  // MR 22OCT23 - SetContext Changes
  public void setContext(String field, Object value) {
    // VD 09jul25 - query optimization changes
    this.paramMap.put(field, value);
    if (field == 'contactId') {
      this.contactId = (String) value;
    }
  }

  //getting the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }
  // 12Jun24 - translation changes
  //read the records of the user by passing the json input
  public String readRecords(String inputJSON, String languageCode) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    String ansId = inputJSON;
    // VD 09jul25 - query optimization changes
    List<SObject> lstResult;
    // VD 24jun25 Form ID Changes (in place of QB Id)
    String inpId = inputJSON;
    // 11Jun24 - translation changes
    String language = languageCode;
    String namespace = Utility.nameSpace();
    Id objectId = (Id) inpId;
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
      inpId = inputJSON;
    }
    // Initialize the wrapper class to store the response
    ResponseWrapper responseWrapper = new ResponseWrapper();
    Question_Book__c retQB = new Question_Book__c();
    list<Answer_Book__c> retABList = new List<Answer_Book__c>();
    Answer_Book__c retAB = new Answer_Book__c();
    List<QuestionBookWrapper> booklet = new List<QuestionBookWrapper>();
    // 11Jun24 - translation changes

    // Step 1: Query the Question_Book__c records
    Set<Id> questionBookIds = new Set<Id>();
    for (Question_Book__c qb : [
      SELECT Id, First_Question__c
      FROM Question_Book__c
      WHERE Parent_Booklet_QB__c = :inpId
    ]) {
      questionBookIds.add(qb.Id);
      questionBookIds.add(qb.First_Question__c);
    }
    // VD 20Jan24 - translation changes
    // Fetch related translations
    Map<Id, List<TranslationWrapper>> translationMap = new Map<Id, List<TranslationWrapper>>();

    // Read all QB related to the booklet
    // Get all First Questions
    Set<Id> firstQIds = new Set<Id>();
    list<Question_Book__c> retQB1 = new List<Question_Book__c>();
    retQB1 = [
      SELECT Id, Name, Parent_Booklet_QB__c
      FROM Question_Book__c
      WHERE Parent_Booklet_QB__c = :inpId
      WITH SECURITY_ENFORCED
    ];
    // MR 20NOV23 Print Mode Changes
    // MR 18DEC23 Including Style on the response

    // VD 25Feb24 -added Unique Identifer field in the query
    //AP 09DEC24 -added action field in the query
    if (retQB1.size() > 0) {
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
          Version_Status__c, //VD 20Jun25 removed boolean and created picklist
          Version__c,
          Total_Questions__c,
          Query__c,
          Unique_Identifier__c,
          Api_Key__c,
          Actions__c,
          Order__c,
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
              // VD 05MAR25 table action changes
              // VD 19Mar25 table action changes
              IsAddRowAction__c,
              isSno__c,
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
              Is_Row_Draggable__c,
              Value__c, // VD 29jul defaul value handling
              Is_Rich_Text__c, // VD 29jun24 richText Support
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
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
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Style__c,
              Is_Dependent__c
            FROM Questions__r
            WHERE Type__c = 'Book' AND Question_No__c = 1
          )
        FROM Question_Book__c
        WHERE Parent_Booklet_QB__c = :inpId
        WITH SECURITY_ENFORCED
      ]) {
        booklet.add(new QuestionBookWrapper(qb));
        firstQIds.add(qb.First_Question__c);
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
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              // VD 19Mar25 table action changes
              isSno__c,
              Is_Row_Draggable__c,
              Value__c, // VD 29jul defaul value handling
              Is_Rich_Text__c, // VD 29jun24 richText Support
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
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
              Minimum_Fraction_Digits__c,
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
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
      ]) {
        booklet.add(new QuestionBookWrapper(qb));
        firstQIds.add(qb.First_Question__c);
      }
    }

    // MR - 13AUG23 - START
    // Get the Questions & its related options
    Map<Id, QuestionWrapper> bookQuestionsMap = new Map<Id, QuestionWrapper>();
    Map<Id, QuestionWrapper> sqOptMap = new Map<Id, QuestionWrapper>();
    Set<Id> qoIds = new Set<Id>();
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
        // VD 05MAR25 table action changes
        IsAddRowAction__c,
        isSno__c,
        Is_Row_Draggable__c,
        Value__c, // VD 29jul defaul value handling
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
        Is_Rich_Text__c,
        Date_Format__c, // RT 19SEP25 - Date Format
        Input_JSON__c,
        Is_Serial_No__c,
        Is_ReadJSONFromAttachment__c,
        Print_Mode__c,
        IsDeleteRowAction__c,
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
        QB_Reference_Questions__c,
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
            Is_Default__c,
            Order__c,
            Tracking_ID__c
          FROM Question_Options__r
          ORDER BY Order__c
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
            // VD 05MAR25 table action changes
            IsAddRowAction__c,
            isSno__c,
            Is_Row_Draggable__c,
            Value__c,
            Is_Rich_Text__c,
            Date_Format__c, // RT 19SEP25 - Date Format
            Input_JSON__c,
            Is_Serial_No__c,
            Is_ReadJSONFromAttachment__c,
            Print_Mode__c,
            IsDeleteRowAction__c,
            Help_Text__c,
            SubTitle__c,
            Is_Date_Forward__c,
            Is_Optional__c,
            Is_Title__c,
            Next_Question__c,
            Error_Message__c,
            X24_Hours__c,
            Allowed_File_Extensions__c,
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
          // VD 05MAR25 table action changes
          IsAddRowAction__c,
          isSno__c,
          Is_Row_Draggable__c,
          Value__c,
          Is_Rich_Text__c,
          Date_Format__c, // RT 19SEP25 - Date Format
          Input_JSON__c,
          Is_Serial_No__c,
          Is_ReadJSONFromAttachment__c,
          Print_Mode__c,
          IsDeleteRowAction__c,
          Help_Text__c,
          Next_Question__c,
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
              Value__c,
              Unique_Identifier__c,
              Next_Question__c,
              Tracking_ID__c,
              Is_Default__c,
              Order__c,
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
    // 11Jun24 - translation changes
    responseWrapper.bookQuestionsMap = bookQuestionsMap;
    responseWrapper.sqOptions = sqOptMap;
    responseWrapper.translationMap = translationMap;
    jsonGen.writeObjectField('translationMap', responseWrapper.translationMap);
    jsonGen.writeObjectField(
      'bookQuestionsMap',
      responseWrapper.bookQuestionsMap
    );
    jsonGen.writeObjectField('sqOptions', responseWrapper.sqOptions);
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
          (SELECT Id, Name, API_Name__c, Type__c, Value_Field__c, Source_Question_Id__c, Question__c, Question_Book__c, Hidden__c, Logics__c FROM Inputs__r), // VD 09jul25 - query optimization changes // RT 14AUG25 - Value Field for Input JSON
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
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Value__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
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
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
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
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ][0];

      // create the answerbook
      retAB.Question_Book__c = inpId;
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
        WHERE id = :inpId
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
                // VD 05MAR25 table action changes
                IsAddRowAction__c,
                isSno__c,
                Is_Row_Draggable__c,
                Value__c,
                Is_Rich_Text__c,
                Date_Format__c, // RT 19SEP25 - Date Format
                Input_JSON__c,
                Is_Serial_No__c,
                Is_ReadJSONFromAttachment__c,
                Print_Mode__c,
                IsDeleteRowAction__c,
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
          WHERE Parent_Booklet_QB__c = :retAB.Question_Book__c
          WITH SECURITY_ENFORCED
        ]) {
          booklet.add(new QuestionBookWrapper(qb));
          firstQIds.add(qb.First_Question__c);
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
                // VD 05MAR25 table action changes
                IsAddRowAction__c,
                isSno__c,
                Is_Row_Draggable__c,
                Value__c,
                Is_Rich_Text__c,
                Date_Format__c, // RT 19SEP25 - Date Format
                Input_JSON__c,
                Is_Serial_No__c,
                Is_ReadJSONFromAttachment__c,
                Print_Mode__c,
                IsDeleteRowAction__c,
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
          WHERE id = :retAB.Question_Book__c
          WITH SECURITY_ENFORCED
        ]) {
          booklet.add(new QuestionBookWrapper(qb));
          firstQIds.add(qb.First_Question__c);
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
          // VD 05MAR25 table action changes
          IsAddRowAction__c,
          isSno__c,
          Is_Row_Draggable__c,
          Value__c,
          Is_Rich_Text__c,
          Date_Format__c, // RT 19SEP25 - Date Format
          Input_JSON__c,
          Is_Serial_No__c,
          Is_ReadJSONFromAttachment__c,
          Print_Mode__c,
          IsDeleteRowAction__c,
          Help_Text__c,
          Next_Question__c,
          Error_Message__c,
          X24_Hours__c,
          Allowed_File_Extensions__c,
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
          QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
          Question_Book__r.SubTitle__c,
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
              Is_Default__c,
              Order__c,
              Tracking_ID__c
            FROM Question_Options__r
            ORDER BY Order__c
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
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              isSno__c,
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
              Is_Row_Draggable__c,
              Value__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
              Read_Only__c,
              Record_Id__c,
              Is_Hide__c,
              Help_Text__c,
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
              Type__c,
              Question_Parent__c,
              RecordType.Name,
              RecordTypeId,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Question_Book__r.SubTitle__c,
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
            Next_Question__c,
            Question_Text__c,
            Question_Parent__c,
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
            RecordType.Name,
            RecordTypeId,
            Title__c,
            Read_Only__c,
            Is_Hide__c,
            // VD 05MAR25 table action changes
            IsAddRowAction__c,
            isSno__c,
            Is_Row_Draggable__c,
            Value__c,
            Is_Rich_Text__c,
            Date_Format__c, // RT 19SEP25 - Date Format
            Input_JSON__c,
            Is_Serial_No__c,
            Is_ReadJSONFromAttachment__c,
            Print_Mode__c,
            IsDeleteRowAction__c,
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
                Value__c,
                Unique_Identifier__c,
                Next_Question__c,
                Question__c,
                Is_Default__c,
                Order__c,
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
      responseWrapper.bookQuestionsMap = bookQuestionsMap;
      responseWrapper.records = booklet;
      responseWrapper.sqOptions = sqOptMap;
      jsonGen.writeObjectField(
        'bookQuestionsMap',
        responseWrapper.bookQuestionsMap
      );
      jsonGen.writeObjectField('sqOptions', responseWrapper.sqOptions);
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
              Question_Parent__c,
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
              // VD 05MAR25 table action changes
              IsAddRowAction__c,
              isSno__c,
              Is_Row_Draggable__c,
              Value__c,
              Is_Rich_Text__c,
              Date_Format__c, // RT 19SEP25 - Date Format
              Input_JSON__c,
              Is_Serial_No__c,
              Is_ReadJSONFromAttachment__c,
              Print_Mode__c,
              IsDeleteRowAction__c,
              Help_Text__c,
              SubTitle__c,
              Sub_Text__c,
              Element_Mode__c,
              Fields_Meta__c,
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Question_Book__r.SubTitle__c,
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
    // VD 09jul25 - query optimization changes
    QuestionBookWrapper qbw = new QuestionBookWrapper(retQB);
    if (String.isNotBlank(retQB.Query__c)) {
      // MR 29NOV23 Process the input params
      String qStr = retQB.Query__c;
      for (Input__c inp : retQB.Inputs__r) {
        if (
          inp.Type__c == 'String' && this.paramMap.containsKey(inp.API_Name__c)
        ) {
          qStr = qStr.replace(
            '{' + inp.API_Name__c + '}',
            '\'' + (String) this.paramMap.get(inp.API_Name__c) + '\''
          );
        }
      }
      retQB.Query__c = qStr;
      try {
        system.debug('brfor query ' + qStr);
        List<SObject> result = Database.query(qStr);
        qbw.setQueryResult(result);
        //system.debug('after query'+ lstResult);
      } catch (Exception e) {
        system.debug('qbQueryResult' + new List<SObject>());
        system.debug('exception' + e.getMessage());
        system.debug('line number' + e.getLineNumber());
        system.debug('stackTrace' + e.getStackTraceString());
      }
    } else {
      system.debug('qbQueryResult' + new List<SObject>());
    }
    responseWrapper.records = booklet;
    responseWrapper.questionBook = qbw;
    responseWrapper.answerbook = new AnswerBookWrapper(retAB);
    jsonGen.writeObjectField('questionbook', responseWrapper.questionBook);
    jsonGen.writeObjectField('answerbook', responseWrapper.answerbook);
    jsonGen.writeObjectField('records', responseWrapper.records);

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