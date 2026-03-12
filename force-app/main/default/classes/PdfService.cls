public with sharing class PdfService {

    // RT 02JAN25 - Dummy method for backward compatibility
    public static Map<String, Object> fetchAndStorePDF(
        String json,
        Id relatedRecordId,
        String pdfName,
        String qbName
    ) {
        // Delegate to the new method
        return fetchAndStorePDF(
            json,
            String.valueOf(relatedRecordId), // convert Id → String
            pdfName,
            qbName,
            null,
            null,
            false,
            null
        );
    }
    // RT 05DEC25- Field to Store PFX File Id and Password from Custom Setting and Digital Sign Boolean
    @AuraEnabled
    public static Map<String, Object> fetchAndStorePDF(String json, 
                                                        String relatedRecordId, 
                                                        String pdfName,
                                                        String qbName, 
                                                        String pfxId, 
                                                        String signerName,
                                                        Boolean isSignPadEnabled,
                                                        String signBase64) {
        Map<String, Object> resultMap = new Map<String, Object>();
        try {
            String pfxBase64; // RT 18DEC25 - Variable for PFX Base64
            String pfxPasswordBase64; // RT 18DEC25 - Variable for PFX Password Base64
            BatchLabelPDF__c settings = BatchLabelPDF__c.getInstance();

            // RT 06JAN25 - Check if Custom Setting is configured
            if (settings == null || String.isBlank(settings.PDFGenerateEndpoint__c)) {
                resultMap.put('success', false);
                resultMap.put('message', 'PDF Generate Endpoint not configured in Custom Settings.');
                return resultMap;
            }

            String endpointUrl = settings.PDFGenerateEndpoint__c;
            Boolean isDigitalSign = settings.Is_Digital_Sign__c;
            String companyName = settings.Company_Name__c; // RT 06JAN25 - Added company name

            // RT 18DEC25 - Fetch PFX file and password if pfxId is provided and digital sign is enabled
            if(!String.isBlank(pfxId) && isDigitalSign) {
                ContentVersion pfxFile = [
                    SELECT Id, VersionData 
                    FROM ContentVersion 
                    WHERE Id = :pfxId 
                    AND IsLatest = true
                    LIMIT 1
                ];

                Digital_Sign_Config__mdt dg = [ SELECT Id, 
                                                PFX_ContentVersionId__c,  
                                                PFX_Password__c 
                                                FROM Digital_Sign_Config__mdt 
                                            WHERE PFX_ContentVersionId__c = :pfxId
                                            LIMIT 1];

                pfxBase64 = EncodingUtil.base64Encode(pfxFile.VersionData);
                pfxPasswordBase64 = EncodingUtil.base64Encode(Blob.valueOf(dg.PFX_Password__c));
            } else {
                isDigitalSign = false;
                pfxBase64 = null;
                pfxPasswordBase64 = null;
            }

            // Prepare JSON body
            Map<String, Object> wrapper = new Map<String, Object>();

            Object jsonBody;
            try {
                jsonBody = System.JSON.deserializeUntyped(json);
            } catch (Exception e) {
                resultMap.put('success', false);
                resultMap.put('message', 'Invalid JSON: ' + e.getMessage());
                return resultMap;
            }

            System.debug('SignBase64 (original): ' + (signBase64 != null ? signBase64.left(50) + '...' : 'null'));

            // RT 12JAN26 - Sanitize signBase64 to remove any invalid characters
            // --- Strong sanitize of signBase64 ---
            String sanitizedSignBase64 = null;
            if (String.isNotBlank(signBase64)) {

                sanitizedSignBase64 = signBase64;

                // Remove data URL prefix completely if present
                if (sanitizedSignBase64.toLowerCase().startsWith('data:')) {
                    Integer commaIndex = sanitizedSignBase64.indexOf(',');
                    if (commaIndex > -1) {
                        sanitizedSignBase64 = sanitizedSignBase64.substring(commaIndex + 1);
                    }
                }

                // Remove whitespace
                sanitizedSignBase64 = sanitizedSignBase64.replaceAll('\\s+', '');

                // Remove any character NOT valid in base64
                sanitizedSignBase64 = sanitizedSignBase64.replaceAll('[^A-Za-z0-9+/=]', '');

                System.debug('Sanitized SignBase64 length: ' + sanitizedSignBase64.length());
            }

            wrapper.put('questionbook', jsonBody);
            wrapper.put('isDigitalSign', isDigitalSign);
            wrapper.put('pfxBase64', pfxBase64);
            wrapper.put('pfxPassword', pfxPasswordBase64);
            wrapper.put('companyName', companyName); // RT 06JAN25 - Added company name and signer name
            wrapper.put('signerName', signerName);
            wrapper.put('isSignPadEnabled', isSignPadEnabled); // RT 09JAN26 - Added isSignPadEnabled
            wrapper.put('signBase64', sanitizedSignBase64); 

            // Final JSON — send ONCE
            String requestBody = System.JSON.serialize(wrapper);

            // HTTP Request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpointUrl);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-salesforce-auth', 'R_NXT_2.82');
            req.setBody(requestBody);

            Http http = new Http();
            HttpResponse response = http.send(req);

            if (response.getStatusCode() == 200) {
                String responseString = response.getBody();
                Map<String, Object> responseMap = (Map<String, Object>) System.JSON.deserializeUntyped(responseString);

                if (responseMap.containsKey('success') && (Boolean) responseMap.get('success')) {
                    String base64Data = (String) responseMap.get('data');

                    if (String.isNotBlank(base64Data)) {
                        String cleanBase64 = base64Data;

                        // Remove data URL prefix if present
                        if (cleanBase64.toLowerCase().startsWith('data:')) {
                            Integer idx = cleanBase64.indexOf(',');
                            if (idx > -1) {
                                cleanBase64 = cleanBase64.substring(idx + 1);
                            }
                        }

                        // Remove whitespace
                        cleanBase64 = cleanBase64.replaceAll('\\s+', '');

                        // Remove any invalid base64 chars
                        cleanBase64 = cleanBase64.replaceAll('[^A-Za-z0-9+/=]', '');

                        System.debug('PDF Base64 length (sanitized): ' + cleanBase64.length());

                        // Validate before decode
                        try {
                            Blob pdfBlob = EncodingUtil.base64Decode(cleanBase64);
                            System.debug('pdf size: ' + pdfBlob.size());
                        
                        List<ContentVersion> existingFiles = [
                            SELECT Title FROM ContentVersion 
                            WHERE Title LIKE :pdfName + ' ' + qbName + '%'
                        ];
                        
                        String newTitle = getNextAvailableTitle(existingFiles, pdfName, qbName);

                        ContentVersion contentVersion = new ContentVersion();
                        contentVersion.Title = newTitle;
                        contentVersion.PathOnClient = newTitle + '.pdf';
                        contentVersion.VersionData = pdfBlob;
                        contentVersion.ContentLocation = 'S';

                        if (Schema.sObjectType.ContentVersion.isCreateable()) {
                            insert contentVersion;
                        } else {
                            resultMap.put('success', false);
                            resultMap.put('message', 'Insufficient permissions to create ContentVersion record.');
                            return resultMap;
                        }

                        List<ContentDocument> contentDocs = [
                            SELECT Id FROM ContentDocument 
                            WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id = :contentVersion.Id) 
                            LIMIT 1
                        ];

                        if (contentDocs.isEmpty()) {
                            resultMap.put('success', false);
                            resultMap.put('message', 'ContentDocument not found after PDF creation.');
                            return resultMap;
                        }

                        ContentDocumentLink contentLink = new ContentDocumentLink();
                        contentLink.ContentDocumentId = contentDocs[0].Id;
                        contentLink.LinkedEntityId = relatedRecordId; 
                        contentLink.ShareType = 'V'; 
                        if (Schema.sObjectType.ContentDocumentLink.isCreateable()) {
                            insert contentLink;
                        } else {
                            resultMap.put('success', false);
                            resultMap.put('message', 'Insufficient permissions to create ContentDocumentLink record.');
                            return resultMap;
                        }
                    } catch(Exception e) {
                        resultMap.put('succes', false);
                        resultMap.put('message', 'Exception: ' + e.getMessage() + ' at Line number : ' + e.getLineNumber());
                    }

                        resultMap.put('success', true);
                        resultMap.put('message', 'PDF stored successfully!');
                    } else {
                        resultMap.put('success', false);
                        resultMap.put('message', 'Base64 data is empty.');
                    }
                } else {
                    resultMap.put('success', false);
                    resultMap.put('message', 'API Response unsuccessful.');
                }
            } else {
                resultMap.put('success', false);
                resultMap.put('message', 'HTTP Error: ' + response.getStatusCode());
            }
        } catch (Exception e) {
            resultMap.put('success', false);
            resultMap.put('message', 'Exception: ' + e.getMessage() + ' at Line number : ' + e.getLineNumber());
        }
        System.debug('Result Map: ' + resultMap);
        return resultMap;
    }

    private static String getNextAvailableTitle(List<ContentVersion> existingFiles, String pdfName, String qbName) {
        Set<Integer> usedNumbers = new Set<Integer>();
        
        for (ContentVersion file : existingFiles) {
            String title = file.Title;
            if (title == pdfName + ' ' + qbName) {
                usedNumbers.add(0);
            } else if (title.startsWith(pdfName + ' ' + qbName + ' ')) {
                String suffix = title.substring((pdfName + ' ' + qbName + ' ').length());
                if (!String.isEmpty(suffix) && suffix.isNumeric()) {
                    usedNumbers.add(Integer.valueOf(suffix));
                }
            }
        }
        
        Integer nextNumber = 0;
        while (usedNumbers.contains(nextNumber)) {
            nextNumber++;
        }
        
        return nextNumber == 0 ? pdfName + ' ' + qbName : pdfName + ' ' + qbName + ' ' + String.valueOf(nextNumber);
    }
}