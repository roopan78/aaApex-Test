public class PdfGeneratorQueueable implements Queueable, Database.AllowsCallouts {
    private String pdfJson;
    private String recordId;
    private String typeValue;
    private String qbName;
    private String pfxId; // RT 18DEC25 - Added variable for pfxId
    private String signerName; // RT 06DEC25 - Added variable for signerName
    private Boolean isSignPadEnabled; // RT 09JAN26 - Added variable for isSignPadEnabled
    private String signBase64; // RT 18DEC25 - Added variable for signBase64

    public PdfGeneratorQueueable(String pdfJson, String recordId, String typeValue, String qbName, String pfxId, String signerName, Boolean isSignPadEnabled, String signBase64) {
        this.pdfJson = pdfJson;
        this.recordId = recordId;
        this.typeValue = typeValue;
        this.qbName = qbName;
        this.pfxId = pfxId; // RT 18DEC25 - Initialize pfxId
        this.signerName = signerName; // RT 06DEC25 - Initialize signerName
        this.isSignPadEnabled = isSignPadEnabled; // RT 09JAN26 - Initialize isSignPadEnabled
        this.signBase64 = signBase64; // RT 09JAN26 - Initialize signBase64
    }

    public void execute(QueueableContext context) {
        try {
            // Call PdfService.fetchAndStorePDF in a separate transaction
            // RT 05JAN25 - Pass pfxId to PdfService
            // RT 06JAN25 - Pass signerName to PdfService
            Map<String, Object> pdfResult = PdfService.fetchAndStorePDF(pdfJson, recordId, typeValue, qbName, pfxId, signerName, isSignPadEnabled, signBase64);
            System.debug('PDF generation result: ' + JSON.serialize(pdfResult));

            // RT 29SEP25 - Handled Error log and send to mail
            if (pdfResult.containsKey('error') || !((Boolean)pdfResult.get('success'))) {
                BatchLabelPDF__c settings = BatchLabelPDF__c.getInstance();
                String mailId = settings.Error_Log_Email__c;
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(new String[] { mailId });
                mail.setSubject('Error in PdfGeneratorQueueable');
                mail.setPlainTextBody('An error occurred in PdfGeneratorQueueable:\n' + pdfResult.get('message') + '\n \nFull Result:\n' + JSON.serialize(pdfResult));
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Error in PdfGeneratorQueueable: ' + e.getMessage() + ' - ' + e.getStackTraceString());
            BatchLabelPDF__c settings = BatchLabelPDF__c.getInstance();
            String mailId = settings.Error_Log_Email__c;
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] { mailId });
            mail.setSubject('Error in PdfGeneratorQueueable');
            mail.setPlainTextBody('An error occurred in PdfGeneratorQueueable:\n' + e.getMessage() + '\n\nStack Trace:\n' + e.getStackTraceString());
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            // Optionally, log the error or notify someone
        }
    }
    public class CustomException extends Exception {}
}