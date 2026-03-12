public with sharing class FormWrapper {
  public String id;
  public String name;
  public String type;
  public String anchorObj;
  public String qbId;           // MR 16MAY25 QB Builder Changes
  public String qhResponse;     // MR 16MAY25 QB Builder Changes
  public List<responseWrapper> pages;
  public List<ActionWrapper> actions;
  public Map<Id, List<TranslationWrapper>> tMap;
  public Map<Id, QuestionBookWrapper> qbMap;
  public Map<Id, QuestionWrapper> qMap;
  public Map<Id, QuestionWrapper> oMap;
  public List<FormController.ObjectOption> objectOptions;
  public FormWrapper(Form__c form) {
    this.id = form.Id;
    this.name = form.Name;
    this.type = form.Type__c;
    this.anchorObj = form.Anchor_Object__c;
    this.pages = new List<responseWrapper>();
    this.actions = new List<ActionWrapper>();
    this.objectOptions = FormController.getRelatedObjectOptions(form.Anchor_Object__c);
  }

  // MR 16MAY25 QB Editor Changes
  public FormWrapper(Id qbId, String name) {
    this.id = qbId;
    this.name = name;

    this.actions = new List<ActionWrapper>();
    this.tMap = new Map<Id, List<TranslationWrapper>>();
    this.qbMap = new Map<Id, QuestionBookWrapper>(); 
    this.qMap = new Map<Id, QuestionWrapper>();
    this.oMap = new Map<Id, QuestionWrapper>();
  }
}