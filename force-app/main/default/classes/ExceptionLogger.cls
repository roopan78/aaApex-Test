global class ExceptionLogger {
    // Function to log the Exception without Cause
    global static void log(Exception e, String className) {
        log(e, className, '');
    }
    
    // Function to log the Exception with Cause
    global static void log(Exception e, String className, String cause) {
        // get the Exception details
        Integer line = e.getLineNumber();
        String msg = e.getMessage();
        String st = e.getStackTraceString();
        String typ = e.getTypeName();
        Id userId = UserInfo.getUserId();
        DateTime dt = System.now();
        
        // Create the List for the Exception
        List<Exception__b> eList = new List<Exception__b>();
        
        // Create General Exception Record
        Exception__b gExp = new Exception__b();
        gExp.Line_Number__c = line;
        gExp.Cause__c = cause;
        gExp.Type_Name__c = typ;
        gExp.Message__c = msg;
        gExp.Stack_Trace_String__c = st;
        gExp.Timestamp__c = dt;
        gExp.User__c = userId;
        
        if(String.isNotBlank(className)) {
            gExp.Class_Name__c = className.trim().toUpperCase();
        } else {
            gExp.Class_Name__c = 'APEXLOGIC';
        }
        
        eList.add(gExp);
        
        // Call Queueable Handler
        // if(!Test.isRunningTest()) {
            // }
        if(!ExceptionHandler.firstcall){
            ExceptionHandler.firstcall = true;
            System.enqueueJob(new ExceptionHandler(eList)); 
        }
        
    }
}