@IsTest 
public class AutogenerateIDhandlerTEST {
    // create common test record using @testsetup
    @testSetup
    static void setupTestData() {
        Id recId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('OPTIONONLY').getRecordTypeId();
        Question_Book__c qb = new Question_Book__c(Title__c = 'Test QB',Category__c='simple',Auto_generate_ID__c = true);
        insert qb;
        Question__c question = new Question__c(Question_Book__c = qb.Id,RecordTypeId = recId,Type__c ='Dropdown',Question_No__c = 1,Auto_generate_ID__c = true);
        insert question;
        Option__c option = new Option__c(Question__c = question.Id,Order__c = 1,Value__c ='yes',Auto_generate_ID__c = true);
        insert option;
        Field_Meta__c Fieldmeta = new Field_Meta__c(Question__c = question.Id,Auto_generate_ID__c = true);
        insert Fieldmeta;
        Input__c QBinput = new Input__c(Question_Book__c = qb.Id,Auto_generate_ID__c = true);
        insert QBinput;
        Translation__c Translation = new Translation__c(Question_Book__c = qb.Id,Auto_generate_ID__c = true);
        insert Translation;
    }
    @isTest
    static void testAutoGenerateId() {
        // test method for Question Book Unique ID generation
        List<Question_Book__c> newQB = [SELECT Id, Name, Auto_generate_ID__c, Unique_Identifier__c FROM Question_Book__c];
        AutoGenerateIdHandler.AutoGenerateId(newQB);
        for (Question_Book__c qb : newQB) {
            System.assertNotEquals(null, qb.Unique_Identifier__c, 'Unique Identifier should be generated for Question Book');
            System.assert(qb.Unique_Identifier__c.startsWith('QB-'), 'Unique Identifier should start with QB-');
        }
    }

    @isTest
    static void testQuestionAutoGenerateId() {
        // test method for Question Unique ID generation
        List<Question__c> newQuestion = [SELECT Id, Name, Question_Book__c, Auto_generate_ID__c, Unique_Identifier__c FROM Question__c];
        AutoGenerateIdHandler.QuestionAutoGenerateId(newQuestion);
        for (Question__c q : newQuestion) {
            System.assertNotEquals(null, q.Unique_Identifier__c, 'Unique Identifier should be generated for Question');
            System.assert(q.Unique_Identifier__c.contains('-Q-'), 'Unique Identifier should contain -Q-');
        }
    }

    @isTest
    static void testOptionAutoGenerateId() {
        // test method for Option Unique ID generation
        List<Option__c> newOption = [SELECT Id, Name, Question__c, Auto_generate_ID__c, Unique_Identifier__c FROM Option__c];
        AutoGenerateIdHandler.OptionAutoGenerateId(newOption);
        for (Option__c opt : newOption) {
            System.assertNotEquals(null, opt.Unique_Identifier__c, 'Unique Identifier should be generated for Option');
            System.assert(opt.Unique_Identifier__c.contains('-OP-'), 'Unique Identifier should contain -OP-');
        }
    }
    @isTest
    static void testFieldmetaAutoGenerateId() {
        // test method for Fieldmeta Unique ID generation
        List<Field_Meta__c> newFieldmeta = [SELECT Id, Name, Question__c, Auto_generate_ID__c, Unique_Identifier__c FROM Field_Meta__c];
        AutoGenerateIdHandler.FieldmetaAutoGenerateId(newFieldmeta);
        for (Field_Meta__c FM : newFieldmeta) {
            System.assertNotEquals(null, FM.Unique_Identifier__c, 'Unique Identifier should be generated for Option');
            System.assert(FM.Unique_Identifier__c.contains('-FM-'), 'Unique Identifier should contain -FM-');
        }
    }
    @isTest
    static void testInputAutoGenerateId() {
        // test method for Question Unique ID generation
        List<Input__c> newInput = [SELECT Id, Name, Question_Book__c, Auto_generate_ID__c, Unique_Identifier__c FROM Input__c];
        AutoGenerateIdHandler.QBinputAutoGenerateId(newInput);
        for (Input__c i : newInput) {
            System.assertNotEquals(null, i.Unique_Identifier__c, 'Unique Identifier should be generated for Question');
            System.assert(i.Unique_Identifier__c.contains('-IN-'), 'Unique Identifier should contain -IN-');
        }
    }
    @isTest
    static void testTranslationAutoGenerateId() {
        // test method for Question Unique ID generation
        List<Translation__c> newTranslation = [SELECT Id, Name, Question_Book__c, Auto_generate_ID__c, Unique_Identifier__c FROM Translation__c];
        AutoGenerateIdHandler.TranslationAutoGenerateId(newTranslation);
        for (Translation__c TR : newTranslation) {
            System.assertNotEquals(null, TR.Unique_Identifier__c, 'Unique Identifier should be generated for Question');
            System.assert(TR.Unique_Identifier__c.contains('-TR-'), 'Unique Identifier should contain -TR-');
        }
    }
}