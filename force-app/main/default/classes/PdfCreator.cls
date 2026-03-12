global with sharing class PdfCreator {
    // Existing QuestionMeta inner class remains unchanged
    public class QuestionMeta {
        public String name;
        public String typ;
        public Integer height;
        public Integer width;

        // lightning-input
        public Boolean liFlag;
        public Boolean iconFlag;

        // Flags
        public Boolean typCheckbox;
        public Boolean typData;
        public Boolean typDate;
        public Boolean typDateTime;
        public Boolean typDropdown;
        public Boolean typEmail;
        public Boolean typFile;
        public Boolean typImage;
        public Boolean typeButton;
        public Boolean typList;
        public Boolean typLocation;
        public Boolean typMultiPickList;
        public Boolean typNumber;
        public Boolean typTextArea;
        public Boolean typText;

        // Constructor
        public QuestionMeta(String n, String t, Integer h, Integer w) {
            // System.debug('Inside QuestionMeta constructor with ' + t);

            this.name = n;
            this.typ = t;
            this.height = h;
            this.width = w;
            this.iconFlag = false;

            if (this.typ != null) {
                this.liFlag = true;
                if (this.typ == 'Text') {
                    this.typText = true;
                } else if (this.typ == 'Checkbox') {
                    this.typCheckbox = true;
                } else if (this.typ == 'Data') {
                    this.typData = true;
                    this.liFlag = false;
                } else if (this.typ == 'Date') {
                    this.typDate = true;
                } else if (this.typ == 'DateTime') {
                    this.typDateTime = true;
                } else if (this.typ == 'Dropdown') {
                    this.typDropdown = true;
                    this.liFlag = false;
                } else if (this.typ == 'Email') {
                    this.typEmail = true;
                } else if (this.typ == 'File') {
                    this.typFile = true;
                } else if (this.typ == 'Image') {
                    this.typImage = true;
                    this.liFlag = false;
                } else if (this.typ == 'Button') {
                    this.typeButton = true;
                    this.liFlag = false;
                } else if (this.typ == 'List') {
                    this.typList = true;
                    this.liFlag = false;
                } else if (this.typ == 'Location') {
                    this.typLocation = true;
                } else if (this.typ == 'MultiPickList') {
                    this.typMultiPickList = true;
                } else if (this.typ == 'Number') {
                    this.typ = 'tel';
                    this.typNumber = true;
                } else if (this.typ == 'TextArea') {
                    this.typTextArea = true;
                }
            } else {
                this.iconFlag = true;
            }
        }
    }

    // Flow input parameters wrapper class
    // Flow input parameters wrapper class
    global class FlowInputs {
        @InvocableVariable(label='Record ID' required=true)
        global String recordId;

        // RT 24SEP25 - Deprecated - kept for backward compatibility with managed package
        @InvocableVariable(label='Question Book ID' required=false)
        global String qbId; // DO NOT REMOVE, legacy use only

        // RT 24 SEP25 - New variable replacing qbId
        @InvocableVariable(label='Form ID' required=true)
        global String formId;
    }

    // Flow output parameters wrapper class
    global class FlowOutputs {
        @InvocableVariable(label='Success')
        global Boolean success;

        @InvocableVariable(label='Message')
        global String message;
    }

    global class Result {
        public Boolean success;
        public String message;
        public Object data;

        public Result(Boolean success, String message, Object data) {
            this.success = success;
            this.message = message;
            this.data = data;
        }

        public Result(Boolean success, String message) {
            this(success, message, null);
        }
    }

    // RT 29SEP25 - Exception handler for PDF Service
    private static Result fromException(Exception e) {
        return new Result(
            false,
            'Error: ' +
                e.getMessage() +
                ' | Line: ' +
                e.getLineNumber() +
                ' | Class: ' +
                e.getTypeName()
        );
    }

    // Static variables remain unchanged
    global static string recordId;
    global static string qbId;
    global static string formId;
    global static string objectApiName;
    global static Boolean hasTable = false;
    public static Map<String, Object> jsonData;
    public static String qbName;
    // Invocable method to be called from Flow

    @InvocableMethod(
        label='Generate PDF from Question Book'
        description='Generates a PDF from a Question Book and attaches it to a record'
    )
    global static List<FlowOutputs> generatePdfFromFlow(
        List<FlowInputs> inputs
    ) {
        List<FlowOutputs> outputs = new List<FlowOutputs>();
        FlowOutputs result = new FlowOutputs();

        try {
            if (inputs.isEmpty()) {
                throw new IllegalArgumentException(
                    'Input parameters cannot be empty'
                );
            }

            FlowInputs input = inputs[0];
            // Call the existing readQB method
            Result readResult = readQB(input.recordId, input.formId); // // VD 24jun25 Form ID Changes (in place of QB Id)

            // Assign both success and message from Result class
            result.success = readResult.success;
            result.message = readResult.message;
        } catch (Exception e) {
            // RT 29SEP25 - Exception handler for flow
            System.debug(
                'Error in Flow: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            FlowOutputs errorOutput = new FlowOutputs();
            errorOutput.success = false;
            errorOutput.message =
                'Error: ' +
                e.getMessage() +
                ' | Line: ' +
                e.getLineNumber() +
                ' | Class: ' +
                e.getTypeName();
            List<FlowOutputs> errorList = new List<FlowOutputs>();
            errorList.add(errorOutput);
            return errorList;
        }

        outputs.add(result);
        return outputs;
    }

    // RT 25SEP25 - New AuraEnabled method for LWC
    @AuraEnabled
    global static String generatePdfFromLWC(String recordId, String formId) {
        try {
            // Validate input parameters
            if (String.isBlank(recordId) || String.isBlank(formId)) {
                return JSON.serialize(
                    new Result(
                        false,
                        'recordId and formId cannot be null or empty'
                    )
                );
            }

            // Call the existing readQB method
            Result readResult = readQB(recordId, formId);

            // Return the result as JSON string for LWC consumption
            return JSON.serialize(readResult);
        } catch (Exception e) {
            // Handle exceptions and return error result
            System.debug(
                'Error in generatePdfFromLWC: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            return JSON.serialize(fromException(e)); // RT 29SEP25 - Return error result
        }
    }
    // VD 24jun25 Form ID Changes (in place of QB Id)
    @AuraEnabled
    public static Result readQB(String recordId, string formId) {
        return commonReadQB(recordId, formId);
    }
    // VD 24jun25 Form ID Changes (in place of QB Id)
    global static Result utilityQB(String recordId, string formId) {
        return commonReadQB(recordId, formId);
    }
    @TestVisible
    private static Result commonReadQB(String recordId, string formId) {
        try {
            // VD 24jun25 Form ID Changes (in place of QB Id)

            // RT 18DEC25 - Added variable for pfxId // RT 05JAN26 - Moved to recursive method
            // Check if recordId and formId are not null or empty
            if (String.isBlank(recordId) || String.isBlank(formId)) {
                return new Result(
                    false,
                    'recordId and formId cannot be null or empty'
                );
            }
            PdfCreator.recordId = recordId;
            PdfCreator.formId = formId;
            // Create paramMap in Apex
            Map<String, Object> paramMap = new Map<String, Object>();
            paramMap.put('createAnswerBookFlag', false);
            paramMap.put('c__record_id', recordId);
            paramMap.put('c__qb_id', formId);

            // Create para map
            Map<String, Object> para = new Map<String, Object>();
            para.put('dataType', 'Form');
            para.put('operation', 'read');
            para.put('param1', formId);
            para.put('paramJSON', JSON.serialize(paramMap)); // Convert paramMap to JSON string
            para.put('languageCode', '');
            // VD 24jun25 Form ID Changes
            string result = NxtController.processData(JSON.serialize(para));
            Map<String, Object> outerMap = (Map<String, Object>) JSON.deserializeUntyped(
                result
            );
            String qhResponseStr = (String) outerMap.get('qhResponse');
            jsonData = (Map<String, Object>) JSON.deserializeUntyped(
                qhResponseStr
            );
            // Extract the required parameters for nxtProcessQuestions
            Map<String, Object> questionbook = (Map<String, Object>) jsonData.get(
                'questionbook'
            );
            // VD 24jun25 Form ID Changes
            String title = (String) questionbook.get('title');
            qbName = title != null ? title : 'Untitled';
            // versionStatus check
            String versionStatus = (String) questionbook.get('versionStatus');
            if (versionStatus == null || versionStatus != 'Active') {
                return new Result(
                    false,
                    'The selected book is not active. Please contact your administrator.'
                );
            }
            List<Object> rawList = (List<Object>) questionbook.get(
                'subQuestions'
            );
            List<Map<String, Object>> qList = new List<Map<String, Object>>();
            for (Object obj : rawList) {
                qList.add((Map<String, Object>) obj);
            }
            Map<String, Object> sqOps = (Map<String, Object>) jsonData.get(
                'sqOptions'
            );
            List<Object> rawQbQueryResults = (List<Object>) jsonData.get(
                'qbQueryResult'
            );
            List<Map<String, Object>> qbQueryResults = new List<Map<String, Object>>();
            for (Object obj : rawQbQueryResults) {
                qbQueryResults.add((Map<String, Object>) obj);
            }
            List<Map<String, Object>> refFMList = new List<Map<String, Object>>(); // Empty list as your 4th parameter

            // Call the nxtProcessQuestions method with the parameters
            List<Map<String, Object>> processedQuestions = CustomUtility.nxtProcessQuestions(
                qList,
                sqOps,
                qbQueryResults,
                refFMList
            );
            if (processedQuestions == null || processedQuestions.isEmpty()) {
                return new Result(
                    false,
                    'No records found in processed questions.'
                );
            }
            for (Map<String, Object> question : processedQuestions) {
                if (question == null) {
                    System.debug('Null question found in processed questions.');
                    return new Result(
                        false,
                        'Invalid question found in processed questions.'
                    );
                }
            }
            System.debug(
                'Processed Questions: ' + JSON.serialize(processedQuestions)
            );
            // Now you can use the processed questions

            questionbook.put('subQuestions', processedQuestions);

            // System.debug('Updated JSON: ' + JSON.serialize(jsonData));
            map<string, object> mapData = new Map<string, object>();
            if (jsonData.containsKey('questionbook')) {
                mapData.put('questionbook', questionbook);
                Map<String, String> signResult = new Map<String, String>();
                Boolean isSignPadEnabled = false; // RT 09JAN26 - Initialize SignPad flag
                // RT 05JAN26 - Moved to recursive method
                findSignPadRecursive(
                    (List<Object>) questionbook.get('subQuestions'),
                    signResult
                );
                String pfxId = signResult.get('pfxId');
                String signerName = signResult.get('signerName'); // RT 06JAN25 - signerName extraction
                isSignPadEnabled = signResult.containsKey('isSignPadEnabled')
                    ? Boolean.valueOf(signResult.get('isSignPadEnabled'))
                    : false; // RT 09JAN26 - Extract isSignPadEnabled from signResult

                for (Map<String, Object> data : processedQuestions) {
                    if (
                        data.containsKey('type') &&
                        String.valueOf(data.get('type')) == 'table'
                    ) {
                        Result processResult = processTable(data);
                        if (!processResult.success) {
                            return processResult;
                        }
                        hasTable = true;
                    }
                    // RT 18DEC25 - Extract pfxId if SignPad type question found
                    // RT 05JAN26 - Moved to recursive method
                }

                String signBase64 = isSignPadEnabled == true
                    ? extractSignBase64(recordId)
                    : null;
                // System.debug('signbase' + signBase64);
                return generatePdf(
                    jsonData.get('questionbook'),
                    recordId,
                    pfxId,
                    signerName,
                    isSignPadEnabled,
                    signBase64
                ); // RT 06JAN25 - Passed signerName
            } else {
                System.debug('jsonData does not contain key: questionbook');
                return new Result(
                    false,
                    'Missing questionbook data in response'
                );
            }
        } catch (Exception e) {
            System.debug(
                'Error in commonReadQB: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            return fromException(e); // RT 29SEP25 - Exception handler for PDF Service
        }
    }

    @TestVisible
    private static Result processTable(Map<String, Object> questionObj) {
        try {
            Map<String, Object> fldMetaMap = new Map<String, Object>();
            Map<String, Object> fldQuestionsMap = new Map<String, Object>();
            List<Object> tableFieldList = new List<Object>();

            map<string, object> fldObject = new Map<string, object>();
            map<string, object> fldQuestion = new Map<string, object>();

            String objectApiName = String.valueOf(questionObj.get('title'));
            String filterQuery = String.valueOf(questionObj.get('subTitle'));
            List<Object> rawFieldsMetadata = (List<Object>) JSON.deserializeUntyped(
                String.valueOf(questionObj.get('fieldsMeta'))
            );
            List<Map<String, Object>> fieldsMetadata = new List<Map<String, Object>>();

            for (Object obj : rawFieldsMetadata) {
                fieldsMetadata.add((Map<String, Object>) obj);
            }

            for (Map<String, Object> fld : fieldsMetadata) {
                // Create a deep clone of the original field object to preserve all properties
                Map<String, Object> fldObj = (Map<String, Object>) JSON.deserializeUntyped(
                    JSON.serialize(fld)
                );

                // Extract field type from questionReference if available
                String fldTyp;
                Map<String, Object> fldQRef = new Map<String, Object>();
                if (
                    fld.containsKey('questionReference') &&
                    String.isNotBlank(
                        String.valueOf(fld.get('questionReference'))
                    )
                ) {
                    fldQRef = (Map<String, Object>) JSON.deserializeUntyped(
                        String.valueOf(fld.get('questionReference'))
                    );

                    // Navigate to the question object if it exists
                    if (fldQRef.containsKey('question')) {
                        Map<String, Object> question = (Map<String, Object>) fldQRef.get(
                            'question'
                        );
                        fldTyp = question.containsKey('type')
                            ? String.valueOf(question.get('type'))
                            : String.valueOf(fld.get('fldType'));
                    } else {
                        fldTyp = String.valueOf(fld.get('fldType'));
                    }
                } else {
                    fldTyp = String.valueOf(fld.get('fldType'));
                }

                // Create QuestionMeta instance
                QuestionMeta fieldMeta = new QuestionMeta(
                    String.valueOf(fld.get('name')),
                    fldTyp,
                    1,
                    1
                );

                // Convert QuestionMeta to Map before storing in fldMetaMap
                Map<String, Object> metaMap = (Map<String, Object>) JSON.deserializeUntyped(
                    JSON.serialize(fieldMeta)
                );

                // Store the serialized meta object in fldMetaMap
                fldMetaMap.put(String.valueOf(fld.get('name')), fieldMeta);

                // Also store meta inside fldObj for debugging or later use
                fldObj.put('meta', metaMap);

                fldQuestionsMap.put(
                    String.valueOf(fld.get('name')),
                    fldQRef.get('question')
                );

                fldObject.putAll(fldMetaMap);
                fldQuestion.putAll(fldQuestionsMap);
                if (Boolean.valueOf(fld.get('outputFlag')) == true) {
                    tableFieldList.add(fldObj);
                }
            }
            return loadTable(
                objectApiName,
                filterQuery,
                fieldsMetadata,
                fldObject,
                fldQuestion
            );
        } catch (Exception e) {
            System.debug(
                'Error in processTable: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            return fromException(e); // RT 29SEP25 - Exception handler for pdf Service
        }
    }

    // RT 18DEC25 - Extract PFX Id from SignPad question
    // RT 05JAN26 - Moved to Recursive method to find SignPad and extract pfxId

    @TestVisible
    private static Result loadTable(
        String objectApiName,
        String filterQuery,
        List<Map<String, Object>> fieldsMetadata,
        map<string, object> fldObject,
        map<string, object> fldQuestion
    ) {
        try {
            list<map<string, object>> tableRecordList = new List<map<string, object>>();
            Map<String, Object> params = new Map<String, Object>();
            params.put('recordId', recordId);

            string query = CustomUtility.stringInject(filterQuery, params);

            String responseJson = JSON.serialize(
                RCustomLookupController.queryRecords(
                    '',
                    objectApiName,
                    JSON.serialize(fieldsMetadata),
                    query,
                    false
                )
            );

            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(
                responseJson
            );

            List<Object> records = (List<Object>) responseMap.get('records');
            // RT 23OCT25 - Footer Map handling
            List<Object> footMap = new List<Object>();

            if (
                responseMap.containsKey('footMap') &&
                responseMap.get('footMap') != null
            ) {
                footMap = (List<Object>) responseMap.get('footMap');
            }

            for (Object obj : records) {
                // Create a new list for each record to prevent data leakage between iterations
                List<Object> fvList = new List<Object>();
                Map<String, Object> record = (Map<String, Object>) obj;
                list<object> resElement = (list<object>) record.get(
                    'filterFieldValueList'
                );

                for (Object field : resElement) {
                    map<string, object> fvItem = (map<string, object>) field;
                    string fldId = String.valueOf(
                        ((Map<String, Object>) field).get('fieldId')
                    );
                    fvItem.put('meta', fldObject.get(fldId));

                    // Create new list for each field
                    list<object> qlList = new List<object>();

                    // Make a deep copy of the question to avoid reference issues
                    map<string, object> ques = new Map<string, object>();
                    if (fldQuestion.containsKey(fldId)) {
                        // Create a deep copy of the question
                        map<string, object> originalQues = (Map<String, Object>) fldQuestion.get(
                            fldId
                        );
                        if (originalQues != null) {
                            // Copy all fields from the original question
                            for (String key : originalQues.keySet()) {
                                ques.put(key, originalQues.get(key));
                            }
                        }
                    }
                    // RT 13JAN26 - Preserve existing style object and override showLabel to false
                    Map<String, Object> style;
                    if (ques.containsKey('style') && ques.get('style') != null) {
                        Object styleObj = ques.get('style');
                        // Check if style is a JSON string or already a Map
                        if (styleObj instanceof String) {
                            // Deserialize JSON string to Map
                            String styleStr = (String) styleObj;
                            if (String.isNotBlank(styleStr)) {
                                style = (Map<String, Object>) JSON.deserializeUntyped(styleStr);
                            } else {
                                style = new Map<String, Object>();
                            }
                        } else if (styleObj instanceof Map<String, Object>) {
                            // Deep copy the existing style Map
                            Map<String, Object> originalStyle = (Map<String, Object>) styleObj;
                            style = new Map<String, Object>();
                            for (String key : originalStyle.keySet()) {
                                style.put(key, originalStyle.get(key));
                            }
                        } else {
                            // Unknown type, create new style
                            style = new Map<String, Object>();
                        }
                    } else {
                        // Create new style if it doesn't exist
                        style = new Map<String, Object>();
                    }
                    // Always set showLabel to false
                    style.put('showLabel', false);
                    ques.put('style', style);
                    ques.put('input', fvItem.get('fieldValue'));

                    // Generate unique rowId for each question
                    Long timestamp = System.currentTimeMillis();
                    Integer randomNumber = (Integer) (Math.random() * 1000);
                    String rowId = 'ques_' + timestamp + '_' + randomNumber;
                    ques.put('rowId', rowId);
                    // MA 06OCT25 - Style handling for Book element
                    if (String.valueOf(ques.get('element')) == 'Book') {
                        String qbRefStr = String.valueOf(
                            ques.get('qbReferenceQuestions')
                        );
                        if (String.isNotBlank(qbRefStr)) {
                            Map<String, Object> qbRef = (Map<String, Object>) JSON.deserializeUntyped(
                                qbRefStr
                            );
                            if (qbRef != null) {
                                Map<String, Object> queryResult = new Map<String, Object>();
                                Map<String, Object> addlFldMap = (Map<String, Object>) ((Map<String, Object>) obj)
                                    .get('addlFldMap');
                                if (addlFldMap != null) {
                                    queryResult.putAll(addlFldMap);
                                }
                                queryResult.put(
                                    String.valueOf(fvItem.get('fieldApiName')),
                                    fvItem.get('fieldValue')
                                );

                                List<Object> qbQueryResult = new List<Object>{
                                    queryResult
                                };
                                qbRef.put('qbQueryResult', qbQueryResult);
                                ques.put(
                                    'qbReferenceQuestions',
                                    JSON.serialize(qbRef)
                                );
                            }
                        }
                    } else {
                        ques.put('input', fvItem.get('fieldValue'));
                    }
                    qlList.add(ques);
                    fvItem.put('questions', qlList);
                    fvList.add(fvItem);
                }

                map<string, object> tableRecord = new Map<string, object>();
                tableRecord.put(
                    'recordId',
                    string.valueOf(((Map<String, Object>) obj).get('recordId'))
                );
                tableRecord.put('value', fvList);
                tableRecordList.add(tableRecord);
            }

            map<string, object> qb = (map<string, object>) jsonData.get(
                'questionbook'
            );
            list<object> subQuestions = (list<object>) qb.get('subQuestions');
            for (object sq : subQuestions) {
                Map<String, Object> sqMap = (Map<String, Object>) sq;
                if (
                    sqMap.containsKey('type') &&
                    String.valueOf(sqMap.get('type')) == 'Table'
                ) {
                    sqMap.put('input', tableRecordList);
                    sqMap.put('footerMap', footMap); // RT 23OCT25 - Footer Map handling
                }
            }

            return new Result(true, 'Table data processed');
        } catch (Exception e) {
            System.debug(
                'Error in loadTable: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            return fromException(e); // RT 29SEP25 - Exception handler for PDF Service
        }
    }

    // RT 02JAN25 - Dummy method for backward compatibility
    global static void generatePdf(
        Map<String, Object> questionBookData,
        String recordId
    ) {
        // Delegate to the new implementation
        generatePdf(questionBookData, recordId, null, null, false, null);
    }

    @TestVisible
    private static Result generatePdf(
        Object questionBookData,
        String recordId,
        String pfxId,
        String signerName,
        Boolean isSignPadEnabled,
        String signBase64
    ) {
        try {
            Map<String, Object> pdfjson = new Map<String, Object>();
            pdfjson.put('questionbook', questionBookData);
            List<Object> attachments = (List<Object>) jsonData.get(
                'qbQueryResult'
            );
            String typeValue = '';
            for (Object obj : attachments) {
                Map<String, Object> record = (Map<String, Object>) obj;
                typeValue = (String) record.get('Name');
                break;
            }

            // RT 25SEP25 - Added pfxId parameter to the PdfGeneratorQueueable
            // Enqueue a Queueable job to handle the callout and DML
            System.enqueueJob(
                new PdfGeneratorQueueable(
                    JSON.serialize(pdfjson),
                    recordId,
                    typeValue,
                    qbName,
                    pfxId,
                    signerName, // RT 06JAN25 - Passed signerName to Queueable
                    isSignPadEnabled, // RT 09JAN26 - Passed isSignPadEnabled to Queueable
                    signBase64 // RT 09JAN26 - Passed signBase64 to Queueable
                )
            );

            // RT 05JAN26 - Log pfxId if available
            // Return a success result immediately, as the PDF generation is asynchronous
            return new Result(
                true,
                'PDF generation queued successfully' +
                (pfxId != null ? ' with pfxId: ' + pfxId : '')
            );
        } catch (Exception e) {
            System.debug(
                'Error in generatePdf: ' +
                    e.getMessage() +
                    ' - ' +
                    e.getStackTraceString()
            );
            return fromException(e); // RT 29SEP25 - Exception handler for PDF Service
        }
    }

    // RT 05JAN26 - Recursive method to find SignPad and extract title/subTitle
    // RT 06JAN26 - Also extracts signerName from subTitle
    @TestVisible
    private static void findSignPadRecursive(
        List<Object> nodes,
        Map<String, String> result
    ) {
        if (nodes == null || !result.isEmpty()) {
            return;
        }

        for (Object obj : nodes) {
            if (obj == null) {
                continue;
            }

            Map<String, Object> q = (Map<String, Object>) obj;
            String nodeType = String.valueOf(q.get('type'));

            // ✅ FOUND SignPad - extract both title and subTitle
            if ('SignPad'.equals(nodeType)) {
                String titleValue = q.get('title') != null
                    ? String.valueOf(q.get('title'))
                    : null;
                String subTitleValue = q.get('subTitle') != null
                    ? String.valueOf(q.get('subTitle'))
                    : null;
                Boolean isSignPadEnabled = q.get('isSignPadEnabled') != null
                    ? (Boolean) q.get('isSignPadEnabled')
                    : false; // RT 09JAN26 - Check if SignPad is enabled

                // Store both values if at least one exists
                if (titleValue != null || subTitleValue != null) {
                    if (titleValue != null) {
                        result.put('pfxId', titleValue);
                    }
                    if (subTitleValue != null) {
                        result.put('signerName', subTitleValue);
                    }
                    result.put(
                        'isSignPadEnabled',
                        String.valueOf(isSignPadEnabled)
                    ); // RT 09JAN26 - Store isSignPadEnabled
                    return;
                }
            }

            // 🔁 Recursively search nested structures with early returns
            if (q.get('questions') instanceof List<Object>) {
                findSignPadRecursive((List<Object>) q.get('questions'), result);
                if (!result.isEmpty()) {
                    return;
                }
            }

            if (q.get('subQuestions') instanceof List<Object>) {
                findSignPadRecursive(
                    (List<Object>) q.get('subQuestions'),
                    result
                );
                if (!result.isEmpty()) {
                    return;
                }
            }

            Object qbRefObj = q.get('qbReferenceQuestions');
            if (
                qbRefObj instanceof String &&
                String.isNotBlank((String) qbRefObj)
            ) {
                Map<String, Object> qbRef = (Map<String, Object>) JSON.deserializeUntyped(
                    (String) qbRefObj
                );
                if (qbRef.containsKey('questionbook')) {
                    Map<String, Object> qb = (Map<String, Object>) qbRef.get(
                        'questionbook'
                    );
                    if (qb.get('subQuestions') != null) {
                        findSignPadRecursive(
                            (List<Object>) qb.get('subQuestions'),
                            result
                        );
                        if (!result.isEmpty()) {
                            return;
                        }
                    }
                }
            }
        }
    }

    private static String extractSignBase64(String recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }

        List<ContentVersion> versions = [
            SELECT VersionData, FileType
            FROM ContentVersion
            WHERE
                ContentDocument.Title LIKE '%Signature%'
                AND FirstPublishLocationId = :recordId
                AND IsLatest = TRUE
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];

        if (versions.isEmpty() || versions[0].VersionData == null) {
            return null;
        }

        // Encode the binary image data to Base64
        String base64String = EncodingUtil.base64Encode(
            versions[0].VersionData
        );

        // Clean the Base64 string - remove any whitespace or invalid characters
        if (base64String != null) {
            base64String = base64String.replaceAll('\\s+', ''); // Remove all whitespace
        }

        return base64String;
    }
}