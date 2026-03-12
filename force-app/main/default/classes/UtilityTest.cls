/*
 * Test class for Utility.
 */
@isTest
public class UtilityTest {
    @isTest
    static void testUpdatePossibilities() {
        // Arrange
        // Create Question Book record
        Question_Book__c qb = new Question_Book__c(Title__c = 'Test Question Book',Unique_Identifier__c = '12345',
                                                            Category__c = 'Simple');
        insert qb;
        
        // Create a Question record with Next_Question reference
        Question__c q1 = new Question__c(
            Question_No__c = 1, Type__c = 'Radio', Unique_Identifier__c = 'Test1',
            Question_Book__c = qb.Id
        );
        insert q1;
        
        Question__c q2 = new Question__c(
            Question_No__c = 2, Type__c = 'Radio', Unique_Identifier__c = 'Test2',
            Question_Book__c = qb.Id
        );
        insert q2;
        
        Question__c q3 = new Question__c(
            Question_No__c = 3, Type__c = 'Radio', Unique_Identifier__c = 'Test3',
            Question_Book__c = qb.Id
        );
        insert q3;
        
        // Create Option records with Next_Question reference
            Option__c opt1 = new Option__c(Unique_Identifier__c = 'text1', Question__c = q3.Id, Order__c = 1, Value__c = 'value1');
        insert opt1;
        
        Option__c opt2 = new Option__c(Unique_Identifier__c = 'text2', Question__c = q3.Id, Order__c = 2, Value__c = 'value2');
        insert opt2;
        
        // Add the Question and Option data to the Question Book record
        qb.First_Question__c = q1.Id;
        update qb;

        // Mock the necessary method call
        Test.startTest();
        
        // Act
        Utility.updatePossibilities(qb.Id);  // Call the method to be tested
        
        Test.stopTest();
        
        // Assert
        Question_Book__c updatedQb = [SELECT Possibilities__c FROM Question_Book__c WHERE Id = :qb.Id];
        System.assertNotEquals(null, updatedQb.Possibilities__c, 'Possibilities__c should not be null.');
        
        // Assert the possibilities structure inside Possibilities__c
        // Based on your test structure, validate the min, max and total paths.
        String possibilitiesJson = updatedQb.Possibilities__c;
        System.assert(possibilitiesJson.contains('minQuestions'), 'JSON should contain minQuestions.');
        System.assert(possibilitiesJson.contains('maxQuestions'), 'JSON should contain maxQuestions.');
        System.assert(possibilitiesJson.contains('total'), 'JSON should contain total.');
        
        // Verify the paths in Possibilities__c
        System.assert(possibilitiesJson.contains('paths'), 'JSON should contain paths array.');
    }
    
    @isTest
    static void testJsName() {
        // Arrange
        String apiName = 'custom_field_name__c';
        
        // Act
        String jsName = Utility.jsName(apiName);
        
        // Assert
        System.assertEquals('customFieldName', jsName, 'The JavaScript name should be correctly formatted.');
    }
    
    @isTest
    static void testPossibilityWrapperDefaultValues() {
        // Arrange
        // Create an instance of PossibilityWrapper
        PossibilityWrapper wrapper = new PossibilityWrapper();

        // Act
        // No specific actions needed since we are testing default values

        // Assert
        System.assertEquals(0, wrapper.minQuestions, 'Expected minQuestions to be initialized to 0.');
        System.assertEquals(0, wrapper.maxQuestions, 'Expected maxQuestions to be initialized to 0.');
        System.assertEquals(0, wrapper.total, 'Expected total to be initialized to 0.');
        System.assertEquals(0, wrapper.paths.size(), 'Expected paths to be an empty list initially.');
    }

    @isTest
    static void testPathWrapperDefaultValues() {
        // Arrange
        // Create an instance of the nested PathWrapper class
        PossibilityWrapper.PathWrapper pathWrapper = new PossibilityWrapper.PathWrapper();

        // Act
        // No specific actions needed since we are testing default values

        // Assert
        System.assertEquals(0, pathWrapper.count, 'Expected count to be initialized to 0.');
        System.assertEquals(0, pathWrapper.questions.size(), 'Expected questions to be an empty list initially.');
    }
    
    @isTest
    static void testAddingPathToPossibilityWrapper() {
        // Arrange
        // Create an instance of PossibilityWrapper
        PossibilityWrapper wrapper = new PossibilityWrapper();

        // Create a PathWrapper instance and populate it with data
        PossibilityWrapper.PathWrapper path = new PossibilityWrapper.PathWrapper();
        path.count = 3;
        path.questions.add('Question 1');
        path.questions.add('Question 2');
        path.questions.add('Question 3');

        // Act
        // Add the PathWrapper instance to the PossibilityWrapper paths list
        wrapper.paths.add(path);
        wrapper.total = wrapper.paths.size();

        // Assert
        System.assertEquals(1, wrapper.paths.size(), 'Expected paths to contain one PathWrapper instance.');
        System.assertEquals(3, wrapper.paths[0].count, 'Expected count in the first path to be 3.');
        System.assertEquals(3, wrapper.paths[0].questions.size(), 'Expected 3 questions in the first path.');
        System.assertEquals('Question 1', wrapper.paths[0].questions[0], 'Expected the first question to be "Question 1".');
        System.assertEquals(1, wrapper.total, 'Expected total to match the number of paths.');
    }
}