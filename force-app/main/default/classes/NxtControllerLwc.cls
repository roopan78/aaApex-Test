global with sharing class NxtControllerLwc {
    global static String nxtAppVersion { get {return '1.0.6'; } set; }
 
    //@remoteAction
    @AuraEnabled(cacheable=true)
    global static String process(String dataType, String operation, String param1) {
        String responseJSON = '';
 
        String className = '';        
        if(dataType == 'Question') {
            className = 'QuestionHandler';
        } else if(dataType == 'QuestionBook') {
            className = 'QuestionBookHandler';
        } else if(dataType == 'Answer') {
            className = 'AnswerHandler';
        } else if(dataType == 'AnswerBook') {
            className = 'AnswerBookHandler';
        } else if(dataType == 'Attachment') {
            className = 'AttachmentHandler';
        } //getting answer count  
          else if(dataType == 'answerCount') {
            AnswerHandler ah = new AnswerHandler();
            return ah.getAnswerCount(param1);
        }
 
        Type controller = Type.forName(className);
        DataHandler reader = (DataHandler)controller.newInstance();
 
        if(operation.equalsIgnoreCase('list')) {
            responseJSON = reader.getRecords();
        } else if(operation.equalsIgnoreCase('read')) {
            responseJSON = reader.readRecords(param1, 'en'); //  //VD -27-dec-24 languageCode changes
        } else if(operation.equalsIgnoreCase('create')) {
            responseJSON = reader.createRecords(param1);
        } else if(operation.equalsIgnoreCase('update')) {
            responseJSON = reader.updateRecords(param1);                
        } else if(operation.equalsIgnoreCase('delete')) {
            responseJSON = reader.deleteRecords(param1);
        }
 
        return responseJSON.replaceAll('RNXT__','');
    }
}