/*
 * Test class for QuestionWrapper.
 */
@isTest
public class QuestionWrapperTest {
  @isTest
  static void testQuestionWrapper() {
    // Create test data
    Account account = new Account(Name = 'Test Account');
    insert account;

    // Create a parent Question_Book__c record
    Question_Book__c questionBook = new Question_Book__c(
      Title__c = 'Test Question Book',
      Unique_Identifier__c = 'qwrap',
      Category__c = 'Simple'
    );
    insert questionBook;

    // Create parent Question__c record
    Question__c parentQuestion = new Question__c(
      Reference_Field__c = 'Next Question',
      Unique_Identifier__c = 'UID123',
      Additional_Rich__c = 'Additional Content',
      Group__c = 'Group1',
      Is_Date_Backward__c = true,
      Title__c = 'Parent Title',
      SubTitle__c = 'Parent SubTitle',
      Is_Date_Forward__c = false,
      Is_Optional__c = true,
      Is_Title__c = true,
      Read_Only__c = false,
      Is_Hide__c = false,
      Help_Text__c = 'Help Text',
      //Next_Question__c = 'a06fL000000Vd3VQAS',
      Error_Message__c = 'Error Message',
      X24_Hours__c = true,
      Allowed_File_Extensions__c = '.jpg',
      Question_Text__c = 'What is your name?',
      Question__c = 'Name Question',
      Question_No__c = 1,
      Question_Book__c = questionBook.Id,
      Size__c = 10,
      Type__c = 'Dropdown',
      Question_Parent__c = null,
      Sub_Text__c = 'Sub Text',
      Element_Mode__c = 'Line',// VD 20Sep25 - line element Fix
      Fields_Meta__c = 'Meta Data',
      RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
        .get('CONDITIONAL')
        .getRecordTypeId(),
      Tracking_ID__c = 'Tracking123',
      Date_Text__c = 'Date Text',
      Time_Text__c = 'Time Text',
      QB_Reference__c = questionBook.Id,
      QB_Reference_Questions__c = 'Reference Questions',
      Style__c = 'Default Style'
    );
    insert parentQuestion;

    // Create child Question__c records
    List<Question__c> childQuestions = new List<Question__c>();
    for (Integer i = 1; i <= 2; i++) {
      childQuestions.add(
        new Question__c(
          Question_Parent__c = parentQuestion.Id,
          Reference_Field__c = 'Ref' + i,
          Unique_Identifier__c = 'UID' + i,
          Question_Text__c = 'Child Question Text ' + i,
          Question_No__c = i + 1,
          Question_Book__c = questionBook.Id
        )
      );
    }
    insert childQuestions;

    // Create Question_Options__c records for the parent question
    List<Option__c> options = new List<Option__c>();
    for (Integer i = 1; i <= 2; i++) {
      options.add(
        new Option__c(
          Question__c = parentQuestion.Id,
          Unique_Identifier__c = 'opp' + i,
          Value__c = 'Value ' + i,
          Order__c = i
        )
      );
    }
    insert options;

    // Query the parent Question__c with related records
    Question__c queriedQuestion = [
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
        Is_Rich_Text__c,
        Is_Optional__c,
        Is_Title__c,
        Read_Only__c,
        IsAddRowAction__c,
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
        Size__c,
        Type__c,
        Question_Parent__c,
        QB_Reference__r.Anchor_Object__c,
        Sub_Text__c,
        Element_Mode__c,
        Fields_Meta__c,
        RecordType.Name,
        RecordTypeId,
        Tracking_ID__c,
        Date_Text__c,
        Time_Text__c,
        QB_Reference__c,
        QB_Reference_Questions__c,
        isSno__c,
        Is_Row_Draggable__c,
        Minimum_Fraction_Digits__c,
        Maximum_Fraction_Digits__c,
        Currency_Code__c,
        Locale__c,
        Sno_Title__c, // RT 13OCT25 - S.no Title
        Enable_Signature_Drawing__c,// VD 29Sep25 signpad datetime/url update changes
        Sign_URL_Reference__c,
        Date_Format__c,
        Sign_DateTime_Reference__c,
        Is_SignPad_Enabled__c, // RT 09JAN26 - SignPad Enable Check
        Location_DateTime_Reference__c,
        Longitude_Reference__c,
        Latitude_Reference__c,
        Value__c,
        Enable_Name_Signing__c,
        Enable_Default_Location__c,
        Input_JSON__c,
        Is_Serial_No__c,
        Style__c,
        Is_Dependent__c,
        Is_ReadJSONFromAttachment__c,
        IsDeleteRowAction__c,
        Question_Book__r.SubTitle__c,
        Record_Id__c,
        (
          SELECT
            Id,
            Name,
            Reference_Field__c,
            Unique_Identifier__c,
            Additional_Rich__c,
            Group__c,
            Is_Date_Backward__c,
            QB_Reference__r.Anchor_Object__c,
            Title__c,
            Value__c,
            SubTitle__c,
            Is_Date_Forward__c,
            Is_Optional__c,
            Is_Title__c,
            Read_Only__c,
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
            Size__c,
            Record_Id__c,
            Type__c,
            Question_Parent__c,
            isSno__c,
            IsDeleteRowAction__c,
            Sub_Text__c,
            Element_Mode__c,
            Fields_Meta__c,
            RecordType.Name,
            RecordTypeId,
            Tracking_ID__c,
            Date_Text__c,
            Is_Serial_No__c,
            Is_Rich_Text__c,
            Time_Text__c,
            QB_Reference__c,
            Is_ReadJSONFromAttachment__c,
            QB_Reference_Questions__c,
            IsAddRowAction__c,
            Is_Row_Draggable__c,
            Minimum_Fraction_Digits__c,
            Maximum_Fraction_Digits__c,
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
            Date_Format__c,
            Enable_Name_Signing__c,
            Enable_Default_Location__c,
            Input_JSON__c,
            Style__c,
            Is_Dependent__c,
            Question_Book__r.SubTitle__c
          FROM Questions__r
        ),
        (
          SELECT
            Id,
            Name,
            Question__c,
            Unique_Identifier__c,
            Value__c,
            Order__c,
            Is_Default__c,
            Next_Question__c
          FROM Question_Options__r
        )
      FROM Question__c
      WHERE Id = :parentQuestion.Id
    ];

    // Initialize the wrapper class
    QuestionWrapper wrapper = new QuestionWrapper(queriedQuestion);

    // Assertions to validate the data
    System.assertNotEquals(null, wrapper);
    //System.assertEquals(parentQuestion.Name, wrapper.name);
    System.assertEquals(
      parentQuestion.Reference_Field__c,
      wrapper.referenceField
    );
    System.assertEquals(2, wrapper.subQuestions.size());
    System.assertEquals(2, wrapper.options.size());
    System.assertEquals(
      childQuestions[0].Question_Text__c,
      wrapper.subQuestions[0].questionText
    );
    //System.assertEquals(options[0].Name, wrapper.options[0].name);
  }
}