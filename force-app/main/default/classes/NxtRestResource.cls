@RestResource(urlMapping='/Nxt/*')
global with sharing class NxtRestResource {
    global static String dataType = '';
    global static String className = '';
    global static String operation = 'list';
    global static String paramId = '';
    global static String responseJSON = '';

@HttpGet
    global static String process() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
		 System.debug('Authentication' + res);

        String dataType = req.params.get('dataType');
        String operation = req.params.get('operation');
        String param1 = req.params.get('param1');

        String responseJSON = '';
        String className = '';

        if (dataType == 'Booklet') {
            className = 'BookletHandler';
        } else if (dataType == 'Question') {
            className = 'QuestionHandler';
        } else if (dataType == 'QuestionBook') {
            className = 'QuestionBookHandler';
        } else if (dataType == 'Answer') {
            className = 'AnswerHandler';
        } else if (dataType == 'AnswerBook') {
            className = 'AnswerBookHandler';
        } else if (dataType == 'Attachment') {
            className = 'AttachmentHandler';
        } else if (dataType == 'answerCount') {		
            AnswerHandler ah = new AnswerHandler();
            return ah.getAnswerCount(param1);
        }

        Type controller = Type.forName(className);
        DataHandler reader = (DataHandler)controller.newInstance();

        if (operation.equalsIgnoreCase('list')) {
              // Set authorization header
            responseJSON = reader.getRecords();
        } else if (operation.equalsIgnoreCase('read')) {
            responseJSON = reader.readRecords(param1,'');
        } else if (operation.equalsIgnoreCase('create')) {
            responseJSON = reader.createRecords(param1);
        } else if (operation.equalsIgnoreCase('update')) {
            responseJSON = reader.updateRecords(param1);
        } else if (operation.equalsIgnoreCase('delete')) {
            responseJSON = reader.deleteRecords(param1);
        }
		System.debug('responseJSON' + responseJSON);
        return responseJSON.replaceAll('RNXT__', '');
    }


    


/*
    @HttpGet
    global static String getProcess() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String reqURI = req.requestURI.split('/Nxt/')[1];
        handleURI('get', reqURI);

        Type controller = Type.forName(className);
        DataHandler reader = (DataHandler)controller.newInstance();

        if(operation.equalsIgnoreCase('list')) {
            responseJSON = reader.getRecords();
        } else if(operation.equalsIgnoreCase('read')) {
            responseJSON = reader.readRecords(paramId);
        }

        return responseJSON;
    }
*/
/*    
    @HttpPost
    global static String postProcess() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String reqURI = req.requestURI.split('/Nxt/')[1];
        handleURI('post', reqURI);
        
        Type controller = Type.forName(className);
        DataHandler reader = (DataHandler)controller.newInstance();
        
		if(operation.equalsIgnoreCase('create')) {
        //    responseJSON = reader.createRecords(req.requestBody);
        } 
		//else if(operation.equalsIgnoreCase('update')) {
        //    responseJSON = reader.updateRecords(param1);                
        //} else if(operation.equalsIgnoreCase('delete')) {
        //    responseJSON = reader.deleteRecords(param1);
        //}
        
        return responseJSON;
    }
*/

/*
    static void handleURI(String method, String URL) {
        List<String> uriList = URL.split('/');
		
        dataType = uriList[0];

        if(method == 'get') {
            operation = 'list';
            if(uriList.size() == 2) {
                operation = 'read';
                paramId = uriList[1];
            }
        } else if(method == 'post') {
            operation = 'create';
        }

        if(dataType == 'Question') {
            className = 'QuestionHandler';
        } else if(dataType == 'QuestionBook') {
            className = 'QuestionBookHandler';
        } else if(dataType == 'Answer') {
            className = 'AnswerHandler';
        }
    }
*/
}