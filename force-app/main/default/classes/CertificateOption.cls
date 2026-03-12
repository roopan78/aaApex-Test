public class CertificateOption {
    // RT 18DEC25 - Added to wrap the certificate label and id to use in combobox
    @AuraEnabled public String label;
    @AuraEnabled public String id;

    public CertificateOption(String label, String id) {
        this.label = label;
        this.id = id;
    }
}