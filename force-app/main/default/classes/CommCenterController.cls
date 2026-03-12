public with sharing class CommCenterController {

    @AuraEnabled(cacheable=true)
    public static List<CommCenterWrapper> getCommCenterList(){
        try {
            List<CommCenterWrapper> commCenterList = new List<CommCenterWrapper>();
            if (Schema.sObjectType.Comm_Center__c.isAccessible()) {
                for (Comm_Center__c cc : [SELECT Name, Id, Status__c, Action_Center_Name__c, Owner.Name,
                                          Action_Owner_Email_ID__c, Action_Owner_Name__c, Description__c,
                                          Flow_Type__c, Is_Email_Sent__c, Is_Optional__c, Object_Name__c, 
                                          Order__c, Parent_Comm_Center__c, Reason__c, Record_Id__c, User_Mail_ID__c, 
                                          User_Name__c, Notification_Process_Config__c 
                                          FROM Comm_Center__c
                                          WHERE Is_Active__c = true
                                          ORDER BY CreatedDate DESC]){
                    commCenterList.add(new CommCenterWrapper(cc));
                }
            } 
            return commCenterList;
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Comm Center: ' + e.getMessage());
        }
    }
}