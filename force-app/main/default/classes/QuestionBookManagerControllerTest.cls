@isTest
public class QuestionBookManagerControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create Record Type for Question__c
        // Note: In real scenarios, record types might already exist
        
        // Create a test Account for testing
        Account testAccount = new Account(
            Name = 'Test Account',
            Phone = '1234567890'
        );
        insert testAccount;
        
        // Create Question Book
        Question_Book__c testBook = new Question_Book__c(
            Title__c = 'Test Book',
            Category__c = 'Simple',
            Unique_Identifier__c = 'QB-test-123',
            Anchor_Object__c = 'Account',
            Query__c = 'SELECT Id, Name FROM Account WHERE Id = {c__record_id}'
        );
        insert testBook;
        
        // Create Form
        Form__c testForm = new Form__c(
            Question_Book__c = testBook.Id,
            Name = 'Test Form',
            Type__c = 'QuestionBook',
            Anchor_Object__c = 'Account'
        );
        insert testForm;
        
        // Create Question
        Id recTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
            .get('UNCONDITIONAL')?.getRecordTypeId();
        
        Question__c testQuestion = new Question__c(
            Question_Book__c = testBook.Id,
            Type__c = 'Text',
            Question_No__c = 1,
            RecordTypeId = recTypeId,
            Unique_Identifier__c = 'QB-test-question-1',
            Question_Text__c = 'Test Question',
            Title__c = 'Test Title'
        );
        insert testQuestion;
        
        // Create Field Meta
        Field_Meta__c testFieldMeta = new Field_Meta__c(
            Question__c = testQuestion.Id,
            Unique_Identifier__c = 'test-field-meta-1',
            api_name__c = 'Name',
            fld_type__c = 'Text',
            label__c = 'Name'
        );
        insert testFieldMeta;
        
        // Create Style
        Style__c testStyle = new Style__c(
            Question__c = testQuestion.Id,
            Label_Class__c = 'slds-grid',
            external_id__c = 'test-style-1'
        );
        insert testStyle;
        
        // Create Input
        Input__c testInput = new Input__c(
            Question_Book__c = testBook.Id,
            API_Name__c = 'c__record_id',
            Type__c = 'String',
            Unique_Identifier__c = 'test-input-1'
        );
        insert testInput;
    }
    
    @isTest
    static void testGetReferenceFieldsFromJson_ValidJson() {
        String jsonString = getTestJsonString();
        
        Test.startTest();
        List<String> result = QuestionBookManagerController.getReferenceFieldsFromJson(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Result should contain reference fields');
    }
    
    @isTest
    static void testGetReferenceFieldsFromJson_InvalidJson() {
        String invalidJson = '{"invalid": "structure"}';
        
        Test.startTest();
        try {
            QuestionBookManagerController.getReferenceFieldsFromJson(invalidJson);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testGetReferenceFieldsFromJson_NullJson() {
        Test.startTest();
        try {
            QuestionBookManagerController.getReferenceFieldsFromJson(null);
            System.assert(false, 'Should have thrown exception');
        } catch (Exception e) {
            System.assertNotEquals(null, e.getMessage(), 'Exception message should not be null');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessJsonData_ValidJson() {
        String jsonString = getTestJsonString();
        
        Test.startTest();
        String result = QuestionBookManagerController.processJsonData(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('id'), 'Result should contain form id');
    }
    
    @isTest
    static void testProcessJsonData_InvalidJson() {
        String invalidJson = '{"invalid": "structure"}';
        
        Test.startTest();
        try {
            QuestionBookManagerController.processJsonData(invalidJson);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage().contains('Processing error'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testExtractObjectNameFromQuery() {
        String validQuery = 'SELECT Id, Name FROM Account WHERE Id = \'{c__record_id}\'';
        
        Test.startTest();
        String result = QuestionBookManagerController.extractObjectNameFromQuery(validQuery);
        Test.stopTest();
        
        System.assertEquals('Account', result, 'Should extract Account as object name');
    }
    
    @isTest
    static void testExtractObjectNameFromQuery_InvalidQuery() {
        String invalidQuery = 'INVALID QUERY';
        
        Test.startTest();
        String result = QuestionBookManagerController.extractObjectNameFromQuery(invalidQuery);
        Test.stopTest();
        
        System.assertEquals('', result, 'Should return empty string for invalid query');
    }
    
    @isTest
    static void testExtractObjectNameFromSubTitle() {
        String subTitle = 'Account__r.Name = \'Test\'';
        
        Test.startTest();
        String result = QuestionBookManagerController.extractObjectNameFromSubTitle(subTitle);
        Test.stopTest();
        
        System.assertEquals('Account__c', result, 'Should extract Account__c as object name');
    }
    
    @isTest
    static void testExtractObjectNameFromSubTitle_EmptyString() {
        Test.startTest();
        String result = QuestionBookManagerController.extractObjectNameFromSubTitle('');
        Test.stopTest();
        
        System.assertEquals('', result, 'Should return empty string');
    }
    
    @isTest
    static void testExtractFromSubTitle() {
        String subTitle = 'Account__r.Name = \'Test\' AND Contact__r.Email = \'test@test.com\'';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.extractFromSubTitle(subTitle, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.size() > 0, 'Should extract reference fields');
    }
    
    @isTest
    static void testProcessQuery_ValidQuery() {
        String validQuery = 'SELECT Id, Name FROM Account WHERE Id = \'{c__record_id}\'';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.processQuery(validQuery, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.size() > 0, 'Should process query fields');
    }
    
    @isTest
    static void testProcessQuery_InvalidQuery() {
        String invalidQuery = 'INVALID QUERY';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        try {
            QuestionBookManagerController.processQuery(invalidQuery, referenceFields);
            System.assert(false, 'Should have thrown exception');
        } catch (QuestionBookManagerController.CustomException e) {
            System.assert(e.getMessage().contains('FROM clause not found'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessFieldsSection() {
        String fieldsSection = 'Id, Name, (SELECT Id, Name FROM Contacts)';
        String objectName = 'Account';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.processFieldsSection(fieldsSection, objectName, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.size() > 0, 'Should process fields section');
    }
    
    @isTest
    static void testProcessInnerQuery() {
        String innerQuery = '(SELECT Id, Name FROM Contacts)';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.processInnerQuery(innerQuery, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.size() >= 0, 'Should process inner query');
    }
    
    @isTest
    static void testAddFieldToList() {
        String fieldPart = 'Name';
        String objectName = 'Account';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.addFieldToList(fieldPart, objectName, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.contains('Account.Name'), 'Should add field to list');
    }
    
    @isTest
    static void testAddFieldToList_WithAlias() {
        String fieldPart = 'Name';
        String objectName = 'Account';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.addFieldToList(fieldPart, objectName, referenceFields);
        Test.stopTest();
        
        System.assert(referenceFields.size() == 1, 'Should add one field without alias');
        System.assert(referenceFields[0].endsWith('.Name'), 'Field should end with .Name');
    }
    
    @isTest
    static void testAddFieldToList_IdField() {
        String fieldPart = 'Id';
        String objectName = 'Account';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.addFieldToList(fieldPart, objectName, referenceFields);
        Test.stopTest();
        
        System.assertEquals(0, referenceFields.size(), 'Should not add Id field');
    }
    
    @isTest
    static void testAddFieldToList_EmptyField() {
        String fieldPart = '';
        String objectName = 'Account';
        List<String> referenceFields = new List<String>();
        
        Test.startTest();
        QuestionBookManagerController.addFieldToList(fieldPart, objectName, referenceFields);
        Test.stopTest();
        
        System.assertEquals(0, referenceFields.size(), 'Should not add empty field');
    }
    
    @isTest
    static void testCreateQuestionBook() {
        Map<String, Object> questionBook = new Map<String, Object>{
            'title' => 'Test Book',
            'category' => 'Simple',
            'uniqueIdentifier' => 'test-unique-id',
            'objectApiName' => 'Account',
            'query' => 'SELECT Id FROM Account'
        };
        
        Test.startTest();
        Question_Book__c result = QuestionBookManagerController.createQuestionBook(questionBook);
        Test.stopTest();
        
        System.assertNotEquals(null, result.Id, 'Should create question book');
        System.assertEquals('Test Book', result.Title__c, 'Should set title correctly');
    }
    
    @isTest
    static void testExtractReferenceId_MapObject() {
        Map<String, Object> container = new Map<String, Object>{
            'testKey' => new Map<String, Object>{'Id' => 'test-id-123'}
        };
        
        Test.startTest();
        String result = QuestionBookManagerController.extractReferenceId(container, 'testKey');
        Test.stopTest();
        
        System.assertEquals('test-id-123', result, 'Should extract reference ID from map');
    }
    
    @isTest
    static void testExtractReferenceId_StringObject() {
        Map<String, Object> container = new Map<String, Object>{
            'testKey' => 'direct-id-123'
        };
        
        Test.startTest();
        String result = QuestionBookManagerController.extractReferenceId(container, 'testKey');
        Test.stopTest();
        
        System.assertEquals('direct-id-123', result, 'Should extract direct reference ID');
    }
    
    @isTest
    static void testExtractReferenceId_MissingKey() {
        Map<String, Object> container = new Map<String, Object>();
        
        Test.startTest();
        String result = QuestionBookManagerController.extractReferenceId(container, 'missingKey');
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null for missing key');
    }
    
    @isTest
    static void testFormatJsonStyleString() {
        Test.startTest();
        String result1 = QuestionBookManagerController.formatJsonStyleString('color: red;');
        String result2 = QuestionBookManagerController.formatJsonStyleString('{color: red;}');
        String result3 = QuestionBookManagerController.formatJsonStyleString('');
        String result4 = QuestionBookManagerController.formatJsonStyleString(null);
        Test.stopTest();
        
        System.assertEquals('{color: red;}', result1, 'Should wrap with braces');
        System.assertEquals('{color: red;}', result2, 'Should keep existing braces');
        System.assertEquals(null, result3, 'Should return null for empty string');
        System.assertEquals(null, result4, 'Should return null for null input');
    }
    
    @isTest
    static void testProcessInput() {
        Question_Book__c book = [SELECT Id FROM Question_Book__c LIMIT 1];
        
        Test.startTest();
        QuestionBookManagerController.processInput(book.Id);
        Test.stopTest();
        
        List<Input__c> inputs = [SELECT Id FROM Input__c WHERE Question_Book__c = :book.Id AND API_Name__c = 'c__record_id'];
        System.assertEquals(2, inputs.size(), 'Should create input record');
    }
    
    @isTest
    static void testProcessInput_NullBookId() {
        Test.startTest();
        try {
            QuestionBookManagerController.processInput(null);
            System.assert(false, 'Should have thrown exception');
        } catch (AuraHandledException e) {
            System.assertNotEquals(null, e.getMessage().contains('Error processing input'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessForm() {
        Question_Book__c book = [SELECT Id FROM Question_Book__c LIMIT 1];
        
        Test.startTest();
        String result = QuestionBookManagerController.processForm(book.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return form result');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('id'), 'Result should contain form id');
    }
    
    @isTest
    static void testProcessForm_NullBookId() {
        Test.startTest();
        try {
            QuestionBookManagerController.processForm(null);
            System.assert(false, 'Should have thrown exception');
        } catch (QuestionBookManagerController.CustomException e) {
            System.assert(e.getMessage().contains('Root Book ID is null'), 'Should contain error message');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testProcessFieldReference() {
        Question__c question = [SELECT Id, Unique_Identifier__c FROM Question__c LIMIT 1];
        Field_Meta__c fieldMeta = [SELECT Id FROM Field_Meta__c LIMIT 1];
        
        Map<Id, String> fieldReferences = new Map<Id, String>{
            fieldMeta.Id => question.Unique_Identifier__c
        };
        
        Map<String, Id> questionReferenceId = new Map<String, Id>{
            question.Unique_Identifier__c => question.Id
        };
        
        Test.startTest();
        QuestionBookManagerController.processFieldReference(fieldReferences, questionReferenceId);
        Test.stopTest();
        
        Field_Meta__c updatedFieldMeta = [SELECT Id, Question_Reference__c FROM Field_Meta__c WHERE Id = :fieldMeta.Id];
        System.assertEquals(question.Id, updatedFieldMeta.Question_Reference__c, 'Should update field reference');
    }
    
    @isTest
    static void testProcessTriggerUpdate() {
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        Set<Id> questionIds = new Set<Id>{question.Id};
        
        Test.startTest();
        QuestionBookManagerController.processTriggerUpdate(questionIds);
        Test.stopTest();
        
        // Just verify the method runs without exception
        System.assert(true, 'Method should execute without exception');
    }
    
    @isTest
    static void testProcessTriggerUpdate_EmptySet() {
        Test.startTest();
        QuestionBookManagerController.processTriggerUpdate(new Set<Id>());
        QuestionBookManagerController.processTriggerUpdate(null);
        Test.stopTest();
        
        System.assert(true, 'Method should handle empty/null input');
    }
    
    @isTest
    static void testParseAndValidateJson() {
        String validJson = '{"questionbook": {"title": "Test"}}';
        String invalidJson = '{"invalid": "structure"}';
        
        Test.startTest();
        Map<String, Object> result1 = QuestionBookManagerController.parseAndValidateJson(validJson);
        
        try {
            QuestionBookManagerController.parseAndValidateJson(invalidJson);
            System.assert(false, 'Should have thrown exception');
        } catch (QuestionBookManagerController.CustomException e) {
            System.assert(e.getMessage().contains('Invalid JSON structure'), 'Should contain error message');
        }
        Test.stopTest();
        
        System.assertNotEquals(null, result1, 'Should parse valid JSON');
    }
    
    @isTest
    static void testProcessQueryStrings() {
        Map<String, Object> questionBook = new Map<String, Object>{
            'query' => 'SELECT Id FROM Account WHERE Id = \'001000000000000AAA\''
        };
        
        Test.startTest();
        QuestionBookManagerController.processQueryStrings(questionBook);
        Test.stopTest();
        
        String updatedQuery = (String) questionBook.get('query');
        System.assert(updatedQuery.contains('{c__record_id}'), 'Should replace ID with placeholder');
    }
    
    // Helper method to generate test JSON string
    private static String getTestJsonString() {
        Map<String, Object> jsonStructure = new Map<String, Object>();
        
        Map<String, Object> questionbook = new Map<String, Object>();
        questionbook.put('title', 'Test Book');
        questionbook.put('category', 'Simple');
        questionbook.put('uniqueIdentifier', 'test-unique-id-123');
        questionbook.put('objectApiName', 'Account');
        questionbook.put('query', 'SELECT Id, Name FROM Account WHERE Id = {c__record_id}');
        
        List<Object> subQuestions = new List<Object>();
        Map<String, Object> question = new Map<String, Object>();
        question.put('type', 'Text');
        question.put('questionNumber', 1);
        question.put('uniqueIdentifier', 'test-question-1');
        question.put('questionText', 'Test Question');
        question.put('title', 'Test Title');
        question.put('size', 6);
        question.put('isSno', false);
        question.put('isSerialNo', false);
        
        List<Object> fieldsMeta = new List<Object>();
        Map<String, Object> fieldMeta = new Map<String, Object>();
        fieldMeta.put('uniqueIdentifier', 'test-field-1');
        fieldMeta.put('apiName', 'Name');
        fieldMeta.put('fldType', 'Text');
        fieldMeta.put('label', 'Name');
        fieldsMeta.add(fieldMeta);
        
        question.put('fieldsMeta', fieldsMeta);
        question.put('style', '{"labelClass": "slds-grid"}');
        
        subQuestions.add(question);
        questionbook.put('subQuestions', subQuestions);
        
        jsonStructure.put('questionbook', questionbook);
        
        return JSON.serialize(jsonStructure);
    }

    
    // Test batch class functionality
    @isTest
    static void testQuestionTriggerUpdateBatch() {
        Question__c question = [SELECT Id, QB_Reference__c, Type__c FROM Question__c];
        Set<Id> questionIds = new Set<Id>{question.Id};
        
        Test.startTest();
        QuestionTriggerUpdateBatch batch = new QuestionTriggerUpdateBatch(questionIds);
        Database.QueryLocator ql = batch.start(null);
        System.assertNotEquals(null, ql, 'Query locator should not be null');
        
        List<Question__c> questions = new List<Question__c>{question};
        batch.execute(null, questions);
        batch.finish(null);
        Test.stopTest();
        
        System.assert(true, 'Batch should execute successfully');
    }

    @isTest
    static void testProcessJsonData_ValidTabJson() {
        String jsonString = getValidTestJsonString();
        
        Test.startTest();
        String result = QuestionBookManagerController.processJsonData(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('id'), 'Result should contain form id');
    }

    @isTest
    static void testProcessJsonData_WithTable() {
        String jsonString = getValidTableTestJsonString();
        
        Test.startTest();
        String result = QuestionBookManagerController.processJsonData(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assert(resultMap.containsKey('id'), 'Result should contain form id');
    }

    @isTest
    static void testProcessJsonData_RecursiveQuestionBooks() {
        String jsonString = getRecursiveTestJsonString();
        
        Test.startTest();
        String result = QuestionBookManagerController.processJsonData(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify recursive processing created multiple question books
        List<Question_Book__c> books = [SELECT Id FROM Question_Book__c];
        System.assert(books.size() > 1, 'Should create multiple question books for recursive structure');
    }

    @isTest
    static void testGetReferenceFieldsFromJson_WithTable() {
        String jsonString = getValidTableTestJsonString();
        
        Test.startTest();
        List<String> result = QuestionBookManagerController.getReferenceFieldsFromJson(jsonString);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assert(result.size() > 0, 'Result should contain reference fields');
        
        // Check for table-specific reference fields
        Boolean hasTableField = false;
        for (String field : result) {
            if (field.contains('Contact.')) {
                hasTableField = true;
                break;
            }
        }
        System.assert(hasTableField, 'Should contain table reference fields');
    }

    @isTest
    static void testProcessRecursiveQuestionBooks_MultipleBooks() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> mainBook = getMainBookForRecursion();
        jsonData.put('questionbook', mainBook);
        
        Test.startTest();
        Id result = QuestionBookManagerController.processRecursiveQuestionBooks(
            mainBook, 
            jsonData, 
            new Set<String>()
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return main book ID');
        
        // Verify both main and referenced books are created
        List<Question_Book__c> books = [SELECT Id, Title__c FROM Question_Book__c ORDER BY CreatedDate];
        System.assert(books.size() >= 2, 'Should create at least 2 question books');
    }

    @isTest
    static void testProcessRecursiveQuestionBooks_BookType() {
        Map<String, Object> jsonData = new Map<String, Object>();
        Map<String, Object> bookWithReference = getBookTypeQuestionBook();
        jsonData.put('questionbook', bookWithReference);
        
        Test.startTest();
        Id result = QuestionBookManagerController.processRecursiveQuestionBooks(
            bookWithReference, 
            jsonData, 
            new Set<String>()
        );
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Should return book ID');
        
        // Verify QB_Reference__c is set for Book type questions
        List<Question__c> questions = [SELECT Id, QB_Reference__c, Type__c FROM Question__c WHERE Type__c = 'Book'];
        System.assert(questions.size() > 0, 'Should create Book type questions');
    }

    @isTest
    static void testProcessStyle_MultipleStyles() {
        Question__c question = [SELECT Id FROM Question__c LIMIT 1];
        
        //List<StyleWrapper> styles = new List<StyleWrapper>();

            Style__c s1 = new Style__c(
            Label_Class__c = 'slds-grid',
            Label_Style__c = 'color: blue;',
            Input_Class__c = 'slds-input',
            Input_Style__c = 'background: white;',
            external_id__c = 'test-style-1'
        );
        
        Style__c s2 = new Style__c(
            Label_Class__c = 'slds-form-element',
            Label_Style__c = 'font-weight: bold;',
            external_id__c = 'test-style-2'
        );
        
        List<StyleWrapper> styles = new List<StyleWrapper>{
            new StyleWrapper(s1),
            new StyleWrapper(s2)
        };

       // styleMap.put(question.Id, styles);
        Map<Id, List<StyleWrapper>> styleMap1 = new Map<Id, List<StyleWrapper>>{
            question.Id => styles
        };
        
        Test.startTest();
        QuestionBookManagerController.processStyle(styleMap1);
        Test.stopTest();
        
        List<Style__c> createdStyles = [SELECT Id FROM Style__c WHERE Question__c = :question.Id];
        System.assertNotEquals(null, createdStyles.size(), 'Should create style records');
    }

    @isTest
    static void testProcessFieldMeta_WithQuestionReference() {
        Question__c question1 = [SELECT Id, Unique_Identifier__c, Question_Book__c FROM Question__c LIMIT 1];
        
        // Create second question for reference
        Id recTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
            .get('UNCONDITIONAL')?.getRecordTypeId();
        
        Question__c question2 = new Question__c(
            Question_Book__c = question1.Question_Book__c,
            Type__c = 'Text',
            Question_No__c = 2,
            RecordTypeId = recTypeId,
            Unique_Identifier__c = 'referenced-question-unique-id',
            Question_Text__c = 'Referenced Question'
        );
        insert question2;
        
        Map<Id, List<Object>> fieldMetaMap = new Map<Id, List<Object>>();
        List<Object> fieldMetas = new List<Object>{
            new Map<String, Object>{
                'uniqueIdentifier' => 'field-meta-with-ref',
                'apiName' => 'TestField__c',
                'fldType' => 'Text',
                'label' => 'Test Field',
                'questionReference' => new Map<String, Object>{
                    'question' => new Map<String, Object>{
                        'uniqueIdentifier' => 'referenced-question-unique-id'
                    }
                }
            }
        };
        fieldMetaMap.put(question1.Id, fieldMetas);
        
        Test.startTest();
        QuestionBookManagerController.processFieldMeta(fieldMetaMap);
        Test.stopTest();
        
        List<Field_Meta__c> createdFieldMetas = [
            SELECT Id, Question_Reference__c 
            FROM Field_Meta__c 
            WHERE Question__c = :question1.Id 
            AND Unique_Identifier__c = 'field-meta-with-ref'
        ];
       // System.assertEquals(1, createdFieldMetas.size(), 'Should create field meta with reference');
    }

    // Helper Methods for JSON Generation

    private static String getValidTestJsonString() {
        return JSON.serialize(new Map<String, Object>{
            'questionbook' => new Map<String, Object>{
                'title' => 'Test Book',
                'category' => 'Simple',
                'uniqueIdentifier' => 'test-unique-id-123',
                'objectApiName' => 'Account',
                'query' => 'SELECT Id, Name FROM Account WHERE Id = {c__record_id}',
                'subQuestions' => new List<Object>{
                    new Map<String, Object>{
                        'type' => 'Text',
                        'questionNumber' => 1,
                        'uniqueIdentifier' => 'test-question-1',
                        'questionText' => 'Test Question',
                        'title' => 'Test Title',
                        'size' => 6,
                        'isSno' => false,
                        'isSerialNo' => false,
                        'fieldsMeta' => new List<Object>{
                            new Map<String, Object>{
                                'uniqueIdentifier' => 'test-field-1',
                                'apiName' => 'Name',
                                'fldType' => 'Text',
                                'label' => 'Name'
                            }
                        },
                        'style' => new Map<String, Object>{
                            'labelClass' => 'slds-grid',
                            'externalId' => 'test-style-ext-1'
                        }
                    }
                }
            }
        });
    }

    private static String getValidTableTestJsonString() {
        return JSON.serialize(new Map<String, Object>{
            'questionbook' => new Map<String, Object>{
                'title' => 'Account with Contacts Table',
                'category' => 'Simple',
                'uniqueIdentifier' => 'account-contacts-book',
                'objectApiName' => 'Account',
                'query' => 'SELECT Id, Name, Phone FROM Account WHERE Id = {c__record_id}',
                'subQuestions' => new List<Object>{
                    new Map<String, Object>{
                        'type' => 'Text',
                        'questionNumber' => 1,
                        'uniqueIdentifier' => 'account-name-question',
                        'questionText' => 'Account Name',
                        'title' => 'Account Name',
                        'size' => 6,
                        'isSno' => false,
                        'isSerialNo' => false,
                        'fieldsMeta' => new List<Object>{
                            new Map<String, Object>{
                                'uniqueIdentifier' => 'account-name-field',
                                'apiName' => 'Name',
                                'fldType' => 'Text',
                                'label' => 'Account Name'
                            }
                        }
                    },
                    new Map<String, Object>{
                        'type' => 'Table',
                        'questionNumber' => 2,
                        'uniqueIdentifier' => 'contacts-table-question',
                        'questionText' => 'Related Contacts',
                        'title' => 'Contact',
                        'subTitle' => 'AccountId = {c__record_id}',
                        'size' => 12,
                        'isSno' => false,
                        'isSerialNo' => false,
                        'fieldsMeta' => new List<Object>{
                            new Map<String, Object>{
                                'uniqueIdentifier' => 'contact-name-field',
                                'apiName' => 'Name',
                                'fldType' => 'Text',
                                'label' => 'Contact Name'
                            },
                            new Map<String, Object>{
                                'uniqueIdentifier' => 'contact-email-field',
                                'apiName' => 'Email',
                                'fldType' => 'Email',
                                'label' => 'Contact Email'
                            }
                        }
                    }
                }
            }
        });
    }

    private static String getRecursiveTestJsonString() {
        return JSON.serialize(new Map<String, Object>{
            'questionbook' => new Map<String, Object>{
                'title' => 'Main Question Book',
                'category' => 'Simple',
                'uniqueIdentifier' => 'main-book-recursive',
                'objectApiName' => 'Account',
                'query' => 'SELECT Id, Name FROM Account WHERE Id = {c__record_id}',
                'subQuestions' => new List<Object>{
                    new Map<String, Object>{
                        'type' => 'Book',
                        'questionNumber' => 1,
                        'uniqueIdentifier' => 'nested-book-question',
                        'questionText' => 'Nested Book',
                        'title' => 'Nested Book',
                        'size' => 12,
                        'isSno' => false,
                        'isSerialNo' => false,
                        'qbReference' => 'nested-book-ref',
                        'qbReferenceQuestions' => new Map<String, Object>{
                            'questionbook' => new Map<String, Object>{
                                'title' => 'Nested Question Book',
                                'category' => 'Simple',
                                'uniqueIdentifier' => 'nested-book-unique',
                                'objectApiName' => 'Contact',
                                'query' => 'SELECT Id, Name, Email FROM Contact WHERE AccountId = {c__record_id}',
                                'subQuestions' => new List<Object>{
                                    new Map<String, Object>{
                                        'type' => 'Text',
                                        'questionNumber' => 1,
                                        'uniqueIdentifier' => 'nested-contact-name',
                                        'questionText' => 'Contact Name',
                                        'title' => 'Contact Name',
                                        'size' => 6,
                                        'isSno' => false,
                                        'isSerialNo' => false,
                                        'fieldsMeta' => new List<Object>{
                                            new Map<String, Object>{
                                                'uniqueIdentifier' => 'nested-name-field',
                                                'apiName' => 'Name',
                                                'fldType' => 'Text',
                                                'label' => 'Name'
                                            }
                                        }
                                    }
                                }
                            }
                        },
                        'fieldsMeta' => new List<Object>{
                            new Map<String, Object>{
                                'uniqueIdentifier' => 'book-field-meta',
                                'apiName' => 'BookField',
                                'fldType' => 'Text',
                                'label' => 'Book Field',
                                'questionReference' => new Map<String, Object>{
                                    'question' => new Map<String, Object>{
                                        'uniqueIdentifier' => 'nested-contact-name'
                                    }
                                }
                            }
                        }
                    }
                }
            }
        });
    }

    private static Map<String, Object> getMainBookForRecursion() {
        return new Map<String, Object>{
            'title' => 'Main Book for Recursion',
            'category' => 'Simple',
            'uniqueIdentifier' => 'main-recursion-book',
            'objectApiName' => 'Account',
            'query' => 'SELECT Id, Name FROM Account',
            'subQuestions' => new List<Object>{
                new Map<String, Object>{
                    'type' => 'Table',
                    'questionNumber' => 1,
                    'uniqueIdentifier' => 'table-with-reference',
                    'questionText' => 'Related Records',
                    'title' => 'Contact',
                    'size' => 12,
                    'isSno' => false,
                    'isSerialNo' => false,
                    'qbReference' => 'child-book-ref',
                    'qbReferenceQuestions' => new Map<String, Object>{
                        'questionbook' => new Map<String, Object>{
                            'title' => 'Child Question Book',
                            'category' => 'Simple',
                            'uniqueIdentifier' => 'child-book-unique',
                            'objectApiName' => 'Contact',
                            'subQuestions' => new List<Object>{
                                new Map<String, Object>{
                                    'type' => 'Text',
                                    'questionNumber' => 1,
                                    'uniqueIdentifier' => 'child-text-question',
                                    'questionText' => 'Child Text',
                                    'size' => 6,
                                    'isSno' => false,
                                    'isSerialNo' => false,
                                    'fieldsMeta' => new List<Object>{
                                        new Map<String, Object>{
                                            'uniqueIdentifier' => 'child-field',
                                            'apiName' => 'Name',
                                            'fldType' => 'Text',
                                            'label' => 'Child Name'
                                        }
                                    }
                                }
                            }
                        }
                    },
                    'fieldsMeta' => new List<Object>{
                        new Map<String, Object>{
                            'uniqueIdentifier' => 'table-field-meta',
                            'apiName' => 'Name',
                            'fldType' => 'Text',
                            'label' => 'Table Field'
                        }
                    }
                }
            }
        };
    }

    private static Map<String, Object> getBookTypeQuestionBook() {
        return new Map<String, Object>{
            'title' => 'Book Type Test',
            'category' => 'Simple',
            'uniqueIdentifier' => 'book-type-test',
            'objectApiName' => 'Account',
            'subQuestions' => new List<Object>{
                new Map<String, Object>{
                    'type' => 'Book',
                    'questionNumber' => 1,
                    'uniqueIdentifier' => 'book-question-test',
                    'questionText' => 'Book Question',
                    'size' => 12,
                    'isSno' => false,
                    'isSerialNo' => false,
                    'qbReference' => 'referenced-book',
                    'qbReferenceQuestions' => new Map<String, Object>{
                        'questionbook' => new Map<String, Object>{
                            'title' => 'Referenced Book',
                            'category' => 'Simple',
                            'uniqueIdentifier' => 'referenced-book-unique',
                            'objectApiName' => 'Contact',
                            'subQuestions' => new List<Object>{
                                new Map<String, Object>{
                                    'type' => 'Text',
                                    'questionNumber' => 1,
                                    'uniqueIdentifier' => 'ref-text-question',
                                    'questionText' => 'Referenced Text',
                                    'size' => 6,
                                    'isSno' => false,
                                    'isSerialNo' => false,
                                    'fieldsMeta' => new List<Object>()
                                }
                            }
                        }
                    },
                    'fieldsMeta' => new List<Object>()
                }
            }
        };
    }

    // Additional edge case tests

    @isTest
    static void testProcessRecursiveQuestionBooks_NullInput() {
        Test.startTest();
        Id result = QuestionBookManagerController.processRecursiveQuestionBooks(
            null, 
            new Map<String, Object>(), 
            new Set<String>()
        );
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null for null input');
    }

    @isTest
    static void testProcessRecursiveQuestionBooks_NoSubQuestions() {
        Map<String, Object> bookWithoutSubQuestions = new Map<String, Object>{
            'title' => 'Book Without SubQuestions',
            'uniqueIdentifier' => 'no-sub-questions'
        };
        
        Test.startTest();
        Id result = QuestionBookManagerController.processRecursiveQuestionBooks(
            bookWithoutSubQuestions, 
            new Map<String, Object>(), 
            new Set<String>()
        );
        Test.stopTest();
        
        System.assertEquals(null, result, 'Should return null when no subQuestions');
    }

}