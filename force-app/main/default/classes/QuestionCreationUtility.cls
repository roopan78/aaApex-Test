public class QuestionCreationUtility {
    public static void optionCreation(List<String> optionsValueList, string questionId, Integer questionNumber) {
        List<Option__c> optionList = new List<Option__c>();
        Integer i = 1;  // Initialize counter for loop
        
        for (String optionsValue : optionsValueList) {
            Option__c opt = new Option__c();
            opt.Order__c = i;
            opt.Question__c = questionId;
            opt.Value__c  = optionsValue;
            optionList.add(opt);
            i++;  // Increment the counter after each loop iteration
        }
        
        insert optionList;
    }
    
    public static void questionCreation(String questionbookId, String questionBookNumber) {
        List<Question__c> questionList = new List<Question__c>();
        
        for (Integer i = 9; i <= 28; i++) {  // Corrected loop condition and added increment
            Question__c ques = new Question__c();
            ques.Question_Book__c = questionbookId;
            ques.Type__c = 'Radio';
            ques.Question_No__c = i;
            questionList.add(ques);
        }
        
        insert questionList;
    }
}