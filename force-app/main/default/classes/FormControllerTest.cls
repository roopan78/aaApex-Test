@IsTest
private class FormControllerTest {
    @isTest // ✅ Changed @IsTest to @isTest
    static void getPicklistValues() {
        // ✅ Correct case
        List<PLEWrapper> picklistValues = FormController.getPicklistValues();
       // System.debug('picklistValues-->'+ picklistValues);
        System.assertNotEquals(
            null,
            picklistValues,
            'Picklist values should not be null'
        );
        System.assert(
            !picklistValues.isEmpty(),
            'Picklist values should not be empty'
        );
        System.assertEquals(
            3,
            picklistValues.size(),
            'Should return exactly 3 picklist values'
        );
       // System.assert(picklistValues[0].contains('Form'),'Should contain "Form" value');
    }
    
    @isTest
    static void createFormWithQuestionBook_WithSubmitAndCancel() {
        Account parentAccount = new Account(Name = 'Test Account');
    	insert parentAccount;
        
         Form__c testForm = new Form__c(
            Name = 'Test Form',
            Type__c = 'Form',
            Anchor_Object__c = 'Account'
        );
        insert testForm;
        
        FormController.CreateRecordResult result = FormController.createFormWithQuestionBook(
            'Test Form',
            'Form',
            true,
            true,
            'Account'
        );
        FormController.getForms();
        FormController.getObjectsByName('');
        FormController.getFieldsForObject('Account');
        
        // Verify Form was created
        System.assertNotEquals(null, result.form, 'Form should not be null');
        System.assertEquals(
            'Test Form',
            result.form.Name,
            'Form name should match'
        );
        System.assertEquals('Form', result.form.Type__c, 'Form type should match');
        
        // Verify related records were created
        List<Question_Book__c> questionBooks = [
            SELECT Id, Title__c, Category__c, Parent_Booklet_QB__c
            FROM Question_Book__c
            WHERE Form__c = :result.form.Id OR Parent_Booklet_QB__c != NULL
        ];
        System.assertEquals(
            2,
            questionBooks.size(),
            'Should create 2 question books'
        );
        
        // Verify actions were created
        List<Actions__c> actions = [
            SELECT Id, Name, Event_to_Emit__c
            FROM Actions__c
            WHERE Form__c = :result.form.Id
        ];
        System.assertEquals(2, actions.size(), 'Should create 2 actions');
    }
    
    @isTest
    static void createFormWithQuestionBook_ErrorHandling() {
        try {
            FormController.CreateRecordResult result = FormController.createFormWithQuestionBook(
                null, // This should cause an error
                null,
                false,
                false,
                null
            );
            
            System.assert(false, 'Expected an exception to be thrown');
        } catch (Exception e) {
            System.assert(
                e instanceof AuraHandledException,
                'Expected AuraHandledException'
            );
        }
    }
}