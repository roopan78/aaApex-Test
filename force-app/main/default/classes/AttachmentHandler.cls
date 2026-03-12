public with sharing class AttachmentHandler implements DataHandler {
  @testvisible
  private String abId = '';

  public AttachmentHandler() {
    this.abId = '';
  }
  public static final Set<String> ALLOWED_FILE_EXTENSIONS = new Set<String>{
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'heic',
    'heif'
  };
  public static final Set<String> ALLOWED_FILE_TYPES = new Set<String>{
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/heic',
    'image/heic-sequence',
    'image/heif',
    'image/heif-sequence'
  };

  // MR 22OCT23 - SetContext Changes
  public void setContext(String field, Object value) {
    if (field == 'abId') {
      this.abId = (String) value;
    }
  }

  // List the records
  public String getRecords() {
    return '{"status":"failure","message":"List operation is not supported"}';
  }

  // Get the information of a particular record
  //VD -27-dec-24  param Changes
  public String readRecords(String inpJson, String languageCode) {
    return '{"status":"failure","message":"Read operation is not supported"}';
  }

  // Create a record
  public String createRecords(String inpJson) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    AttachmentWrapper fWrapper = (AttachmentWrapper) JSON.deserialize(
      inpJson,
      AttachmentWrapper.class
    );

    String fileNameOnly = (fWrapper.fileName.contains('\\')
      ? fWrapper.fileName.subStringAfterLast('\\')
      : fWrapper.fileName);

    // Check for File Extenstion
    String fileExtString = fileNameOnly.toLowerCase().subStringAfterLast('.');
    if (
      String.isBlank(fileExtString) ||
      !ALLOWED_FILE_EXTENSIONS.contains(fileExtString)
    ) {
      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeStringField('message', 'Invalid File Extension');

      return jsonGen.getAsString();
    }

    // Check for file Content Type and Magic Bytes
    Integer iBase64String = fWrapper.fileContent.indexOf(';base64,');
    // List<String> base64String = fileContent.split(';base64,');

    if (iBase64String > 0) {
      String fileType = fWrapper.fileContent.substringBetween(
        'data:',
        ';base64,'
      );
      if (!ALLOWED_FILE_TYPES.contains(fileType.toLowerCase())) {
        jsonGen.writeStringField('status', 'failure');
        jsonGen.writeStringField('message', 'Invalid File Type');

        return jsonGen.getAsString();
      }
      Blob fileBody = EncodingUtil.base64Decode(
        fWrapper.fileContent.subStringAfter(';base64,')
      );

      // File Vulnerability Check for COS-212
      Boolean fileCheckFlag = isValidFile(fileBody);
      System.debug(fileBody);

      if (
        fileCheckFlag &&
        fileNameOnly != null &&
        fileBody != null &&
        fWrapper.parentId != null
      ) {
        //Insert ContentVersion
        ContentVersion cVersion = new ContentVersion();
        cVersion.ContentLocation = 'S'; //S-Document is in Salesforce. E-Document is outside of Salesforce. L-Document is on a Social Netork.
        cVersion.PathOnClient = fileNameOnly; //File name with extention
        cVersion.Origin = 'H'; //C-Content Origin. H-Chatter Origin.
        cVersion.OwnerId = UserInfo.getUserID(); //getContactId();      //Owner of the file
        cVersion.Title = fileNameOnly; //Name of the file
        cVersion.VersionData = fileBody; //File content
        SObjectAccessDecision createAccess = Security.stripInaccessible(
          AccessType.CREATABLE,
          new List<ContentVersion>{ cVersion }
        );

        if (createAccess.getRecords().size() > 0) {
          if (
            ContentVersion.SObjectType.getDescribe().isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.ContentLocation.isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.PathOnClient.isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.Origin.isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.OwnerId.isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.Title.isCreateable() &&
            Schema.sObjectType.ContentVersion.fields.VersionData.isCreateable()
          ) {
            Database.insert(cVersion);
          }
        }

        //After saved the Content Verison, get the ContentDocumentId
        Id conDocumentId = [
          SELECT ContentDocumentId
          FROM ContentVersion
          WHERE Id = :cVersion.Id
          WITH SECURITY_ENFORCED
        ]
        .ContentDocumentId;

        //Insert ContentDocumentLink
        ContentDocumentLink cDocLink = new ContentDocumentLink();
        cDocLink.ContentDocumentId = conDocumentId; //Add ContentDocumentId
        cDocLink.LinkedEntityId = fWrapper.parentId; //Add attachment parentId
        cDocLink.ShareType = 'I'; //V - Viewer permission. C - Collaborator permission. I - Inferred permission.
        //cDocLink.Visibility = 'AllUsers';          //AllUsers, InternalUsers, SharedUsers
        SObjectAccessDecision createAcces = Security.stripInaccessible(
          AccessType.CREATABLE,
          new List<ContentDocumentLink>{ cDocLink }
        );

        if (createAcces.getRecords().size() > 0) {
          if (ContentDocumentLink.SObjectType.getDescribe().isCreateable()) {
            Database.insert(cDocLink);
          }
        }

        jsonGen.writeObjectField('attachmentId', conDocumentId);
        jsonGen.writeObjectField('attachmentName', cVersion.Title);

        jsonGen.writeStringField('status', 'success');
        jsonGen.writeStringField('message', 'Attachment Inserted Successfully');
      } else {
        jsonGen.writeStringField('status', 'failure');
        jsonGen.writeStringField(
          'message',
          'Attachment failed to upload ' +
          (fileCheckFlag ? ', Unsupported File Type' : '')
        );
      }
    } else {
      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeStringField('message', 'Invalid File Content');
    }
    return jsonGen.getAsString();
  }
  // Update the records
  public String updateRecords(String inpJson) {
    return '{"status":"failure","message":"Update operation is not supported"}';
  }

  // Delete the records
  public String deleteRecords(String inpJson) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();

    ContentDocument cDoc = new ContentDocument(id = inpJson);
    try {
      if (
        Schema.sObjectType.ContentDocument.isDeletable() &&
        ContentDocument.sObjectType.getDescribe().isDeletable()
      ) {
        Database.delete(cDoc);
      }
      jsonGen.writeStringField('status', 'success');
      jsonGen.writeStringField(
        'message',
        'Content Document is deleted Successfully'
      );
    } catch (Exception e) {
      jsonGen.writeStringField('status', 'failure');
      jsonGen.writeStringField('message', 'Content Document is not deleted');
    }

    jsonGen.writeEndObject();

    return jsonGen.getAsString();
  }

  public Boolean isValidFile(Blob fileContent) {
    String hexBody = EncodingUtil.convertToHex(fileContent);
    System.debug(hexBody.length());
    String firstFewHEX = hexBody.subString(0, 30).tolowerCase();
    String magicNumber = '';

    // Check PDF
    if (firstFewHEX.startsWith('25504446')) {
      return true;
    }

    // Check JPEG
    if (
      firstFewHEX.startsWith('FFD8FFDB'.tolowerCase()) ||
      firstFewHEX.startsWith('FFD8FFE000104A4649460001'.tolowerCase()) ||
      firstFewHEX.startsWith('FFD8FFEE'.tolowerCase()) ||
      firstFewHEX.startsWith('FFD8FFE1'.tolowerCase())
    ) {
      return true;
    }

    // Check PNG
    if (firstFewHEX.startsWith('89504E470D0A1A0A'.tolowerCase())) {
      return true;
    }

    // Check HEIC / HEIF
    if (
      firstFewHEX.startsWith('00000018667479706D696631'.tolowerCase()) ||
      firstFewHEX.startsWith('00000018667479706D736631'.tolowerCase()) ||
      firstFewHEX.startsWith('000000186674797068656963') ||
      firstFewHEX.startsWith('000000186674797068656978') ||
      firstFewHEX.startsWith('000000186674797068657678') ||
      firstFewHEX.startsWith('000000186674797068657663')
    ) {
      return true;
    }

    return false;
  }
  // VD 10jun25 - getImagePreviewUrl
  @AuraEnabled(cacheable=false)
  public static String getImagePreviewUrl(Id contentVersionId) {
    if (contentVersionId == null) {
      return null;
    }
    return URL.getSalesforceBaseUrl().toExternalForm() +
      '/sfc/servlet.shepherd/version/download/' +
      contentVersionId;
  }
}