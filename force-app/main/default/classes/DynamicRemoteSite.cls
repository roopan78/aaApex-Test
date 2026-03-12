public without sharing  class DynamicRemoteSite {
  // @AuraEnabled
  // public static string createRemoteSite(string url , string name) {  
    
  //  JSONGenerator jsonGen = JSON.createGenerator(true);
  ////  jsonGen.writeStartObject();
  ////  List<object> result = new List<object>();
  //  try{
  ////     string  externalUrl = url;
  //     string  remoteSiteName = name;
  //  MetadataService.MetadataPort service = createService();
  //  MetadataService.RemoteSiteSetting remoteSiteSettings = new MetadataService.RemoteSiteSetting();
  //  remoteSiteSettings.fullName = remoteSiteName;
  //  remoteSiteSettings.url = externalUrl;
  //  remoteSiteSettings.isActive=true;
  //  remoteSiteSettings.disableProtocolSecurity=false;
  //  MetadataService.AsyncResult[] results = service.create(new List<MetadataService.Metadata> { remoteSiteSettings });
  //  MetadataService.AsyncResult[] checkResults = service.checkStatus(new List<string> {string.ValueOf(results[0].Id)});
  //  system.debug('result of remote site' + checkResults );

  //  result.add(checkResults);
   // system.debug('result' + result );
   
  // }catch(exception e){

   //// System.debug('Inside the exception section '+e.getMessage());

   // }

  //  jsonGen.writeObjectField('result', result);
   // jsonGen.writeEndObject();
   // return jsonGen.getAsString();

// }
	//@AuraEnabled
	//public static MetadataService.MetadataPort createService(){
    //    system.debug('inside service -->' );
    //    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
     //       service.SessionHeader = new MetadataService.SessionHeader_element();
     ////       service.SessionHeader.sessionId = UserInfo.getSessionId();
     //       system.debug('sessionId -->'+ UserInfo.getSessionId());
      //      system.debug('service -->'+ service);
     //        return service;
       
   // }
}