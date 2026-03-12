@isTest
private class FormVersionControllerTest {
    
    @testSetup
    static void setup() {
        // Create Form
        Form__c form = new Form__c(Name = 'Test Form');
        insert form;
        
        // Create Main Question Book
        Question_Book__c qb = new Question_Book__c(
            Title__c = 'Original Book',
            Form__c = form.Id,
            Version__c = 1,
            Version_Status__c = 'Active',
            Style__c = 'test-style',
            Query__c = 'SELECT Id FROM Account',
            Anchor_Object__c = 'Account'
        );
        insert qb;
        
        // Create Referenced Question Book (for Book/Table type questions)
        Question_Book__c refQb = new Question_Book__c(
            Title__c = 'Reference Book',
            Version__c = 1,
            Version_Status__c = 'Inactive'
        );
        insert refQb;
        
        // Update Form with QB
        form.Question_Book__c = qb.Id;
        update form;
        
        // Create Questions in main book
        List<Question__c> questions = new List<Question__c>();
        
        // Regular text question
        Question__c q1 = new Question__c(
            Question_Book__c = qb.Id,
            Question_No__c = 1,
            Title__c = 'Question 1',
            Type__c = 'Text',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            Is_Optional__c = false,
            Question_Text__c = 'Test Question',
            Reference_Field__c = 'Name',
            Date_Format__c = 'DD/MM/YYYY',
            Is_Dependent__c = true
        );
        questions.add(q1);
        
        // Book type question with QB reference
        Question__c q2 = new Question__c(
            Question_Book__c = qb.Id,
            Question_No__c = 2,
            Title__c = 'Question 2',
            Type__c = 'Book',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            QB_Reference__c = refQb.Id
        );
        questions.add(q2);
        
        // Table type question with QB reference
        Question__c q3 = new Question__c(
            Question_Book__c = qb.Id,
            Question_No__c = 3,
            Title__c = 'Question 3',
            Type__c = 'Table',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
            QB_Reference__c = refQb.Id,
            QB_Reference_Questions__c = 'Q1'
        );
        questions.add(q3);
        
        insert questions;
        
        // Create questions in reference book
        Question__c refQ1 = new Question__c(
            Question_Book__c = refQb.Id,
            Question_No__c = 1,
            Title__c = 'Ref Question 1',
            Type__c = 'Text',
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId()
        );
        insert refQ1;
        
        // Create Field Meta (both with and without Question_Reference__c)
        List<Field_Meta__c> fieldMetas = new List<Field_Meta__c>();
        
        // Field meta without reference
        Field_Meta__c fm1 = new Field_Meta__c(
            Question__c = q1.Id,
            api_name__c = 'Name',
            label__c = 'Account Name',
            fld_type__c = 'Text',
            order__c = 1,
            db_name__c = 'Name',
            File_Size__c = 100,
            File_Type__c = '.pdf',
            filterCondition__c = 'Name != null',
            filterFlag__c = true,
            filterLogic__c = 'AND',
            filterValue__c = 'test',
            Is_Serial_No__c = true,
            isChild__c = false,
            isGrandChild__c = false,
            orderByFlag__c = true,
            output_flag__c = true,
            resultantFlag__c = false,
            searchFlag__c = true,
            Table_Data_Style__c = 'data-style',
            Table_Head_Style__c = 'head-style',
            width_style__c = '100px',
            childFilter__c = 'Id != null',
            childObjFldName__c = 'ParentId',
            childObjName__c = 'Contact',
            grandChildFilter__c = 'Id != null',
            grandChildObjFldName__c = 'AccountId',
            grandChildObjName__c = 'Opportunity',
            grandChildParentField__c = 'ContactId'
        );
        fieldMetas.add(fm1);
        
        // Field meta with reference
        Field_Meta__c fm2 = new Field_Meta__c(
            Question__c = q2.Id,
            Question_Reference__c = q1.Id,
            api_name__c = 'Email',
            label__c = 'Email',
            fld_type__c = 'Text',
            order__c = 2
        );
        fieldMetas.add(fm2);
        insert fieldMetas;
        
        // Create Options
        List<Option__c> options = new List<Option__c>();
        Option__c opt1 = new Option__c(
            Question__c = q1.Id,
            Value__c = 'Option 1',
            Order__c = 1,
            Is_Default__c = true
        );
        options.add(opt1);
        
        Option__c opt2 = new Option__c(
            Question__c = q2.Id,
            Value__c = 'Option 2',
            Order__c = 2
        );
        options.add(opt2);
        
        Option__c opt3 = new Option__c(
            Question__c = refQ1.Id,
            Value__c = 'Option 3',
            Order__c = 1
        );
        options.add(opt3);
        
        insert options;
        
        // Create Question Styles
        List<Style__c> styles = new List<Style__c>();
        Style__c qStyle = new Style__c(
            Question__c = q1.Id,
            Label_Class__c = 'label-class',
            Label_Style__c = 'color: blue',
            Input_Class__c = 'input-class',
            Input_Style__c = 'border: 1px solid',
            Input_Align__c = 'left',
            showLabel__c = true,
            classHeadFoot__c = 'header-footer',
            headerSpaceStyle__c = 'margin-top: 10px',
            footerSpaceStyle__c = 'margin-bottom: 10px',
            isHead__c = true,
            isFoot__c = false,
            bookStyle__c = 'book-style',
            Label_Color__c = '#000000',
            label_font_size__c = 6,
            Field_Border_Color__c = '#cccccc',
            Field_Input_Color__c = '#333333',
            Field_Input_Size__c = 3,
            Heading_Font_Color__c = '#000000',
            Heading_Size__c = 10,
            labelValueStyle__c = 'font-weight: bold',
            ElementStyle__c = 'display: block',
            CheckboxStyle__c = 'margin: 5px',
            headingStyle__c = 'text-align: center',
            external_id__c = 'EXT001',
            Size__c = 12,
            Style_Class__c = 'custom-class',
            Button_Style_Class__c = 'btn-primary',
            width__c = '100%',
            height__c = '50px'
        );
        styles.add(qStyle);
        
        // Create Book Styles
        Style__c bookStyle = new Style__c(
            Question_Book__c = qb.Id,
            bookStyle__c = 'main-book-style',
            Input_Class__c = 'book-input',
            Label_Class__c = 'book-label'
        );
        styles.add(bookStyle);
        
        Style__c refBookStyle = new Style__c(
            Question_Book__c = refQb.Id,
            bookStyle__c = 'ref-book-style'
        );
        styles.add(refBookStyle);
        
        insert styles;
        
        // Create Actions
        List<Actions__c> actions = new List<Actions__c>();
        Actions__c action1 = new Actions__c(
            Question_Book__c = qb.Id,
            Order__c = 1,
            Style__c = 'action-style',
            IsActive__c = true,
            Event_to_Emit__c = 'save'
        );
        actions.add(action1);
        
        Actions__c action2 = new Actions__c(
            Question_Book__c = refQb.Id,
            Order__c = 1,
            IsActive__c = true
        );
        actions.add(action2);
        
        insert actions;
        
        // Create Action Styles
        List<Style__c> actionStyles = new List<Style__c>();
        Style__c actionStyle1 = new Style__c(
            Action__c = action1.Id,
            Button_Style_Class__c = 'btn-primary',
            Style_Class__c = 'action-class'
        );
        actionStyles.add(actionStyle1);
        
        Style__c actionStyle2 = new Style__c(
            Action__c = action2.Id,
            Button_Style_Class__c = 'btn-secondary'
        );
        actionStyles.add(actionStyle2);
        
        insert actionStyles;
        
        // Create Inputs
        List<Input__c> inputs = new List<Input__c>();
        Input__c input1 = new Input__c(
            Question_Book__c = qb.Id,
            API_Name__c = 'Name',
            Type__c = 'String',
            Value_Field__c = 'Name',
            Unique_Identifier__c = 'UI-001',
            Question__c = q1.Id,
            Source_Question_Id__c = 'SRC-001',
            Hidden__c = false,
            Logics__c = 'logic1'
        );
        inputs.add(input1);
        
        Input__c input2 = new Input__c(
            Question_Book__c = refQb.Id,
            API_Name__c = 'Status',
            Type__c = 'String',
            Value_Field__c = 'Status__c',
            Unique_Identifier__c = 'UI-002'
        );
        inputs.add(input2);
        
        insert inputs;
    }
    
