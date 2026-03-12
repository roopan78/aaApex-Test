/**
 * @description : Test class for JsonCleaner 
 * @date        : 2025-03-24
 * @author      : Gomathy V
 */
@isTest
private class JsonCleanerTest {
    
    @isTest
    static void testCleanJsonWithBlankInput() {
        // Test with blank input
        String result = JsonCleaner.cleanJson('');
        System.assertEquals('', result, 'Blank input should return blank output');
        
        result = JsonCleaner.cleanJson(null);
        System.assertEquals(null, result, 'Null input should return null output');
    }
    
    @isTest
    static void testCleanJsonWithValidInput() {
        // Create a sample JSON with questionbook structure
        String inputJson = createSampleJson();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null or blank
        System.assertNotEquals(null, result);
        System.assertNotEquals('', result);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertNotEquals(null, resultMap);
        System.assert(resultMap.containsKey('questionbook'), 'Result should contain questionbook key');
    }
    
    @isTest
    static void testCleanJsonWithStyleFields() {
        // Create a sample JSON with style field that needs cleaning
        String inputJson = createJsonWithUncleanStyleField();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        String styleStr = String.valueOf(qbMap.get('style'));
        
        // Verify style field is properly formatted
        System.assert(styleStr.startsWith('{'), 'Style field should start with {');
        System.assert(styleStr.endsWith('}'), 'Style field should end with }');
    }
    
    @isTest
    static void testCleanJsonWithFieldsMeta() {
        // Create a sample JSON with fieldsMeta that needs cleaning
        String inputJson = createJsonWithFieldsMeta();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        List<Object> questions = (List<Object>) qbMap.get('subQuestions');
        Map<String, Object> question = (Map<String, Object>) questions[0];
        List<Object> fieldsMeta = (List<Object>) question.get('fieldsMeta');
        Map<String, Object> fieldMeta = (Map<String, Object>) fieldsMeta[0];
        String styleStr = String.valueOf(fieldMeta.get('style'));
        
        // Verify style field is properly formatted in fieldsMeta
        System.assert(styleStr.startsWith('{'), 'FieldsMeta style field should start with {');
        System.assert(styleStr.endsWith('}'), 'FieldsMeta style field should end with }');
    }
    
    @isTest
    static void testCleanJsonWithQbReferenceQuestionsString() {
        // Create a sample JSON with qbReferenceQuestions as string
        String inputJson = createJsonWithQbReferenceQuestionsAsString();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        List<Object> questions = (List<Object>) qbMap.get('subQuestions');
        Map<String, Object> question = (Map<String, Object>) questions[0];
        
        // Verify qbReferenceQuestions was properly processed
        System.assert(question.containsKey('qbReferenceQuestions'), 'qbReferenceQuestions should exist');
    }
    
    @isTest
    static void testCleanJsonWithQbReferenceQuestionsObject() {
        // Create a sample JSON with qbReferenceQuestions as object
        String inputJson = createJsonWithQbReferenceQuestionsAsObject();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        List<Object> questions = (List<Object>) qbMap.get('subQuestions');
        Map<String, Object> question = (Map<String, Object>) questions[0];
        
        // Verify qbReferenceQuestions was properly processed
        System.assert(question.containsKey('qbReferenceQuestions'), 'qbReferenceQuestions should exist');
    }
    
    @isTest
    static void testCleanJsonWithQbReferenceQuestionsMap() {
        // Create a sample JSON with qbReferenceQuestions as map
        String inputJson = createJsonWithQbReferenceQuestionsAsMap();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        List<Object> questions = (List<Object>) qbMap.get('subQuestions');
        Map<String, Object> question = (Map<String, Object>) questions[0];
        
        // Verify qbReferenceQuestions was properly processed
        Map<String, Object> refQuestions = (Map<String, Object>) question.get('qbReferenceQuestions');
        System.assertNotEquals(null, refQuestions, 'qbReferenceQuestions should be a map');
    }
    
    @isTest
    static void testCleanJsonWithFieldsMetaAsString() {
        // Create a sample JSON with fieldsMeta as string
        String inputJson = createJsonWithFieldsMetaAsString();
        
        // Clean the JSON
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
        
        // Deserialize the result to verify structure
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        Map<String, Object> qbMap = (Map<String, Object>) resultMap.get('questionbook');
        List<Object> questions = (List<Object>) qbMap.get('subQuestions');
        Map<String, Object> question = (Map<String, Object>) questions[0];
        
        // Verify fieldsMeta was properly processed
        System.assert(question.containsKey('fieldsMeta'), 'fieldsMeta should exist');
    }
    
