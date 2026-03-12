/**
* Created by: Vijay Dreamer
* Description: To handle the Version Control of Question Books
              by Cone the Book and its related 
              Questions (and its options,styles field metas)
              Actions(its related Styles)
* Created on (DD/MM/YYYY): 05/06/2025.
**/
public with sharing class FormVersionController {
  @AuraEnabled
  public static String saveAsVersion(Id formId, Id bookId, String versionName) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    try {
      Form__c formRecord = [
        SELECT Id, Name, Question_Book__c
        FROM Form__c
        WHERE Id = :formId
      ];
      Id originalBookId = bookId;
      // Clone top-level QuestionBook and all nested content recursively
      ClonedEntities rootClone = cloneQuestionBookRecursive(
        originalBookId,
        null,
        new Map<Id, Id>()
      );
      //VD 20Jun25 version control changes

      // Mark the new Question Book as latest version
      Question_Book__c newBook = [
        SELECT Id, Name, Version__c, Version_Status__c
        FROM Question_Book__c
        WHERE Id = :rootClone.bookId
      ];
      // VD 20Jun25 version control changes
      // Count every Question_Book__c already linked to this form
      AggregateResult ar = [
        SELECT COUNT(Id) total
        FROM Question_Book__c
        WHERE Form__c = :formRecord.Id
      ];
      Decimal nextVersion = ((Decimal) ar.get('total')) + 1;
      newBook.Version__c = nextVersion;
      newBook.Version_Status__c = 'Inactive';
      newBook.Form__c = formRecord.Id;
      newBook.Title__c = versionName;
      update newBook;

      jsonGen.writeStringField('status', 'success');
      jsonGen.writeStringField('message', 'Form version saved successfully.');
      jsonGen.writeStringField('newBookId', newBook.Id);
    } catch (Exception e) {
      System.debug('Inside the exception section ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
      jsonGen.writeStringField('status', 'error');
      jsonGen.writeStringField('error', e.getMessage());
      jsonGen.writeStringField('stackTrace', e.getStackTraceString());
    }

    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  private class ClonedEntities {
    public Id bookId;
    public Map<Id, Id> questionIdMap = new Map<Id, Id>();
    public Map<Id, Id> fieldMetaIdMap = new Map<Id, Id>();
  }

  private static ClonedEntities cloneQuestionBookRecursive(
    Id bookId,
    Id parentQuestionId,
    Map<Id, Id> globalQuestionIdMap
  ) {
    ClonedEntities result = new ClonedEntities();

    // Clone the Question Book
    //VD 20Jun25 version control changes
    Question_Book__c originalBook = [
      SELECT
        Id,
        Name,
        Version__c,
        Title__c,
        Style__c,
        Query__c,
        Anchor_Object__c
      FROM Question_Book__c
      WHERE Id = :bookId
    ];
    Question_Book__c newBook = originalBook.clone(false, true, false, false);
    insert newBook;
    result.bookId = newBook.Id;

    // Clone Questions
    List<Question__c> questions = [
      SELECT
        Id,
        Name,
        Question_Book__c,
        Question_No__c,
        RecordTypeId,
        Reference_Field__c,
        Additional_Rich__c,
        Group__c,
        Is_Date_Backward__c,
        Title__c,
        SubTitle__c,
        Is_Date_Forward__c,
        Is_Optional__c,
        Is_Title__c,
        Is_Hide__c,
        IsAddRowAction__c,
        isSno__c,
        Is_Row_Draggable__c,
        Value__c,
        Is_Rich_Text__c, // VD 29jun24 richText Support
        Date_Format__c, // RT 19SEP25 - Date Format
        Input_JSON__c,
        Is_Serial_No__c,
        Is_ReadJSONFromAttachment__c,
        Sign_URL_Reference__c,   // VD 08OCT Version Control changes
        Sign_DateTime_Reference__c,
        Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
        Enable_Signature_Drawing__c,
        Enable_Name_Signing__c,
        Latitude_Reference__c,
        Longitude_Reference__c,
        Location_DateTime_Reference__c,
        Currency_Code__c,
        Locale__c,
        Print_Mode__c,
        IsDeleteRowAction__c,
        Help_Text__c,
        Read_Only__c,
        Next_Question__c,
        Error_Message__c,
        X24_Hours__c,
        Allowed_File_Extensions__c,
        Question_Text__c,
        Question__c,
        Question_Parent__c,
        Size__c,
        Type__c,
        Sub_Text__c,
        Element_Mode__c,
        Fields_Meta__c,
        Tracking_ID__c,
        Date_Text__c,
        Time_Text__c,
        Record_Id__c,
        QB_Reference__c,
        QB_Reference_Questions__c,
        Style__c,
        Is_Dependent__c
      FROM Question__c
      WHERE Question_Book__c = :bookId
    ];
    Map<Id, Id> questionIdMap = new Map<Id, Id>();
    List<Question__c> newQuestions = new List<Question__c>();
    Map<Id, Id> clonedQbReferences = new Map<Id, Id>(); // Original → Cloned QB Reference

    // First pass: clone referenced books
    for (Question__c q : questions) {
      if (
        (q.Type__c == 'Book' || q.Type__c == 'Table') &&
        q.QB_Reference__c != null
      ) {
        // Recurse to clone the referenced book
        ClonedEntities nestedClone = cloneQuestionBookRecursive(
          q.QB_Reference__c,
          q.Id,
          globalQuestionIdMap
        );
        clonedQbReferences.put(q.QB_Reference__c, nestedClone.bookId);
      }
    }

    // Second pass: clone questions and assign cloned QB_Reference__c
    for (Question__c q : questions) {
      Question__c qClone = q.clone(false, true, false, false);
      qClone.Question_Book__c = newBook.Id;
      // Recurse if Book/Table type and QB_Reference__c present
      if (
        (q.Type__c == 'Book' || q.Type__c == 'Table') &&
        q.QB_Reference__c != null
      ) {
        // ClonedEntities nested = cloneQuestionBookRecursive(q.QB_Reference__c, q.Id);
        qClone.QB_Reference__c = clonedQbReferences.get(q.QB_Reference__c);
      }

      newQuestions.add(qClone);
    }
    if (!newQuestions.isEmpty()) {
      insert newQuestions;
    }

    for (Integer i = 0; i < questions.size(); i++) {
      questionIdMap.put(questions[i].Id, newQuestions[i].Id);
      globalQuestionIdMap.put(questions[i].Id, newQuestions[i].Id);
    }
    result.questionIdMap = questionIdMap;

    // Clone Field Meta
    List<Field_Meta__c> fieldMetas = [
      SELECT
        Id,
        Name,
        Question__c,
        RecordTypeId,
        api_name__c,
        childFilter__c,
        childObjFldName__c,
        childObjName__c,
        db_name__c,
        fld_type__c,
        File_Size__c,
        File_Type__c,
        filterCondition__c,
        filterFlag__c,
        filterLogic__c,
        filterValue__c,
        grandChildFilter__c,
        grandChildObjFldName__c,
        grandChildObjName__c,
        grandChildParentField__c,
        Is_Serial_No__c,
        isChild__c,
        isGrandChild__c,
        label__c,
        order__c,
        orderByFlag__c,
        output_flag__c,
        Question_Reference__c,
        resultantFlag__c,
        searchFlag__c,
        Is_Foot__c,
        Table_Data_Style__c,
        Table_Head_Style__c,
        Type__c,
        width_style__c
      FROM Field_Meta__c
      WHERE Question__c IN :questions
    ];
    List<Field_Meta__c> newFieldMetas = new List<Field_Meta__c>();
    Map<Id, Id> fieldMetaIdMap = new Map<Id, Id>();

    for (Field_Meta__c fm : fieldMetas) {
      Field_Meta__c fmClone = fm.clone(false, true, false, false);
      if (fm.Question__c != null && fm.Question_Reference__c == null) {
        fmClone.Question__c = questionIdMap.get(fm.Question__c);
      } else if (
        fm.Question__c != null &&
        fm.Question_Reference__c != null &&
        globalQuestionIdMap.containsKey(fm.Question_Reference__c)
      ) {
        fmClone.Question__c = questionIdMap.get(fm.Question__c);
        fmClone.Question_Reference__c = globalQuestionIdMap.get(
          fm.Question_Reference__c
        );
      }
      newFieldMetas.add(fmClone);
    }
    if (!newFieldMetas.isEmpty()) {
      insert newFieldMetas;
    }

    for (Integer i = 0; i < fieldMetas.size(); i++) {
      fieldMetaIdMap.put(fieldMetas[i].Id, newFieldMetas[i].Id);
    }
    result.fieldMetaIdMap = fieldMetaIdMap;

    // Clone Options
    List<Option__c> options = [
      SELECT
        Id,
        Name,
        Question__c,
        Order__c,
        Value__c,
        Is_Default__c,
        Next_Question__c
      FROM Option__c
      WHERE Question__c IN :questions
    ];
    List<Option__c> newOptions = new List<Option__c>();
    for (Option__c opt : options) {
      Option__c optClone = opt.clone(false, true, false, false);
      optClone.Question__c = globalQuestionIdMap.get(opt.Question__c);
      newOptions.add(optClone);
    }
    if (!newOptions.isEmpty()) {
      insert newOptions;
    }

    // Clone Question Styles
    List<Style__c> questionStyles = [
      SELECT
        Id,
        Name,
        Question__c,
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
        Font__c,   // VD 08OCT Version Control changes
        Pad_Color__c,
        Pen_Color__c,
        Stroke_Thickness__c,
        Size__c,
        Style_Class__c,
        Button_Style_Class__c,
        width__c,
        height__c
      FROM Style__c
      WHERE Question__c IN :questions
    ];
    List<Style__c> newQStyles = new List<Style__c>();
    for (Style__c style : questionStyles) {
      Style__c styleClone = style.clone(false, true, false, false);
      styleClone.Question__c = globalQuestionIdMap.get(style.Question__c);
      newQStyles.add(styleClone);
    }

    if (!newQStyles.isEmpty()) {
      insert newQStyles;
    }

    // clone Book Style
    List<Style__c> bookStyles = [
      SELECT
        Id,
        Name,
        Question_Book__c,
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
        Font__c,   // VD 08OCT Version Control changes
        Pad_Color__c,
        Pen_Color__c,
        Stroke_Thickness__c,
        Heading_Size__c,
        labelValueStyle__c,
        ElementStyle__c,
        CheckboxStyle__c,
        headingStyle__c,
        external_id__c,
        Size__c,
        Style_Class__c,
        Button_Style_Class__c,
        width__c,
        height__c
      FROM Style__c
      WHERE Question_Book__c = :originalBook.Id
    ];
    List<Style__c> newBookStyles = new List<Style__c>();
    for (Style__c style : bookStyles) {
      Style__c styleClone = style.clone(false, true, false, false);
      styleClone.Question_Book__c = newBook.Id;
      newBookStyles.add(styleClone);
    }
    if (!newBookStyles.isEmpty()) {
      insert newBookStyles;
    }

    // Clone Action
    List<Actions__c> bookActions = [
      SELECT
        Id,
        Name,
        Question_Book__c,
        Order__c,
        Style__c,
        IsActive__c,
        Question_Book__r.Anchor_Object__c, // RT 08SEP25 - Anchor object added for field visibility
        Event_to_Emit__c
      FROM Actions__c
      WHERE Question_Book__c = :originalBook.Id
    ];
    List<Actions__c> newActions = new List<Actions__c>();
    for (Actions__c act : bookActions) {
      Actions__c actClone = act.clone(false, true, false, false);
      actClone.Question_Book__c = newBook.Id;
      newActions.add(actClone);
    }
    if (!newActions.isEmpty()) {
      insert newActions;
    }

    // Clone Input
    // RT 14AUG25 - Value field for Input json
    // RT 21AUG25 - Dependency handling fields included
    List<Input__c> inputs = [
      SELECT Id, API_Name__c, Value_Field__c, Type__c, Question_Book__c, Unique_Identifier__c, Question__c, Source_Question_Id__c, Hidden__c, Logics__c
      FROM Input__c
      WHERE Question_Book__c = :originalBook.Id
    ];
    List<Input__c> newInputs = new List<Input__c>();
    for (Input__c input : inputs) {
      Input__c inputClone = input.clone(false, true, false, false);
      inputClone.Question_Book__c = newBook.Id;
      newInputs.add(inputClone);
    }
    if (!newInputs.isEmpty()) {
      insert newInputs;
    }

    // Create a map of original → cloned Action Ids
    Map<Id, Id> actionIdMap = new Map<Id, Id>();
    for (Integer i = 0; i < bookActions.size(); i++) {
      actionIdMap.put(bookActions[i].Id, newActions[i].Id);
    }

    // Clone Action-related Styles
    List<Style__c> actionStyles = [
      SELECT
        Id,
        Name,
        Action__c,
        Question_Book__c,
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
        Font__c,   // VD 08OCT Version Control changes
        Pad_Color__c,
        Pen_Color__c,
        Stroke_Thickness__c,
        external_id__c,
        Size__c,
        Style_Class__c,
        Button_Style_Class__c
      FROM Style__c
      WHERE Action__c IN :bookActions
    ];
    List<Style__c> newActionStyles = new List<Style__c>();
    for (Style__c style : actionStyles) {
      Style__c styleClone = style.clone(false, true, false, false);
      styleClone.Action__c = actionIdMap.get(style.Action__c);
      newActionStyles.add(styleClone);
    }
    if (!newActionStyles.isEmpty()) {
      insert newActionStyles;
    }

    return result;
  }
  //VD 20Jun25 version control changes
  @AuraEnabled
  public static String activateDeactivateForm(Id bookId, String status) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    try {
      if (bookId == null) {
        throw new AuraHandledException('No Question Book to activate.');
      }
      /* 1. Get the target book (with its parent Form) */
      Question_Book__c targetBook = [
        SELECT Id, Form__c, Version_Status__c
        FROM Question_Book__c
        WHERE Id = :bookId
        LIMIT 1
      ];

      if (status == 'Deactivate') {
        targetBook.Version_Status__c = 'Deactivated';
        update targetBook;
        // VD 08OCT Version Control changes
      } else if(status == 'Inactive'){
        targetBook.Version_Status__c = 'Inactive';
        update targetBook;
      } else {
        if (targetBook.Version_Status__c == 'Active') {
          throw new AuraHandledException(
            'This Question Book is already active.'
          );
        }

        /* 2. Gather every other book on the same Form that’s currently active */
        List<Question_Book__c> booksToDeactivate = [
          SELECT Id, Version_Status__c
          FROM Question_Book__c
          WHERE
            Form__c = :targetBook.Form__c
            AND Id != :targetBook.Id
            AND Version_Status__c = 'Active'
        ];

        for (Question_Book__c qb : booksToDeactivate) {
          qb.Version_Status__c = 'Inactive';
        }

        /* 3. Activate the requested book */
        targetBook.Version_Status__c = 'Active';

        /* 4. Commit updates with a single DML statement */
        List<Question_Book__c> booksToUpdate = new List<Question_Book__c>();
        booksToUpdate.add(targetBook);
        booksToUpdate.addAll(booksToDeactivate);
        update booksToUpdate;

        /* 5. Tag the Form with the newly‑activated book */
        if (targetBook.Form__c != null) {
          update new Form__c(
            Id = targetBook.Form__c,
            Question_Book__c = targetBook.Id
          );
        }
      }
      jsonGen.writeStringField('status', 'success');
      jsonGen.writeStringField('message', 'Form activated successfully.');
      jsonGen.writeStringField('bookId', targetBook.Id);
    } catch (Exception e) {
      jsonGen.writeStringField('status', 'error');
      jsonGen.writeStringField('error', e.getMessage());
      jsonGen.writeStringField('stackTrace', e.getStackTraceString());
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  // VD 20Jun25 handle using wrapper support
  @AuraEnabled(cacheable=true)
  public static List<QuestionBookWrapper> getQuestionBooksByForm(Id formId) {
    List<Question_Book__c> books = [
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
        Version_Status__c,
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
        Anchor_Object__c
      FROM Question_Book__c
      WHERE Form__c = :formId
      ORDER BY CreatedDate DESC
    ];

    List<QuestionBookWrapper> wrappedList = new List<QuestionBookWrapper>();
    for (Question_Book__c book : books) {
      wrappedList.add(new QuestionBookWrapper(book));
    }

    return wrappedList;
  }
}