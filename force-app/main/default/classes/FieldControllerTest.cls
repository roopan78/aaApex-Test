/*
 * Test class for FieldController.
 */
@isTest
public class FieldControllerTest {

    @isTest
    static void testGetRequiredFields() {
        // Arrange
        String testObjectName = 'Account';

        // Create a mock field using a test custom object or field if available.
        Test.startTest();
        List<Map<String, Object>> requiredFields = FieldController.getRequiredFields(testObjectName);
        Test.stopTest();

        // Assert
        System.assertNotEquals(0, requiredFields.size(), 'Expected required fields to be retrieved.');

        for (Map<String, Object> field : requiredFields) {
            //System.assertNotNull(field.get('label'), 'Expected the field label to be present.');
            //System.assertNotNull(field.get('name'), 'Expected the field name to be present.');
        }

        // Ensure that non-creatable or defaulted fields are not included
        for (Map<String, Object> field : requiredFields) {
            String fieldName = (String) field.get('name');
            Schema.DescribeFieldResult describeFieldResult = Schema.SObjectType.Account.fields.getMap().get(fieldName).getDescribe();
            System.assert(describeFieldResult.isCreateable(), 'Expected only createable fields.');
            System.assert(!describeFieldResult.isNillable(), 'Expected only required (non-nillable) fields.');
            System.assert(!describeFieldResult.defaultedOnCreate, 'Expected fields not defaulted on create.');
        }
    }
}