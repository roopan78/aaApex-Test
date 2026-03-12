public without sharing class QuestionHandler implements DataHandler {
  @testvisible
  private String contactId = '';
  public static ErrorWrapper errWrapper = new ErrorWrapper();

  //constructor with one parameter to set the contact id
  public QuestionHandler(String contact) {
    this.contactId = contact;
  }

  public QuestionHandler() {
  }

  // MR 22OCT23 - SetContext Changes
  public void setContext(String field, Object value) {
    if (field == 'contactId') {
      this.contactId = (String) value;
    }
  }

  //getting the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }
  // VD 12Jun24 - translation changes
  //read the records of the user by passing the json input
  public String readRecords(String inputJSON, String languageCode) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    String quesId = inputJSON; // Assuming inputJSON is a simple string containing the Question ID

    Question__c retQ;

    try {
      // Query to retrieve the question, its options, and child questions
      retQ = [
        SELECT
          Id,
          Name,
          Reference_Field__c,
          Unique_Identifier__c, //AP 09DEC24 -added unique identifiert field in the query
          Additional_Rich__c,
          Group__c,
          Is_Date_Backward__c,
          Title__c,
          SubTitle__c,
          Is_Date_Forward__c,
          Is_Optional__c,
          Is_Title__c,
          Read_Only__c, //AP 09DEC24 -added help text field in the query
          // VD 05MAR25 table action changes
          IsAddRowAction__c,
          isSno__c,
          Is_Row_Draggable__c,
          Value__c,
          Is_Rich_Text__c, // VD 29jun24 richText Support
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
          Is_ReadJSONFromAttachment__c, // VD 12Jun25 handle JSON from attachment
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
          Question_Parent__c, //AP 09DEC24 -added parent qusetion field in the query
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
              Order__c,
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
              Is_ReadJSONFromAttachment__c, // VD 12Jun25 handle json from attachment
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
              Question_Parent__c,
              Size__c,
              Type__c,
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
              QB_Reference__c,
              QB_Reference_Questions__c,
              QB_Reference__r.Anchor_Object__c, // RT 12JUN25 - Anchor Object for QB
              Style__c,
              Is_Dependent__c
            FROM Questions__r
            ORDER BY Question_No__c
          )
        FROM Question__c
        WHERE Id = :quesId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      // VD 28jan25 handle the childquestions option correctly
      // Step 2: Collect IDs of all child questions for querying their options
      Set<Id> childQuestionIds = new Set<Id>();
      if (retQ.Questions__r != null) {
        for (Question__c subQuestion : retQ.Questions__r) {
          childQuestionIds.add(subQuestion.Id);
        }
      }

      // Step 3: Query options for all child questions
      Map<Id, List<Option__c>> childOptionsMap = new Map<Id, List<Option__c>>();
      if (!childQuestionIds.isEmpty()) {
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
          WHERE Question__c IN :childQuestionIds
          ORDER BY Order__c
        ]) {
          if (!childOptionsMap.containsKey(opt.Question__c)) {
            childOptionsMap.put(opt.Question__c, new List<Option__c>());
          }
          childOptionsMap.get(opt.Question__c).add(opt);
        }
      }

      // Step 4: Wrap the main question in the QuestionWrapper
      QuestionWrapper mainQuestionWrapper = new QuestionWrapper(retQ);

      // Step 5: Populate options for child questions
      if (mainQuestionWrapper.subQuestions != null) {
        for (
          QuestionWrapper subQuestionWrapper : mainQuestionWrapper.subQuestions
        ) {
          if (childOptionsMap.containsKey(subQuestionWrapper.id)) {
            subQuestionWrapper.options = new List<OptionWrapper>();
            for (Option__c opt : childOptionsMap.get(subQuestionWrapper.id)) {
              subQuestionWrapper.options.add(new OptionWrapper(opt));
            }
          }
        }
      }

      // Add the serialized data to JSON
      jsonGen.writeStringField('status', 'success');
      jsonGen.writeObjectField('question', mainQuestionWrapper);
    } catch (Exception rq) {
      // Handle exceptions and log error details
      System.debug(
        LoggingLevel.ERROR,
        'Error while read records. Error Message = ' + rq.getMessage()
      );
      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeStringField('errorCode', rq.getTypeName());
      jsonGen.writeStringField('errorMessage', rq.getMessage());
      jsonGen.writeStringField('errorStackTrace', rq.getStackTraceString());
    }

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