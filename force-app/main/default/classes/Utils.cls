// VD 10-Oct25 utility global class to get session ID changes
global with sharing class Utils {
    // global static String getSessionIdFromVFPage(PageReference visualforcePage) {
    //     String content = visualforcePage.getContent().toString();
    //     Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
    //     Integer e = content.indexOf('End_Of_Session_Id');
    //     return content.substring(s, e).trim();
    // }
global static String getSessionIdFromVFPage(PageReference visualforcePage) {
    String content = visualforcePage.getContent().toString();
    return extractSessionId(content);
}

// Core parsing logic extracted and marked TestVisible
@TestVisible
private static String extractSessionId(String content) {
    Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
    Integer e = content.indexOf('End_Of_Session_Id');
    return content.substring(s, e).trim();
}
}