    @isTest
    static void testSaveAsVersion_Success() {
        Form__c form = [SELECT Id FROM Form__c LIMIT 1];
        Question_Book__c qb = [SELECT Id FROM Question_Book__c WHERE Form__c = :form.Id LIMIT 1];
        
        Test.startTest();
        String result = FormVersionController.saveAsVersion(form.Id, qb.Id, 'Version 2.0');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assert(result.contains('success'));
        
        // Verify new book was created
        List<Question_Book__c> books = [SELECT Id, Version__c, Version_Status__c FROM Question_Book__c WHERE Form__c = :form.Id];
        System.assertEquals(2, books.size());
    }
    
    @isTest
    static void testSaveAsVersion_Exception() {
        Test.startTest();
        String result = FormVersionController.saveAsVersion(null, null, 'Version Error');
        Test.stopTest();
        
        System.assert(result.contains('error'));
    }
    
    @isTest
    static void testActivateDeactivateForm_Activate() {
        Question_Book__c qb = [SELECT Id, Form__c FROM Question_Book__c WHERE Form__c != null LIMIT 1];
        
        // Create inactive version
        Question_Book__c inactiveQb = new Question_Book__c(
            Title__c = 'Inactive Book',
            Form__c = qb.Form__c,
            Version__c = 2,
            Version_Status__c = 'Inactive'
        );
        insert inactiveQb;
        
        Test.startTest();
        String result = FormVersionController.activateDeactivateForm(inactiveQb.Id, 'Activate');
        Test.stopTest();
        
        System.assert(result.contains('success'));
        
        // Verify status changed
        Question_Book__c updatedQb = [SELECT Version_Status__c FROM Question_Book__c WHERE Id = :inactiveQb.Id];
        System.assertEquals('Active', updatedQb.Version_Status__c);
    }
    
