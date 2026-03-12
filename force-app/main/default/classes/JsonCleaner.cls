/** 
 * @description : Clean JSON data by removing unnecessary escape characters.
 * @date        : 2025-02-20
 * @author      : Gomathy V
 * @lastModified: 2025-02-27
 * **/
public with sharing class JsonCleaner {
    //GV = 2025-02-20 : Clean JSON data by removing unnecessary escape characters.
    public static String cleanJson(String jsonString) {
        if (String.isBlank(jsonString)) {
            return jsonString;
        }
        try {
            Map<String, Object> jsonData = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
            if (jsonData == null) {
                return jsonString;
            }
            
            if (jsonData.containsKey('questionbook') && jsonData.get('questionbook') != null) {
                Map<String, Object> questionBook = (Map<String, Object>) jsonData.get('questionbook');
                cleanQuestionBookData(questionBook);
            }
            
            return JSON.serialize(jsonData);
        } catch (Exception e) {
            throw new AuraHandledException('Error cleaning JSON: ' + e.getMessage());
        }
    }
    
    private static void cleanQuestionBookData(Map<String, Object> questionBook) {
        if (questionBook == null){
            return;
        } 
        if (questionBook.containsKey('style')) {
            cleanStyleField(questionBook);
        }
        
        if (questionBook.containsKey('subQuestions') && questionBook.get('subQuestions') != null) {
            List<Object> questionsData = (List<Object>) questionBook.get('subQuestions');
            if (questionsData != null) {
                for (Object qObj : questionsData) {
                    if (qObj instanceof Map<String, Object>) {
                        cleanQuestionData((Map<String, Object>) qObj);
                    }
                }
            }
        }
    }
    
    private static void cleanQuestionData(Map<String, Object> question) {
        if (question == null) {
            return;
        }       
        cleanStyleField(question);
        
        if (question.containsKey('fieldsMeta')) {
            cleanFieldMetaWithStyle(question);
        }
        
        if (question.containsKey('qbReferenceQuestions') && question.get('qbReferenceQuestions') != null) {
            cleanQbReferenceQuestions(question);
        }
    }
    
    private static void cleanStyleField(Map<String, Object> data) {
        if (data.containsKey('style') && data.get('style') != null) {
            String styleStr = String.valueOf(data.get('style')).trim();
            if (String.isNotBlank(styleStr) && !styleStr.startsWith('{')) {
                styleStr = '{' + styleStr + '}';
                data.put('style', styleStr);
            }
        }
    }
    
    private static void cleanFieldMetaWithStyle(Map<String, Object> question) {
        Object fieldMetaObj = question.get('fieldsMeta');
        if (fieldMetaObj == null) {
            return;
        }
        
        List<Object> fieldMetaData = convertToList(fieldMetaObj);
        if (fieldMetaData == null || fieldMetaData.isEmpty()) {
            return;
        }
        
        List<Map<String, Object>> cleanedFieldMeta = new List<Map<String, Object>>();
        for (Object fm : fieldMetaData) {
            if (fm instanceof Map<String, Object>) {
                Map<String, Object> fieldMeta = (Map<String, Object>) fm;
                cleanStyleField(fieldMeta); 
                cleanedFieldMeta.add(fieldMeta);
            }
        }
        
        if (!cleanedFieldMeta.isEmpty()) {
            question.put('fieldsMeta', cleanedFieldMeta);
        }
    }
    
    private static void cleanQbReferenceQuestions(Map<String, Object> question) {
        Object qbRefObj = question.get('qbReferenceQuestions');
        if (qbRefObj == null) return;
        
        if (qbRefObj instanceof String) {
            String qbRefStr = String.valueOf(qbRefObj).trim();
            if (String.isNotBlank(qbRefStr)) {
                try {
                    // Try to parse if it's a JSON string
                    if (qbRefStr.startsWith('[') || qbRefStr.startsWith('{')) {
                        Object parsedObj = JSON.deserializeUntyped(qbRefStr);
                        if (parsedObj instanceof List<Object>) {
                            List<Object> qbRefList = (List<Object>) parsedObj;
                            cleanQbRefList(qbRefList);
                            question.put('qbReferenceQuestions', qbRefList);
                        } else if (parsedObj instanceof Map<String, Object>) {
                            Map<String, Object> qbRefMap = (Map<String, Object>) parsedObj;
                            cleanQuestionData(qbRefMap);
                            question.put('qbReferenceQuestions', qbRefMap);
                        }
                    }
                } catch (Exception e) {
                    throw new AuraHandledException('Error cleaning qbReferenceQuestions: ' + e.getMessage());
                }
            }
        } else if (qbRefObj instanceof List<Object>) {
            List<Object> qbRefList = (List<Object>) qbRefObj;
            cleanQbRefList(qbRefList);
        } else if (qbRefObj instanceof Map<String, Object>) {
            Map<String, Object> qbRefMap = (Map<String, Object>) qbRefObj;
            cleanQuestionData(qbRefMap);
        }
    }
    
    private static void cleanQbRefList(List<Object> qbRefList) {
        if (qbRefList == null || qbRefList.isEmpty()) {
            return;
        }
        
        for (Integer i = 0; i < qbRefList.size(); i++) {
            if (qbRefList[i] instanceof Map<String, Object>) {
                cleanQuestionData((Map<String, Object>) qbRefList[i]);
            }
        }
    }
    
    private static List<Object> convertToList(Object obj) {
        if (obj instanceof String) {
            String str = String.valueOf(obj).trim();
            if (String.isNotBlank(str) && str.startsWith('[')) {
                try {
                    return (List<Object>) JSON.deserializeUntyped(str);
                } catch (Exception e) {
                  return null;
                }
            }
        } else if (obj instanceof List<Object>) {
            return (List<Object>) obj;
        }
        return null;
    }
}