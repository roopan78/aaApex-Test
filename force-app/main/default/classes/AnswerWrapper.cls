public class AnswerWrapper {
    public String ansId;
    public Integer ansNumber;
	public String abId;
    public String quesId;
    public String qTyp;
    public String quesValue;
    public String ansValue;
    public string status;
    public string groupText;
    public string squesValue;
    public string recordId;

    // MR 05FEB24 - convert for reusability
    public static AnswerWrapper convert(Answer__c aRec) {
        AnswerWrapper wrap = new AnswerWrapper();
        wrap.ansId = aRec.Id;
        wrap.ansNumber = Integer.valueOf(aRec.Number__c);
        wrap.abId = aRec.Answer_Book__c;
        wrap.quesId = aRec.Question_Ref__c;
        wrap.qTyp = aRec.Question_Type__c;
        wrap.recordId = aRec.recordId__c;
        if(aRec.Question_Rich_Text__c != null) {
            wrap.quesValue = aRec.Question_Rich_Text__c.unescapeHtml4();
        } else {
            wrap.quesValue = '';
        }
        if(aRec.Answer_Long__c != null) {
            wrap.ansValue = aRec.Answer_Long__c.unescapeHtml4();
        } else {
            wrap.ansValue = '';
        }
        
        wrap.groupText = aRec.Question_Group_Text__c;
        wrap.squesValue = '';

        return wrap;
    }
}