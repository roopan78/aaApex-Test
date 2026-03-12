global with sharing class FieldHistoryLogger {
    public static Set<String> fieldToIgnore = new Set<String>();

    // Function to Process the input
    global static void handler(Boolean isUpdate, Map<Id, sObject> oldMap, Map<Id, sObject> newMap){
        FieldHistoryLogger.process(isUpdate, oldMap, newMap);
        system.debug('inside handler');
    }
// Function to Process the input
    
    global static void process( Boolean isUpdate, Map<Id, sObject> oldMap, Map<Id, sObject> newMap) {
        Logger.methodEntry('FieldHistoryLogger.process(' +  isUpdate + ')');
        if(oldMap != null) { 
            Logger.log('Old Map Size => ' + oldMap.size()); 
        }
        if(newMap != null) { 
            Logger.log('New Map Size => ' + newMap.size()); 
        }

        fieldToIgnore.add('systemmodstamp');
        fieldToIgnore.add('lastmodifieddate');
        // Create the List for the Field History
        List<Field_History__b> fhList = new List<Field_History__b>();

        //create event call
        List<History_Platform_Event__e> eventObjList = new List<History_Platform_Event__e>();
        History_Platform_Event__e eventObj = new History_Platform_Event__e();

        String valueString = '';
        if(isUpdate) {
            valueString = 'Record got Updated';
        } 

        //while updating the records 
        if(isUpdate){
            //system.debug('not known');
            String oldRecordId = '';
            Datetime tsValue = null;
            String oldValue = '';
            String newValue = '';
            
            Map<String, Schema.SObjectField> objFieldsMap = new Map<String, Schema.SObjectField>();
            // Changes to be processed
            for(sObject oldRecord: oldMap.values()) {
                if(oldRecordId == '') {
                    Schema.DescribeSObjectResult objResult = oldRecord.getSObjectType().getDescribe();
                    objFieldsMap = objResult.fields.getMap();
                    system.debug('oldvalue from');
                    System.debug(objFieldsMap);
                    //Logger.log('Fields Identified for the Object => ' + objFieldsMap.keySet());
                }

                oldRecordId = (String)oldRecord.get('Id');
                Logger.log('Old Record Id => ' + oldRecordId);

                if(isUpdate){
                    //system.debug('NEW');
                    // Loop thru all the field value changes
                    sObject newRecord = newMap.get(oldRecordId);
                    tsValue = (Datetime)newRecord.get('systemmodstamp');

                    for(String fldName: objFieldsMap.keySet()) {
                        Logger.log('Field being Processed => ' + fldName);
                        if(!fieldToIgnore.contains(fldName)) {
                            oldValue = String.valueOf(oldRecord.get(fldName));
                            newValue = String.valueOf(newRecord.get(fldName));
    
                            if(oldValue != newValue) {
                                eventObj = new History_Platform_Event__e();
                                Field_History__b hist = new Field_History__b();
                                hist.Record_ID__c = oldRecordId;
                                hist.Field_Name__c = fldName;
                                hist.New_Value__c = newValue;
                                hist.Old_Value__c = oldValue;
                                hist.Timestamp__c = System.now();
                                hist.User__c = UserInfo.getUserId();
                                
            
                                fhList.add(hist);

                                eventObj.Record_Id__c = oldRecordId;
                                eventObjList.add(eventObj);
                                try{
                                    if(eventObjList <> null && !eventObjList.isEmpty()){
                                        Eventbus.publish(eventObjList);
                                        //system.debug(eventObjList);
                                        system.debug('success in Event');
                                    }
                                }catch(Exception e){
                                    system.debug('Exception during publishing');
                                    }
                            }
                        }
                    }
                }
            }
        }

        Logger.log('Size of the Input passed to Queueable Job -> ' + fhList.size());
        Logger.methodExit('FieldHistoryLogger.process()');
        if(!FieldHistoryHandler.firstcall){
            FieldHistoryHandler.firstcall = true;
       		System.enqueueJob(new FieldHistoryHandler(fhList));
        }
    }
}