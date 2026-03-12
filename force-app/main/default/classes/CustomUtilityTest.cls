@isTest
private class CustomUtilityTest {

    @isTest
    static void testStringInjectWithListAndMap() {
        String result1 = CustomUtility.stringInject('Hi {0}!', new List<Object>{'World'});
        System.assertEquals('Hi World!', result1);

        Map<String, Object> mapData = new Map<String, Object>{'greet' => 'Hello', 'name' => 'Alice'};
        String result2 = CustomUtility.stringInject('{greet}, {name}!', mapData);
        System.assertEquals('Hello, Alice!', result2);

        // Invalid type fallback
        String fallback = CustomUtility.stringInject('No change', 'invalid');
        System.assertEquals('No change', fallback);
    }

    @isTest
    static void testIsValidJSON() {
        System.assert(CustomUtility.isValidJSON('{"key":"value"}'));
        System.assert(!CustomUtility.isValidJSON('{key:value}'));
    }

    @isTest
    static void testSkipQuestionVariants() {
        // EQ true
        Map<String, Object> dMeta = new Map<String, Object>{
            'logics' => new List<Object>{
                new Map<String, Object>{ 'order' => 1, 'operation' => 'EQ', 'value' => 'yes' }
            },
            'valueField' => 'field1'
        };
        Map<String, Object> answer = new Map<String, Object>{
            'typ' => 'Text',
            'ansValue' => 'yes'
        };
        System.assertEquals(true, CustomUtility.skipQuestion(dMeta, answer));

        // GT
        dMeta.put('logics', new List<Object>{
            new Map<String, Object>{ 'order' => 1, 'operation' => 'GT', 'value' => 10 }
        });
        answer.put('ansValue', 20);
        System.assert(CustomUtility.skipQuestion(dMeta, answer));

        // LT
        dMeta.put('logics', new List<Object>{
            new Map<String, Object>{ 'order' => 1, 'operation' => 'LT', 'value' => 100 }
        });
        answer.put('ansValue', 50);
        System.assert(CustomUtility.skipQuestion(dMeta, answer));

        // NE
        dMeta.put('logics', new List<Object>{
            new Map<String, Object>{ 'order' => 1, 'operation' => 'NE', 'value' => 'no' }
        });
        answer.put('ansValue', 'yes');
        System.assert(CustomUtility.skipQuestion(dMeta, answer));

        // List type logic
        answer.put('typ', 'List');
        answer.put('ansValue', new Map<String, Object>{
            'arrItems' => new List<Object>{
                new Map<String, Object>{
                    'value' => new Map<String, Object>{
                        'addlFldMap' => new Map<String, Object>{ 'field1' => 'match' }
                    }
                }
            }
        });
        dMeta.put('logics', new List<Object>{
            new Map<String, Object>{ 'order' => 1, 'operation' => 'EQ', 'value' => 'match' }
        });
        System.assert(CustomUtility.skipQuestion(dMeta, answer));
    }

    @isTest
    static void testNxtProcessQuestionsWithBookAndList() {
        Map<String, Object> subQ = new Map<String, Object>{
            'id' => 'sub1',
            'type' => 'List',
            'fieldsMeta' => JSON.serialize(new List<Map<String, Object>>{
                new Map<String, Object>{
                    'apiName' => 'Age',
                    'outputFlag' => true,
                    'resultantflag' => false,
                    'searchflag' => true,
                    'readOnly' => false,
                    'ischild' => false
                }
            })
        };

        Map<String, Object> qbData = new Map<String, Object>{
            'questionbook' => new Map<String, Object>{ 'subQuestions' => new List<Object>{subQ} },
            'sqOptions' => new Map<String, Object>{}
        };

        Map<String, Object> q = new Map<String, Object>{
            'id' => 'book1',
            'type' => 'Book',
            'qbReference' => 'someId',
            'qbReferenceQuestions' => JSON.serialize(qbData),
            'fieldsMeta' => JSON.serialize(new List<Map<String, Object>>{
                new Map<String, Object>{ 'apiName' => 'dummy', 'readOnly' => false, 'outputFlag' => true, 'resultantflag' => false, 'searchflag' => false, 'ischild' => false }
            })
        };

        List<Map<String, Object>> qbQueryResults = new List<Map<String, Object>>{
            new Map<String, Object>{ 'Age' => 30 }
        };

        List<Map<String, Object>> result = CustomUtility.nxtProcessQuestions(
            new List<Map<String, Object>>{ q },
            new Map<String, Object>{},
            qbQueryResults,
            new List<Map<String, Object>>{
                new Map<String, Object>{ 'readOnly' => false }
            }
        );

        System.assertEquals(1, result.size());
    }

    @isTest
    static void testReadFieldValueChildAndParent() {
        Map<String, Object> queryResult = new Map<String, Object>{
            'ParentField' => 'ParentValue',
            'ChildObject__r' => new Map<String, Object>{ 'ChildField__c' => 'ChildValue' }
        };

        // Non-child
        Map<String, Object> field1 = new Map<String, Object>{
            'apiName' => 'ParentField',
            'ischild' => false
        };
        System.assertEquals('ParentValue', CustomUtility.readFieldValue(field1, queryResult));

        // Child
        Map<String, Object> field2 = new Map<String, Object>{
            'ischild' => true,
            'childobjname' => 'ChildObject__r',
            'childobjfldname' => 'ChildField__c'
        };
        System.assertEquals('ChildValue', CustomUtility.readFieldValue(field2, queryResult));
    }
}