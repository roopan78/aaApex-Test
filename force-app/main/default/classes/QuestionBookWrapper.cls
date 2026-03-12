public with sharing class QuestionBookWrapper {
  // VD 8feb25 aura enabled save changes
  // RT 31MAY25 - Input Wrapper and its method to create list added
  @AuraEnabled
  public String id;
  @AuraEnabled
  public String name;
  @AuraEnabled
  public String parentBooklet;
  @AuraEnabled
  public String status;
  @AuraEnabled
  public String title;
  @AuraEnabled
  public Boolean isShengel;
  @AuraEnabled
  public String subTitle;
  @AuraEnabled
  public String firstQuestion;
  @AuraEnabled
  public String uniqueIdentifier;
  @AuraEnabled
  public String lastQuestion;
  @AuraEnabled
  public String category;
  @AuraEnabled
  public Integer totalQuestions;
  @AuraEnabled
  public String next;
  @AuraEnabled
  public String back;
  @AuraEnabled
  public String submit;
  @AuraEnabled
  public String apiKey;
  @AuraEnabled
  public String action;
  @AuraEnabled
  public String cancel;
  @AuraEnabled
  public String edit;
  @AuraEnabled
  public String query; // VD 28-Jan-25 added query field
  @AuraEnabled
  public String possibilities;
  @AuraEnabled
  public String summaryText;
  @AuraEnabled
  public String summarySubText;
  @AuraEnabled
  public Boolean progressBar;
  @AuraEnabled
  public String style;
  @AuraEnabled
  public Decimal order; // // VD 28Mar25 page order handling
  //VD 20Jun25 removed boolean and created picklist
  @AuraEnabled
  public Decimal version;
  @AuraEnabled
  public String objectApiName; // RT 12JUN25 -  ObjectApiName for QB Builder
  @AuraEnabled
  public String versionStatus; //VD 20Jun25 removed boolean and created picklist
  @AuraEnabled
  public List<QuestionWrapper> subQuestions;
  public List<ActionWrapper> actions;
  public List<StyleWrapper> styles;
  public List<InputWrapper> inputs;
  public List<SObject> lstResult; //VD 09jul25 - query optimization changes
  public QuestionBookWrapper(Question_Book__c qb) {
    this.id = qb.Id;
    this.name = qb.Name;
    this.parentBooklet = qb.Parent_Booklet_QB__c;
    this.status = qb.Status__c;
    this.title = qb.Title__c;
    this.isShengel = qb.isShengel__c;
    this.subTitle = qb.SubTitle__c;
    this.firstQuestion = qb.First_Question__c;
    this.uniqueIdentifier = qb.Unique_Identifier__c;
    this.lastQuestion = qb.Last_Question__c;
    this.category = qb.Category__c;
    this.totalQuestions = qb.Total_Questions__c != null
      ? qb.Total_Questions__c.intValue()
      : null;
    this.next = qb.Next__c;
    this.back = qb.Back__c;
    this.submit = qb.Submit__c;
    this.apiKey = qb.Api_Key__c;
    this.action = qb.Actions__c;
    this.cancel = qb.Cancel__c;
    this.order = qb.Order__c != null ? qb.Order__c : 0; // // VD 28Mar25 page order handling
    this.query = qb.Query__c; // VD 28-jan-25 added query fied
    this.edit = qb.Edit__c;
    this.possibilities = qb.Possibilities__c;
    this.summaryText = qb.Summary_Text__c;
    this.summarySubText = qb.Summary_Sub_Text__c;
    this.progressBar = qb.Progress_Bar__c;
    this.style = qb.Style__c;
    this.version = qb.Version__c;
    this.versionStatus = qb.Version_Status__c; //VD 20Jun25 removed boolean and created picklist
    this.objectApiName = qb.Anchor_Object__c; // RT 12JUN25 - Anchor Object for QB

    // Wrap nested questions (Questions__r.records)
    if (qb.Questions__r != null && !qb.Questions__r.isEmpty()) {
      this.subQuestions = new List<QuestionWrapper>();
      for (Question__c subQuestion : qb.Questions__r) {
        this.subQuestions.add(new QuestionWrapper(subQuestion));
      }
    }

    // VD 12jun25 removed unwanted logic
    // RT 08SEP25 - Added CRUD Validation and Removed the unwanted codes

    Boolean allowActions = false;
    if (!String.isBlank(this.objectApiName)) {
        try {
            Schema.DescribeSObjectResult objDesc = Schema.getGlobalDescribe().get(this.objectApiName).getDescribe();
            allowActions = objDesc.isCreateable() && objDesc.isUpdateable();
        } catch (Exception e) {
            allowActions = false;
        }
    }

    if (allowActions && qb.Actions__r != null && !qb.Actions__r.isEmpty()) {
        this.actions = ActionWrapper.createList(qb.Actions__r);
    } else {
        this.actions = new List<ActionWrapper>(); // empty if not allowed
    }

    if (qb.Styles__r != null && !qb.Styles__r.isEmpty()) {
      this.styles = StyleWrapper.createList(qb.Styles__r);
    }

    if (qb.Inputs__r != null && !qb.Inputs__r.isEmpty()) {
      this.inputs = InputWrapper.createList(qb.Inputs__r);
    }
  }
  // VD 09jul25 - query optimization changes
  public void setQueryResult(List<SObject> result) {
    this.lstResult = result;
    system.debug('after query' + this.lstResult);
  }
}