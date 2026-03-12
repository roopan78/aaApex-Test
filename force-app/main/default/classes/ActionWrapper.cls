public with sharing class ActionWrapper {
  public String id;
  public String buttonLabel;
  public String eventToEmit;
  public Boolean isActive;
  public Decimal order;
  public Boolean isDisabled;
  public String objectApiName; // RT 08SEP25 -  ObjectApiName for QB Builder
  public List<StyleWrapper> styles; // Actions2/19May25/Thangarasu-Include Style obj into actions

  public ActionWrapper(Actions__c action) {
    this.id = action.Id;
    this.buttonLabel = action.Name;
    this.eventToEmit = action.Event_to_Emit__c;
    this.isActive = action.IsActive__c;
    this.order = action.Order__c;
    this.objectApiName = action.Question_Book__r != null ? action.Question_Book__r.Anchor_Object__c: null; // RT 08SEP25 -  ObjectApiName for QB Builder
    this.isDisabled = false;
    if (this.objectApiName != null) {
      Schema.DescribeSObjectResult objDescribe = Schema.getGlobalDescribe().get(this.objectApiName).getDescribe();
      if (!objDescribe.isCreateable() && !objDescribe.isUpdateable()) {
        this.isDisabled = true;
      }
    }
    if (action.Styles__r != null && !action.Styles__r.isEmpty()) {
      // Actions2/19May25/Thangarasu-Include Style obj into actions
      this.styles = StyleWrapper.createList(action.Styles__r);
    }
  }

  public static List<ActionWrapper> createList(List<Actions__c> actions) {
    List<ActionWrapper> wrappedActions = new List<ActionWrapper>();
    for (Actions__c action : actions) {
      wrappedActions.add(new ActionWrapper(action));
    }
    return wrappedActions;
  }
}