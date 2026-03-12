global class Logger {
    // Configuration for Logger
    private static Configuration__mdt config = [SELECT Id, Print_Debug__c FROM Configuration__mdt WHERE MasterLabel = 'Logger' LIMIT 1][0];
    
    // Variable to trace the execution flow
    private static List<String> printStack = new List<String>();
    private static List<String> flowStack = new List<String>();
    private static List<String> methodStack = new List<String>();
    private static Integer methodIndex = 0;
    
    // Function to add item to Print Stack
    global static void log(String str) {
        if(config.Print_Debug__c) { System.debug(str); }
        printStack.add(str);
    }
    
    // Function to add item from Methods Stack
    global static void methodEntry(String str) {
        log('Entering into ' + str);
        
        methodStack.add(str);
        methodIndex++;
        
        flowStack.add(String.join(methodStack, '->'));
    }
    
    // Function to remove item from Methods Stack
    global static void methodExit(String str) {
        log('Exiting from ' + str);
        
        methodIndex--;
        methodStack.remove(methodIndex);
        
        flowStack.add(String.join(methodStack, '<-'));
    }
    
    // Function to print the latest flow Stack
    global static void printMethodStack() {
        System.debug(String.join(methodStack, '->'));
    }
}