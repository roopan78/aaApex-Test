/*
 * Test class for NxtControllerLwc.
 */
@isTest
public class NxtControllerLwcTest {
    
    @isTest
    public static void testNxtAppVersion() {
        // Arrange
        String expectedVersion = '1.0.6';

        // Act
        String actualVersion = NxtControllerLwc.nxtAppVersion;

        // Assert
        System.assertEquals(expectedVersion, actualVersion, 'The nxtAppVersion should return the correct version number.');
    }
    @isTest
    public static void testCase001() {
        // Read the Question Record Types
        Map<String, Id> qRTypeMap = new Map<String, Id>();
        for(RecordType rt: [Select Id, Name from RecordType where Name IN ('UNCONDITIONAL', 'OPTIONONLY', 'CONDITIONAL')]) {
            qRTypeMap.put(rt.Name, rt.Id);
        }
        Question_Book__c qb = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert qb;
        NxtControllerLwc.process('QuestionBook','create','test');
        
        // Create Question 001
        Question__c q01 = new Question__c();
        q01.Type__c = 'Text';
        q01.RecordTypeId = qRTypeMap.get('UNCONDITIONAL');
        q01.Question_Text__c = 'What is yours Name?';
        q01.Question__c = 'what is your Name';
        q01.Question_No__c = 1;
        q01.Question_Book__c = qb.Id;
        q01.Unique_Identifier__c = '123';
        q01.Title__c = 'Test Question title';
        q01.SubTitle__c = 'Test Questions Book';
        q01.Reference_Field__c= 'Source_URL__c';
        insert q01;
        NxtControllerLwc.process('Question','create','test');
        qb.First_Question__c = q01.Id;
        //update qb01;
        
        NxtControllerLwc.process('Question','list','test');
        NxtControllerLwc.process('QuestionBook','update','test');
        NxtControllerLwc.process('answerCount','create','test');
        NxtControllerLwc.process('QuestionBook','delete','test');
        NxtControllerLwc.process('Answer','read','test');
        NxtControllerLwc.process('AnswerBook','create','test');
        NxtControllerLwc.process('Attachment','read','test');
    }
}