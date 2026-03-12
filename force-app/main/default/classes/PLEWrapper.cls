public class PLEWrapper {
    // MR 16MAY25 QB Builder Changes
    // Wrapper class to send Type Options to LWC
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    
    public PLEWrapper(String l, String v) {
        this.label = l;
        this.value = v;
    }
}