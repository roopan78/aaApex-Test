public with sharing class OptionWrapper {
  public String id; // Holds the Salesforce Id of the Option record
  public String name; // The Name of the Option
  public String value; // The Value field from Option__c
  public String uniqueIdentifier; // Unique Identifier field from Option__c
  public String questionId; // Lookup to the Question__c object
  public String nextQuestion;
  public Boolean isDefault;
  public Decimal order; //VD 29Jul25 options order

  public OptionWrapper(Option__c option) {
    this.id = option.Id;
    this.name = option.Name;
    this.value = option.Value__c;
    this.uniqueIdentifier = option.Unique_Identifier__c;
    this.questionId = option.Question__c;
    this.nextQuestion = option.Next_Question__c;
    this.isDefault = option.Is_Default__c == true ? true : false;
    this.order = option.order__c;
  }
  // // VD 29Jul25 options handling changes
  public static Option__c loadOptionWrapper(
    OptionWrapper ow,
    Id parentQuestionId
  ) {
    Option__c opt = new Option__c();

    if (String.isNotBlank(ow.id)) {
      opt.Id = ow.id;
    } else {
      opt.Question__c = parentQuestionId;
    }
    opt.Value__c = ow.value;
    opt.order__c = ow.order;
    opt.Is_Default__c = ow.isDefault == true ? true : false;
    //opt.Unique_Identifier__c = ow.uniqueIdentifier;
    opt.Next_Question__c = ow.nextQuestion;
    opt.Is_Default__c = ow.isDefault;

    return opt;
  }
}