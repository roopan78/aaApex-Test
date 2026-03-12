public with sharing class AutoGenerateIdHandler {
  // AS 13JAN25 - Auto generate Unique ID for Question Book
  // VD handled the list on each method
  public static void AutoGenerateId(List<Question_Book__c> newQB) {
    for (Question_Book__c b : newQB) {
      if (b.Auto_generate_ID__c == true) {
        b.Unique_Identifier__c = 'QB-' + UUID.randomUUID().toString();
      }
    }
  }

  // AS 13JAN25 - Auto generate Unique ID for Question
  public static void QuestionAutoGenerateId(List<Question__c> newQuestion) {
    if (!newQuestion.isEmpty()) {
      Set<Id> questionBookIds = new Set<Id>();
      for (Question__c q : newQuestion) {
        if (q.Auto_generate_ID__c == true) {
          questionBookIds.add(q.Question_Book__c);
        }
      }

      if (!questionBookIds.isEmpty()) {
        Map<Id, String> questionBookNameMap = new Map<Id, String>();
        for (Question_Book__c qb : [
          SELECT Id, Name
          FROM Question_Book__c
          WHERE Id IN :questionBookIds
          WITH SECURITY_ENFORCED
        ]) {
          questionBookNameMap.put(qb.Id, qb.Name);
        }

        for (Question__c q : newQuestion) {
          if (q.Auto_generate_ID__c == true) {
            String questionBookName = questionBookNameMap.get(
              q.Question_Book__c
            );
            q.Unique_Identifier__c =
              questionBookName +
              '-Q-' +
              UUID.randomUUID().toString();
          }
        }
      }
    }
  }

  // AS 13JAN25 - Auto generate Unique ID for Option
  public static void OptionAutoGenerateId(List<Option__c> newOption) {
    if (!newOption.isEmpty()) {
      Set<Id> questionIds = new Set<Id>();
      for (Option__c opt : newOption) {
        if (opt.Auto_generate_ID__c == true) {
          questionIds.add(opt.Question__c);
        }
      }

      if (!questionIds.isEmpty()) {
        Map<Id, String> questionNameMap = new Map<Id, String>();
        for (Question__c q : [
          SELECT Id, Name
          FROM Question__c
          WHERE Id IN :questionIds
          WITH SECURITY_ENFORCED
        ]) {
          questionNameMap.put(q.Id, q.Name);
        }

        for (Option__c opt : newOption) {
          if (opt.Auto_generate_ID__c == true) {
            String questionName = questionNameMap.get(opt.Question__c);
            opt.Unique_Identifier__c =
              questionName +
              '-OP-' +
              UUID.randomUUID().toString();
          }
        }
      }
    }
  }

  // AS 13JAN25 - Auto generate Unique ID for Fieldmeta
  public static void FieldmetaAutoGenerateId(List<Field_Meta__c> newFieldMeta) {
    if (!newFieldMeta.isEmpty()) {
      Set<Id> questionIds = new Set<Id>();
      for (Field_Meta__c fm : newFieldMeta) {
        if (fm.Auto_generate_ID__c == true) {
          questionIds.add(fm.Question__c);
        }
      }

      if (!questionIds.isEmpty()) {
        Map<Id, String> questionNameMap = new Map<Id, String>();
        for (Question__c q : [
          SELECT Id, Name
          FROM Question__c
          WHERE Id IN :questionIds
          WITH SECURITY_ENFORCED
        ]) {
          questionNameMap.put(q.Id, q.Name);
        }

        for (Field_Meta__c fm : newFieldMeta) {
          if (fm.Auto_generate_ID__c == true) {
            String questionName = questionNameMap.get(fm.Question__c);
            fm.Unique_Identifier__c =
              questionName +
              '-FM-' +
              UUID.randomUUID().toString();
          }
        }
      }
    }
  }

  // AS 13JAN25 - Auto generate Unique ID for QBInput
  public static void QBinputAutoGenerateId(List<Input__c> newQBinput) {
    if (!newQBinput.isEmpty()) {
      Set<Id> questionBookIds = new Set<Id>();
      for (Input__c input : newQBinput) {
        if (input.Auto_generate_ID__c == true) {
          questionBookIds.add(input.Question_Book__c);
        }
      }

      if (!questionBookIds.isEmpty()) {
        Map<Id, String> questionBookNameMap = new Map<Id, String>();
        for (Question_Book__c qb : [
          SELECT Id, Name
          FROM Question_Book__c
          WHERE Id IN :questionBookIds
          WITH SECURITY_ENFORCED
        ]) {
          questionBookNameMap.put(qb.Id, qb.Name);
        }

        for (Input__c input : newQBinput) {
          if (input.Auto_generate_ID__c == true) {
            String questionBookName = questionBookNameMap.get(
              input.Question_Book__c
            );
            input.Unique_Identifier__c =
              questionBookName +
              '-IN-' +
              UUID.randomUUID().toString();
          }
        }
      }
    }
  }

  // AS 13JAN25 - Auto generate Unique ID for Translation
  public static void TranslationAutoGenerateId(
    List<Translation__c> newTranslation
  ) {
    if (!newTranslation.isEmpty()) {
      Set<Id> questionBookIds = new Set<Id>();
      for (Translation__c trans : newTranslation) {
        if (trans.Auto_generate_ID__c == true) {
          questionBookIds.add(trans.Question_Book__c);
        }
      }

      if (!questionBookIds.isEmpty()) {
        Map<Id, String> questionBookNameMap = new Map<Id, String>();
        for (Question_Book__c qb : [
          SELECT Id, Name
          FROM Question_Book__c
          WHERE Id IN :questionBookIds
          WITH SECURITY_ENFORCED
        ]) {
          questionBookNameMap.put(qb.Id, qb.Name);
        }

        for (Translation__c trans : newTranslation) {
          if (trans.Auto_generate_ID__c == true) {
            String questionBookName = questionBookNameMap.get(
              trans.Question_Book__c
            );
            trans.Unique_Identifier__c =
              questionBookName +
              '-TR-' +
              UUID.randomUUID().toString();
          }
        }
      }
    }
  }

  // RT 06JUN25 - Auto Generate Unique ID for Style
  // AS 13JAN24 - Auto generate Unique ID for Style
public static void StyleAutoGenerateId(List<Style__c> newStyle) {
  if (!newStyle.isEmpty()) {
    Set<Id> questionBookIds = new Set<Id>();
    Set<Id> questionIds = new Set<Id>();
    
    for (Style__c style : newStyle) {
      if (style.Auto_generate_ID__c == true) {
        if (style.Question_Book__c != null) {
          questionBookIds.add(style.Question_Book__c);
        }
        if (style.Question__c != null) {
          questionIds.add(style.Question__c);
        }
      }
    }

    Map<Id, String> questionBookNameMap = new Map<Id, String>();
    Map<Id, String> questionNameMap = new Map<Id, String>();

    if (!questionBookIds.isEmpty()) {
      for (Question_Book__c qb : [
        SELECT Id, Name
        FROM Question_Book__c
        WHERE Id IN :questionBookIds
        WITH SECURITY_ENFORCED
      ]) {
        questionBookNameMap.put(qb.Id, qb.Name);
      }
    }

    if (!questionIds.isEmpty()) {
      for (Question__c q : [
        SELECT Id, Name
        FROM Question__c
        WHERE Id IN :questionIds
        WITH SECURITY_ENFORCED
      ]) {
        questionNameMap.put(q.Id, q.Name);
      }
    }

    for (Style__c style : newStyle) {
      if (style.Auto_generate_ID__c == true) {
        String prefix = '';
        
        if (style.Question_Book__c != null) {
          String questionBookName = questionBookNameMap.get(style.Question_Book__c);
          prefix = questionBookName;
        } else if (style.Question__c != null) {
          String questionName = questionNameMap.get(style.Question__c);
          prefix = questionName;
        }
        
        if (!String.isEmpty(prefix)) {
          style.external_id__c = prefix + '-ST-' + UUID.randomUUID().toString();
        }
      }
    }
  }
}
}