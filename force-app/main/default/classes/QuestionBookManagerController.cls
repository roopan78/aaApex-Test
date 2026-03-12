/**
 * @description : Process JSON data to extract reference fields and create records in Salesforce.
 * @date        : 2025-03-24
 * @author      : Gomathy V, Roopan Thangam A
 * @param      : jsonString - JSON data to process
 * @version     : 2.0
 */
public with sharing class QuestionBookManagerController {
    private static Id recTypeId {
        get {
            if (recTypeId == null) {
                recTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId();
            }
            return recTypeId;
        }
        set;
    }
    public static Map<String, Id> questionReferenceId = new Map<String, Id>();
    public static Map<Id, String> fieldReferences = new Map<Id, String>();
    public static Set<Id> processedQuestions = new Set<Id>();
    public static Map<String, String> uniqueIdMap = new Map<String, String>();
    public static Map<String, String> jsonUMap = new Map<String, String>();
    public static Map<Id, List<StyleWrapper>> style = new Map<Id, List<StyleWrapper>>();
    public static Map<Id, List<Object>> fieldsMeta = new Map<Id, List<Object>>();


    // RT 2JUN25 - Removed unused fields
    @AuraEnabled
    public static List<String> getReferenceFieldsFromJson(String jsonString) {
        List<String> referenceFields = new List<String>();
        try {
            String cleanedJson = JsonCleaner.cleanJson(jsonString);
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(cleanedJson);

            if (jsonData == null || !jsonData.containsKey('questionbook')) {
                throw new CustomException('Invalid JSON structure: questionbook not found');
            }

            Map<String, Object> questionBook = (Map<String, Object>) jsonData.get('questionbook');

            String mainObjectName = '';
            List<String> tableObjectNames = new List<String>();
            Set<String> relationUnique = new Set<String>();

            if (questionBook.containsKey('query') && questionBook.get('query') != null) {
                String queryString = String.valueOf(questionBook.get('query'));
                if (String.isNotBlank(queryString)) {
                    queryString = queryString.trim();

                    if (!queryString.toLowerCase().startsWith('select ')) {
                        throw new CustomException('Invalid SOQL query format');
                    }

                    mainObjectName = extractObjectNameFromQuery(queryString);

                    processQuery(queryString, referenceFields);
                }
            }

            if (questionBook.containsKey('subQuestions') && questionBook.get('subQuestions') != null) {
                List<Object> subQuestions = (List<Object>) questionBook.get('subQuestions');
                String subTitleObjectName = '';
                for (Object subQ : subQuestions) {
                    Map<String, Object> subQuestion = (Map<String, Object>) subQ;

                    if (subQuestion.containsKey('type') && String.valueOf(subQuestion.get('type')) == 'Table') {
                        if (subQuestion.containsKey('title') && subQuestion.get('title') != null) {
                            String tableObjectName = String.valueOf(subQuestion.get('title'));
                            tableObjectNames.add(tableObjectName);

                            if (String.isBlank(mainObjectName) && subQuestion.containsKey('subTitle') && subQuestion.get('subTitle') != null) {
                                String subTitle = String.valueOf(subQuestion.get('subTitle'));
                                subTitleObjectName = extractObjectNameFromSubTitle(subTitle);
                                if (String.isBlank(mainObjectName)) {
                                    mainObjectName = subTitleObjectName;
                                }

                                extractFromSubTitle(subTitle, referenceFields);
                            }

                            // RT 29JUL25 - List<Object> check to avoid Blob file names
                            if (subQuestion.containsKey('fieldsMeta') && subQuestion.get('fieldsMeta') != null && subQuestion.get('fieldsMeta') instanceof List<Object>) {
                                List<Object> fieldsMeta = (List<Object>) subQuestion.get('fieldsMeta');

                                for (Object fieldObj : fieldsMeta) {
                                    Map<String, Object> field = (Map<String, Object>) fieldObj;

                                    if (field.containsKey('apiName') && field.get('apiName') != null) {
                                        String fieldName = String.valueOf(field.get('apiName'));
                                        String fullFieldReference = tableObjectName + '.' + fieldName;
                                        referenceFields.add(fullFieldReference);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if (!tableObjectNames.isEmpty() && String.isNotBlank(mainObjectName)) {
                for (String tableObjectName : tableObjectNames) {
                    String relationshipStatement = '<!-- ' + mainObjectName + ' should be parent to ' + tableObjectName + ' -->';
                    relationUnique.add(relationshipStatement);
                }
                referenceFields.addAll(relationUnique);
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error extracting reference fields: ' + e.getMessage() + e.getLineNumber());
        }
        return referenceFields;
    }

    @TestVisible
    private static void extractFromSubTitle(String subTitle, List<String> referenceFields) {
        if (String.isBlank(subTitle)) {
            return;
        }

        List<String> conditions = new List<String>();
        Pattern andPattern = Pattern.compile('(?i)\\s+AND\\s+');
        Matcher andMatcher = andPattern.matcher(subTitle);

        if (!andMatcher.find()) {
            conditions.add(subTitle);
        } else {
            andMatcher.reset();

            Integer lastEnd = 0;
            while (andMatcher.find()) {
                conditions.add(subTitle.substring(lastEnd, andMatcher.start()).trim());
                lastEnd = andMatcher.end();
            }
            conditions.add(subTitle.substring(lastEnd).trim());
        }

        for (String condition : conditions) {
            Pattern fieldPattern = Pattern.compile('([\\w_]+__r)\\.([\\w_]+)\\s*=');
            Matcher fieldMatcher = fieldPattern.matcher(condition);

            if (fieldMatcher.find()) {
                String objectName = fieldMatcher.group(1);
                String fieldName = fieldMatcher.group(2);

                if (objectName.endsWith('__r')) {
                    objectName = objectName.substring(0, objectName.length() - 3) + '__c';
                }

                String fullFieldReference = objectName + '.' + fieldName;
                if (!referenceFields.contains(fullFieldReference)) {
                    referenceFields.add(fullFieldReference);
                }
            }
        }
    }

    @TestVisible
    private static String extractObjectNameFromSubTitle(String subTitle) {
        if (String.isBlank(subTitle)) {
            return '';
        }

        Pattern objectPattern = Pattern.compile('([\\w_]+__r)\\.');
        Matcher objectMatcher = objectPattern.matcher(subTitle);

        if (objectMatcher.find()) {
            String objectName = objectMatcher.group(1);

            if (objectName.endsWith('__r')) {
                return objectName.substring(0, objectName.length() - 3) + '__c';
            }

            return objectName;
        }

        return '';
    }
    @TestVisible
    private static String extractObjectNameFromQuery(String queryString) {
        Integer fromPos = queryString.toLowerCase().indexOf(' from ');
        if (fromPos <= 0) {
            return '';
        }

        String remaining = queryString.substring(fromPos + 6).trim();
        Integer wherePos = remaining.toLowerCase().indexOf(' where ');
        String objectName = wherePos > 0 ? remaining.substring(0, wherePos).trim() : remaining.trim();

        if (objectName.contains(' ')) {
            objectName = objectName.split(' ')[0];
        }

        return objectName;
    }
    @TestVisible
    private static void processQuery(String queryString, List<String> referenceFields) {
        Integer fromPos = queryString.toLowerCase().indexOf(' from ');
        if (fromPos <= 0) {
            throw new CustomException('Invalid SOQL query: FROM clause not found');
        }

        String fieldsSection = queryString.substring(7, fromPos).trim();

        String objectName = extractObjectNameFromQuery(queryString);

        processFieldsSection(fieldsSection, objectName, referenceFields);
    }
    @TestVisible
    private static void processFieldsSection(String fieldsSection, String objectName, List<String> referenceFields) {
        Integer openParens = 0;
        Integer currentPos = 0;
        String currentField = '';

        for (Integer i = 0; i < fieldsSection.length(); i++) {
            String c = fieldsSection.substring(i, i + 1);
            if (c == '(') {
                openParens++;
                currentField += c;
            } else if (c == ')') {
                openParens--;
                currentField += c;

                if (openParens == 0 && currentField.toLowerCase().contains('select')) {
                    processInnerQuery(currentField, referenceFields);
                    currentField = '';
                }
            } else if (c == ',' && openParens == 0) {
                addFieldToList(currentField.trim(), objectName, referenceFields);
                currentField = '';
            } else {
                currentField += c;
            }
        }

        if (String.isNotBlank(currentField)) {
            addFieldToList(currentField.trim(), objectName, referenceFields);
        }
    }
    @TestVisible
    private static void processInnerQuery(String innerQuery, List<String> referenceFields) {
        innerQuery = innerQuery.trim();
        if (innerQuery.startsWith('(') && innerQuery.endsWith(')')) {
            innerQuery = innerQuery.substring(1, innerQuery.length() - 1).trim();
        }

        Integer fromPos = innerQuery.toLowerCase().indexOf(' from ');
        if (fromPos <= 0) {
            return;
        }

        String fieldsSection = innerQuery.substring(7, fromPos).trim();

        String remaining = innerQuery.substring(fromPos + 6).trim();
        Integer wherePos = remaining.toLowerCase().indexOf(' where ');
        String objectName = wherePos > 0 ? remaining.substring(0, wherePos).trim() : remaining.trim();

        if (objectName.contains(' ')) {
            objectName = objectName.split(' ')[0];
        }

        String[] fieldParts = fieldsSection.split(',');
        for (String fieldPart : fieldParts) {
            fieldPart = fieldPart.trim();

            if (fieldPart.toLowerCase().contains(' as ')) {
                fieldPart = fieldPart.split(' as ')[0].trim();
            }

            if (fieldPart.equalsIgnoreCase('id')) {
                continue;
            }

            String fullFieldReference = objectName + '.' + fieldPart;
            referenceFields.add(fullFieldReference);
        }
    }
    @TestVisible
    private static void addFieldToList(String fieldPart, String objectName, List<String> referenceFields) {
        if (String.isBlank(fieldPart)) {
            return;
        }

        if (fieldPart.toLowerCase().contains('select')) {
            processInnerQuery(fieldPart, referenceFields);
            return;
        }

        if (fieldPart.toLowerCase().contains(' as ')) {
            fieldPart = fieldPart.split(' as ')[0].trim();
        }

        if (fieldPart.equalsIgnoreCase('id')) {
            return;
        }

        String fullFieldReference = objectName + '.' + fieldPart;
        referenceFields.add(fullFieldReference);
    }

    @TestVisible
    private static void processQueryStrings(Map<String, Object> questionBook) {
        if (questionBook.containsKey('query')) {
            String queryString = String.valueOf(questionBook.get('query'));
            if (queryString != null) {
                queryString = queryString.replaceAll('Id\\s*=\\s*\'[a-zA-Z0-9]{15,18}\'', 'Id = \\{c__record_id\\}');
                questionBook.put('query', queryString);
            }
        }
    }

    // RT 13SEP25 - Style Processing is done here with bulkified insert
    @AuraEnabled
    public static String processJsonData(String jsonString) {
        try {
            String cleanedJson = JsonCleaner.cleanJson(jsonString);
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(cleanedJson);

            if (!jsonData.containsKey('questionbook')) {
                throw new CustomException('questionbook not found');
            }

            Map<String, Object> rootBookJson = (Map<String, Object>) jsonData.get('questionbook');

            Id rootBookId = processRecursiveQuestionBooks(rootBookJson, jsonData, null);
            processFieldMeta(fieldsMeta);
            processFieldReference(fieldReferences, questionReferenceId);
            processStyle(style);
            processInput(rootBookId);
            String result = processForm(rootBookId);
            processTriggerUpdate(processedQuestions);

            return result;
        } catch (Exception e) {
            throw new AuraHandledException('Processing error: ' + e.getMessage() + ' \n at Line : ' + e.getLineNumber());
        }
    }

    @TestVisible
    private static Map<String, Object> parseAndValidateJson(String jsonString) {
        Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        if (jsonData == null || !jsonData.containsKey('questionbook')) {
            throw new CustomException('Invalid JSON structure: questionbook not found');
        }
        return jsonData;
    }

    // RT 12NOV25 - Query String modification to handle Id replacement
    @TestVisible
    private static Question_Book__c createQuestionBook(Map<String, Object> questionBook) {
        if (!Schema.sObjectType.Question_Book__c.isCreateable() || !Schema.sObjectType.Question_Book__c.isUpdateable()) {
            throw new CustomException('Insufficient permissions to create/update Question Book');
        }

        String queryStr = questionBook.containsKey('query') && questionBook.get('query') != null ? String.valueOf(questionBook.get('query')) : null;
        if( queryStr != null && queryStr.contains('Id = \'') ) {
            queryStr = queryStr.replaceAll('Id\\s*=\\s*\'[a-zA-Z0-9]{15,18}\'', 'Id = \\{c__record_id\\}');
        }

        Question_Book__c book = new Question_Book__c(
            Title__c = questionBook.containsKey('title') && questionBook.get('title') != null ? String.valueOf(questionBook.get('title')) : null,
            SubTitle__c = questionBook.containsKey('subTitle') && questionBook.get('subTitle') != null ? String.valueOf(questionBook.get('subTitle')) : null,
            Category__c = questionBook.containsKey('category') && questionBook.get('category') != null ? String.valueOf(questionBook.get('category')) : 'Simple',
            Unique_Identifier__c = 'QB-' + UUID.randomUUID().toString(), // RT 23JUL25 - Create a unique identifier with timestamp
            Status__c = questionBook.containsKey('status') && questionBook.get('status') != null ? String.valueOf(questionBook.get('status')) : null,
            Anchor_Object__c = questionBook.containsKey('objectApiName') && questionBook.get('objectApiName') != null ? String.valueOf(questionBook.get('objectApiName')) : null,
            Query__c = queryStr,
            Version__c = questionBook.containsKey('version') && questionBook.get('version') != null ? Decimal.valueOf(String.valueOf(questionBook.get('version'))) : 1,
            Version_Status__c = questionBook.containsKey('versionStatus') && questionBook.get('versionStatus') != null ? String.valueOf(questionBook.get('versionStatus')) : 'Inactive',
            Style__c = questionBook.containsKey('style') && questionBook.get('style') != null ? formatJsonStyleString(String.valueOf(questionBook.get('style'))) : null, // RT 26JUL25 - Added style handling
            Auto_generate_ID__c = false
        );

        insert book; // RT 13SEP25 - Only insert as of now.
        return book;
    }

    @TestVisible
    private static String extractReferenceId(Map<String, Object> container, String keyName) {
        if (!container.containsKey(keyName)) {
            return null;
        }

        Object refObj = container.get(keyName);
        if (refObj instanceof Map<String, Object>) {
            Map<String, Object> refMap = (Map<String, Object>) refObj;
            return String.valueOf(refMap.get('Id'));
        } else {
            return String.valueOf(refObj);
        }
    }

    @TestVisible
    private static String formatJsonStyleString(String style) {
        if (String.isBlank(style)) {
            return null;
        }

        if (style.startsWith('{') && style.endsWith('}')) {
            return style;
        }

        return '{' + style.trim() + '}';
    }

    public class CustomException extends Exception {
    }

    @TestVisible
    private static void processInput(Id bookId) {
        try {
            if (bookId == null) {
                throw new CustomException('Question Book ID is null');
            } else {
                try {
                    if (!Schema.sObjectType.Input__c.isCreateable() || !Schema.sObjectType.Input__c.isUpdateable()) {
                        throw new CustomException('Insufficient permissions to create/update Input record');
                    }

                    Input__c input = new Input__c(
                        Question_Book__c = bookId,
                        API_Name__c = 'c__record_id',
                        Type__c = 'String',
                        Unique_Identifier__c = UUID.randomUUID().toString(), // RT 23JUL25 - Create a unique identifier for the input
                        Auto_generate_ID__c = false
                    );
                    upsert input;
                } catch (Exception e) {
                    throw new CustomException('Error creating input record: ' + e.getMessage());
                }
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error processing input: ' + e.getMessage());
        }
    }

    @TestVisible
    private static Id processRecursiveQuestionBooks(Map<String, Object> questionBook, Map<String, Object> jsonData, Set<String> processedBooks) {
        if (questionBook == null) {
            return null;
        }

        if (processedBooks == null) {
            processedBooks = new Set<String>();
        }

    try {
        String uniqueId = String.valueOf(questionBook.get('uniqueIdentifier'));

        Question_Book__c createdBook = createQuestionBook(questionBook);
        Id bookId = createdBook.Id;
        String bookName = createdBook.Name;

        Id refBookId = null;
        processedBooks.add(String.valueOf(bookId));

        if (!questionBook.containsKey('subQuestions')) {
            return null;
        }

        List<Object> subQuestions = (List<Object>) questionBook.get('subQuestions');
        List<Question__c> questions = new List<Question__c>();
        Map<String, List<Object>> fieldMap = new Map<String, List<Object>>();
        Map<String, List<Object>> styleMap = new Map<String, List<Object>>();

        // RT 26JUL25 - Check if Blob file names are present
        for (Object qObj : subQuestions) {
            Map<String, Object> q = (Map<String, Object>) qObj;

            Id rtId = recTypeId;
            String jsonUniqueId = String.valueOf(q.get('uniqueIdentifier'));
            String questionUniqueId = bookName + '-' + UUID.randomUUID().toString(); // RT 23JUL25 - Create a unique identifier if not provided
            if (jsonUniqueId != null) {
                uniqueIdMap.put(questionUniqueId, jsonUniqueId);
                jsonUMap.put(jsonUniqueId, questionUniqueId);
            }
            System.debug(
                'unique id map: ' + uniqueIdMap
            );
            List<Object> fieldsMetaList;
            if (q.get('fieldsMeta') instanceof List<Object>) {
                fieldsMetaList = (List<Object>) q.get('fieldsMeta');
            } else if (
                q.get('fieldsMeta') instanceof String &&
                String.isNotBlank((String) q.get('fieldsMeta')) &&
                ((String) q.get('fieldsMeta') != null &&
                ((String) q.get('fieldsMeta')).trim().startsWith('[') &&
                ((String) q.get('fieldsMeta')).trim().endsWith(']'))
            ) {
                fieldsMetaList = (List<Object>) JSON.deserializeUntyped((String) q.get('fieldsMeta'));
            } else {
                fieldsMetaList = new List<Object>();
            }
            fieldMap.put(questionUniqueId, fieldsMetaList);
            if (q.get('style') instanceof List<Object>) {
                styleMap.put(questionUniqueId, (List<Object>) q.get('style'));
            } else if (q.get('style') instanceof String && String.isNotBlank((String) q.get('style'))) {
                String styleStr = (String) q.get('style');
                Object styleDeserialized;
                try {
                    // Only attempt to deserialize if it looks like valid JSON
                    if (styleStr != null && (styleStr.trim().startsWith('{') || styleStr.trim().startsWith('['))) {
                        styleDeserialized = JSON.deserializeUntyped(styleStr);
                    } else {
                        styleDeserialized = null;
                    }
                } catch (Exception ex) {
                    // If deserialization fails, treat as empty style
                    styleDeserialized = null;
                }
                if (styleDeserialized instanceof List<Object>) {
                    styleMap.put(questionUniqueId, (List<Object>) styleDeserialized);
                } else if (styleDeserialized instanceof Map<String, Object>) {
                    styleMap.put(questionUniqueId, new List<Object>{ (Map<String, Object>) styleDeserialized });
                } else {
                    styleMap.put(questionUniqueId, new List<Object>());
                }
            } else {
                styleMap.put(questionUniqueId, new List<Object>());
            }

            List<StyleWrapper> wrapperList = new List<StyleWrapper>();

            // No fieldsMeta or qbReferenceQuestions
            Question__c question = new Question__c(
                Question_Book__c = bookId,
                Type__c = String.valueOf(q.get('type')),
                Question_No__c = Decimal.valueOf(String.valueOf(q.get('questionNumber'))),
                RecordTypeId = rtId,
                isSno__c = (q.get('isSno') != null && (String.valueOf(q.get('isSno')).toLowerCase() == 'true' || String.valueOf(q.get('isSno')).toLowerCase() == 'false')) ? Boolean.valueOf(String.valueOf(q.get('isSno'))) : false,
                Is_Serial_No__c = (q.get('isSerialNo') != null && (String.valueOf(q.get('isSerialNo')).toLowerCase() == 'true' || String.valueOf(q.get('isSerialNo')).toLowerCase() == 'false')) ? Boolean.valueOf(String.valueOf(q.get('isSerialNo'))) : false, // RT 23JUL25 - Handle isSerialNo field
                Unique_Identifier__c = questionUniqueId, // RT 23JUL25 - Removed null as it is already handled above
                Question_Text__c = String.valueOf(q.get('questionText')),
                Minimum_Fraction_Digits__c = q.get('minimumFractionDigits') != null ? Integer.valueOf(String.valueOf(q.get('minimumFractionDigits'))) : null,
                Maximum_Fraction_Digits__c = q.get('maximumFractionDigits') != null ? Integer.valueOf(String.valueOf(q.get('maximumFractionDigits'))) : null,
                Currency_Code__c = q.get('currencyCode') != null ? String.valueOf(q.get('currencyCode')) : null, // RT 06OCT25 - Currency Format
                Locale__c = q.get('locale') != null ? String.valueOf(q.get('locale')) : null,
                Sno_Title__c = q.get('snoTitle') != null ? String.valueOf(q.get('snoTitle')) : null, // RT 13OCT25 - Sno Title
                Is_Rich_Text__c = q.get('isRichText') != null ? Boolean.valueOf(String.valueOf(q.get('isRichText'))) : false,
                Date_Format__c = q.get('dateFormat') != null ? String.valueOf(q.get('dateFormat')) : null, // RT 19SEP25 - Date Format
                Group__c = String.valueOf(q.get('groupName')),
                Question__c = String.valueOf(q.get('question')),
                Title__c = String.valueOf(q.get('title')),
                Sub_Text__c = String.valueOf(q.get('subText')),
                Element_Mode__c = q.get('elementMode') != null ? String.valueOf(q.get('elementMode')) : null,// VD 20Sep25 - line elment Fix // RT 12NOV25 - Element mode bug fix
                SubTitle__c = String.valueOf(q.get('subTitle')),
                Size__c = q.get('size') != null ? Integer.valueOf(String.valueOf(q.get('size'))) : null,
                Auto_generate_ID__c = false
            );

            // RT 26JUL25 - Null checks for qbReference
            if (q.containsKey('qbReference') && (q.get('type') == 'Book' || q.get('type') == 'Table') && q.get('qbReference') != null) {
                Object qbRef = q.get('qbReferenceQuestions');
                Map<String, Object> refBook;
                if (qbRef instanceof Map<String, Object>) {
                    refBook = (Map<String, Object>) qbRef;
                } else if (qbRef instanceof String && String.isNotBlank((String) qbRef)) {
                    // Try to deserialize if it's a JSON string
                    refBook = (Map<String, Object>) JSON.deserializeUntyped((String) qbRef);
                } else {
                    throw new CustomException('Invalid qbReferenceQuestions format: Not a Map or JSON string');
                }
                if (refBook != null && refBook.containsKey('questionbook')) {
                    Object refBookObj = refBook.get('questionbook');
                    if (refBookObj != null && refBookObj instanceof Map<String, Object>) {
                        refBook = (Map<String, Object>) refBookObj;
                    }
                } else {
                    throw new CustomException('Invalid qbReferenceQuestions format');
                }
                if (refBook != null) {
                    refBookId = processRecursiveQuestionBooks(refBook, jsonData, processedBooks);
                    // Tag the processed book in QB_Reference__c field
                    question.QB_Reference__c = refBookId;
                }
            }
            questions.add(question);
        }

        if (!questions.isEmpty()) {
            insert questions;
            for (Question__c q : questions) {
                if (q.Id != null) {
                    processedQuestions.add(q.Id);
                    fieldsMeta.put(q.Id, fieldMap.get(q.Unique_Identifier__c) ?? new List<Object>());
                    questionReferenceId.put(q.Unique_Identifier__c, q.Id);
                    List<StyleWrapper> wrapperList = new List<StyleWrapper>();
                    List<Object> rawStyles = styleMap.get(q.Unique_Identifier__c) ?? new List<Object>();

                    for (Object o : rawStyles) {
                        if (o instanceof Map<String, Object>) {
                            Map<String, Object> styleData = (Map<String, Object>) o;

                            // Convert Map -> JSON -> StyleWrapper
                            String styleJson = JSON.serialize(styleData);
                            StyleWrapper sw = (StyleWrapper) JSON.deserialize(styleJson, StyleWrapper.class);
                            wrapperList.add(sw);
                        }
                    }
                    style.put(q.Id, wrapperList);
                }
            }
        }
            return bookId;
        } catch (Exception e) {
            throw new CustomException('Error processing question books: ' + e.getMessage() + ' \n at Line : ' + e.getLineNumber());
        }
    }

    @TestVisible
    private static void processFieldMeta(Map<Id, List<Object>> fm) {
        try {
            List<Field_Meta__c> fieldMetas = new List<Field_Meta__c>();
        Map<String, Object> referMap = new Map<String, Object>();

        for (Id qId : fm.keySet()) {
            List<Object> fmObj = fm.get(qId);
            for (Object o : fmObj) {
                Map<String, Object> oMap = (Map<String, Object>) o;
                Object reference = oMap.get('questionReference');
                System.debug('field reference' + reference);
                Map<String, Object> referenceMap = new Map<String, Object>();
                if (reference != null) {
                    if (reference instanceof Map<String, Object>) {
                        referenceMap = (Map<String, Object>) reference;
                    } else if (reference instanceof String && String.isNotBlank((String) reference)) {
                        try {
                            referenceMap = (Map<String, Object>) JSON.deserializeUntyped((String) reference);
                        } catch (Exception ex) {
                            System.debug('Failed to deserialize reference: ' + ex.getMessage());
                        }
                    }
                }
                Object refObj = referenceMap.get('question') ?? null;
                Map<String, Object> que = (refObj instanceof Map<String, Object>) ? (Map<String, Object>) refObj : null;
                String qUnique = (que != null && que.containsKey('uniqueIdentifier')) ? String.valueOf(que.get('uniqueIdentifier')) : null;
                system.debug('question Unique Id: ' + qUnique);
                String uniqueId = 'FM-' + qId + '-' + UUID.randomUUID().toString();
                String qUniqueId = jsonUMap.get(qUnique);
                referMap.put(uniqueId, qUniqueId);
                Id questionReferenceId = null;

                // RT 21JUL25 - Added missed fields
                Field_Meta__c f = new Field_Meta__c(
                    Unique_Identifier__c =  uniqueId, // RT 23JUL25 - Create a unique identifier if not provided
                    api_name__c = oMap.get('apiName') != null ? String.valueOf(oMap.get('apiName')) : null,
                    fld_type__c = oMap.get('fldType') != null ? String.valueOf(oMap.get('fldType')) : null,
                    label__c = oMap.get('label') != null ? String.valueOf(oMap.get('label')) : null,
                    output_flag__c = oMap.get('outputFlag') != null ? Boolean.valueOf(String.valueOf(oMap.get('outputFlag'))) : false,
                    filterFlag__c = oMap.get('filterflag') != null ? Boolean.valueOf(String.valueOf(oMap.get('filterflag'))) : false,
                    isChild__c = oMap.get('ischild') != null ? Boolean.valueOf(String.valueOf(oMap.get('ischild'))) : false,
                    orderByFlag__c = oMap.get('orderbyflag') != null ? Boolean.valueOf(String.valueOf(oMap.get('orderbyflag'))) : false,
                    order__c = oMap.get('order') != null ? Integer.valueOf(String.valueOf(oMap.get('order'))) : null,
                    read_only__c = oMap.get('readOnly') != null ? Boolean.valueOf(String.valueOf(oMap.get('readOnly'))) : false,
                    resultantFlag__c = oMap.get('resultantflag') != null ? Boolean.valueOf(String.valueOf(oMap.get('resultantflag'))) : false,
                    Is_Foot__c = oMap.get('isfoot') != null ? Boolean.valueOf(String.valueOf(oMap.get('isfoot'))) : false,
                    Colspan__c = oMap.get('colspan') != null ? Integer.valueOf(String.valueOf(oMap.get('colspan'))) : null,
                    Table_Head_Style__c = (String.valueOf(oMap.get('tableHeadStyle'))) != null ? String.valueOf(oMap.get('tableHeadStyle')) : null,
                    Table_Data_Style__c = (String.valueOf(oMap.get('tableDataStyle'))) != null ? String.valueOf(oMap.get('tableDataStyle')) : null, // RT 26JUL25 - Added table styles
                    searchFlag__c = oMap.get('searchflag') != null ? Boolean.valueOf(String.valueOf(oMap.get('searchflag'))) : false,
                    isGrandChild__c = oMap.get('isgrandchild') != null ? Boolean.valueOf(String.valueOf(oMap.get('isgrandchild'))) : false,
                    Question__c = qId,
                    Auto_generate_ID__c = false
                );
                fieldMetas.add(f);
            }
        }
        if (!fieldMetas.isEmpty()) {
            insert fieldMetas;
            for (Field_Meta__c f : fieldMetas) {
                if (f.Id != null) {
                    fieldReferences.put(f.Id, (referMap.get(f.Unique_Identifier__c) != null ? String.valueOf(referMap.get(f.Unique_Identifier__c)) : null));
                }
            }
        }
        } catch (Exception e) {
            throw new CustomException('Error processing field metadata: ' + e.getMessage() + ' \n at Line : ' + e.getLineNumber());
        }
    }

    @TestVisible
    private static void processFieldReference(Map<Id, String> fieldReferences, Map<String, Id> questionReferenceId) {
        // Collect all unique identifiers that need to be queried
        Set<String> uniqueIdsToQuery = new Set<String>();
        for (String refUniqueId : fieldReferences.values()) {
            if (String.isNotBlank(refUniqueId) && !questionReferenceId.containsKey(refUniqueId)) {
                uniqueIdsToQuery.add(refUniqueId);
            }
        }

        // Single SOQL query to get all missing question references
        Map<String, Id> additionalQuestionRefs = new Map<String, Id>();
        if (!uniqueIdsToQuery.isEmpty()) {
            for (Question__c q : [
                SELECT Id, Unique_Identifier__c
                FROM Question__c
                WHERE Unique_Identifier__c IN :uniqueIdsToQuery
            ]) {
                additionalQuestionRefs.put(q.Unique_Identifier__c, q.Id);
            }
        }

        // Merge with existing questionReferenceId map
        Map<String, Id> completeQuestionReferenceId = new Map<String, Id>();
        completeQuestionReferenceId.putAll(questionReferenceId);
        completeQuestionReferenceId.putAll(additionalQuestionRefs);

        // Build field reference mapping
        Map<Id, Id> fReference = new Map<Id, Id>();
        for (Id fieldId : fieldReferences.keySet()) {
            String refUniqueId = fieldReferences.get(fieldId);
            if (refUniqueId != null && completeQuestionReferenceId.containsKey(refUniqueId)) {
                Id questionRefId = completeQuestionReferenceId.get(refUniqueId);
                fReference.put(fieldId, questionRefId);
                System.debug('Field ID: ' + fieldId + ', Question Reference ID: ' + questionRefId);
            } else {
                System.debug('No question reference found for unique ID: ' + refUniqueId);
            }
        }

        // Bulk update field references
        if (!fReference.isEmpty()) {
            List<Field_Meta__c> fieldMetaList = new List<Field_Meta__c>();
            for (Id fieldId : fReference.keySet()) {
                Field_Meta__c fieldMeta = new Field_Meta__c(Id = fieldId, Question_Reference__c = fReference.get(fieldId));
                fieldMetaList.add(fieldMeta);
            }
            try {
                update fieldMetaList;
            } catch (Exception e) {
                throw new CustomException('Error updating field references: ' + e.getMessage());
            }
        } else {
            System.debug('No field references to update');
        }
    }

    // Updated method to launch the batch
    @TestVisible
    private static void processTriggerUpdate(Set<Id> questionIds) {
        if (questionIds == null || questionIds.isEmpty())
            return;
        if (!Schema.sObjectType.Question__c.isAccessible()) {
            throw new CustomException('Insufficient permissions');
        }
        // Only execute batch outside of tests
        if (!Test.isRunningTest()) {
            Database.executeBatch(new QuestionTriggerUpdateBatch(questionIds), 1);
        }
    }

    // RT 23JUL25 - Added width and height for Image
    // RT 26JUL25 - Removed formatting since it is directly handled in the Trigger
    // RT 13SEP25 - Refactored processStyle using StyleWrapper + loadStyleWrapper
    // make method to cover unit test
    @TestVisible
    private static void processStyle(Map<Id, List<StyleWrapper>> styleMap) {
        try {
            List<Style__c> styles = new List<Style__c>();

            for (Id qId : styleMap.keySet()) {
                for (StyleWrapper sw : styleMap.get(qId)) {
                    // Convert wrapper back to SObject
                    sw.id = null;
                    Style__c s = StyleWrapper.loadStyleWrapper(sw);

                    // Always make sure Question__c is set
                    s.Id = null;
                    s.Question__c = qId;

                    // Ensure external_id__c exists
                    if (String.isEmpty(s.external_id__c)) {
                        s.external_id__c = qId + '-' + String.valueOf(UUID.randomUUID().toString());
                    }

                    // Disable auto id generation
                    s.Auto_generate_ID__c = false;

                    styles.add(s);
                }
            }

            if (!styles.isEmpty()) {
                insert styles; // external id for idempotency
            }
        } catch (Exception e) {
            //System.debug('style error: ' + e.getMessage() + ' \n at Line : ' + e.getLineNumber());
            throw new CustomException('Error processing styles: ' + e.getMessage() + ' \n at Line : ' + e.getLineNumber());
        }
    }

    // RT 13SEP25 - Refactored processForm to only handle insert
    @TestVisible
    private static String processForm(Id rootBookId) {
        try {
            if (rootBookId == null) {
                throw new CustomException('Root Book ID is null');
            }

            Question_Book__c rootBook = [
                SELECT Id, Title__c, Anchor_Object__c
                FROM Question_Book__c
                WHERE Id = :rootBookId
                LIMIT 1
            ];

            if (!Schema.sObjectType.Form__c.isCreateable() || !Schema.sObjectType.Form__c.isUpdateable()) {
                throw new CustomException('Insufficient permissions to create/update Form record');
            }

            Form__c form = new Form__c(Question_Book__c = rootBookId, Name = rootBook.Title__c, Type__c = 'QuestionBook', Anchor_Object__c = rootBook.Anchor_Object__c);
            insert form;
            if (form.Id != null) {
                Question_Book__c bookToUpdate = new Question_Book__c(Id = rootBookId, Form__c = form.Id);
                update bookToUpdate;
            }
            Map<String, Object> result = new Map<String, Object>();
            result.put('id', form.Id);
            result.put('name', form.Name);
            result.put('anchorObject', form.Anchor_Object__c);
            return JSON.serialize(result);
        } catch (Exception e) {
            throw new CustomException('Error processing form: ' + e.getMessage());
        }
    }
}