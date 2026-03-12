public class ExceptionHandler implements Queueable {
    private List<Exception__b> eList;
    public static Boolean firstcall= false;
    
    public ExceptionHandler(List<Exception__b> eList) {
        this.eList = eList;
    }

    public void execute(QueueableContext context) {
        Boolean allInsertedFlag = false;
        
        do {
            allInsertedFlag = true;
            
            if(!Test.isRunningTest()) {
                for (Database.SaveResult sr: Database.insertImmediate(eList)) {
                    if (!sr.isSuccess()) {
                        allInsertedFlag = false;
                    }
                }
            }
        } while (!allInsertedFlag);
    }
}