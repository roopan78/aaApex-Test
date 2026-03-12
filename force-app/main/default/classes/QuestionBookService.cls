public with sharing class QuestionBookService {
  // MR 18MAY25 QB Builder Changes - Create this class for getting Question Books
  // RT 26MAY25 Style Wrapper Style Key added
  // RT 29MAY25 - Label Class, Label Style, Input Class, Input Style replaced
  public static FormWrapper getQuestions(String qbId, String language) {
    String qbName = '';
    // Get the Questions & its related options
    Set<Id> qoIds = new Set<Id>();
    Set<Id> qIds = new Set<Id>();

    Map<Id, QuestionBookWrapper> qbMap = new Map<Id, QuestionBookWrapper>();
    Map<Id, QuestionWrapper> sqOptMap = new Map<Id, QuestionWrapper>();
    map<Id, QuestionWrapper> qMap = new Map<Id, QuestionWrapper>();
    Map<Id, List<TranslationWrapper>> translationMap = new Map<Id, List<TranslationWrapper>>();

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
        Is_Rich_Text__c, // VD 29jun24 richText Support
        Date_Format__c, // RT 19SEP25 - Date Format
        Input_JSON__c,
        Is_Serial_No__c,
        Is_ReadJSONFromAttachment__c, // VD 12Jun25 handle JSON from attachment
        Help_Text__c,
        Next_Question__c,
        Error_Message__c,
        QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
        X24_Hours__c,
        Allowed_File_Extensions__c,
        Question_Text__c,
        Question__c,
        Question_No__c,
        Question_Book__c,
        Question_Book__r.Name,
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
        Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
        Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
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
        Record_Id__c,
        Question_Book__r.SubTitle__c,
        QB_Reference__c,
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
          SELECT Id, Name, Order__c, Style__c, IsActive__c, Event_to_Emit__c
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
            Is_Optional__c,
            Is_Title__c,
            Next_Question__c,
            Error_Message__c,
            X24_Hours__c,
            Allowed_File_Extensions__c,
            Question_Text__c,
            Question__c,
            Question_No__c,
            Minimum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
            Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
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
            Question_Book__c,
            Size__c,
            Record_Id__c,
            RecordType.Name,
            RecordTypeId,
            Type__c,
            Question_Parent__c,
            Question_Book__r.SubTitle__c,
            QB_Reference__c,
            QB_Reference_Questions__c,
            Style__c,
            Is_Dependent__c
          FROM Questions__r
          ORDER BY Question_No__c
        )
      FROM Question__c
      WHERE Question_Book__c = :qbId
      WITH SECURITY_ENFORCED
    ]) {
      if (qbName == '') {
        qbName = q.Question_Book__r.Name;
      }
      List<Translation__c> translation = new List<Translation__c>();
      List<object> translatedText = new List<object>();
      if (language == 'All') {
        translation = [
          SELECT Unique_Identifier__c, Language__c, Translated_Text__c
          FROM Translation__c
          WHERE Question_Book__c = :qbId
        ];
      } else {
        translation = [
          SELECT Unique_Identifier__c, Language__c, Translated_Text__c
          FROM Translation__c
          WHERE Question_Book__c = :qbId AND Language__c = :language
        ];
      }

      if (translation.size() > 0) {
        List<TranslationWrapper> wrappedTranslations = new List<TranslationWrapper>();
        for (Translation__c tr : translation) {
          if (tr.Translated_Text__c != null) {
            wrappedTranslations.add(new TranslationWrapper(tr));
          }
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
          Minimum_Fraction_Digits__c,
          Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
          Enable_Signature_Drawing__c,
          Currency_Code__c, // RT 06OCT25 - Currency Format
          Locale__c,
          Sno_Title__c, // RT 13OCT25 - S.no Title
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
          SubTitle__c,
          Sub_Text__c,
          Element_Mode__c,
          Fields_Meta__c,
          Question_Book__r.SubTitle__c,
          QB_Reference__c,
          QB_Reference_Questions__c,
          Style__c,
          Is_Dependent__c,
          (
            SELECT Id, Name, Order__c, Style__c, IsActive__c, Event_to_Emit__c
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
          Minimum_Fraction_Digits__c,
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
          Maximum_Fraction_Digits__c, // RT 24JUL25 - added for decimal support
          Question_Book__r.SubTitle__c,
          QB_Reference__c,
          QB_Reference_Questions__c,
          QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
          Style__c,
          Is_Dependent__c,
          (
            SELECT Id, Name, Order__c, Style__c, IsActive__c, Event_to_Emit__c
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

    FormWrapper formWrapper = new FormWrapper(qbId, qbName);
    formWrapper.qbMap = qbMap;
    formWrapper.oMap = sqOptMap;
    formWrapper.qMap = qMap;
    formWrapper.tMap = translationMap;

    return formWrapper;
  }
  // VD 18Jun25 field Meta Handling changes
  // RT 25OCT25 - Return value Id changed
  @AuraEnabled(cacheable=true)
  public static Id getQBReferenceQuestion(String questionBookId) {
    if (String.isBlank(questionBookId)) {
      return null; // defensive guard‑rail
    }
    // Parent + limited child sub‑query (ORDER BY CreatedDate DESC LIMIT 1)
    Question_Book__c book = [
      SELECT
        Id,
        (
          SELECT Id, Name, CreatedDate
          FROM QBRef__r
          ORDER BY CreatedDate DESC
          LIMIT 1
        )
      FROM Question_Book__c
      WHERE Id = :questionBookId
      LIMIT 1
    ];
    // Safely return the first (and only) child if it exists
    return (book.QBRef__r != null && !book.QBRef__r.isEmpty())
      ? book.QBRef__r[0].Id
      : null;
  }

  // RT 14AUG25 - Check if any QB Referred for Table Question
  @AuraEnabled(cacheable=true)
  public static Boolean checkTableColumn(String questionBookId) {
    List<Question__c> refQuestions = [
        SELECT Id, Type__c
        FROM Question__c
        WHERE QB_Reference__c = :questionBookId
    ];
    
    // Return true if any child has Type__c = 'Table'
    for (Question__c q : refQuestions) {
        if (q.Type__c == 'Table') {
            return true;
        }
    }
    return false;
  }
}