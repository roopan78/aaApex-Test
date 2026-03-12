public with sharing class AnswerBookWrapper {
    public String id; // Id of the Answer_Book__c record
    public String questionBookId; // Question_Book__c
    public String name; // Name of the Answer_Book__c
    public String status; // Status__c
    public String recordId; // RecordId__c
    public String answerLong; // Answer_Long__c
    public List<AnswerWrapper> answers; // List of related AnswerWrapper objects

    public AnswerBookWrapper(Answer_Book__c answerBook) {
        this.id = answerBook.Id;
        this.questionBookId = answerBook.Question_Book__c;
        this.name = answerBook.Name;
        this.status = answerBook.Status__c;
        this.recordId = answerBook.RecordId__c;
        this.answerLong = answerBook.Answer_Long__c;

        // Wrap related Answers__r records
        if (answerBook.Answers__r != null && !answerBook.Answers__r.isEmpty()) {
            for (Answer__c answer : answerBook.Answers__r) {
                this.answers = new List<AnswerWrapper>();
                this.answers.add(AnswerWrapper.convert(answer));
            }
        }
    }
}