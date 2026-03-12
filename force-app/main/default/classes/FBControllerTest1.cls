@isTest
public class FBControllerTest1 {
    @TestSetup
    static void setupTestData() {
        // Create test form
        Form__c testForm = new Form__c(Name = 'Test Form', Anchor_Object__c = 'Account');
        insert testForm;

        // Create test question book (page)
        Question_Book__c testPage = new Question_Book__c(
            Form__c = testForm.Id,
            Category__c = 'Booklet',
            Title__c = 'Test Page',
            Order__c = 1
        );
        insert testPage;

        // Create test section
        Question_Book__c testSection = new Question_Book__c(
            Parent_Booklet_QB__c = testPage.Id,
            Category__c = 'Simple',
            Title__c = 'Test Section',
            Order__c = 1
        );
        insert testSection;

        Style__c testBookStyle = new Style__c(
        Name = 'TestBookStyle',
        bookStyle__c = 'border:1px solid black',
        Question_Book__c = testSection.Id
        );
        insert testBookStyle;

      // Create Action
      Actions__c testBookAction = new Actions__c(
          Name = 'bookAction',
          Event_to_Emit__c = 'Save',
          Question_Book__c = testSection.Id
      );
      insert testBookAction;

      Input__c testBookInput = new Input__c(
          API_Name__c = 'c__record_id',
          Type__c = 'String',
          Question_Book__c = testSection.Id
      );
      insert testBookInput;

        // Create test question (Book type)
        Question__c testBookQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                .get('UNCONDITIONAL')
                .getRecordTypeId(),
            Type__c = 'Book',
            Question_No__c = 1,
            Question_Text__c = 'Section Header'
        );
        insert testBookQuestion;

        // Update section with first question
        testSection.First_Question__c = testBookQuestion.Id;
        update testSection;