    @isTest
    static void testCleanJsonWithException() {
        // Test with invalid JSON to trigger exception
        String invalidJson = '{invalid json:}';
        
        try {
            JsonCleaner.cleanJson(invalidJson);
            System.assert(false, 'Should have thrown an exception for invalid JSON');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
    }
    
    @isTest
    static void testCleanJsonWithQbReferenceQuestionsException() {
        // Create a sample JSON with invalid qbReferenceQuestions
        String inputJson = createJsonWithInvalidQbReferenceQuestions();
        
        try {
            JsonCleaner.cleanJson(inputJson);
            System.assert(false, 'Should have thrown an exception for invalid qbReferenceQuestions');
        } catch (AuraHandledException e) {
            System.assert(e.getMessage() != null, 'Exception message should not be null');
        }
    }
    
    @isTest
    static void testConvertToListError() {
        // Create a sample JSON with invalid field that should be a list
        String inputJson = createJsonWithInvalidFieldsList();
        
        // This should not throw an exception but should handle the error gracefully
        String result = JsonCleaner.cleanJson(inputJson);
        
        // Verify the result is not null
        System.assertNotEquals(null, result);
    }
    
    // Helper methods to create test data
    
    private static String createSampleJson() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        question.put('type', 'Label');
        question.put('questionText', '<p>Visit Report to Finance</p>');
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        questionbook.put('title', 'SGL');
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithUncleanStyleField() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        question.put('style', 'showLabel: true, labelValueStyle: "color:black;font-weight:bold"');
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        questionbook.put('style', 'showLabel: true, labelValueStyle: "color:black;font-weight:bold"');
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithFieldsMeta() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        List<Map<String, Object>> fieldsMeta = new List<Map<String, Object>>();
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', 'testField');
        field.put('style', 'width: 100%, color: red');
        fieldsMeta.add(field);
        
        question.put('fieldsMeta', fieldsMeta);
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithQbReferenceQuestionsAsString() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        List<Map<String, Object>> refQuestionsList = new List<Map<String, Object>>();
        Map<String, Object> refQuestion = new Map<String, Object>();
        refQuestion.put('name', 'refQuestion');
        refQuestion.put('style', 'width: 100%, color: red');
        refQuestionsList.add(refQuestion);
        
        question.put('qbReferenceQuestions', JSON.serialize(refQuestionsList));
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithQbReferenceQuestionsAsObject() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        List<Map<String, Object>> refQuestionsList = new List<Map<String, Object>>();
        Map<String, Object> refQuestion = new Map<String, Object>();
        refQuestion.put('name', 'refQuestion');
        refQuestion.put('style', 'width: 100%, color: red');
        refQuestionsList.add(refQuestion);
        
        question.put('qbReferenceQuestions', refQuestionsList);
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithQbReferenceQuestionsAsMap() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        Map<String, Object> refQuestion = new Map<String, Object>();
        refQuestion.put('name', 'refQuestion');
        refQuestion.put('style', 'width: 100%, color: red');
        
        question.put('qbReferenceQuestions', refQuestion);
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithFieldsMetaAsString() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        List<Map<String, Object>> fieldsMeta = new List<Map<String, Object>>();
        Map<String, Object> field = new Map<String, Object>();
        field.put('name', 'testField');
        field.put('style', 'width: 100%, color: red');
        fieldsMeta.add(field);
        
        question.put('fieldsMeta', JSON.serialize(fieldsMeta));
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithInvalidQbReferenceQuestions() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        // Invalid JSON string that will throw an exception when parsed
        question.put('qbReferenceQuestions', '[{Invalid JSON}]');
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
    
    private static String createJsonWithInvalidFieldsList() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> questionbook = new Map<String, Object>();
        List<Object> subQuestions = new List<Object>();
        
        Map<String, Object> question = new Map<String, Object>();
        question.put('uniqueIdentifier', 'QB-00000-Q-7e3d1d8c-9e72-4204-8555-03b4fd43e547');
        
        // Invalid JSON string that will cause an error in convertToList but should be handled
        question.put('fieldsMeta', '[Invalid list]');
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonData.put('questionbook', questionbook);
        
        return JSON.serialize(jsonData);
    }
}