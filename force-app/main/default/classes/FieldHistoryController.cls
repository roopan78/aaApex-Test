global class FieldHistoryController {
    public class fieldWrapper{
        public string id;
        public Datetime timeStamp;
        public string fieldValue;
        public string oldValue;
        public string newValue;
        public string userName;
        public string userId;
    }
    // Method to return all the fieldhistories for a specific record id
    @AuraEnabled(Cacheable=true)
    global static string fetchfieldHistories(String recId, string objectname) {
        
        list<fieldWrapper> fieldList = new List<fieldWrapper>();
        List<Field_History__b> historyRecords = new List<Field_History__b>();
        List<Field_History__b> historyRec = new List<Field_History__b>();
        
        Set<String> fldSet = new Set<String>();
        fldSet.add('phone');
        System.debug('Input Record Id from LWC => ' + recId);
        
        // Read the Object Info based on recId
        SObjectType objType = getSObjectType(Id.valueOf(recId));
        Schema.DescribeSObjectResult objResult = objType.getDescribe();
        
        if(!objResult.isAccessible()) {
            string jsonstring = JSON.serialize(fieldList);
            return jsonstring;
        }
        
        // Read the Field Access based on the Object Identified
        Map<String,Schema.SObjectField> allFields = objResult.fields.getMap();
        System.debug('Got ' + allFields.size() + ' fields for ' + objResult.getName());
        for(Schema.SObjectField fld: allFields.values()) {
            Schema.DescribeFieldResult fldResult = fld.getDescribe();
            System.debug('Processing ' + fldResult.getName() + ' with ' + fldResult.isAccessible() + ' access');
            if(fldResult.isAccessible()) {
                fldSet.add(fldResult.getName().toLowerCase());   
            }
        }
        string userId = UserInfo.getUserId();
        List<History_Tracking_Fields__c> htfList = new List<History_Tracking_Fields__c>();
        htfList = [Select id, Fields__c, Object_Name__c from History_Tracking_Fields__c WHERE Object_Name__c =:objectname AND User_ID__c = :userId];
        system.debug(htfList);
        
        List<Field_History__b> fieldHistoryList = new List<Field_History__b>();
        if (Test.isRunningTest()) {
            Field_History__b testRecord = new Field_History__b();
            testRecord.Record_ID__c = recId;
            testRecord.Field_Name__c = 'LastName';
            testRecord.New_Value__c = 'Test 02';
            testRecord.Old_Value__c = 'Test 01';
            fieldHistoryList.add(testRecord);
        } else {
            fieldHistoryList = [SELECT id , Field_Name__c , New_Value__c, Old_Value__c, Record_ID__c, Timestamp__c, User__r.name FROM Field_History__b WHERE Record_ID__c = :recId];
            system.debug(fieldHistoryList);
        }
        
        if(htfList.size()> 0){
            system.debug('full data');
            for(Field_History__b record : fieldHistoryList){
                for(History_Tracking_Fields__c rec : htfList){
                    List <string> val = rec.Fields__c.split(',');
                    integer lastIndex = val.size() -1 ;
                    for (integer i = 0; i <= lastIndex; ++i){
                        string str = string.valueOf(val[i]);
                        string values = str.toLowerCase();
                        string mystr = values.replaceAll( '\\s+', '');
                        if(mystr ==record.Field_Name__c ){
                            historyRecords.add(record);
                            system.debug('inside record');
                            
                        }
                    } 
                }
            }
        }
        
        //field accessibility check
        if(historyRecords.size()>0){
            for(Field_History__b rec: historyRecords){
                if(fldSet.contains(rec.Field_Name__c)) {
                    historyRec.add(rec);
                }
            }
            //convert List record values to json for Lwc
            if(historyRec.size()>0){
                for(Field_History__b rec: historyRecords){
                    fieldWrapper fw = new fieldWrapper();
                    fw.id = rec.Id;
                    fw.fieldValue = rec.Field_Name__c; 
                    fw.newValue = rec.New_Value__c;
                    fw.oldValue = rec.Old_Value__c;
                    fw.timeStamp = rec.Timestamp__c;
                    fw.userName = rec.User__r.name;
                    fieldList.add(fw);
                }
            }
        }
        string jsonstring = JSON.serialize(fieldList);
        System.debug(jsonstring);
        return jsonstring;
    } 
    
    
    public static SObjectType getSObjectType(Id recordId) {
        return recordId?.getSObjectType();
    }
    
    @AuraEnabled(cacheable = true)
    public static string getProfile(){
        Id profileId = UserInfo.getProfileId();
        String profileName =[Select Id, Name from Profile where Id=:profileId].Name;
        //system.debug('Profile Name'+profileName);
        return profileName;
    }
}