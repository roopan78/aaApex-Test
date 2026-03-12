public class ApexTablecontroller {

    // Method to return all the apex class names
    @AuraEnabled(Cacheable=true)
    public static list<apexclass> GetApexClasses() {
        return [select id, name from apexclass limit 2];
    }   
}