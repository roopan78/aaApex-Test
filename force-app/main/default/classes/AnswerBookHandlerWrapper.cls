public with sharing class AnswerBookHandlerWrapper {
    public String id;
    public String name;
    public String status;
    public Id questionBookId;
    public List<AnswerWrapper> answers;

    public AnswerBookHandlerWrapper(Answer_Book__c retABS) {
        this.id = retABS.Id;
        this.name = retABS.Name;
        this.status = retABS.Status__c;
        this.questionBookId = retABS.Question_Book__c;
     }
}