public with sharing class QuestionBookRecController {
  @AuraEnabled(cacheable=true)
  // RT - 23JAN2025 - Retrieve the list of Question Books
  public static List<QuestionBookWrapper> getQuestionBooks() {
    List<Question_Book__c> questionBooks = [
      SELECT
        Id,
        Name,
        Parent_Booklet_QB__c,
        Version__c,
        Version_Status__c,
        Anchor_Object__c,
        Status__c,
        Title__c,
        isShengel__c,
        SubTitle__c,
        First_Question__c,
        First_Question__r.Type__c,
        Last_Question__c,
        Category__c,
        Total_Questions__c,
        Next__c,
        Back__c,
        Submit__c,
        Api_Key__c,
        Cancel__c,
        Edit__c,
        Actions__c,
        Order__c,
        Possibilities__c,
        Summary_Text__c,
        Summary_Sub_Text__c,
        Progress_Bar__c,
        Next_Tracking_ID__c,
        Back_Tracking_ID__c,
        Cancel_Tracking_ID__c,
        Submit_Tracking_ID__c,
        Query__c,
        Unique_Identifier__c,
        Style__c
      FROM Question_Book__c
    ];

    List<QuestionBookWrapper> wrappers = new List<QuestionBookWrapper>();

    for (Question_Book__c qb : questionBooks) {
      wrappers.add(new QuestionBookWrapper(qb));
    }

    return wrappers;
  }

  @AuraEnabled
  // RT - 24JAN2025 - Create a new Question Book
  public static Question_Book__c createQuestionBook(String title) {
    Question_Book__c newRecord = new Question_Book__c();
    newRecord.Title__c = title;
    insert newRecord;
    return newRecord;
  }
}