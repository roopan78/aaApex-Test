public with sharing class AnswerHandler implements DataHandler {
  @testvisible
  private String contactId = '';
  public static ErrorWrapper errWrapper = new ErrorWrapper();

  //constructor with one parameter to set the contact id
  public AnswerHandler(String contact) {
    this.contactId = contact;
  }

  public AnswerHandler() {
    system.debug('NXT APP');
  }

  // MR 22OCT23 - SetContext Changes
  public void setContext(String field, Object value) {
    if(field == 'contactId') {
        this.contactId = (String) value;
    }
  }

  //getting the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }
   // VD 12Jun24 - translation changes
  //read the records of the user by passing the json input
  public String readRecords(String inputJSON,String languageCode) {
    return '{"status":"failure","message":"read operation is not supported"}';
  }

  //creation of records by passing the json as a parameter
  public String createRecords(String inputJSON) {
    List<Answer_Book__c> answerBookList = new List<Answer_Book__c>();
    List<Answer__c> answerList = new List<Answer__c>();

    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    AnswerWrapper inpWrapper = (AnswerWrapper) JSON.deserialize(inputJSON, AnswerWrapper.class);

    Answer_Book__c retAB = new Answer_Book__c();
    if (inpWrapper.abId == null) {
      try {
        Question__c retQ = [SELECT Id, Question_Book__c FROM Question__c WHERE ID = :inpWrapper.quesId WITH SECURITY_ENFORCED][0];

        retAB.Question_Book__c = retQ.Question_Book__c;
        retAB.Status__c = 'Pending';

        SObjectAccessDecision createAccess = Security.stripInaccessible( AccessType.CREATABLE, new List<Answer_Book__c>{ retAB });

        if (createAccess.getRecords().size() > 0) {
          if (Answer_Book__c.SObjectType.getDescribe().isCreateable() &&
              Schema.sObjectType.Answer_Book__c.fields.Question_Book__c.isCreateable() &&
              Schema.sObjectType.Answer_Book__c.fields.Status__c.isCreateable()
          ) {
            Database.insert(retAB);
          }
        }

        inpWrapper.abId = retAB.Id;
      } catch (Exception abie) {
        errWrapper.errorCode = abie.getTypeName();
        errWrapper.errorMsg = abie.getMessage();
        errWrapper.errorDetails = abie.getStackTraceString();

        jsonGen.writeStringField('status', 'failure');
        jsonGen.writeObjectField('error', errWrapper);
      }
    }

    if (inpWrapper.abId != null) {
      Answer__c ans = new Answer__c();
      ans.Number__c = inpWrapper.ansNumber;
      ans.Answer_Book__c = inpWrapper.abId;
      ans.Question_Ref__c = inpWrapper.quesId;
      ans.Question_Rich_Text__c = inpWrapper.quesValue.escapeHtml4();
      ans.Question_Type__c = inpWrapper.qTyp;
      ans.Answer_Long__c = inpWrapper.ansValue.escapeHtml4();
      ans.Question_Group_Text__c = inpWrapper.GroupText;

      if(inpWrapper.squesValue != null){
        ans.Question_Text__c = inpWrapper.squesValue.escapeHtml4();
      }

      try {
        SObjectAccessDecision createAcces = Security.stripInaccessible(
          AccessType.CREATABLE,
          new List<Answer__c>{ ans }
        );

        if (createAcces.getRecords().size() > 0) {
          if(Answer__c.SObjectType.getDescribe().isCreateable() && Schema.sObjectType.Answer__c.fields.Number__c.isCreateable()
            && Schema.sObjectType.Answer__c.fields.Answer_Book__c.isCreateable() && Schema.sObjectType.Answer__c.fields.Question_Ref__c.isCreateable()
            && Schema.sObjectType.Answer__c.fields.Question_Rich_Text__c.isCreateable() && Schema.sObjectType.Answer__c.fields.Question_Type__c.isCreateable()
            && Schema.sObjectType.Answer__c.fields.Answer_Long__c.isCreateable() && Schema.sObjectType.Answer__c.fields.Question_Group_Text__c.isCreateable()
            && Schema.sObjectType.Answer__c.fields.Question_Text__c.isCreateable())
          {
            Database.insert(ans);
            inpWrapper.ansId = ans.Id;
          }
        }

        jsonGen.writeStringField('status', 'success');
        jsonGen.writeObjectField('answer', inpWrapper);

        List<Answer__c> answers =[select id,Answer_Long__c,Question_Rich_Text__c, Question_Group_Text__c, Question_Text__c,
                                  Question_Type__c from Answer__c where Answer_Book__c =: inpWrapper.abId WITH SECURITY_ENFORCED];
        jsonGen.writeObjectField('questionanswers', answers);
      } catch (Exception ie) {
        // AP 09DEC24 - Added detailed error logging
        System.debug(LoggingLevel.ERROR, 'Error while create Records Error Message = ' +
        ie.getMessage());
        errWrapper.errorCode = ie.getTypeName();
        errWrapper.errorMsg = ie.getMessage();
        errWrapper.errorDetails = ie.getStackTraceString();

        jsonGen.writeStringField('status', 'failure');
        jsonGen.writeObjectField('error', errWrapper);
      }
    }
    // MR 05FEB24 Handle the remaining answers - deleting them all is not a right solution
    // Remove all the answer records after this answer number
    //if (Schema.sObjectType.Answer__c.isDeletable()) {
    // if(inpWrapper.qTyp == 'Radio') {
    //   List<Answer__c> unusedList = [SELECT Id, Name, Question_Ref__c FROM Answer__c WHERE Answer_Book__c = :inpWrapper.abId
    //         AND Number__c > :inpWrapper.ansNumber WITH SECURITY_ENFORCED];
    //   if (unusedList.size() > 0 && Schema.sObjectType.Answer__c.isDeletable() && Answer__c.sObjectType.getDescribe().isDeletable()) {
    //     Database.delete(unusedList);
    //   }
    // }
    // }

    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  //updating records of the user who have already exists by passing the json as a parameter
  public String updateRecords(String inputJSON) {
    List<Answer__c> ansList = new List<Answer__c>();
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    AnswerWrapper inpWrapper = (AnswerWrapper) JSON.deserialize(inputJSON, AnswerWrapper.class);

    Answer__c ans = new Answer__c();
    ans.Id = inpWrapper.ansId;
    ans.Number__c = inpWrapper.ansNumber;
    ans.Question_Ref__c = inpWrapper.quesId;
    ans.Question_Rich_Text__c = inpWrapper.quesValue.escapeHtml4();
    ans.Question_Type__c = inpWrapper.qTyp;
    ans.Answer_Long__c = inpWrapper.ansValue.escapeHtml4();
    ans.Question_Group_Text__c = inpWrapper.GroupText;
    ans.Question_Text__c = inpWrapper.squesValue.escapeHtml4();

    // Used saveResult to handle Exception on DML operation v1.0.3 --25AUG2020
    // MR 06FEB24 - Answer Update Fix
    try {
      SObjectAccessDecision updateAccess = Security.stripInaccessible( AccessType.UPDATABLE, new List<Answer__c>{ ans } );
      if (updateAccess.getRecords().size() > 0) {
        if(Answer__c.SObjectType.getDescribe().isUpdateable() &&
          Schema.sObjectType.Answer__c.fields.Number__c.isUpdateable() && Schema.sObjectType.Answer__c.fields.Question_Ref__c.isUpdateable() &&
          Schema.sObjectType.Answer__c.fields.Question_Rich_Text__c.isUpdateable() && Schema.sObjectType.Answer__c.fields.Question_Type__c.isUpdateable() &&
          Schema.sObjectType.Answer__c.fields.Answer_Long__c.isUpdateable() && Schema.sObjectType.Answer__c.fields.Question_Group_Text__c.isUpdateable() &&
          Schema.sObjectType.Answer__c.fields.Question_Text__c.isUpdateable()
        ) {
          Database.update(ans);
          jsonGen.writeStringField('status', 'success');
          jsonGen.writeObjectField('answer', AnswerWrapper.convert(ans));
        } else {
          jsonGen.writeStringField('status', 'failure field access problem');
        }
      } else {
        jsonGen.writeStringField('status', 'failure record access problem');
      }
    } catch (Exception ue) {
      // AP 09DEC24 - Added detailed error logging
      System.debug(LoggingLevel.ERROR, 'Error while update Records Error Message = ' +
      ue.getMessage());
      errWrapper.errorCode = ue.getTypeName();
      errWrapper.errorMsg = ue.getMessage();
      errWrapper.errorDetails = ue.getStackTraceString();

      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeObjectField('error', errWrapper);
    }

    // if(inpWrapper.qTyp == 'Radio') {
    //   this.handleExisting(inpWrapper);
    // }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  //deleting records of the user who have already exists, by passing the json as a parameter
  public String deleteRecords(String inputJSON) {
    return '{"status":"failure","message":"Delete operation is not supported"}';
  }

  // MR 05FEB24 - Function to handle the answer records that are existing after the created/updated answer.
  public void handleExisting(AnswerWrapper inpWrapper) {
    // Remove all the answer records after this answer number
    List<Answer__c> unusedList = [SELECT Id, Name, Question_Ref__c, Answer_Long__c FROM Answer__c WHERE Answer_Book__c = :inpWrapper.abId
        AND Number__c > :inpWrapper.ansNumber WITH SECURITY_ENFORCED ];
    if (unusedList.size() > 0 && Schema.sObjectType.Answer__c.isDeletable() && Answer__c.sObjectType.getDescribe().isDeletable()) {
      Database.delete(unusedList);
    }
    // If the current answer is Conditional, then we have an impact
    // Non-conditional answers need not to be worrie
  }

  public String getAnswerCount(String abId) {
    if (abId != null) {
      SObjectAccessDecision decisionRead = Security.stripInaccessible(
        AccessType.READABLE,
        [ SELECT id, Answer_Book__c, name FROM answer__c WHERE Answer_Book__c = :abId WITH SECURITY_ENFORCED]);
      if (decisionRead.getRecords().size() > 0) {
        //jsonGen.writeNumberField('answerCount', ansList.size());
        return '' + decisionRead.getRecords().size() + 1;
      }
    }
    return '1';
  }
}