    @isTest
    static void testActivateDeactivateForm_Deactivate() {
        Question_Book__c qb = [SELECT Id FROM Question_Book__c WHERE Form__c != null LIMIT 1];
        
        Test.startTest();
        String result = FormVersionController.activateDeactivateForm(qb.Id, 'Deactivate');
        Test.stopTest();
        
        System.assert(result.contains('success'));
    }
    
    @isTest
    static void testActivateDeactivateForm_AlreadyActive() {
        Question_Book__c qb = [SELECT Id FROM Question_Book__c WHERE Form__c != null LIMIT 1];
        qb.Version_Status__c = 'Active';
        update qb;
        
        Test.startTest();
        String result = FormVersionController.activateDeactivateForm(qb.Id, 'Activate');
        Test.stopTest();
        
        System.assert(result.contains('error'));
    }
    
    @isTest
    static void testActivateDeactivateForm_NullBookId() {
        Test.startTest();
        String result = FormVersionController.activateDeactivateForm(null, 'Activate');
        Test.stopTest();
        
        System.assert(result.contains('error'));
    }
    
    @isTest
    static void testGetQuestionBooksByForm() {
        Form__c form = [SELECT Id FROM Form__c LIMIT 1];
        
        // Create additional books
        List<Question_Book__c> books = new List<Question_Book__c>();
        books.add(new Question_Book__c(
            Title__c = 'Book 2',
            Form__c = form.Id,
            Version__c = 2,
            Version_Status__c = 'Inactive'
        ));
        books.add(new Question_Book__c(
            Title__c = 'Book 3',
            Form__c = form.Id,
            Version__c = 3,
            Version_Status__c = 'Inactive'
        ));
        insert books;
        
        Test.startTest();
        List<QuestionBookWrapper> result = FormVersionController.getQuestionBooksByForm(form.Id);
        Test.stopTest();
        
        System.assertEquals(3, result.size());
    }
    
    @isTest
    static void testGetQuestionBooksByForm_NoBooks() {
        Form__c newForm = new Form__c(Name = 'Empty Form');
        insert newForm;
        
        Test.startTest();
        List<QuestionBookWrapper> result = FormVersionController.getQuestionBooksByForm(newForm.Id);
        Test.stopTest();
        
        System.assertEquals(0, result.size());
    }
}