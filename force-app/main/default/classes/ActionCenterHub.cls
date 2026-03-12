/**
 * @description Support class to convert field API names into record data and handle Chatter posts.
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version - field to data conversion
 * 2.0        02/01/2026    Roopan Thangam A       Added mention handling and feed item posting
 * 3.0        22/01/2026    Roopan Thangam A       Code optimised
 */
public with sharing class ActionCenterHub {

    private static final String MENTION_PATTERN_STRING = '@\\{(.*?)\\}';
    private static final String PLACEHOLDER_PATTERN_STRING = '\\{(.*?)\\}';
    private static final Pattern MENTION_PATTERN = Pattern.compile(MENTION_PATTERN_STRING);
    private static final Pattern PLACEHOLDER_PATTERN = Pattern.compile(PLACEHOLDER_PATTERN_STRING);

    /**
     * @description Merges template placeholders with actual record field values
     * @param template The template string with placeholders
     * @param record The SObject record containing field values
     * @return Merged template string
     */
    public static String mergeTemplate(String template, SObject record) {
        if (String.isBlank(template) || record == null) {
            return template;
        }

        List<String> placeholders = extractPlaceholders(template);

        for (String placeholder : placeholders) {
            String fieldValue = parseField(record, placeholder);
            template = template.replace('{' + placeholder + '}', fieldValue);
        }

        return template;
    }

    /**
     * @description Builds a Chatter post with mention support
     * @param recordId The record ID to post to
     * @param postBody The post body template
     * @param recordContext The SObject record for field resolution
     * @return ConnectApi.FeedItemInput for posting
     */
    public static ConnectApi.FeedItemInput buildChatterPost(Id recordId, String postBody, SObject recordContext) {
        if (recordId == null || String.isBlank(postBody) || recordContext == null) {
            return null;
        }

        postBody = preserveAndMergeMentions(postBody, recordContext);

        ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
        input.feedElementType = ConnectApi.FeedElementType.FeedItem;
        input.subjectId = recordId;
        input.body = buildMessageBody(postBody, recordContext);

        return input;
    }

    /**
     * @description Posts multiple Chatter feed items
     * @param feedInputs List of feed items to post
     */
    public static void postChatterPosts(List<ConnectApi.FeedItemInput> feedInputs) {
        if (feedInputs == null || feedInputs.isEmpty()) {
            return;
        }

        for (ConnectApi.FeedItemInput input : feedInputs) {
            postSingleFeedItem(input);
        }
    }

    /**
     * @description Parses nested field paths from an SObject
     * @param obj The SObject to parse
     * @param fieldPath The dot-notation field path
     * @return String value of the field
     */
    public static String parseField(SObject obj, String fieldPath) {
        if (obj == null || String.isBlank(fieldPath)) {
            return '';
        }

        if (!fieldPath.contains('.')) {
            return getSimpleFieldValue(obj, fieldPath);
        }

        return parseNestedField(obj, fieldPath);
    }

    private static String preserveAndMergeMentions(String postBody, SObject recordContext) {
        Map<String, String> mentionTokenMap = new Map<String, String>();
        Integer tokenCounter = 0;

        Matcher mentionMatcher = MENTION_PATTERN.matcher(postBody);

        while (mentionMatcher.find()) {
            String fullToken = mentionMatcher.group(0);
            String tempKey = '##MENTION_' + tokenCounter + '##';
            mentionTokenMap.put(tempKey, fullToken);
            postBody = postBody.replace(fullToken, tempKey);
            tokenCounter++;
        }

        postBody = mergeTemplate(postBody, recordContext);

        for (String key : mentionTokenMap.keySet()) {
            postBody = postBody.replace(key, mentionTokenMap.get(key));
        }

        return postBody;
    }

    private static ConnectApi.MessageBodyInput buildMessageBody(String postBody, SObject recordContext) {
        ConnectApi.MessageBodyInput body = new ConnectApi.MessageBodyInput();
        body.messageSegments = new List<ConnectApi.MessageSegmentInput>();

        Matcher matcher = MENTION_PATTERN.matcher(postBody);
        Integer lastIndex = 0;

        while (matcher.find()) {
            addTextSegmentIfNeeded(body, postBody, lastIndex, matcher.start());
            addMentionOrFallbackSegment(body, matcher.group(1), recordContext);
            lastIndex = matcher.end();
        }

        addTrailingTextSegment(body, postBody, lastIndex);

        return body;
    }

    private static void addTextSegmentIfNeeded(ConnectApi.MessageBodyInput body, String postBody, Integer startIdx, Integer endIdx) {
        if (endIdx > startIdx) {
            ConnectApi.TextSegmentInput textSeg = new ConnectApi.TextSegmentInput();
            textSeg.text = postBody.substring(startIdx, endIdx);
            body.messageSegments.add(textSeg);
        }
    }

    private static void addMentionOrFallbackSegment(ConnectApi.MessageBodyInput body, String fieldApiName, SObject recordContext) {
        Object fieldValue = recordContext.get(fieldApiName);

        if (fieldValue != null && fieldValue instanceof Id) {
            ConnectApi.MentionSegmentInput mention = new ConnectApi.MentionSegmentInput();
            mention.id = (Id) fieldValue;
            body.messageSegments.add(mention);
        } else {
            ConnectApi.TextSegmentInput fallback = new ConnectApi.TextSegmentInput();
            fallback.text = '@{' + fieldApiName + '}';
            body.messageSegments.add(fallback);
        }
    }

    private static void addTrailingTextSegment(ConnectApi.MessageBodyInput body, String postBody, Integer lastIndex) {
        if (lastIndex < postBody.length()) {
            ConnectApi.TextSegmentInput tail = new ConnectApi.TextSegmentInput();
            tail.text = postBody.substring(lastIndex);
            body.messageSegments.add(tail);
        }
    }

    private static void postSingleFeedItem(ConnectApi.FeedItemInput input) {
        try {
            ConnectApi.ChatterFeeds.postFeedElement(null, input);
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Chatter post failed: ' + e.getMessage());
        }
    }

    private static List<String> extractPlaceholders(String template) {
        List<String> placeholderList = new List<String>();
        Set<String> seenPlaceholders = new Set<String>();
        Matcher matcher = PLACEHOLDER_PATTERN.matcher(template);

        while (matcher.find()) {
            String fieldPath = matcher.group(1);
            if (!seenPlaceholders.contains(fieldPath)) {
                seenPlaceholders.add(fieldPath);
                placeholderList.add(fieldPath);
            }
        }
        return placeholderList;
    }

    private static String getSimpleFieldValue(SObject obj, String fieldPath) {
        Object fieldValue = obj.get(fieldPath);
        return fieldValue != null ? String.valueOf(fieldValue) : '';
    }

    private static String parseNestedField(SObject obj, String fieldPath) {
        List<String> parts = fieldPath.split('\\.');
        String parentField = parts[0];
        String remainingPath = buildRemainingPath(parts);

        SObject parentObj = obj.getSObject(parentField);
        return parentObj != null ? parseField(parentObj, remainingPath) : '';
    }

    private static String buildRemainingPath(List<String> parts) {
        List<String> remainingParts = new List<String>();
        for (Integer i = 1; i < parts.size(); i++) {
            remainingParts.add(parts[i]);
        }
        return String.join(remainingParts, '.');
    }
}