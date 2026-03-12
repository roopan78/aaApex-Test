/* * @description : Batch class to update Question__c records based on specific criteria.
 * @date        : 2025-06-21
 * @author      : Roopan Thangam A
 * @param       : questionIds - Set of Question IDs to process.
 * @version     : 1.0
 */
public class QuestionTriggerUpdateBatch implements Database.Batchable<SObject> {
    private Set<Id> questionIds;

    public QuestionTriggerUpdateBatch(Set<Id> questionIds) {
      this.questionIds = questionIds;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
      // Query only the questions we need to process
      return Database.getQueryLocator([
        SELECT Id, Unique_Identifier__c, Type__c, QB_Reference__c
        FROM Question__c
        WHERE Id IN :questionIds
      ]);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
      List<Question__c> questionScope = (List<Question__c>)scope;
      Set<Id> qbReferenceIds = new Set<Id>();
      for (Question__c q : questionScope) {
        if ((q.Type__c == 'Book' || q.Type__c == 'Table') && q.QB_Reference__c != null) {
          qbReferenceIds.add(q.QB_Reference__c);
        }
      }
      Map<Id, Question__c> childQuestionsMap = new Map<Id, Question__c>();
      if (!qbReferenceIds.isEmpty()) {
        for (Question__c childQ : [
          SELECT Id, Question_Book__c, QB_Reference__c FROM Question__c WHERE Question_Book__c IN :qbReferenceIds LIMIT 50
        ]) {
          childQuestionsMap.put(childQ.Question_Book__c, childQ);
        }
      }
      Set<Id> updateQuestions = new Set<Id>();
      for (Question__c q : questionScope) {
        Question__c childQ = childQuestionsMap.get(q.QB_Reference__c);
        if (childQ != null) {
          updateQuestions.add(childQ.Id);
        }
      }
      List<Question__c> questionsToUpdate = new List<Question__c>();
      for (Id questionId : updateQuestions) {
        questionsToUpdate.add(new Question__c(Id = questionId));
      }
      if (!questionsToUpdate.isEmpty()) {
        try {
          update questionsToUpdate;
        } catch (Exception e) {
          throw new QuestionBookManagerController.CustomException(
            'Error updating questions: ' + e.getStackTraceString() + ' line number ' + e.getLineNumber()
          );
        }
      }
    }

    public void finish(Database.BatchableContext bc) {
      String svgUrl = 'https://horizon-projects.s3.us-east-1.amazonaws.com/RangerNXT_Full+logo.svg'; 

      String htmlBody = '<html><body>';
      htmlBody += '<div style="text-align: center;">';
      htmlBody += '<img src="' + svgUrl + '" alt="RangerNXT Logo" width="200"/>';
      htmlBody += '<h2>Import JSON processed Successfully.</h2>';
      htmlBody += '<p>The Question Book Transfer has finished successfully.</p>';
      htmlBody += '</div></body></html>';

      Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
      mail.setToAddresses(new String[] { UserInfo.getUserEmail() });
      mail.setSubject('RangerNXT');
      mail.setHtmlBody(htmlBody);

      try {
          Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
      } catch (Exception e) {
          System.debug('Email failed: ' + e.getMessage());
      }
  }


  }