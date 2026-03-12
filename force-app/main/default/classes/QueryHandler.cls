public with sharing class QueryHandler {
    /**
     * @author Roopan
     * @param qbId Id of the Question Book
     * @param objectName Name of the object
     * @CreatedOn 15-October-2025
     * Build and update Query__c for the given Question Book Ids.
     * Uses aggregate SOQL to get distinct Api_Name__c values (per book).
     * @description Handles construction and updating of dynamic SOQL queries for Question Book records.
     */
    @AuraEnabled
    public static String constructQuery(String qbId, String objectName) {
        if(!Schema.SObjectType.Question__c.isAccessible() || !Schema.SObjectType.Field_Meta__c.isAccessible() 
            || !Schema.SObjectType.Question_Book__c.isAccessible() || !Schema.SObjectType.Question_Book__c.isUpdateable()) {
                throw new AuraHandledException('Insufficient access to Question__c, Field_Meta__c, Question_Book__c');
            }

        Set<Id> allBookIds = new Set<Id>{qbId};
        Set<String> allApiNames = new Set<String>{'Id','Name'};
        
        // Start recursive traversal
        traverseQuestionBooks(new Set<Id>{qbId}, allBookIds);
        System.debug('bookids' + allBookIds);

        // RT 16OCT25 - Ignored Table Question
        List<AggregateResult> agg = [SELECT Api_Name__c api 
                                    FROM Field_Meta__c 
                                    WHERE Question__r.Question_Book__c IN: allBookIds AND Question__r.Type__c != 'Table'
                                    GROUP BY Question__r.Question_Book__c, Api_Name__c
                                    ];

        // RT 24DEC25 - Handle Location questions 
        List<Question__c> locationQuestions = [SELECT Location_DateTime_Reference__c,
                                                Longitude_Reference__c,
                                                Latitude_Reference__c
                                            FROM Question__c
                                            WHERE Question_Book__c IN :allBookIds
                                            AND Type__c = 'Location'
        ];

        for (Question__c q : locationQuestions) {
            if (String.isNotBlank(q.Location_DateTime_Reference__c)) {
                allApiNames.add(q.Location_DateTime_Reference__c);
            }
            if (String.isNotBlank(q.Longitude_Reference__c)) {
                allApiNames.add(q.Longitude_Reference__c);
            }
            if (String.isNotBlank(q.Latitude_Reference__c)) {
                allApiNames.add(q.Latitude_Reference__c);
            }
        }

        for (AggregateResult ar : agg) {
            String apiName = (String) ar.get('api');
            allApiNames.add(apiName);
        }

        processQuery(qbId, objectName, allApiNames);

        Integer fieldCount = allApiNames.size();
        String output = '';
        if(fieldCount > 0) {
            output = 'Query updated. ' + fieldCount + ' fields added.';
        }
        return output;
    }

    /**
     * Recursively traverse question books to find all referenced books
     * @param toProcess - Set of Question Book IDs to process in this iteration
     * @param allBookIds - Accumulator set containing all discovered book IDs
    */
    private static void traverseQuestionBooks(Set<Id> toProcess, Set<Id> allBookIds) {
        // Base case: no more books to process
        if (toProcess.isEmpty()) {
            return;
        }

        // Fetch all Questions with QB_Reference__c from current books
        List<Question__c> nextQuestions = [
            SELECT Id, Question_Book__c, QB_Reference__c, Type__c
            FROM Question__c
            WHERE Question_Book__c IN: toProcess
            AND QB_Reference__c != null
            AND Type__c = 'Book'
        ];

        Set<Id> nextLevel = new Set<Id>();
        for (Question__c q : nextQuestions) {
            if (q.QB_Reference__c != null && !allBookIds.contains(q.QB_Reference__c)) {
                nextLevel.add(q.QB_Reference__c);
            }
        }

        // Add discovered refs to overall set
        allBookIds.addAll(nextLevel);
        
        System.debug('toProcess: ' + nextLevel);
        
        // Recursive call with next level of books
        traverseQuestionBooks(nextLevel, allBookIds);
    }

    private static void processQuery(String qbId, String objectName, Set<String> allApiNames) {

        if(!Schema.SObjectType.Question_Book__c.isAccessible() || !Schema.SObjectType.Question_Book__c.isUpdateable()) {
            throw new AuraHandledException('Insufficient access to Question_Book__c');
        }

        // RT 16OCT25 - Remove empty or blank API names
        List<String> filteredApiNames = new List<String>();
        for (String apiName : allApiNames) {
            if (String.isNotBlank(apiName)) {
            filteredApiNames.add(apiName);
            }
        }
        String query = 'SELECT ' + String.join(filteredApiNames, ',') + ' FROM ' + objectName + ' WHERE Id = {c__record_id}';

        Question_Book__c qb = new Question_Book__c(Id = qbId, Query__c = query);
        update qb;
    }
}