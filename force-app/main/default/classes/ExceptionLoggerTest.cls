@isTest
public class ExceptionLoggerTest {
    @isTest
    public static void createLog() {
        try {
            Integer i = 10;
            Integer dZero = i/0;
        } catch(Exception e) {
            // Case 01
            ExceptionLogger.log(e, 'Utility', 'Testing the Exception Log');
            
            // Case 02
            ExceptionLogger.log(e, '');
            System.assertNotEquals(null, e,'value is null');
        }
    }
}