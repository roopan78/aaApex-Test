@isTest
public class LoggerTest {
    @isTest 
    public static void log() {
        Logger.log('Testing');
        System.assertNotEquals('123','value is null','Test');
    }
    
    @isTest
    public static void methodStack() {
        Logger.methodEntry('Testing');
        Logger.printMethodStack();
        Logger.methodExit('Testing');
        System.assertNotEquals('Logger','value is null','Test');
    }
}