global with sharing class FieldHistoryHandler implements Queueable {
    private List<Field_History__b> fhList = new List<Field_History__b>();
       public static Boolean firstcall= false;
    
    global FieldHistoryHandler(List<Field_History__b> inpList) {
        this.fhList = inpList;
    }
    
    global void execute(QueueableContext context) {
        Boolean allInsertedFlag = false;
        
        do {
            allInsertedFlag = true;
            
            if(!Test.isRunningTest()) {
                for (Database.SaveResult sr: Database.insertImmediate(fhList)) {
                    if (!sr.isSuccess()) {
                        allInsertedFlag = false;
                    }
                }
            }
        } while (!allInsertedFlag);
    }
}