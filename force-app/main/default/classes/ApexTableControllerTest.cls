@isTest
public class ApexTableControllerTest {
    @isTest 
    public static void getApexClassTest(){
        apexclass[] checkClass = [select id, name from apexclass limit 2];
        Test.startTest();
        System.assertEquals(ApexTablecontroller.GetApexClasses(),checkClass);
        Test.stopTest();
    }
}