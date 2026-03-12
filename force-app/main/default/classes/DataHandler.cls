public interface DataHandler {
     // MR 22OCT23 - Changes for different field value on Handler Classes
     void setContext(String fieldName, Object fieldValue);
     // List the records
     String getRecords();
    // Get the information of a particular record
     String readRecords(String inpJson,String languageCode);
     // Create a record
     String createRecords(String inpJson);
     // Update the records
     String updateRecords(String inpJson);
     // Delete the records
     String deleteRecords(String inpJson);
}