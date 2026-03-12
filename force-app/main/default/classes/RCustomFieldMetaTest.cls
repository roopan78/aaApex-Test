@isTest
private class RCustomFieldMetaTest {

    @isTest
    static void testLoadFieldMetaWrapper() {
        // Create test RCustomFieldMeta
        RCustomFieldMeta fm = new RCustomFieldMeta();
        fm.id = 'a05fJ000005XNivQAG';
        fm.apiName = 'Test_API_Name__c';
        fm.fldType = 'Text';
        fm.searchFlag = true;
        fm.orderByFlag = false;
        fm.filterFlag = true;
        fm.filterLogic = 'AND';
        fm.filterCondition = 'Equals';
        fm.filterValue = 'TestValue';
        fm.outputFlag = true;
        fm.label = 'Test Label';
        fm.widthStyle = '100px';
        fm.tableDataStyle = 'data-style';
        fm.tableHeadStyle = 'head-style';
        fm.order = 1;
        fm.resultantFlag = false;
        fm.isChild = true;
        fm.childObjName = 'ChildObj__c';
        fm.childObjFldName = 'ChildFld__c';
        fm.childFilter = 'Active = true';
        fm.isGrandChild = true;
        fm.grandChildObjName = 'GrandChildObj__c';
        fm.grandChildObjFldName = 'GrandChildFld__c';
        fm.grandChildFilter = 'Status = Active';
        fm.grandChildParentField = 'ParentField__c';

        // Call method
        Field_Meta__c fieldMeta = RCustomFieldMeta.loadFieldMetaWrapper(fm);

        // Minimal assertions
        System.assertNotEquals(null, fieldMeta);
        System.assertEquals(fm.apiName, fieldMeta.API_Name__c);
        System.assertEquals(fm.label, fieldMeta.Label__c);
    }

    @isTest
    static void testLoadFieldMetaWrapperWithEmptyId() {
        // Test scenario where Id is empty
        RCustomFieldMeta fm = new RCustomFieldMeta();
        fm.apiName = 'NoId_API__c';
        fm.fldType = 'Number';
        fm.searchFlag = false;
        fm.orderByFlag = true;

        Field_Meta__c fieldMeta = RCustomFieldMeta.loadFieldMetaWrapper(fm);

        // Minimal check
        System.assertEquals('NoId_API__c', fieldMeta.API_Name__c);
    }
}