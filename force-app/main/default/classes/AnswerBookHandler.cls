public with sharing class AnswerBookHandler implements DataHandler {
  @testvisible
  private String contactId = '';
  public static ErrorWrapper errWrapper = new ErrorWrapper();
  //constructor with one parameter to set the contact id
  public AnswerBookHandler(String contact) {
    this.contactId = contact;
  }
  public AnswerBookHandler() {
    // system.debug('NXT APP');
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
  public String readRecords() {
    return '{"status":"failure","message":"Read operation is not supported"}';
  }
  //update the records of the user by passing the json input
  public String updateRecords(String inputJSON) {
    List<Answer_Book__c> answerBookList = new List<Answer_Book__c>();
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    String inpId = inputJSON;
   //Answer_Book__c retABS = new Answer_Book__c();
      try {
      Answer_Book__c retABS = [SELECT Id, Question_Book__c, Name, Status__c FROM Answer_Book__c WHERE id = :inpId WITH SECURITY_ENFORCED LIMIT 1][0];
      retABS.Status__c = 'Completed';
      AnswerBookHandlerWrapper wrapper = new AnswerBookHandlerWrapper( retABS);
      // Check if the Answer_Book__c and its fields are updateable
      if (
        Answer_Book__c.SObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.Answer_Book__c.fields.Status__c.isUpdateable()) {
        Database.update(retABS);
      }
      List<Answer__c> ans = [ SELECT Id, Question_Rich_Text__c, Answer_Long__c, Question_Group_Text__c, Question_Text__c, Number__c, Answer_Book__c, Question_Ref__c, Question_Type__c FROM Answer__c
        WHERE Answer_Book__c = :inpId AND Answer_Book__r.Status__c = 'Completed' WITH SECURITY_ENFORCED];

      List<AnswerWrapper> answers = new List<AnswerWrapper>();
      for (Answer__c aRec : ans) {
        answers.add(AnswerWrapper.convert(aRec));
      }
      // Build the response JSON
      jsonGen.writeStringField('status', 'success');
      jsonGen.writeObjectField('AnswerBook', wrapper);
      jsonGen.writeObjectField('Answers',answers );

    } catch (Exception abE) {
      System.debug(LoggingLevel.ERROR, 'Error while update Records Error Message = ' +
      abE.getMessage());

      errWrapper.errorCode = abE.getTypeName();
      errWrapper.errorMsg = abE.getMessage();
      errWrapper.errorDetails = abE.getStackTraceString();

      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeObjectField('message', errWrapper);
    }
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }
  //creation of records by passing the json as a parameter
  public String createRecords(String inputJSON) {
    return '{"status":"failure","message":"Create operation is not supported"}';
  }
  // VD 12Jun24 - translation changes
  //read records by passing the json as a parameter
  public String readRecords(String inputJSON, String languageCode) {
    return '{"status":"failure","message":"Read operation is not supported"}';
  }
  //deleting records of the user who have already exists, by passing the json as a parameter
  public String deleteRecords(String inputJSON) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    String ansId = inputJSON;
    //Answer_Book__c retABS = new Answer_Book__c();
    try {
      // Query to get Answer_Book__c and related answers using the Question_Book__c ID
      Answer_Book__c retABS = [
            SELECT Id, Question_Book__c, Name, Status__c, (SELECT Id, Number__c, Answer_Book__c, Question_Rich_Text__c, Answer_Long__c, Question_Ref__c, Question_Type__c, Question_Group_Text__c, Question_Text__c FROM Answers__r)
            FROM Answer_Book__c WHERE Id = :ansId WITH SECURITY_ENFORCED LIMIT 1 ];
            // Use a Set to avoid duplicate Answer__c IDs
            Set<Id> uniqueAnswerIds = new Set<Id>();
            List<Answer__c> answersToDelete = new List<Answer__c>();
            for (Answer__c answer : retABS.Answers__r) {
                if (uniqueAnswerIds.add(answer.Id)) {
                    // Only add unique answers
                    answersToDelete.add(answer);
                }
              } // Delete unique answers
      if (!answersToDelete.isEmpty()) {
        delete answersToDelete;
      }
      jsonGen.writeStringField('status', 'success');
      jsonGen.writeStringField('message', 'Records deleted successfully');
    }
    catch (Exception e) {
      System.debug(LoggingLevel.ERROR, 'Error while Deleting Records Error Message = ' + e.getMessage());
      jsonGen.writeStringField('status', 'error');
      jsonGen.writeObjectField('error', e.getMessage());}
      return jsonGen.getAsString();
    // return '{"status":"failure","message":"Delete operation is not supported"}';
  }
}