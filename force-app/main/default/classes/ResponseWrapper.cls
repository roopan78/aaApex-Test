public with sharing class ResponseWrapper {
  public Map<Id, List<TranslationWrapper>> translationMap;
  public Map<Id, QuestionWrapper> bookQuestionsMap;
  public Map<Id, QuestionWrapper> sqOptions;
  public List<QuestionBookWrapper> records;
  public QuestionBookWrapper questionBook;
  public AnswerBookWrapper answerbook;
  public List<ActionWrapper> actions;
  public Decimal order;

  // public AnswerBookWrapper answerBook;
}