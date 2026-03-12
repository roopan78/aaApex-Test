public class QuestionOptionWrapper {
    public Id optionId;
    public String optionName;
    public String value;
    public String nextQuestion;

    public QuestionOptionWrapper(Option__c retOption) {
        this.optionId = retOption.Id;
        this.optionName = retOption.Name;
        this.value = retOption.Value__c;
        this.nextQuestion = retOption.Next_Question__c;
    }
}