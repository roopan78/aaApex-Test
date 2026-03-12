/**
 * @description Utility class for evaluating custom logic conditions with AND/OR operators.
 *              Supports expressions like (1 AND 2) OR (3 AND 4).
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version - condition evaluation
 * 2.0        22/01/2026    Roopan Thangam A       RT 22JAN26 - Added valuesEqual method for equality checks and Code optimised
 */
public with sharing class ConditionControlHandler {

    private static final String OP_EQUALS = 'Equals';
    private static final String OP_NOT_EQUALS = 'Not Equals';
    private static final String OP_GREATER_THAN = 'Greater Than';
    private static final String OP_LESS_THAN = 'Less Than';
    private static final String OP_GREATER_EQUALS = 'Greater Than or Equals';
    private static final String OP_LESS_EQUALS = 'Less Than or Equals';
    private static final String LOGICAL_AND = 'AND';
    private static final String LOGICAL_OR = 'OR';
    private static final String BOOL_TRUE = 'true';
    private static final String BOOL_FALSE = 'false';

    /**
     * @description Evaluates conditions for an approval process
     * @param record The SObject record to evaluate
     * @param conditions List of Field_Meta__c conditions
     * @return Boolean result of condition evaluation
     */
    public static Boolean evaluateConditions(SObject record, List<Field_Meta__c> conditions) {
        if (conditions == null || conditions.isEmpty()) {
            return false;
        }

        String logicalExpression = buildLogicalExpression(conditions, record);
        return evaluateBooleanExpression(logicalExpression);
    }

    /**
     * @description Evaluates a single condition for a record
     * @param record The SObject record
     * @param condition The Field_Meta__c condition
     * @return Boolean result
     */
    public static Boolean evaluateSingleCondition(SObject record, Field_Meta__c condition) {
        Object fieldValue = record.get(condition.api_name__c);
        if (fieldValue == null) {
            return false;
        }

        return compareValues(fieldValue, condition.filterValue__c, condition.Condition__c);
    }

    /**
     * @description Checks if a filter value equals a field value (type-aware equality check)
     * @param filterValue The filter/expected value as string
     * @param fieldValue The actual field value from record
     * @return Boolean true if values are equal
     */
    public static Boolean valuesEqual(String filterValue, Object fieldValue) {
        if (filterValue == null && fieldValue == null) {
            return true;
        }
        if (filterValue == null || fieldValue == null) {
            return false;
        }

        if (fieldValue instanceof Boolean) {
            return compareBooleanValues((Boolean) fieldValue, filterValue, OP_EQUALS);
        }
        if (fieldValue instanceof Decimal || fieldValue instanceof Integer || fieldValue instanceof Long || fieldValue instanceof Double) {
            return compareDecimalValues(Decimal.valueOf(String.valueOf(fieldValue)), filterValue, OP_EQUALS);
        }
        if (fieldValue instanceof Date) {
            return compareDateValues((Date) fieldValue, filterValue, OP_EQUALS);
        }
        if (fieldValue instanceof DateTime) {
            return compareDateTimeValues((DateTime) fieldValue, filterValue, OP_EQUALS);
        }
        return filterValue.equals(String.valueOf(fieldValue));
    }

    /**
     * @description Compares field value and target value based on condition type
     * @param fieldValue The field value from the record
     * @param targetValue The target value to compare against
     * @param operator The comparison operator
     * @return Boolean comparison result
     */
    public static Boolean compareValues(Object fieldValue, String targetValue, String operator) {
        if (fieldValue == null || targetValue == null) {
            return false;
        }

        if (fieldValue instanceof String) {
            return compareStringValues(String.valueOf(fieldValue), targetValue, operator);
        }
        if (fieldValue instanceof Decimal) {
            return compareDecimalValues(Decimal.valueOf(String.valueOf(fieldValue)), targetValue, operator);
        }
        if (fieldValue instanceof Date) {
            return compareDateValues((Date) fieldValue, targetValue, operator);
        }
        if (fieldValue instanceof DateTime) {
            return compareDateTimeValues((DateTime) fieldValue, targetValue, operator);
        }
        if (fieldValue instanceof Boolean) {
            return compareBooleanValues((Boolean) fieldValue, targetValue, operator);
        }

        return false;
    }

    /**
     * @description Compares String values
     */
    public static Boolean compareStringValues(String fieldValue, String targetValue, String operator) {
        if (operator == OP_EQUALS) {
            return fieldValue == targetValue;
        }
        if (operator == OP_NOT_EQUALS) {
            return fieldValue != targetValue;
        }
        return false;
    }

    /**
     * @description Compares Decimal values
     */
    public static Boolean compareDecimalValues(Decimal fieldValue, String targetValue, String operator) {
        Decimal targetDecimal = Decimal.valueOf(targetValue);

        if (operator == OP_EQUALS) {
            return fieldValue == targetDecimal;
        }
        if (operator == OP_NOT_EQUALS) {
            return fieldValue != targetDecimal;
        }
        if (operator == OP_GREATER_THAN) {
            return fieldValue > targetDecimal;
        }
        if (operator == OP_LESS_THAN) {
            return fieldValue < targetDecimal;
        }
        if (operator == OP_GREATER_EQUALS) {
            return fieldValue >= targetDecimal;
        }
        if (operator == OP_LESS_EQUALS) {
            return fieldValue <= targetDecimal;
        }
        return false;
    }

    /**
     * @description Compares Date values
     */
    public static Boolean compareDateValues(Date fieldValue, String targetValue, String operator) {
        Date targetDate = Date.valueOf(targetValue);

        if (operator == OP_EQUALS) {
            return fieldValue == targetDate;
        }
        if (operator == OP_NOT_EQUALS) {
            return fieldValue != targetDate;
        }
        if (operator == OP_GREATER_THAN) {
            return fieldValue > targetDate;
        }
        if (operator == OP_LESS_THAN) {
            return fieldValue < targetDate;
        }
        if (operator == OP_GREATER_EQUALS) {
            return fieldValue >= targetDate;
        }
        if (operator == OP_LESS_EQUALS) {
            return fieldValue <= targetDate;
        }
        return false;
    }

    /**
     * @description Compares DateTime values
     */
    public static Boolean compareDateTimeValues(DateTime fieldValue, String targetValue, String operator) {
        DateTime targetDateTime = DateTime.valueOf(targetValue);

        if (operator == OP_EQUALS) {
            return fieldValue == targetDateTime;
        }
        if (operator == OP_NOT_EQUALS) {
            return fieldValue != targetDateTime;
        }
        if (operator == OP_GREATER_THAN) {
            return fieldValue > targetDateTime;
        }
        if (operator == OP_LESS_THAN) {
            return fieldValue < targetDateTime;
        }
        if (operator == OP_GREATER_EQUALS) {
            return fieldValue >= targetDateTime;
        }
        if (operator == OP_LESS_EQUALS) {
            return fieldValue <= targetDateTime;
        }
        return false;
    }

    /**
     * @description Compares Boolean values
     */
    public static Boolean compareBooleanValues(Boolean fieldValue, String targetValue, String operator) {
        String normalizedTarget = targetValue.trim().toLowerCase();
        Boolean targetBoolean;

        if (normalizedTarget == BOOL_TRUE) {
            targetBoolean = true;
        } else if (normalizedTarget == BOOL_FALSE) {
            targetBoolean = false;
        } else {
            return false;
        }

        if (operator == OP_EQUALS) {
            return fieldValue == targetBoolean;
        }
        if (operator == OP_NOT_EQUALS) {
            return fieldValue != targetBoolean;
        }
        return false;
    }

    /**
     * @description Evaluates a boolean expression string
     */
    public static Boolean evaluateBooleanExpression(String expression) {
        try {
            expression = expression.replaceAll(LOGICAL_AND, '&&').replaceAll(LOGICAL_OR, '||');
            expression = evaluateParentheses(expression);
            List<String> tokens = expression.split(' ');
            return evaluateTokens(tokens);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error evaluating expression: ' + e.getMessage());
            return false;
        }
    }

    private static String buildLogicalExpression(List<Field_Meta__c> conditions, SObject record) {
        if (conditions.isEmpty()) {
            return '';
        }

        List<String> expressionTokens = new List<String>();
        Boolean lastOperatorWasOr = false;

        for (Integer i = 0; i < conditions.size(); i++) {
            String conditionResult = String.valueOf(evaluateSingleCondition(record, conditions[i]));
            String operator = getLogicalOperator(conditions, i);

            if (i == 0) {
                expressionTokens.add(conditionResult);
            } else {
                handleOperatorPrecedence(expressionTokens, operator, lastOperatorWasOr);
                expressionTokens.add(operator);
                expressionTokens.add(conditionResult);
            }

            lastOperatorWasOr = (operator == LOGICAL_OR);
        }

        return String.join(expressionTokens, ' ');
    }

    private static String getLogicalOperator(List<Field_Meta__c> conditions, Integer index) {
        if (index > 0 && String.isNotBlank(conditions[index - 1].Logical_Criteria__c)) {
            return conditions[index - 1].Logical_Criteria__c;
        }
        return LOGICAL_AND;
    }

    private static void handleOperatorPrecedence(List<String> expressionTokens, String operator, Boolean lastOperatorWasOr) {
        if (operator == LOGICAL_AND && lastOperatorWasOr && !expressionTokens.isEmpty()) {
            String lastExpression = expressionTokens.remove(expressionTokens.size() - 1);
            expressionTokens.add('(' + lastExpression + ')');
        }
    }

    private static String evaluateParentheses(String expression) {
        while (expression.contains('(')) {
            Integer startIdx = expression.lastIndexOf('(');
            Integer endIdx = expression.indexOf(')', startIdx);

            if (startIdx == -1 || endIdx == -1) {
                return expression;
            }

            String subExpression = expression.substring(startIdx + 1, endIdx);
            Boolean subResult = evaluateBooleanExpression(subExpression);
            expression = expression.substring(0, startIdx) + subResult + expression.substring(endIdx + 1);
        }
        return expression;
    }

    private static Boolean evaluateTokens(List<String> tokens) {
        List<String> processedTokens = processAndOperators(tokens);
        return processOrOperators(processedTokens);
    }

    private static List<String> processAndOperators(List<String> tokens) {
        List<String> processedTokens = new List<String>();

        for (Integer i = 0; i < tokens.size(); i++) {
            if (tokens[i] == '&&') {
                Boolean left = Boolean.valueOf(processedTokens.remove(processedTokens.size() - 1));
                Boolean right = Boolean.valueOf(tokens[i + 1]);
                processedTokens.add(String.valueOf(left && right));
                i++;
            } else {
                processedTokens.add(tokens[i]);
            }
        }

        return processedTokens;
    }

    private static Boolean processOrOperators(List<String> processedTokens) {
        Boolean result = Boolean.valueOf(processedTokens[0]);

        for (Integer i = 1; i < processedTokens.size(); i += 2) {
            if (processedTokens[i] == '||') {
                result = result || Boolean.valueOf(processedTokens[i + 1]);
            }
        }

        return result;
    }
}