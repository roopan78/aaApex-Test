public with sharing class CommCenterWrapper {
@AuraEnabled public Id id;
    @AuraEnabled public Id parentCommCenterId;
    @AuraEnabled public Id notificationProcessConfigId;
    
    @AuraEnabled public String name;
    @AuraEnabled public String status;
    @AuraEnabled public String actionCenterName;
    @AuraEnabled public String actionOwnerName;
    @AuraEnabled public String actionOwnerEmailId;
    @AuraEnabled public String description;
    @AuraEnabled public String flowType;
    @AuraEnabled public String objectName;
    @AuraEnabled public String reason;
    @AuraEnabled public String recordId;
    @AuraEnabled public String userName;
    @AuraEnabled public String userMailId;
    @AuraEnabled public String ownerName;
    
    @AuraEnabled public Boolean isEmailSent;
    @AuraEnabled public Boolean isOptional;
    
    @AuraEnabled public Decimal order;

    public CommCenterWrapper() {}

    public CommCenterWrapper(Comm_Center__c commCenter) {
        this.name = commCenter.Name;
        this.id = commCenter.Id;
        this.status = commCenter.Status__c;
        this.actionCenterName = commCenter.Action_Center_Name__c;
        this.actionOwnerEmailId = commCenter.Action_Owner_Email_ID__c;
        this.actionOwnerName = commCenter.Action_Owner_Name__c;
        this.description = commCenter.Description__c;
        this.flowType = commCenter.Flow_Type__c;
        this.isEmailSent = commCenter.Is_Email_Sent__c;
        this.isOptional = commCenter.Is_Optional__c;
        this.objectName = commCenter.Object_Name__c;
        this.order = commCenter.Order__c;
        this.parentCommCenterId = commCenter.Parent_Comm_Center__c;
        this.reason = commCenter.Reason__c;
        this.recordId = commCenter.Record_Id__c;
        this.userMailId = commCenter.User_Mail_ID__c;
        this.userName = commCenter.User_Name__c;
        this.notificationProcessConfigId = commCenter.Notification_Process_Config__c;
    }
}