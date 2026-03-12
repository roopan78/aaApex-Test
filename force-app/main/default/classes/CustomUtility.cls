public class CustomUtility {
  public static String stringInject(String str, Object data) {
    if (data instanceof List<Object>) {
      List<Object> dataList = (List<Object>) data;
      // Replace {0}, {1}, etc. with corresponding array element
      Pattern p = Pattern.compile('\\{(\\d)\\}');
      Matcher m = p.matcher(str);
      String result = str;
      while (m.find()) {
        Integer index = Integer.valueOf(m.group(1));
        if (index < dataList.size()) {
          result = result.replace(
            '{' + index + '}',
            String.valueOf(dataList[index])
          );
        }
      }
      return result;
    } else if (data instanceof Map<String, Object>) {
      Map<String, Object> dataMap = (Map<String, Object>) data;
      if (dataMap.isEmpty()) {
        return str;
      }

      // Replace {key} with corresponding map value
      Pattern p = Pattern.compile('\\{([^}]+)\\}');
      Matcher m = p.matcher(str);
      String result = str;
      while (m.find()) {
        String key = m.group(1);
        if (dataMap.containsKey(key)) {
          result = result.replace(
            '{' + key + '}',
            String.valueOf(dataMap.get(key))
          );
        }
      }
      return result;
    } else {
      return str;
    }
  }

  @AuraEnabled
  public static List<Map<String, Object>> nxtProcessQuestions(
    List<Map<String, Object>> qList,
    Map<String, Object> sqOps,
    List<Map<String, Object>> qbQueryResults,
    List<Map<String, Object>> refFMList
  ) {
    List<Map<String, Object>> questionList = new List<Map<String, Object>>();

    // Works out the Options
    Map<String, Object> sqOptions = new Map<String, Object>();
    for (String sq : sqOps.keySet()) {
      sqOptions.put(sq, sqOps.get(sq));
    }

    // Process the Questions
    if (qList != null) {
      for (Map<String, Object> sq : qList) {
        sq.put('readOnly', false);

        // VD 12Jun25 handle table type JSON from attachment
        if (
          (String) sq.get('type') == 'Table' &&
          (Boolean) sq.get('isReadJSONFromAttachment') == true
        ) {
          Id questionId = (Id) sq.get('id');
          // Get all JSON file attachments related to this question
          Map<String, String> attachmentMap = Utility.getFieldMetaJson(
            questionId
          );
          for (String name : attachmentMap.keySet()) {
            // RT 12DEC25 - Base64 decode only
            String decoded = EncodingUtil.base64Decode(attachmentMap.get(name)).toString();
            decoded = sanitizeJson(decoded);

            if ((String) sq.get('fieldsMeta') == name) {
              sq.put('fieldsMeta', decoded);
            } else if ((String) sq.get('qbReferenceQuestions') == name) {
              sq.put('qbReferenceQuestions', decoded);
            }
          }
        }

        // Handle dropdown or radio question types
        if (sq.get('type') == 'Dropdown' || sq.get('type') == 'Radio') {
          sq.put(
            'options',
            ((Map<String, Object>) sqOptions.get((String) sq.get('id')))
              .get('options')
          );
        }
        // Handle book question type
        else if (sq.get('type') == 'Book') {
          if (
            sq.containsKey('qbReference') &&
            sq.containsKey('qbReferenceQuestions')
          ) {
            Map<String, Object> qData = (Map<String, Object>) JSON.deserializeUntyped(
              (String) sq.get('qbReferenceQuestions')
            );
            Map<String, Object> questionbook = (Map<String, Object>) qData.get(
              'questionbook'
            );

            // FIX: Proper casting of List<Object> to List<Map<String, Object>>
            List<Object> rawSubQuestions = (List<Object>) questionbook.get(
              'subQuestions'
            );
            List<Map<String, Object>> subQuestions = new List<Map<String, Object>>();
            for (Object item : rawSubQuestions) {
              subQuestions.add((Map<String, Object>) item);
            }

            Map<String, Object> sqOpsData = (Map<String, Object>) qData.get(
              'sqOptions'
            );

            // FIX: Proper casting of List<Object> to List<Map<String, Object>>
            List<Object> rawFieldsMeta = (List<Object>) JSON.deserializeUntyped(
              (String) sq.get('fieldsMeta')
            );
            List<Map<String, Object>> fieldsMeta = new List<Map<String, Object>>();
            for (Object item : rawFieldsMeta) {
              fieldsMeta.add((Map<String, Object>) item);
            }

            sq.put(
              'questions',
              nxtProcessQuestions(
                subQuestions,
                sqOpsData,
                qbQueryResults,
                fieldsMeta
              )
            );
          }
        }

        // Clone the question object to avoid reference issues
        Map<String, Object> clonedSq = deepClone(sq);
        questionList.add(nxtGetInputValue(clonedSq, refFMList, qbQueryResults));
      }
    }

    return questionList;
  }

  private static Map<String, Object> deepClone(Map<String, Object> original) {
    String jsonStr = JSON.serialize(original);
    return (Map<String, Object>) JSON.deserializeUntyped(jsonStr);
  }

  public static Map<String, Object> nxtGetInputValue(
    Map<String, Object> qObj,
    List<Map<String, Object>> refFMList,
    List<Map<String, Object>> queryResults
  ) {
    // Check read only flag from reference
    if (refFMList != null) {
      for (Map<String, Object> rf : refFMList) {
        if (!((Boolean) qObj.get('readOnly')) && (Boolean) rf.get('readOnly')) {
          qObj.put('readOnly', true);
        }
      }
    }

    Object retValue = null;

    String qType = (String) qObj.get('type');
    String fmString = (String) qObj.get('fieldsMeta');
    String refField = (String) qObj.get('referenceField');

    if (fmString != null) {
      // FIX: Proper casting of List<Object> to List<Map<String, Object>>
      List<Object> rawFmList = (List<Object>) JSON.deserializeUntyped(fmString);
      List<Map<String, Object>> fmList = new List<Map<String, Object>>();
      for (Object item : rawFmList) {
        fmList.add((Map<String, Object>) item);
      }

      // Process the Question Input
      if (fmList != null) {
        for (Map<String, Object> fld : fmList) {
          // Check Read Only when the field is Only OUTPUT or Resultant
          if (
            !((Boolean) qObj.get('readOnly')) && (Boolean) fld.get('readOnly')
          ) {
            qObj.put('readOnly', true);
          }
        }
      }

      if (queryResults != null && !queryResults.isEmpty()) {
        Map<String, Object> queryResult = queryResults[0];

        if (qType == 'List') {
          retValue = new Map<String, Object>();
          if (fmList != null) {
            for (Map<String, Object> fld : fmList) {
              if ((Boolean) fld.get('searchflag')) {
                retValue = readFieldValue(fld, queryResult);
              }
            }
          }
        } else if (qType == 'Book') {
          retValue = new Map<String, Object>();
          for (Map<String, Object> fld : fmList) {
            retValue = readFieldValue(fld, queryResult);
          }
        } else if (qType == 'Date' && retValue == null && refField == 'TODAY') {
          retValue = Datetime.now().format('MM/dd/yyyy');
        } else {
          for (Map<String, Object> fld : fmList) {
            // Check for Fields with Output or Resultant Flag
            if (
              (Boolean) fld.get('outputFlag') ||
              (Boolean) fld.get('resultantflag')
            ) {
              retValue = readFieldValue(fld, queryResult);
            }
          }
        }
      } else {
        System.debug('No query result to set the input field');
      }
    }

    qObj.put('input', retValue);
    return qObj;
  }

  public static Object readFieldValue(
    Map<String, Object> fld,
    Map<String, Object> queryResult
  ) {
    if ((Boolean) fld.get('ischild')) {
      String childObjName = (String) fld.get('childobjname');
      String childObjFldName = (String) fld.get('childobjfldname');

      if (queryResult.containsKey(childObjName)) {
        Map<String, Object> childObj = (Map<String, Object>) queryResult.get(
          childObjName
        );
        if (childObj.containsKey(childObjFldName)) {
          return childObj.get(childObjFldName);
        }
      }
    } else {
      String apiName = (String) fld.get('apiName');
      if (queryResult.containsKey(apiName)) {
        return queryResult.get(apiName);
      } else if (apiName != null && apiName.contains('.')) {
        // RT 29JAN26 - Handle Reference Fields like Account.Name
        List<String> parts = apiName.split('\\.');
        String parentObj = parts[0];
        String fieldName = parts[1];
        if (queryResult.containsKey(parentObj)) {
          Object parentObjValue = queryResult.get(parentObj);
          if (parentObjValue instanceof Map<String, Object>) {
            Map<String, Object> parentObjMap = (Map<String, Object>) parentObjValue;
            if (parentObjMap.containsKey(fieldName)) {
              return parentObjMap.get(fieldName);
            }
          }
        }
      }
    }

    return null;
  }

  public static Boolean skipQuestion(
    Map<String, Object> dMeta,
    Map<String, Object> answer
  ) {
    try {
      Object val;
      List<String> ops = new List<String>();

      if (answer.containsKey('ansValue') && answer.get('ansValue') != null) {
        String answerType = (String) answer.get('typ');

        if (answerType == 'Checkbox') {
          ops = new List<String>{ 'IN' };
          // Handle Array Answers
        } else if (answerType == 'Book') {
          ops = new List<String>{ 'EQ', 'GT', 'LT', 'NE' };
          // Handle Book Answer
        } else if (answerType == 'List') {
          ops = new List<String>{ 'EQ', 'NE' };
          // Handle List
          // FIX: Proper casting for collection types
          Map<String, Object> ansValue = (Map<String, Object>) answer.get(
            'ansValue'
          );
          List<Object> arrItems = (List<Object>) ansValue.get('arrItems');
          Map<String, Object> firstItem = (Map<String, Object>) arrItems[0];
          Map<String, Object> value = (Map<String, Object>) firstItem.get(
            'value'
          );
          Map<String, Object> addlFldMap = (Map<String, Object>) value.get(
            'addlFldMap'
          );
          val = addlFldMap.get((String) dMeta.get('valueField'));
        } else {
          ops = new List<String>{ 'EQ', 'NE' };
          val = answer.get('ansValue');
        }

        Map<Integer, Boolean> logicMap = new Map<Integer, Boolean>();

        // Logic Processing
        if (dMeta.containsKey('logics')) {
          // FIX: Proper casting of List<Object> to List<Map<String, Object>>
          List<Object> rawLogics = (List<Object>) dMeta.get('logics');
          List<Map<String, Object>> logics = new List<Map<String, Object>>();
          for (Object item : rawLogics) {
            logics.add((Map<String, Object>) item);
          }

          for (Map<String, Object> logic : logics) {
            System.debug(logic);
            Integer order = (Integer) logic.get('order');
            String operation = (String) logic.get('operation');
            Object logicValue = logic.get('value');

            System.debug(
              'Logic ' +
                order +
                ' for ' +
                val +
                ' ' +
                operation +
                ' ' +
                logicValue
            );

            if (operation == 'EQ' && val == logicValue) {
              logicMap.put(order, true);
            } else if (operation == 'GT') {
              // FIX: Safer handling of numeric comparisons
              Decimal valDecimal = val instanceof Decimal
                ? (Decimal) val
                : Decimal.valueOf(String.valueOf(val));
              Decimal logicDecimal = logicValue instanceof Decimal
                ? (Decimal) logicValue
                : Decimal.valueOf(String.valueOf(logicValue));
              logicMap.put(order, valDecimal > logicDecimal);
            } else if (operation == 'LT') {
              // FIX: Safer handling of numeric comparisons
              Decimal valDecimal = val instanceof Decimal
                ? (Decimal) val
                : Decimal.valueOf(String.valueOf(val));
              Decimal logicDecimal = logicValue instanceof Decimal
                ? (Decimal) logicValue
                : Decimal.valueOf(String.valueOf(logicValue));
              logicMap.put(order, valDecimal < logicDecimal);
            } else if (operation == 'NE' && val != logicValue) {
              logicMap.put(order, true);
            } else {
              logicMap.put(order, false);
            }

            System.debug(logicMap);
          }
        }

        return logicMap.get(1);
      }
    } catch (Exception e) {
      System.debug('Error in skipQuestion: ' + e.getMessage());
    }

    return false;
  }

  public static Boolean isValidJSON(String text) {
    try {
      JSON.deserializeUntyped(text);
      return true;
    } catch (Exception e) {
      return false;
    }
  }

  // RT 12DEC25 - Sanitize JSON string to handle invalid characters
  private static String sanitizeJson(String input) {
    if (String.isBlank(input)) { return input; }

    input = input.replaceAll('\\\\(?![\\\\/"bfnrtu])', '\\\\\\\\');
    input = input.replaceAll('%(?![0-9A-Fa-f]{2})', '%25');

    return input;
  }
}