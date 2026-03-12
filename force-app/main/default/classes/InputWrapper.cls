// RT 31MAY25 - Wrapper for Input Object
public with sharing class InputWrapper {
    public String id;
    public String name;
    public String apiName;
    public String type;
    public String valueField; // RT 14AUG25 - Value Field for Input JSON
    public String sourceQuestionId; // RT 20AUG25 - Dependency handling in Input JSON
    public String logics;
    public String question;
    public Boolean hidden;


    public InputWrapper(Input__c input) {
        this.id = input.Id;
        this.name = input.Name;
        this.apiName = input.API_Name__c;
        this.type = input.Type__c;
        this.valueField = input.Value_Field__c;
        this.sourceQuestionId = input.Source_Question_Id__c;
        this.logics = input.Logics__c;
        this.question = input.Question__c;
    }

    public static List<InputWrapper> createList(List<Input__c> inputs) {
    List<InputWrapper> wrappedInputs = new List<InputWrapper>();
    for (Input__c input : inputs) {
      wrappedInputs.add(new InputWrapper(input));
    }
    return wrappedInputs;
  }
}