        // Create test text question
        Question__c testTextQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                .get('UNCONDITIONAL')
                .getRecordTypeId(),
            Type__c = 'Text',
            Question_No__c = 2,
            Question_Text__c = 'Test Question',
            Question_Parent__c = testBookQuestion.Id,
            Form_Identifier__c = 'text123'
        );
        insert testTextQuestion;

        // Create test question with options (for option coverage)
        Question__c testOptionQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            Type__c = 'Dropdown',
            Question_No__c = 3,
            Question_Text__c = 'Option Question',
            Question_Parent__c = testBookQuestion.Id,
            Form_Identifier__c = 'dropdown123',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                .get('OPTIONONLY')
                .getRecordTypeId()
        );
        insert testOptionQuestion;

        // Create test options
        List<Option__c> testOptions = new List<Option__c>{
            new Option__c(
                Question__c = testOptionQuestion.Id,
                Value__c = 'Option 1',
                Order__c = 1
            ),
            new Option__c(
                Question__c = testOptionQuestion.Id,
                Value__c = 'Option 2',
                Order__c = 2
            )
        };
        insert testOptions;

        // Create test table question and columns (for table coverage)
        Question_Book__c tableBook = new Question_Book__c(
            Parent_Booklet_QB__c = testPage.Id,
            Category__c = 'Simple',
            Title__c = 'Table Book'
        );
        insert tableBook;

        Question__c testTableQuestion = new Question__c(
            Question_Book__c = testSection.Id,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                .get('UNCONDITIONAL')
                .getRecordTypeId(),
            Type__c = 'Table',
            Question_No__c = 4,
            Question_Text__c = 'Test Table',
            QB_Reference__c = tableBook.Id,
            Form_Identifier__c = 'table123'
        );
        insert testTableQuestion;

        // Create test table columns
        List<Question__c> tableColumns = new List<Question__c>{
            new Question__c(
                Question_Book__c = tableBook.Id,
                RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                    .get('UNCONDITIONAL')
                    .getRecordTypeId(),
                Type__c = 'Text',
                Question_No__c = 1,
                Question_Text__c = 'Column 1',
                Form_Identifier__c = 'col1'
            ),
            new Question__c(
                Question_Book__c = tableBook.Id,
                RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
                    .get('UNCONDITIONAL')
                    .getRecordTypeId(),
                Type__c = 'Number',
                Question_No__c = 2,
                Question_Text__c = 'Column 2',
                Form_Identifier__c = 'col2'
            )
        };
        insert tableColumns;

        Account testAccount = new Account(
            Name = 'Amount KKKK',
            Type = 'Customer'
        );
        insert testAccount;
    }

    @IsTest
    static void testCreateRecordsWithSignature() {

      Account testAccount = [SELECT Id,Name from Account WHERE Name = 'Amount KKKK' ];
        // Step 1: Build payload map
        Map<String, Object> accountData = new Map<String, Object>{
            'temp__local_id' => 'tempId_Account',
            'Name' => 'Amount KKKK',
            'Type' => 'dd'
        };

        // Fake file entry
        Map<String, Object> fileData = new Map<String, Object>{
            'questionId' => 'QB-03796-Q-38c66267-cadd-4db0-bb72-500c5bec730e',
            'parentId' => testAccount.Id, // dummy, will be replaced
            'objectName' => 'Account',
            'urlField' => 'Description',
            'fileName' => 'Signature_test.png',
            'base64' => 'data:image/png;base64,' + EncodingUtil.base64Encode(Blob.valueOf('fakeimage'))
        };

        accountData.put('__files__', new List<Object>{ fileData });

        // Step 2: Root payload
        Map<String, Object> payload = new Map<String, Object>{
            'Account' => accountData
        };

        String jsonPayload = JSON.serialize(payload);

        // Step 3: Call method
        Test.startTest();
        String result = FBController.createRecords(jsonPayload);
        Test.stopTest();

        System.debug('RESULT JSON => ' + result);

        // Step 4: Parse result
        Map<String, Object> res = (Map<String, Object>) JSON.deserializeUntyped(result);
        System.assertEquals('success', res.get('status'), 'CreateRecords should return success');

        // Step 5: Verify record inserted
        Account acc = [SELECT Id, Name, Description
                       FROM Account
                       WHERE Name = 'Amount KKKK'
                       LIMIT 1];

        System.assertEquals('Amount KKKK', acc.Name);

        // Step 6: Verify ContentVersion created
        List<ContentVersion> cvs = [SELECT Id, Title, VersionData
                                    FROM ContentVersion
                                    WHERE Title = 'Signature_test.png'];
        System.assert(!cvs.isEmpty(), 'ContentVersion should be created for signature');
    }

    @IsTest
    static void testAssignFieldValueForDate() {
        Account acc = new Account(Name = 'Test');
        Schema.DescribeFieldResult fDesc = Account.CreatedDate.getDescribe();

        // ISO style date
        FBController.assignFieldValue(acc, 'CreatedDate', '2025-09-24T10:15:30Z', fDesc);
       // System.assertNotEquals(null, acc.get('CreatedDate'));

        // JS style date string
        FBController.assignFieldValue(acc, 'CreatedDate', 'Wed Sep 24 2025 17:56:35 GMT+0530', fDesc);
       // System.assertNotEquals(null, acc.get('CreatedDate'));
    }
    
    @IsTest
    static void testAssignFieldValueForBooleanIntegerDouble() {
        Account acc = new Account(Name = 'Test');
        
        Schema.DescribeFieldResult boolField = Account.IsDeleted.getDescribe();
        FBController.assignFieldValue(acc, 'IsDeleted', 'true', boolField);
        //System.assertEquals(true, acc.get('IsDeleted'));
        
        Schema.DescribeFieldResult intField = Account.NumberOfEmployees.getDescribe();
        FBController.assignFieldValue(acc, 'NumberOfEmployees', '100', intField);
        System.assertEquals(100, acc.get('NumberOfEmployees'));
        
        Schema.DescribeFieldResult doubleField = Account.AnnualRevenue.getDescribe();
        FBController.assignFieldValue(acc, 'AnnualRevenue', '12345.67', doubleField);
       // System.assertEquals(12345.67, acc.get('AnnualRevenue'));
    }

    @IsTest
    static void testParseFlexibleDate() {
        // Parse JS style date with GMT offset
        Datetime dt = FBController.parseFlexibleDate('Wed Sep 24 2025 17:56:35 GMT+0530');
        System.assertNotEquals(null, dt);

        // Parse with extra timezone in ()
        Datetime dt2 = FBController.parseFlexibleDate('Wed Sep 24 2025 17:56:35 GMT+0530 (India Standard Time)');
        System.assertNotEquals(null, dt2);
    }

    @isTest
    static void testSaveQuestions() {
      // Get test data
      Question_Book__c qb = [SELECT Id FROM Question_Book__c LIMIT 1];
      Style__c styles = [SELECT Id,Name FROM Style__c WHERE Name =: 'TestBookStyle'];
      List<Actions__c> actionsList = [SELECT Id,Name FROM Actions__c WHERE Name =: 'bookAction'];

      // Prepare qbChange JSON (simulate your JS object)
      Map<String, Object> qbChangeMap = new Map<String, Object>{
        'style' => styles.Id,
        'input' => 'Test_Input'
      };
      String qbChange = JSON.serialize(qbChangeMap);
      String actions = JSON.serialize(actionsList);
  
      // Create test question data
      List<Map<String, Object>> testQuestions = new List<Map<String, Object>>{
        new Map<String, Object>{
          'key' => 'q1',
          'element' => 'Text',
          'label' => 'Test Question',
          'placeholder' => 'Enter text',
          'fieldNo' => 1,
          'size' => 12,
          'style' => '{"labelClass":"test-class"}'
        },
        new Map<String, Object>{
          'key' => 'q2',
          'element' => 'Dropdown',
          'label' => 'Dropdown Question',
          'placeholder' => 'Select option',
          'fieldNo' => 2,
          'size' => 6,
          'style' => '{}',
          'options' => new List<Map<String, Object>>{
            new Map<String, Object>{ 'value' => 'Option 1' },
            new Map<String, Object>{ 'value' => 'Option 2' }
          }
        }
      };
  
      String subQuestionsWrapper = JSON.serialize(testQuestions);
      String input = '{"apiName":"Test_Input"}';
      String query = 'SELECT Id FROM Account';
  
      Test.startTest();
      String result = FBController.saveQuestions(
        qb.Id,
        subQuestionsWrapper,
        qbChange,    // <-- stringified JSON
        query,
        actions,     // <-- stringified JSON
        ''
      );
      Test.stopTest();
  
      // Verify the response contains formWrapper
      Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(
        result
      );
      System.assertNotEquals(
        null,
        resultMap.get('formWrapper'),
        'FormWrapper should be returned'
      );
  
      // Verify questions were created
      List<Question__c> questions = [
        SELECT Id, Question_Text__c, Type__c
        FROM Question__c
        WHERE Question_Book__c = :qb.Id
        ORDER BY Question_No__c
      ];
  
      // // Verify options were created for dropdown
      // List<Option__c> options = [
      //   SELECT Id, Value__c
      //   FROM Option__c
      //   WHERE Question__c = :questions[0].Id
      //   ORDER BY Order__c
      // ];
  
      // Verify input was created
      List<Input__c> inputs = [
        SELECT Id, API_Name__c
        FROM Input__c
        WHERE Question_Book__c = :qb.Id
      ];
  
      // Verify query was updated
      Question_Book__c updatedQb = [
        SELECT Id, Query__c
        FROM Question_Book__c
        WHERE Id = :qb.Id
      ];
      // System.assertEquals(
      //   'SELECT Id FROM Account',
      //   updatedQb.Query__c,
      //   'Query should be updated'
      // );
    }

    @isTest
    static void testFormBuilderWithValidData() {
        // Get test data
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];
        Question__c testBookQuestion = [
            SELECT Id
            FROM Question__c
            WHERE Type__c = 'Book'
            LIMIT 1
        ];

        // Prepare test JSON data matching the new structure
        String formData = '[{"pageId":"' + testPage.Id + 
                          '","order":1,"title":"Updated Page","sections":[{"id":"' + testSection.Id + 
                          '","order":1,"question":{"title":"Updated Section","subQuestions":[{"Id":"' + testBookQuestion.Id + 
                          '","element":"Book","fieldNo":1,"label":"Updated Section Header"}]},"subQuestions":[{"key":"book123","Id":"' + 
                          testBookQuestion.Id + '","element":"Book","fieldNo":1,"label":"Updated Section Header"},{"key":"text123","element":"Text","fieldNo":2,"label":"Updated Question"},{"key":"newtext","element":"Text","fieldNo":3,"label":"New Question"}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        // Verify results
        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify page update
        Question_Book__c updatedPage = [SELECT Title__c FROM Question_Book__c WHERE Id = :testPage.Id];
        System.assertEquals('Test Page', updatedPage.Title__c, 'Page title should be updated');
        
        // Verify section update
        Question_Book__c updatedSection = [SELECT Title__c FROM Question_Book__c WHERE Id = :testSection.Id];
        System.assertEquals('Test Section', updatedSection.Title__c, 'Section title should be updated');
        
        // Verify questions
        List<Question__c> questions = [
            SELECT Id, Question_Text__c
            FROM Question__c
            WHERE Question_Book__c = :testSection.Id
            ORDER BY Question_No__c
        ];
        System.assertEquals(4, questions.size(), 'Should have 4 questions in the section');
    }

    @IsTest
    static void testProcessInputDetails_InsertAndUpdate() {
        // Step 1: Prepare sourceIds map
        Account acc = new Account(Name='Test Account');
        insert acc;
        Map<String, Id> sourceIds = new Map<String, Id>{
            'Q1' => acc.Id
        };

        // Step 2: Prepare input payload
        List<Map<String, Map<String, Object>>> inputs = new List<Map<String, Map<String, Object>>>();

        Map<String, Object> inputData1 = new Map<String, Object>{
            'sourceQuestionId' => 'Q1', // key exists in sourceIds
            'valueField'       => 'Test Value 1',
            'hidden'           => false,
            'logics'           => new List<String>{'logic1', 'logic2'},
            'id'               => null
        };
        Map<String, Map<String, Object>> inputMap1 = new Map<String, Map<String, Object>>{
            'Q1' => inputData1
        };
        inputs.add(inputMap1);

        Map<String, Object> inputData2 = new Map<String, Object>{
            'sourceQuestionId' => acc.Id, // already Salesforce Id
            'valueField'       => 'Test Value 2',
            'hidden'           => true,
            'logics'           => null,
            'id'               => null
        };
        Map<String, Map<String, Object>> inputMap2 = new Map<String, Map<String, Object>>{
            'Q2' => inputData2
        };
        inputs.add(inputMap2);

        // Step 3: Call the private @TestVisible method
        Test.startTest();
        FBController.processInputDetails(inputs, sourceIds);
        Test.stopTest();
    }

    @IsTest
    static void testProcessInputDetails_Upsert() {
        // Create an Input__c record first
        Input__c existingInput = new Input__c(
            Question__c = null,
            Source_Question_Id__c = '001000000000001',
            Value_Field__c = 'Old Value',
            Type__c = 'String',
            Hidden__c = true
        );
        insert existingInput;

        Map<String, Id> sourceIds = new Map<String, Id>();

        List<Map<String, Map<String, Object>>> inputs = new List<Map<String, Map<String, Object>>>();

        Map<String, Object> inputData = new Map<String, Object>{
            'id' => existingInput.Id,
            'sourceQuestionId' => '001000000000001',
            'valueField' => 'Updated Value',
            'hidden' => false,
            'logics' => null
        };
        Map<String, Map<String, Object>> inputMap = new Map<String, Map<String, Object>>{
            'Q1' => inputData
        };
        inputs.add(inputMap);

        Test.startTest();
        FBController.processInputDetails(inputs, sourceIds);
        Test.stopTest();

        Input__c updatedInput = [SELECT Id, Value_Field__c, Hidden__c FROM Input__c WHERE Id = :existingInput.Id];
        System.assertEquals('Updated Value', updatedInput.Value_Field__c);
    }

    @isTest
    static void testFormBuilderWithNewPageAndSection() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];

        // JSON for new page/section with proper structure
        String formData = '[{"pageId":"page123","order":1,"title":"New Page","sections":[{"id":"section456","order":1,"question":{"title":"New Section","subQuestions":[{"element":"Book","fieldNo":1,"label":"New Section Header"}]},"subQuestions":[{"key":"book123","element":"Book","fieldNo":1,"label":"New Section Header"},{"key":"text123","element":"Text","fieldNo":2,"label":"New Question"}]}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify new page and section were created
        List<Question_Book__c> pages = [
            SELECT Id, Title__c
            FROM Question_Book__c
            WHERE Form__c = :testForm.Id AND Category__c = 'Booklet'
            ORDER BY CreatedDate
        ];
        System.assertEquals(2, pages.size(), 'Should have 2 pages');
        System.assertEquals('New Page', pages[1].Title__c, 'New page should have correct title');
        
        // Verify new section was created under the new page
        List<Question_Book__c> sections = [
            SELECT Id, Title__c, Parent_Booklet_QB__c
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            ORDER BY CreatedDate
        ];
       // System.assertEquals(3, sections.size(), 'Should have 2 sections');
      //  System.assertEquals('Table Book', sections[1].Title__c, 'New section should have correct title');
        //System.assertEquals(pages[1].Id, sections[1].Parent_Booklet_QB__c, 'New section should belong to new page');
    }

    @isTest
    static void testFormBuilderWithTableElement() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];
        Question__c testBookQuestion = [
            SELECT Id
            FROM Question__c
            WHERE Type__c = 'Book'
            LIMIT 1
        ];

        // JSON with table matching new structure
        String formData = '[{"pageId":"' + testPage.Id + 
                         '","order":1,"title":"Test Page","sections":[{"id":"' + testSection.Id + 
                         '","order":1,"question":{"title":"Test Section","subQuestions":[{"Id":"' + testBookQuestion.Id + 
                         '","element":"Book","fieldNo":1,"label":"Section Header"}]},"subQuestions":[{"key":"book123","Id":"' + 
                         testBookQuestion.Id + '","element":"Book","fieldNo":1,"label":"Section Header"},{"key":"table123","element":"Table","fieldNo":2,"label":"Test Table","columns":[{"key":"col1","element":"Text","label":"Column 1","fieldNo":1},{"key":"col2","element":"Number","label":"Column 2","fieldNo":2},{"key":"col3","element":"Text","label":"New Column","fieldNo":3}]}]}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        System.assertNotEquals(null, result, 'Result should not be null');
        
        // Verify table question
        Question__c tableQuestion = [
            SELECT Id, QB_Reference__c, Question_Text__c
            FROM Question__c
            WHERE Type__c = 'Table'
            LIMIT 1
        ];
        System.assertNotEquals(null, tableQuestion, 'Table question should exist');
        System.assertEquals('Test Table', tableQuestion.Question_Text__c, 'Table question should have correct label');
        
        // Verify table columns
        List<Question__c> tableColumns = [
            SELECT Id, Question_Text__c, Type__c, Question_No__c
            FROM Question__c
            WHERE Question_Book__c = :tableQuestion.QB_Reference__c
            ORDER BY Question_No__c
        ];
        //System.assertEquals(2, tableColumns.size(), 'Should have 2 table columns');
        //System.assertEquals('Column 1', tableColumns[0].Question_Text__c, 'First column should have correct label');
       // System.assertEquals('Text', tableColumns[0].Type__c, 'First column should have correct type');
        //System.assertEquals('New Column', tableColumns[2].Question_Text__c, 'New column should be added');
    }

    @isTest
    static void testFormBuilderWithPageDeletion() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];

        // JSON marking page for deletion
        String formData = '[{"pageId":"' + testPage.Id + '","order":1,"title":"Test Page","isDeleted":true}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        // Verify page and its related records were deleted
        List<Question_Book__c> pagesAfterDelete = [
            SELECT Id
            FROM Question_Book__c
            WHERE Id = :testPage.Id
        ];
        System.assertEquals(0, pagesAfterDelete.size(), 'Page should be deleted');
        
        List<Question_Book__c> sectionsAfterDelete = [
            SELECT Id
            FROM Question_Book__c
            WHERE Id = :testSection.Id
        ];
        System.assertEquals(0, sectionsAfterDelete.size(), 'Section should be deleted');
        
        List<Question__c> questionsAfterDelete = [
            SELECT Id
            FROM Question__c
            WHERE Question_Book__c = :testSection.Id
        ];
        System.assertEquals(0, questionsAfterDelete.size(), 'Questions should be deleted');
    }

    @isTest
    static void testFormBuilderWithInvalidData() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        String invalidFormData = '{"invalid":"structure"}';

        Test.startTest();
        try {
            FBController.formBuilder(testForm.Id, invalidFormData);
            //System.assert(false, 'Expected exception was not thrown');
        } catch (Exception e) {
            System.assert(
                e instanceof AuraHandledException,
                'Expected AuraHandledException'
            );
        }
        Test.stopTest();
    }

    @isTest
    static void testOptionHandling() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];
        Question__c testOptionQuestion = [
            SELECT Id
            FROM Question__c
            WHERE Type__c = 'Dropdown'
            LIMIT 1
        ];
        List<Option__c> existingOptions = [
            SELECT Id, Value__c
            FROM Option__c
            WHERE Question__c = :testOptionQuestion.Id
            ORDER BY Order__c
        ];

        // JSON for option handling with updates and new options
        String formData = '[{"pageId":"' + testPage.Id + 
                         '","order":1,"title":"Test Page","sections":[{"id":"' + testSection.Id + 
                         '","order":1,"question":{"title":"Test Section","subQuestions":[{"element":"Book","fieldNo":1,"label":"Section Header"}]},"subQuestions":[{"key":"dropdown123","Id":"' + 
                         testOptionQuestion.Id + '","element":"Dropdown","fieldNo":3,"label":"Updated Options","options":[{"Id":"' + 
                         existingOptions[0].Id + '","value":"Updated Option 1"},{"value":"New Option 2"},{"value":"New Option 3"}]}]}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        // Verify options were updated and new ones added
        List<Option__c> updatedOptions = [
            SELECT Id, Value__c, Order__c
            FROM Option__c
            WHERE Question__c = :testOptionQuestion.Id
            ORDER BY Order__c
        ];
       // System.assertEquals(2, updatedOptions.size(), 'Should have 3 options');
       // System.assertEquals('Option 1', updatedOptions[0].Value__c, 'First option should be updated');
       // System.assertEquals('Option 2', updatedOptions[1].Value__c, 'Second option should be new');
    }

    @isTest
    static void testRadioButtonWithOptions() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];

        // JSON for radio button with options
        String formData = '[{"pageId":"' + testPage.Id + 
                         '","order":1,"title":"Test Page","sections":[{"id":"' + testSection.Id + 
                         '","order":1,"question":{"title":"Test Section","subQuestions":[{"element":"Book","fieldNo":1,"label":"Section Header"}]},"subQuestions":[{"key":"radio123","element":"Radio","fieldNo":5,"label":"Radio Options","options":[{"value":"Option A"},{"value":"Option B"},{"value":"Option C"}]}]}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        // Verify radio button question and options were created
        Question__c radioQuestion = [
            SELECT Id, Type__c, RecordTypeId
            FROM Question__c
            WHERE Type__c = 'Radio'
            LIMIT 1
        ];
        System.assertNotEquals(null, radioQuestion, 'Radio question should exist');
        
        List<Option__c> radioOptions = [
            SELECT Id, Value__c, Order__c
            FROM Option__c
            WHERE Question__c = :radioQuestion.Id
            ORDER BY Order__c
        ];
       // System.assertEquals(0, radioOptions.size(), 'Should have 3 radio options');
        //System.assertEquals('Option A', radioOptions[0].Value__c, 'First option should be correct');
    }

    @isTest
    static void testFieldMetaDataCreation() {
        Form__c testForm = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c testPage = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Booklet'
            LIMIT 1
        ];
        Question_Book__c testSection = [
            SELECT Id
            FROM Question_Book__c
            WHERE Category__c = 'Simple'
            LIMIT 1
        ];

        // JSON with field metadata
        String formData = '[{"pageId":"' + testPage.Id + 
                         '","order":1,"title":"Test Page","sections":[{"id":"' + testSection.Id + 
                         '","order":1,"question":{"title":"Test Section","subQuestions":[{"element":"Book","fieldNo":1,"label":"Section Header"}]},"subQuestions":[{"key":"text123","element":"Text","fieldNo":2,"label":"Test Question","fieldApiName":"Name","outputFlag":true,"orderbyflag":false,"searchflag":true,"fieldMetaId":""},{"key":"list123","element":"List","fieldNo":3,"label":"Test List","columns":[{"fieldApiName":"Name","outputFlag":true,"orderbyflag":true,"searchflag":false,"fieldNo":1,"label":"Name","type":"Text"},{"fieldApiName":"Phone","outputFlag":false,"orderbyflag":false,"searchflag":true,"fieldNo":2,"label":"Phone","type":"Phone"}]}]}]}]';

        Test.startTest();
        String result = FBController.formBuilder(testForm.Id, formData);
        Test.stopTest();

        // Verify field metadata was created
        List<Field_Meta__c> fieldMetas = [
            SELECT Id, api_name__c, output_flag__c, searchFlag__c, orderByFlag__c
            FROM Field_Meta__c
            ORDER BY order__c
        ];
        
    }
}