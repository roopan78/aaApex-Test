@isTest
public class OptionWrapperTest {
    
    @isTest
    static void testConstructor() {
        Question_Book__c qb = new Question_Book__c(
        	Title__c = 'hello',
            Category__c = 'Simple'
        );
        insert qb;
        // Create test Question
        Question__c question = new Question__c(
            Title__c = 'New Question', 
            Question_Book__c = qb.Id,
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId()
        );
        insert question;
        
        // Create Option with all fields
        Option__c option = new Option__c(
            Value__c = 'test_value',
            order__c = 5,
            Unique_Identifier__c = 'unique_123',
            Question__c = question.Id,
            Next_Question__c = question.Id,
            Is_Default__c = true
        );
        insert option;
        
        // Test constructor
        OptionWrapper wrapper = new OptionWrapper(option);
        
        // Basic assertions
        System.assertNotEquals(null, wrapper.id);
        System.assertEquals(option.Name, wrapper.name);
        System.assertEquals('test_value', wrapper.value);
    }
    
   @isTest
    static void testConstructorWithNullIsDefault() {
        // Create test Question
        Question_Book__c qb = new Question_Book__c(
        	Title__c = 'hello',
            Category__c = 'Simple'
        );
        insert qb;
        Question__c question = new Question__c(
            Title__c = 'New Question3', 
            Question_Book__c = qb.Id,
            Question_No__c = 2,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId()
        );
        insert question;
        
        // Create Option with null Is_Default__c
        Option__c option = new Option__c(
            Question__c = question.Id,
            Is_Default__c = false,
            Value__c = 'test_value',
            order__c = 5
        );
        insert option;
        
        // Test constructor with null default
        OptionWrapper wrapper = new OptionWrapper(option);
        
        // Assert null is handled
        System.assertEquals(false, wrapper.isDefault);
    }
    
    @isTest
    static void testLoadOptionWrapperWithId() {
        // Create test Question and Option
        // 
        Question_Book__c qb = new Question_Book__c(
        	Title__c = 'hello',
            Category__c = 'Simple'
        );
        insert qb;

        Question__c question = new Question__c(
            Title__c = 'new', 
            Question_Book__c = qb.Id,
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId()
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.Id,
            Value__c = 'test_value',
            order__c = 5
        );
        insert option;
        
        // Create wrapper from existing option, then modify
        OptionWrapper wrapper = new OptionWrapper(option);
        wrapper.value = 'test_value';
        wrapper.isDefault = true;
        
        // Test loadOptionWrapper with existing Id
        Option__c result = OptionWrapper.loadOptionWrapper(wrapper, question.Id);
        
        // Assert Id is set
        System.assertEquals(option.Id, result.Id);
        System.assertEquals('test_value', result.Value__c);
    }
    
    @isTest
    static void testLoadOptionWrapperWithoutId() {
        // Create test Question and Option
        // 
        Question_Book__c qb = new Question_Book__c(
        	Title__c = 'hello',
            Category__c = 'Simple'
        );
        insert qb;

        Question__c question = new Question__c(
            Title__c = 'New Question4',
            Question_Book__c = qb.Id,
            Question_No__c = 1,
            RecordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId()
        );
        insert question;
        
        Option__c option = new Option__c(
            Question__c = question.Id,
			Value__c = 'test_value',
            order__c = 5);
        insert option;
        
        // Create wrapper from existing option, then clear Id to simulate new record
        OptionWrapper wrapper = new OptionWrapper(option);
        wrapper.id = null;
        wrapper.value = 'new_value';
        wrapper.isDefault = false;
        
        // Test loadOptionWrapper without Id
        Option__c result = OptionWrapper.loadOptionWrapper(wrapper, question.Id);
        
        // Assert Question is set for new record
        System.assertEquals(question.Id, result.Question__c);
        System.assertEquals('new_value', result.Value__c);
    } 
}