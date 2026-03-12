public with sharing class QuestionController {
  public static List<Answer__c> questionAnswerList { get; set; }
  public static ErrorWrapper errWrapper = new ErrorWrapper();

  @AuraEnabled(cacheable=true)
  public static Question_Book__c getQuestionBook(String qbId) {
    System.debug('Question Book ID => ' + qbId);
    String inpId = qbId;
    Question_Book__c retQB = new Question_Book__c();
    Answer_Book__c retAB = new Answer_Book__c();

    try {
      retQB = [
        SELECT
          Id,
          Name,
          Status__c,
          Title__c,
          SubTitle__c,
          First_Question__c,
          Last_Question__c,
          Possibilities__c,
          Progress_Bar__c,
          Version__c,
          Version_Status__c, //VD 20Jun25 removed boolean and created picklist
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Edit__c,
          Summary_Text__c,
          Summary_Sub_Text__c,
          (SELECT Id, Reference_Field__c, Group__c FROM Questions__r)
        FROM Question_Book__c
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      // create the answerbook
      retAB.Question_Book__c = inpId;
      retAB.Status__c = 'Pending';
      if (
        Answer_Book__c.SObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isCreateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Status__c.isCreateable()
      ) {
        Database.insert(retAB);
      }
      System.debug('Line 27 try => ' + retQB);
    } catch (Exception qbE) {
      // Input param is AnswerBook Id
      retAB = [
        SELECT
          Id,
          Question_Book__c,
          Status__c,
          Name,
          (
            SELECT
              Id,
              Question_Rich_Text__c,
              Answer_Long__c,
              Question_Ref__c,
              Question_Type__c,
              Question_Group_Text__c,
              Question_Text__c
            FROM Answers__r
          )
        FROM Answer_Book__c
        WHERE id = :inpId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      retQB = [
        SELECT
          Id,
          Name,
          Status__c,
          Title__c,
          SubTitle__c,
          First_Question__c,
          Last_Question__c,
          Possibilities__c,
          Progress_Bar__c,
          Version__c,
          Version_Status__c, //VD 20Jun25 removed boolean and created picklist
          Category__c,
          Total_Questions__c,
          Next__c,
          Back__c,
          Submit__c,
          Cancel__c,
          Edit__c,
          (SELECT Id, Reference_Field__c, Group__c FROM Questions__r)
        FROM Question_Book__c
        WHERE id = :retAB.Question_Book__c
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
      System.debug('Line 27 C => ' + retQB);
    }
    return retQB;
  }

  @AuraEnabled
  public static Question__c getQuestion(String quesId) {
    System.debug('Question ID => ' + quesId);
    Question__c retQ = new Question__c();

    retQ = [
      SELECT
        Id,
        Name,
        Reference_Field__c,
        Type__c,
        Question_Text__c,
        Question__c,
        Next_Question__c,
        RecordType.Name,
        Sub_Text__c,
        Element_Mode__c,
        Title__c,
        SubTitle__c,
        Is_Optional__c,
        Group__c,
        Question_No__c,
        Next__c,
        Back__c,
        Submit__c,
        Cancel__c,
        Edit__c,
        Date_Text__c,
        Time_Text__c,
        (
          SELECT Id, Name, Value__c, Is_Default__c, Next_Question__c, Order__c
          FROM Question_Options__r
          ORDER BY Order__c
        )
      FROM Question__c
      WHERE id = :quesId
      WITH SECURITY_ENFORCED
      LIMIT 1
    ];
    system.debug('retQ-->' + retQ);

    return retQ;
  }

  @AuraEnabled
  public static Answer_Book__c saveAnswer(String inpWrapperJSON) {
    // Deserialize the input from UI
    AnswerWrapper inpWrapper = (AnswerWrapper) JSON.deserialize(
      inpWrapperJSON,
      AnswerWrapper.class
    );
    // Initialiting a Answer Book
    Answer_Book__c retAB = new Answer_Book__c();
    if (inpWrapper.abId == null) {
      // If Answer Book is NOT already existing
      try {
        // Read the Question
        Question__c retQ = [
          SELECT Id, Question_Book__c
          FROM Question__c
          WHERE ID = :inpWrapper.quesId
          WITH SECURITY_ENFORCED
        ];

        // Set the values on the Answer Book
        retAB.Question_Book__c = retQ.Question_Book__c;
        retAB.Status__c = 'Pending';

        // Write the value to the DB
        if (
          Answer_Book__c.SObjectType.getDescribe().isCreateable() &&
          Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isCreateable() &&
          Schema.sObjectType.Answer_Book__c.fields.Status__c.isCreateable()
        ) {
          Database.insert(retAB);
        }
        // Set the newly created Answer Book to the Wrapper
        inpWrapper.abId = retAB.Id;
      } catch (Exception abie) {
        errWrapper.errorCode = abie.getTypeName();
        errWrapper.errorMsg = abie.getMessage();
        errWrapper.errorDetails = abie.getStackTraceString();
      }
    } else {
      // Remove all the answer records after this answer number
      List<Answer__c> unusedList = [
        SELECT Id, Name, Question_Ref__c
        FROM Answer__c
        WHERE
          Answer_Book__c = :inpWrapper.abId
          AND Number__c >= :inpWrapper.ansNumber
        WITH SECURITY_ENFORCED
      ];
      if (unusedList.size() > 0) {
        if (
          Schema.sObjectType.Answer__c.isDeletable() &&
          Answer__c.sObjectType.getDescribe().isDeletable()
        ) {
          Database.delete(unusedList);
        }
      }
    }

    // Answer Book is available to save the Answer
    if (inpWrapper.abId != null) {
      // Initialize the Answer variable
      Answer__c ans = new Answer__c();
      Answer_Book__c ab = new Answer_Book__c();

      // Set the status for answerbook
      ab.Status__c = inpWrapper.status;

      // Set the values passed from UI
      ans.Number__c = inpWrapper.ansNumber;
      ans.Answer_Book__c = inpWrapper.abId;
      ans.Question_Ref__c = inpWrapper.quesId;
      ans.Question_Rich_Text__c = inpWrapper.quesValue.escapeHtml4();
      ans.Question_Type__c = inpWrapper.qTyp;
      ans.Answer_Long__c = inpWrapper.ansValue.escapeHtml4();
      ans.Question_Group_Text__c = inpWrapper.GroupText;
      ans.Question_Text__c = inpWrapper.squesValue.escapeHtml4();

      // Save the variable value to the DB
      if (
        Answer__c.SObjectType.getDescribe().isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Number__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Answer_Book__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Question_Ref__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Question_Rich_Text__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Question_Type__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Answer_Long__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Question_Group_Text__c.isCreateable() &&
        Schema.sObjectType.Answer__c.fields.Question_Text__c.isCreateable()
      ) {
        Database.insert(ans);
      }
      // Return the Answer Book
      retAB = [
        SELECT
          Id,
          Status__c,
          Name,
          (SELECT Id, Name, Question_Ref__c, Answer_Long__c FROM Answers__r)
        FROM Answer_Book__c
        WHERE Id = :inpWrapper.abId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
    }
    return retAB;
  }

  @AuraEnabled
  public static void updateAnswer(String aId, String typ, String ansValue) {
    System.debug('Answer ID => ' + aId);
    Answer__c ans = new Answer__c(Id = aId);
    ans.Answer_Long__c = ansValue;
    if (
      Answer__c.SObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Answer__c.fields.Answer_Long__c.isUpdateable()
    ) {
      Database.update(ans);
    }
  }

  @AuraEnabled
  public static void updateABstatus(String abId, String status) {
    Answer_Book__c ab = new Answer_Book__c(Id = abId);
    ab.Status__c = status;
    if (
      Answer_Book__c.SObjectType.getDescribe().isUpdateable() &&
      Schema.sObjectType.Answer_Book__c.fields.Status__c.isUpdateable()
    ) {
      Database.update(ab);
    }
  }

  @AuraEnabled
  public static List<Answer__c> getQuestionAnswer(String qbId) {
    Answer__c retQB = [
      SELECT
        id,
        answer_book__c,
        Answer_Long__c,
        Question_Rich_Text__c,
        Question_Group_Text__c,
        Question_Text__c
      FROM Answer__c
      WITH SECURITY_ENFORCED
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];
    List<Answer__c> ansq = [
      SELECT
        id,
        answer_book__c,
        Answer_Long__c,
        Question_Rich_Text__c,
        Question_Group_Text__c,
        Question_Text__c
      FROM Answer__c
      WHERE answer_book__c = :retQB.answer_book__c
      WITH SECURITY_ENFORCED
    ];
    questionAnswerList = ansq;
    return ansq;
  }
  @AuraEnabled
  public static String getBaseUrl() {
    return URL.getSalesforceBaseUrl().toExternalForm();
  }
}