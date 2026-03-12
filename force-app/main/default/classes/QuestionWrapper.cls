public with sharing class QuestionWrapper {
  // MR 18MAY25 QB Builder Changes
  // RT 20JUN25 - Removed unnecessary fields
  // RT 28JUN25 - Code Optimised
  public String id,
    key,
    placeholder,
    name,
    referenceField,
    uniqueIdentifier,
    additionalRichContent,
    groupName,
    title,
    subTitle,
    helpText,
    nextQuestion,
    errorMessage,
    questionText,
    question,
    questionBookId,
    questionBookKey,
    type,
    element,
    parentQuestion,
    subText,
    elementMode,// VD 20Sep25 - line element Fix
    fieldsMeta,
    recordTypeName,
    recordTypeId,
    trackingId,
    dateText,
    timeText,
    recordId,
    qbReference,
    qbReferenceQuestions,
    questionBookSubTitle,
    style,
    objectApiName,
    fieldApiName,
    tableHeadStyle,
    tableDataStyle,
    imgSrc,
    tableValue,
    tableCondition,
    qbObj,
    label,
    value,
    input,
    dateFormat, // RT 19SEP25 - Date Format
    locale, // RT 06OCT25 - Currency Format
    currencyCode,
    snoTitle, // RT 13OCT25 - Added S.No Title for Table
    inputDetail,
    signURLReference, // VD 29Sep25 signpad datetime/url update changes
    signDateTimeReference, // VD 30Sep25 location changes
    locationDateTimeReference,// VD 03Oct25 - location changes
    longitudeReference,
    latitudeReference;

  public Integer questionNumber, 
    fieldNo, 
    size;
  public Boolean isOptional,
    isTitle,
    readOnly,
    isHide,
    isAddRowAction,
    isDeleteRowAction,
    isSno,
    isSerialNo,
    isRowDraggable,
    isDependent,
    isReadJSONFromAttachment,
    isRichText, // VD 29jun24 richText Support
    isSerialNumber, // RT 29JUL25 - Added isSerialNumber
    enableNameSigning,// VD 26Sep25 signPad changes
    enableSignatureDrawing,// VD 26Sep25 signPad changes
    enableDefaultLocation, // VD 30Sep25 location changes
    isSignPadEnabled; // RT 09JAN26 - SignPad Enable Check

  @AuraEnabled public Boolean isHidden; // RT 08SEP25 - Added CRUD Validation
  @AuraEnabled public Boolean isReadOnly;
  


  public Decimal minimumFractionDigits; // RT 24JUL25 - added for decimal support
  public Decimal maximumFractionDigits; // RT 24JUL25 - added for decimal support

  // Related Wrappers
  public List<QuestionWrapper> subQuestions;
  public List<OptionWrapper> options;
  public List<ActionWrapper> actions;
  public List<StyleWrapper> styles;

  // Constructor
  public QuestionWrapper(Question__c question) {
    this.id = question.Id;
    this.name = question.Name;
    this.referenceField = question.Reference_Field__c;
    this.uniqueIdentifier = question.Unique_Identifier__c;
    this.additionalRichContent = question.Additional_Rich__c;
    this.groupName = question.Group__c;
    this.title = question.Title__c;
    this.imgSrc = question.Title__c; // Used separately
    this.subTitle = question.SubTitle__c;
    this.dateFormat = question.Date_Format__c; // RT 19SEP25 - Date Format
    this.locale = question.Locale__c; // RT 06OCT25 - Currency Format
    this.currencyCode = question.Currency_Code__c; 
    this.isOptional = question.Is_Optional__c;
    this.isTitle = question.Is_Title__c;
    this.isReadOnly = question.Read_Only__c;
    this.isSerialNumber = question.Is_Serial_No__c; // RT 29JUL25 - Added isSerialNumber
    this.isHide = question.Is_Hide__c; // RT 28JUN25 - isHide added
    this.isHidden = question.Is_Hide__c;
    this.snoTitle = question.Sno_Title__c; // RT 13OCT25 - Added S.No Title for Table
    this.helpText = question.Help_Text__c;
    this.minimumFractionDigits = question.Minimum_Fraction_Digits__c; // RT 24JUL25 - added for decimal support
    this.maximumFractionDigits = question.Maximum_Fraction_Digits__c;
    this.nextQuestion = question.Next_Question__c;
    this.errorMessage = question.Error_Message__c;
    this.questionText = question.Question_Text__c;
    this.label = question.Question_Text__c; // unified
    this.placeholder = question.Question__c;
    this.question = question.Question__c; // unified
    this.questionNumber = this.fieldNo = (question.Question_No__c != null)
      ? question.Question_No__c.intValue()
      : null;
    this.questionBookId = question.Question_Book__c;
    this.size = (question.Size__c != null) ? question.Size__c.intValue() : null;
    this.type = this.element = question.Type__c;
    this.parentQuestion = question.Question_Parent__c;
    this.subText = question.Sub_Text__c;
    // VD 20Sep25 - line element Fix
    this.elementMode = question.Element_Mode__c;
    this.fieldsMeta = question.Fields_Meta__c;
    this.recordTypeName = question.RecordType != null
      ? question.RecordType.Name
      : null;
    this.recordTypeId = question.RecordTypeId;
    this.trackingId = question.Tracking_ID__c;
    this.dateText = question.Date_Text__c;
    this.timeText = question.Time_Text__c;
    this.recordId = question.Record_Id__c;
    this.qbReference = question.QB_Reference__c;
    this.qbObj = (question.QB_Reference__c != null)
      ? question.QB_Reference__r.Anchor_Object__c
      : null;
    this.qbReferenceQuestions = question.QB_Reference_Questions__c;
    this.questionBookSubTitle = (question.Question_Book__r != null)
      ? question.Question_Book__r.SubTitle__c
      : null;
    this.style = question.Style__c;
    this.value = question.Value__c; // VD 29Jul25 default value handling
    // Table actions
    this.isAddRowAction = question.IsAddRowAction__c;
    this.isDeleteRowAction = question.IsDeleteRowAction__c;
    this.isSno = question.isSno__c;
    this.isSerialNo = question.Is_Serial_No__c;
    this.isRowDraggable = question.Is_Row_Draggable__c;
    this.isDependent = question.Is_Dependent__c;
    this.isReadJSONFromAttachment = question.Is_ReadJSONFromAttachment__c;
    this.isRichText = question.Is_Rich_Text__c; //VD 29jun24 richText Support
    this.inputDetail = question.Input_JSON__c; //  VD 04jul25 - input handling changes
    this.enableNameSigning = question.Enable_Name_Signing__c; // VD 26Sep25 signPad changes
    this.enableSignatureDrawing = question.Enable_Signature_Drawing__c;
    this.enableDefaultLocation = question.Enable_Default_Location__c; // VD 30Sep25 location changes
    // VD 29Sep25 signpad datetime/url update changes
    this.signUrlReference = question.Sign_URL_Reference__c;
    this.signDateTimeReference = question.Sign_DateTime_Reference__c;
    this.isSignPadEnabled = question.Is_SignPad_Enabled__c; // RT 09JAN26 - SignPad Enable Check
    // VD 03Oct25 - location changes
    this.locationDateTimeReference = question.Location_DateTime_Reference__c;
    this.longitudeReference = question.Longitude_Reference__c; // VD 30Sep25 location changes
    this.latitudeReference = question.Latitude_Reference__c;

    // RT 08SEP25 - Added CRUD Validation
    if (String.isNotBlank(this.referenceField) && this.readOnly == false) {
      try {
          if (!this.referenceField.contains('.')) {
            return;
          }
          List<String> parts = this.referenceField.split('\\.');
          if (parts.isEmpty()) {
            return;
          }

          // First part is the root object (e.g. "Account")
          Schema.SObjectType currentType = Schema.getGlobalDescribe().get(parts[0]);

          Boolean accessible = false;
          Boolean createable = false;
          Boolean updateable = false;
          Boolean deletable = false;

          for (Integer i = 1; i < parts.size(); i++) {
              if (currentType == null) break;

              Map<String, Schema.SObjectField> fieldMap = currentType.getDescribe().fields.getMap();
              if (!fieldMap.containsKey(parts[i])) break;

              Schema.DescribeFieldResult dfr = fieldMap.get(parts[i]).getDescribe();

              if (i == parts.size() - 1) {
                  // Last part → actual field FLS
                  accessible = dfr.isAccessible();
                  createable = dfr.isCreateable();
                  updateable = dfr.isUpdateable();
                  // deletable = dfr.isDeletable(); // Removed: not supported on DescribeFieldResult
              } else {
                // For the object, check if deletable
                deletable = currentType.getDescribe().isDeletable();
                  // Relationship → go deeper
                  if (!dfr.getReferenceTo().isEmpty()) {
                      currentType = dfr.getReferenceTo()[0];
                  } else {
                      currentType = null;
                  }
              }
          }

          this.isHidden = !accessible;
          this.isReadonly = accessible && !(createable || updateable);
      } catch (Exception e) {
          this.isHidden = true;
          this.isReadonly = true;
      }
    }

    if(this.element == 'Table') {
      if(String.isNotBlank(this.title)) {

        try {
          Schema.SObjectType objType = Schema.getGlobalDescribe().get(this.title);
          if (objType != null) {
            Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
            this.isAddRowAction = objDescribe.isCreateable() || objDescribe.isUpdateable();
            this.isDeleteRowAction = objDescribe.isDeletable();
          }
        } catch (Exception e) {
          this.isAddRowAction = false;
          this.isDeleteRowAction = false;
        }
      }
    }


    // Wrap related sub-objects
    if (!isEmpty(question.Questions__r)) {
      this.subQuestions = new List<QuestionWrapper>();
      for (Question__c sub : question.Questions__r)
        this.subQuestions.add(new QuestionWrapper(sub));
    }

    if (!isEmpty(question.Question_Options__r)) {
      this.options = new List<OptionWrapper>();
      for (Option__c opt : question.Question_Options__r)
        this.options.add(new OptionWrapper(opt));
    }

    if (!isEmpty(question.Actions__r)) {
      this.actions = ActionWrapper.createList(question.Actions__r);
    }

    if (!isEmpty(question.Styles__r)) {
      this.styles = StyleWrapper.createList(question.Styles__r);
    }
  }

  // // Helper to check empty
  private static Boolean isEmpty(List<SObject> list1) {
    return list1 == null || list1.isEmpty();
  }

  // Convert wrapper to Question__c
  public static Question__c loadQuestionWrapper(QuestionWrapper qw) {
    Question__c ques = new Question__c();

    if (String.isNotEmpty(qw.id)) {
      ques.Id = qw.id;
    }
    ques.Form_Identifier__c = qw.key;
    ques.Question_Book__c = qw.questionBookId;
    ques.Question_No__c = qw.fieldNo;
    ques.Question_Text__c = qw.label;
    ques.Minimum_Fraction_Digits__c = qw.minimumFractionDigits; // RT 24JUL25 - added for decimal support
    ques.Maximum_Fraction_Digits__c = qw.maximumFractionDigits;
    ques.Question__c = qw.placeholder;
    ques.Date_Format__c = qw.dateFormat; // RT 19SEP25 - Date Format
    ques.Help_Text__c = qw.helpText;
    ques.Read_Only__c = qw.isReadOnly;
    ques.Is_Dependent__c = qw.isDependent;
    ques.Is_Hide__c = qw.isHide; // RT 29JUL25 - isHide added
    ques.Reference_Field__c = qw.referenceField;
    ques.Is_Rich_Text__c = qw.isRichText; // RT 29JUL25 - Rich Text Flag support in Builders
    ques.Is_Serial_No__c = qw.isSerialNumber; // RT 29JUL25 - Added isSerialNumber
    ques.Sub_Text__c = qw.subText;
    // VD 20Sep25 - line element Fix
    ques.Element_Mode__c = qw.elementMode;
    ques.Locale__c = qw.locale; // RT 06OCT25 - Currency Format
    ques.Currency_Code__c = qw.currencyCode;
    ques.Size__c = (qw.size != null) ? qw.size : 12;
    ques.Type__c = qw.element;
    ques.QB_Reference__c = qw.qbReference;
    ques.isSno__c = qw.isSno;
    ques.Sno_Title__c = qw.snoTitle; // RT 13OCT25 - Added S.No Title for Table
    ques.Title__c = qw.title; // VD 15July25 title added
    ques.Value__c = qw.value; // VD 29Jul25 default value handling
    ques.Enable_Name_Signing__c = qw.enableNameSigning; // VD 26Sep25 signPad changes
    ques.Enable_Signature_Drawing__c = qw.enableSignatureDrawing;
    ques.Enable_Default_Location__c = qw.enableDefaultLocation; // VD 30Sep25 location changes
    // VD 29Sep25 signpad datetime/url update changes
    ques.Sign_URL_Reference__c = qw.signURLReference;
    ques.Sign_DateTime_Reference__c = qw.signDateTimeReference;
    ques.Is_SignPad_Enabled__c = qw.isSignPadEnabled != null ? qw.isSignPadEnabled : false; // RT 09JAN26 - SignPad Enable Check
    // VD 03Oct25 - location changes
    ques.Location_DateTime_Reference__c = qw.locationDateTimeReference;
    ques.Longitude_Reference__c = qw.longitudeReference; // VD 30Sep25 location changes
    ques.Latitude_Reference__c = qw.latitudeReference;

    // Title mapping logic
    // RT 01JUL25 - Only append condition and value if both are present
    // RT 29JUL25 - Removed restrictions for Book since Anchor object it is derived from Title__c
    // RT 09OCT25 - anchor object update handling
    if (isImageType(qw)) {
      ques.Title__c = String.isNotEmpty(qw.imgSrc) ? qw.imgSrc : null;
    } else if (isTableorBook(qw)) {
      if (
        String.isNotEmpty(qw.referenceField) && qw.referenceField.contains('.')
      ) {
        List<String> refParts = qw.referenceField.split('\\.');
        if (refParts.size() > 1 && String.isNotEmpty(refParts[1]) && String.isNotEmpty(refParts[0])) {
          String title = refParts[0];
          ques.Title__c = title;
          String subtitle = refParts[1];
          if (
            String.isNotEmpty(qw.tableCondition) &&
            String.isNotEmpty(qw.tableValue)
          ) {
            subtitle += ' ' + qw.tableCondition + ' ' + qw.tableValue;
          }
          ques.SubTitle__c = subtitle;
        }
      }
    }

    // RecordTypeId assignment
    ques.RecordTypeId = getRecordTypeId(qw.element);
    System.debug('Snotitle'+ qw.snoTitle);

    return ques;
  }

  private static Boolean isImageType(QuestionWrapper qw) {
    return qw.element == 'Image';
  }

  // RT 29JUL25 - Check if the question is of type Table or Book
  private static Boolean isTableorBook(QuestionWrapper qw) {
    return qw.element == 'Table' || qw.element == 'Book';
  }

  private static Id getRecordTypeId(String elementType) {
    if (elementType == 'Dropdown') {
      return QuestionUtility.recordTypeIdByName.get('OPTIONONLY');
    } else if (elementType == 'Checkbox' || elementType == 'Radio') {
      return QuestionUtility.recordTypeIdByName.get('CONDITIONAL');
    } else {
      return QuestionUtility.recordTypeIdByName.get('UNCONDITIONAL');
    }
  }
}