public without sharing class FBController {
  @AuraEnabled
  public static string formBuilder(string inputId, string formData) {
    System.debug('inputId --> ' + inputId);
    System.debug('formData --> ' + formData);
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    List<Question__c> qList = new List<Question__c>();
    List<Question__c> allExistingQuestions = new List<Question__c>();
    List<Question__c> questionsToDelete = new List<Question__c>();
    List<Question__c> bookquesList = new List<Question__c>();
    Set<Id> optionIdsToKeep = new Set<Id>();
    Map<String, String> filteredMap = new Map<String, String>();
    Map<String, Question__c> sectionQuestionsMap = new Map<String, Question__c>();
    // Store table questions separately for post-processing
    List<Question__c> tableQuestionsToProcess = new List<Question__c>();

    // Maps to reduce DML operations
    Map<Id, Question__c> questionsToUpsert = new Map<Id, Question__c>();
    Map<Id, Option__c> optionsToUpsert = new Map<Id, Option__c>();
    List<Question_Book__c> questionBooksToUpdate = new List<Question_Book__c>();
    Map<String, Map<String, Object>> fieldMetaDataMap = new Map<String, Map<String, Object>>();
    Map<string, Map<string, Object>> StyleDataMap = new Map<string, Map<string, Object>>();
    Map<String, Map<String, Object>> sectionStyleMap = new Map<String, Map<String, Object>>();
    string objName;

    Map<ID, Id> bookquestionIdCollection = new Map<Id, Id>();
    List<question__c> updateQuestionList = new List<question__c>();
    List<question__c> updateSubTextQuestionList = new List<question__c>();
    Map<String, Id> formIdToQuestionId = new Map<String, Id>();
    List<Question__c> quesList = new List<Question__c>();
    Set<Id> quesIdforST = new Set<Id>();

    try {
      // Deserialize the JSON structure
      Object formDataObj = JSON.deserializeUntyped(formData);
      List<Object> pageArray;

      // Handle different possible JSON structures - more efficient parsing
      if (formDataObj instanceof List<Object>) {
        pageArray = (List<Object>) formDataObj;
      } else if (formDataObj instanceof Map<String, Object>) {
        Map<String, Object> formDataMap = (Map<String, Object>) formDataObj;
        if (formDataMap.containsKey('pages')) {
          pageArray = (List<Object>) formDataMap.get('pages');
        } else if (formDataMap.containsKey('data')) {
          Object dataObj = formDataMap.get('data');
          pageArray = dataObj instanceof List<Object>
            ? (List<Object>) dataObj
            : new List<Object>{ dataObj };
        } else {
          pageArray = new List<Object>{ formDataObj };
        }
      } else {
        throw new AuraHandledException('Invalid form data structure');
      }

      // ASM 09Apr25 Delete Page
      List<String> pagestodelete = new List<String>();
      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        String pageId = (String) pageData.get('pageId');
        Boolean isDeleted = pageData.containsKey('isDeleted')
          ? (Boolean) pageData.get('isDeleted')
          : false;

        if (isDeleted && pageId != null && pageId.length() == 18) {
          System.debug('Found page marked for deletion: ' + pageId);
          pagestodelete.add(pageId);
        }
      }
      // AT 18Apr25 Delete Pages in bulk
      if (!deletePage(pagestodelete, inputId)) {
        throw new AuraHandledException(
          'Error deleting pages: ' + pagestodelete
        );
      }
      System.debug('Deleted page IDs: ' + pagestodelete);

      // Remove deleted pages from further processing
      List<Object> filteredPageArray = new List<Object>();
      List<String> filteredPageIds = new List<String>();
      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        String pageId = (String) pageData.get('pageId');
        if (!pagestodelete.contains(pageId)) {
          filteredPageArray.add(pageObj);
          filteredPageIds.add(pageId);
        }
      }
      // AT 18Apr25 removed unneccessary update pages method
      pageArray = filteredPageArray;

      // Sets for tracking
      Set<Id> questionIdList = new Set<Id>();
      Set<Id> currentSectionIds = new Set<Id>();
      Map<String, Id> tempIdToRealIdMap = new Map<String, Id>();

      // Map to efficiently retrieve existing sections
      Map<Id, Question_Book__c> sectionQBMap = new Map<Id, Question_Book__c>();
      Set<String> existingSectionIds = new Set<String>();

      // SOQL query optimization - use single query with relationship fields
      // RT 12JUN25 - Anchor Object for QB
      Form__c form = [
        SELECT Id, Name, Anchor_Object__c
        FROM Form__c
        WHERE Id = :inputId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];

      // RT 11APR25 - Added page title in Page Qb

      // Get all booklet and section data in bulk
      List<Question_Book__c> pageBooks = [
        SELECT Id, Name, Title__c, Category__c, Order__c
        FROM Question_Book__c
        WHERE Form__c = :inputId AND Category__c = 'Booklet'
        WITH SECURITY_ENFORCED
      ];

      Set<Id> pageIds = new Set<Id>();
      for (Question_Book__c page : pageBooks) {
        pageIds.add(page.Id);
      }

      // Get all sections and their parent relationships at once
      List<Question_Book__c> allExistingSections = [
        SELECT Id, Name, Category__c, Parent_Booklet_QB__c
        FROM Question_Book__c
        WHERE Parent_Booklet_QB__c IN :pageIds AND Category__c = 'Simple'
        WITH SECURITY_ENFORCED
      ];

      Set<Id> allSectionIds = new Set<Id>();
      for (Question_Book__c section : allExistingSections) {
        allSectionIds.add(section.Id);
      }

      // Query all questions and organize by section for easy access
      Map<Id, List<Question__c>> questionsBySection = new Map<Id, List<Question__c>>();
      allExistingQuestions = [
        SELECT
          Id,
          Name,
          Question_Book__c,
          Type__c,
          Question_No__c,
          Question_Text__c
        FROM Question__c
        WHERE Question_Book__c IN :allSectionIds
        WITH SECURITY_ENFORCED
      ];

      for (Question__c q : allExistingQuestions) {
        if (!questionsBySection.containsKey(q.Question_Book__c)) {
          questionsBySection.put(q.Question_Book__c, new List<Question__c>());
        }
        questionsBySection.get(q.Question_Book__c).add(q);
      }

      // Cache for RecordTypeIds - avoid repeated calls
      Map<String, Id> recordTypeIdByName = new Map<String, Id>{
        'UNCONDITIONAL' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('UNCONDITIONAL')
          .getRecordTypeId(),
        'OPTIONONLY' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('OPTIONONLY')
          .getRecordTypeId(),
        'CONDITIONAL' => Schema.SObjectType.Question__c.getRecordTypeInfosByName()
          .get('CONDITIONAL')
          .getRecordTypeId()
      };

      // Process each page
      List<Question_Book__c> pagesToUpsert = new List<Question_Book__c>();
      // VD 27Mar24 changed to upsert
      List<Question_Book__c> sectionsToupsert = new List<Question_Book__c>();

      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        String pageId = (String) pageData.get('pageId');
        // VD 28Mar25 page order handling
        Decimal order = (Decimal) pageData.get('order');
        String originalPageId = pageId;
        String pageTitle = pageData.containsKey('title') &&
          pageData.get('title') != null
          ? String.valueOf(pageData.get('title'))
          : 'Untitled Page';

        // Check if pageId starts with "page" or is invalid
        Boolean isNewPage =
          pageId == null ||
          pageId.trim().length() == 0 ||
          !pageId.startsWith('a') ||
          pageId.length() != 18;

        Question_Book__c pageQB;
        if (!isNewPage) {
          // Check if the page already exists
          for (Question_Book__c qb : pageBooks) {
            if (qb.Id == pageId) {
              pageQB = qb;
              break;
            }
          }
          if (pageQB == null) {
            isNewPage = true;
          }
        }

        if (isNewPage || pageQB == null) {
          System.debug('Creating new page book');
          pageQB = new Question_Book__c(
            Title__c = pageTitle != null ? pageTitle : 'Untitled Page',
            Form__c = form.Id,
            Order__c = order,
            Category__c = 'Booklet'
          );
        } else {
          if (pageTitle != null && pageQB.Title__c != pageTitle) {
            pageQB.Title__c = pageTitle != null ? pageTitle : 'Untitled Page';
          }
          if (order != null && pageQB.Order__c != order) {
            pageQB.Order__c = order;
          }
        }
        pagesToUpsert.add(pageQB);

        // Store mappings for sections
        pageData.put('pageQB', pageQB);

        // Get sections data
        List<Object> sectionsArray = new List<Object>();
        if (pageData.containsKey('sections')) {
          try {
            sectionsArray = (List<Object>) pageData.get('sections');
            if (sectionsArray == null) {
              System.debug(
                'Warning: sections array is null in pageData: ' + pageData
              );
              sectionsArray = new List<Object>();
            }
          } catch (Exception e) {
            System.debug('Error getting sections array: ' + e.getMessage());
            System.debug('Page Data: ' + pageData);
          }
        } else if (pageData.containsKey('id')) {
          sectionsArray = new List<Object>{ pageData };
        }
        // Store section data for later processing
        pageData.put('sectionsArray', sectionsArray);
      }

      // Insert all new pages at once
      if (!pagesToUpsert.isEmpty()) {
        upsert pagesToUpsert;

        // Update mapping with real IDs
        for (Object pageObj : pageArray) {
          Map<String, Object> pageData = (Map<String, Object>) pageObj;
          system.debug('abdul pageDataMap' + pageData);
          String originalPageId = (String) pageData.get('pageId');
          Question_Book__c pageQB = (Question_Book__c) pageData.get('pageQB');

          // Map temporary pageId to real ID if it starts with "page"
          if (
            pageQB.Id != null &&
            originalPageId != null &&
            originalPageId.startsWith('page')
          ) {
            tempIdToRealIdMap.put(originalPageId.trim(), pageQB.Id);
            System.debug(
              'Mapped temp pageId: ' +
                originalPageId +
                ' to real ID: ' +
                pageQB.Id
            );
          }

          // Track this page ID
          pageIds.add(pageQB.Id);
        }
      }

      // Now process sections with valid page references
      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        Question_Book__c pageQB = (Question_Book__c) pageData.get('pageQB');
        List<Object> sectionsArray = (List<Object>) pageData.get(
          'sectionsArray'
        );

        for (Object sectionObj : sectionsArray) {
          Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
          String sectionId = (String) sectionData.get('id');
          if (
            sectionId != null &&
            !sectionId.startsWith('Section') &&
            sectionId.startsWith('a') &&
            sectionId.length() == 18
          ) {
            existingSectionIds.add(sectionId);
            currentSectionIds.add(sectionId);
          }
        }

        // Query existing sections efficiently
        if (!existingSectionIds.isEmpty()) {
          for (Question_Book__c qb : allExistingSections) {
            if (existingSectionIds.contains(qb.Id)) {
              sectionQBMap.put(qb.Id, qb);
            }
          }
        }

        // Collect sections to insert
        for (Object sectionObj : sectionsArray) {
          Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
          String sectionId = (String) sectionData.get('id');
          String originalSectionId = sectionId;
          // VD 28Mar25 section order handling
          Decimal sectionOrder = (Decimal) sectionData.get('order');
          System.debug('sectionOrder-->' + sectionOrder);
          Map<String, Object> sectionBook = (Map<String, Object>) sectionData.get(
            'question'
          );
          String sectionTitle = (String) sectionBook.get('title');

          Question_Book__c sectionQB;
          if (
            sectionId != null &&
            !sectionId.startsWith('Section') &&
            sectionId.startsWith('a') &&
            sectionId.length() == 18
          ) {
            sectionQB = sectionQBMap.get(sectionId);
            if (sectionQB != null) {
              sectionQB.Order__c = sectionOrder;
              sectionQB.Title__c = sectionTitle;
              System.debug('inside Existion sec order: ' + sectionQB.Order__c);
            }
          } else {
            System.debug('Creating new section for ID: ' + sectionId);
            sectionQB = new Question_Book__c(
              Parent_Booklet_QB__c = pageQB.Id,
              Order__c = sectionOrder,
              Title__c = sectionTitle,
              Category__c = 'Simple'
            );
          }
          // VD 27Mar24 changed to upsert
          sectionsToupsert.add(sectionQB);
          // Store for later processing
          sectionData.put('sectionQB', sectionQB);
          System.debug('inside Existion sec: ' + sectionQB);
        }
      }

      // Insert all new sections at once
      // VD 27Mar24 changed to upsert
      if (!sectionsToupsert.isEmpty()) {
        upsert sectionsToupsert;

        // Update mappings with real IDs
        for (Object pageObj : pageArray) {
          Map<String, Object> pageData = (Map<String, Object>) pageObj;
          List<Object> sectionsArray = (List<Object>) pageData.get(
            'sectionsArray'
          );

          for (Object sectionObj : sectionsArray) {
            Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
            Question_Book__c sectionQB = (Question_Book__c) sectionData.get(
              'sectionQB'
            );
            String originalSectionId = (String) sectionData.get('id');

            if (
              sectionQB.Id != null &&
              originalSectionId != null &&
              (originalSectionId.startsWith('Section') ||
              !originalSectionId.startsWith('a'))
            ) {
              tempIdToRealIdMap.put(originalSectionId.trim(), sectionQB.Id);
            }

            // Add to current section IDs set for deletion tracking
            if (sectionQB.Id != null) {
              currentSectionIds.add(sectionQB.Id);
            }
          }
        }
      }

      // Actions/23Apr25/Thangarasu- process all page-actions here
      List<Actions__c> pageActionsToUpsert = new List<Actions__c>();
      Set<Id> pageActionsToDeleteIds = new Set<Id>();
      // Action handling changes VD 22Jul25
      try {
        handleActionsAndStyles(pageArray, 'page');
      } catch (Exception e) {
        System.debug('Inside the exception section ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
        jsonGen.writeObjectField('error', e.getMessage());
        jsonGen.writeObjectField('stackTrace', e.getStackTraceString());
      }
      // RT 04JUL25 - QB Builder Adaptation
      // Now process all questions with valid section references
      List<Question__c> questionsToInsert = new List<Question__c>();
      List<Option__c> optionsToInsert = new List<Option__c>();
      Set<ID> questionBookIdCollection = new Set<ID>();
      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        List<Object> sectionsArray = (List<Object>) pageData.get(
          'sectionsArray'
        );

        for (Object sectionObj : sectionsArray) {
          Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
          Question_Book__c sectionQB = (Question_Book__c) sectionData.get(
            'sectionQB'
          );
          sectionStyleMap.put(sectionQB.Id, sectionData);
          questionBookIdCollection.add(sectionQB.Id);
          // Process subQuestions
          List<Object> subQuestions = new List<Object>();
          if (sectionData.containsKey('subQuestions')) {
            subQuestions = (List<Object>) sectionData.get('subQuestions');
          }
          System.debug(
            'Processing ' +
              (subQuestions != null ? subQuestions.size() : 0) +
              ' subQuestions'
          );
          system.debug('SubQuestions' + subQuestions);
          Question__c bookQuestion = null;
          // First pass - create Book elements (section headers) as they're referenced by other questions
          if (subQuestions != null && !subQuestions.isEmpty()) {
            for (Object item : subQuestions) {
              Map<String, Object> questionData = (Map<String, Object>) item;
              String elementId = (String) questionData.get('Id');
              if (elementId == null) {
                elementId = (String) questionData.get('id');
              }
              Decimal elementNo = (Decimal) questionData.get('fieldNo');
              System.debug('elementNo --> ' + elementNo);
              String element = (String) questionData.get('element');
              if (element == 'Book' && elementNo < 2) {
                String label = (String) questionData.get('label');
                String formId = (String) questionData.get('key');
                Question__c bookques = new Question__c();
                if (elementId != null && elementId instanceof Id) {
                  bookques.Id = elementId;
                } else {
                  bookques = new Question__c();
                }
                bookques.Question_Book__c = sectionQB.Id;
                bookques.Question_No__c = elementNo;
                bookques.RecordTypeId = recordTypeIdByName.get('UNCONDITIONAL');
                bookques.Question_Text__c = label;
                bookques.Type__c = element;
                bookques.Form_Identifier__c = formId;

                if (elementId != null && elementId instanceof Id) {
                  questionsToUpsert.put(elementId, bookques);
                } else {
                  questionsToInsert.add(bookques);
                }
                bookquesList.add(bookques);
                sectionQuestionsMap.put(String.valueOf(sectionQB.Id), bookques);
                bookQuestion = bookques;
                questionData.put('bookQuestion', bookques);
                // Add to tracking set
                if (elementId != null && elementId instanceof Id) {
                  questionIdList.add(elementId);
                }
              }
            }
          }

          // Second pass - process all other questions
          // RT 31MAY25 - Table Condition and Table Value Added
          // RT 06JUN25 - Table Is Serial Added
          if (subQuestions != null && !subQuestions.isEmpty()) {
            for (Object item : subQuestions) {
              Map<String, Object> questionData = (Map<String, Object>) item;
              String elementId = (String) questionData.get('Id');
              Decimal fieldNo = (Decimal) questionData.get('fieldNo');
              if (elementId == null) {
                elementId = (String) questionData.get('id');
              }
              String element = (String) questionData.get('element');
              objName = (string) questionData.get('objectApiName');
              if (fieldNo > 1) {
                // Skip Book elements as they're already processed
                // Extract question properties efficiently
                String key = (String) questionData.get('key');
                String placeholder = (String) questionData.get('placeholder');
                String helpText = (String) questionData.get('helpText');
                Decimal elementNo = questionData.containsKey('fieldNo')
                  ? (Decimal) questionData.get('fieldNo')
                  : 2;
                String label = (String) questionData.get('label');
                // VD 20Sep25 - line element Fix
                String elementMode = (String) questionData.get('elementMode');
                String referenceField = (String) questionData.get(
                  'referenceField'
                );
                String uniqueIdentifier = (String) questionData.get(
                  'uniqueIdentifier'
                );
                Boolean isDependent = questionData.containsKey('isDependent')
                  ? (Boolean) questionData.get('isDependent')
                  : false;
                Object subTextObj = questionData.get('subText');
                String subText = '';
                if (
                  subTextObj == null ||
                  String.valueOf(subTextObj).trim() == '' ||
                  !isDependent
                ) {
                  System.debug('subText is empty');
                } else {
                  Map<String, Object> subTextStr = (Map<String, Object>) subTextObj;
                  if (subTextStr.containsKey('sourceQuestionId')) {
                    String sourceId = String.valueOf(
                      subTextStr.get('sourceQuestionId')
                    );
                    System.debug('sourceId -->' + sourceId);
                    if (
                      sourceId != null &&
                      sourceId.trim() != '' &&
                      sourceId.length() < 10
                    ) {
                      filteredMap.put(key, sourceId);
                      System.debug('filteredMap -->' + filteredMap);
                    }
                  }
                  subText = JSON.serialize(subTextStr);
                  System.debug('subText: ' + subText);
                }
                Decimal size = questionData.containsKey('size')
                  ? (Decimal) questionData.get('size')
                  : 12;
                Boolean isOptional = questionData.containsKey('isOptional')
                  ? (Boolean) questionData.get('isOptional')
                  : true;
                Boolean isHide = questionData.containsKey('isHide')
                  ? (Boolean) questionData.get('isHide')
                  : false;
                Boolean isSno = questionData.containsKey('isSno')
                  ? (Boolean) questionData.get('isSno')
                  : false;
                Boolean readOnly = questionData.containsKey('readOnly')
                  ? (Boolean) questionData.get('readOnly')
                  : false;
                String imgSrc = (String) questionData.get('imgSrc');
                // VD 29jul defaul value handling
                String defaultValue = (String) questionData.get('value');
                String objectApiName = (String) questionData.get(
                  'objectApiName'
                );
                String fieldApiName = (String) questionData.get('fieldApiName');
                String tableCondition = questionData.containsKey(
                    'tableCondition'
                  )
                  ? (String) questionData.get('tableCondition')
                  : '';
                String tableValue = questionData.containsKey('tableValue')
                  ? (String) questionData.get('tableValue')
                  : '';
                List<Object> optionsList = questionData.containsKey('options')
                  ? (List<Object>) questionData.get('options')
                  : new List<Object>();
                Question__c ques = new Question__c();
                if (elementId != null && elementId instanceof Id) {
                  ques.Id = elementId;
                }
                ques.Form_Identifier__c = key;
                ques.Question_Book__c = sectionQB.Id;
                ques.Question_No__c = elementNo;
                ques.Question_Text__c = label;
                ques.Question__c = placeholder;
                ques.Help_Text__c = helpText;
                ques.Read_Only__c = readOnly;
                ques.isSno__c = isSno;
                ques.Is_Dependent__c = isDependent;
                ques.Is_Hide__c = isHide;
                ques.Reference_Field__c = referenceField;
                ques.Sub_Text__c = subText;
                ques.Element_Mode__c = elementMode; // VD 20Sep25 - line element Fix 
                ques.Value__c = defaultValue;
                ques.Size__c = size != null ? size : 12;
                ques.Type__c = element;
                // VD 29may25 avoid objectapi name on basic questions
                if (element == 'Table' || element == 'List') {
                  ques.Title__c = objectApiName;
                  // RT 01JUL25 - Subtitle null check
                  // VD 16jul25 blank check correctly
                  if (fieldApiName != null) {
                    if (
                      !String.isBlank(tableCondition) &&
                      !String.isBlank(tableValue)
                    ) {
                      ques.SubTitle__c =
                        fieldApiName +
                        ' ' +
                        tableCondition +
                        ' ' +
                        tableValue;
                    } else {
                      ques.SubTitle__c = '';
                    }
                  }
                }
                // VD jun1025 - imgSrc  Fix
                if (element == 'Image') {
                  ques.Title__c = imgSrc;
                }
                // Set the parent question to the section's Book question
                Question__c parentQuestion = sectionQuestionsMap.get(
                  String.valueOf(sectionQB.Id)
                );
                if (parentQuestion != null) {
                  system.debug('Parent Question found: ' + parentQuestion.Name);
                  ques.Question_Parent__c = parentQuestion.Id;
                }

                if (element == 'Table' || element == 'Book') {
                  ques.RecordTypeId = recordTypeIdByName.get('UNCONDITIONAL');
                  tableQuestionsToProcess.add(ques); // Store for later processing
                  questionData.put('tableQuestion', ques);
                }

                // Set record type based on element type
                if (element == 'Dropdown') {
                  ques.RecordTypeId = recordTypeIdByName.get('OPTIONONLY');
                } else if (element == 'Checkbox' || element == 'Radio') {
                  ques.RecordTypeId = recordTypeIdByName.get('CONDITIONAL');
                } else {
                  ques.RecordTypeId = recordTypeIdByName.get('UNCONDITIONAL');
                }

                // Add to appropriate collection
                if (elementId != null && elementId instanceof Id) {
                  questionsToUpsert.put(elementId, ques);
                  questionIdList.add(elementId);
                } else {
                  questionsToInsert.add(ques);
                }

                qList.add(ques);
                if (label != null) {
                  // VD 15july25 - avoid book and table type field meta
                  if (element != 'Table' && element != 'Book') {
                    fieldMetaDataMap.put(ques.Form_Identifier__c, questionData);
                  }
                  StyleDataMap.put(ques.Form_Identifier__c, questionData);
                }
                // Store for options processing
                questionData.put('question', ques);
              }
            }
            System.debug('filteredMap ==>' + filteredMap);
          }
        }
      }
      // VD 11jun25 - section styling need to be implment correctly

      // Insert new questions in bulk
      system.debug('questionBookIdCollection==> ' + questionBookIdCollection);

      if (!questionsToInsert.isEmpty()) {
        insert questionsToInsert;

        //Updating Question_Parent__c using book type
        quesList = [
          SELECT
            Id,
            Name,
            Question_Book__c,
            Type__c,
            Question_No__c,
            Question_Text__c,
            Sub_Text__c,
            Form_Identifier__c
          FROM Question__c
          WHERE Question_Book__c IN :questionBookIdCollection
          WITH SECURITY_ENFORCED
        ];

        Map<Id, Id> sectiontoParentQuestionMap = new Map<Id, Id>();
        Map<String, Id> formIdentifierToQuestionId = new Map<String, Id>();

        for (Question__c q : quesList) {
          system.debug(q);
          if (q.Form_Identifier__c != null) {
            formIdToQuestionId.put(q.Form_Identifier__c, q.Id);
            formIdentifierToQuestionId.put(q.Form_Identifier__c, q.Id);
          }
          if (q.Question_No__c < 2) {
            bookquestionIdCollection.put(q.Question_Book__c, q.Id);
            sectiontoParentQuestionMap.put(q.Question_Book__c, q.Id);
          }
        }
        Map<String, Id> formIdToRecordIdMap = new Map<String, Id>();
        Map<Id, Question__c> questionMap = new Map<Id, Question__c>(
          questionsToInsert
        );
        List<Question__c> questionsToUpdateParent = new List<Question__c>();

        // Process each page and section to assign parent questions
        for (Object pageObj : pageArray) {
          Map<String, Object> pageData = (Map<String, Object>) pageObj;
          List<Object> sectionsArray = (List<Object>) pageData.get(
            'sectionsArray'
          );

          for (Object sectionObj : sectionsArray) {
            Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
            Question_Book__c sectionQB = (Question_Book__c) sectionData.get(
              'sectionQB'
            );

            // Get the parent question (fieldNo == 1 or Book type) for this section
            Id parentQuestionId = sectionToParentQuestionMap.get(sectionQB.Id);

            // If no parent found in Book type, look for fieldNo == 1 question
            if (parentQuestionId == null) {
              List<Object> subQuestions = (List<Object>) sectionData.get(
                'subQuestions'
              );
              if (subQuestions != null) {
                for (Object item : subQuestions) {
                  Map<String, Object> questionData = (Map<String, Object>) item;
                  Decimal fieldNo = (Decimal) questionData.get('fieldNo');

                  if (fieldNo != null && fieldNo == 1) {
                    String elementId = (String) questionData.get('Id');
                    if (elementId == null) {
                      elementId = (String) questionData.get('id');
                    }

                    // If it's a new question, use Form_Identifier__c to find the ID
                    if (elementId == null || !elementId.startsWith('a')) {
                      String formIdentifier = (String) questionData.get('key');
                      if (
                        formIdentifier != null &&
                        formIdentifierToQuestionId.containsKey(formIdentifier)
                      ) {
                        parentQuestionId = formIdentifierToQuestionId.get(
                          formIdentifier
                        );
                      }
                    } else {
                      parentQuestionId = elementId;
                    }
                    break;
                  }
                }
              }
            }

            // Now assign this parent to all non-fieldNo-1 questions in this section
            if (parentQuestionId != null) {
              List<Object> subQuestions = (List<Object>) sectionData.get(
                'subQuestions'
              );
              if (subQuestions != null) {
                for (Object item : subQuestions) {
                  Map<String, Object> questionData = (Map<String, Object>) item;
                  Decimal fieldNo = (Decimal) questionData.get('fieldNo');

                  // Only process questions where fieldNo != 1
                  if (fieldNo != null && fieldNo != 1) {
                    String elementId = (String) questionData.get('Id');
                    if (elementId == null) {
                      elementId = (String) questionData.get('id');
                    }

                    Id questionId = null;

                    // If it's a new question, use Form_Identifier__c to find the ID
                    if (elementId == null || !elementId.startsWith('a')) {
                      String formIdentifier = (String) questionData.get('key');
                      if (
                        formIdentifier != null &&
                        formIdentifierToQuestionId.containsKey(formIdentifier)
                      ) {
                        questionId = formIdentifierToQuestionId.get(
                          formIdentifier
                        );
                      }
                    } else {
                      questionId = elementId;
                    }

                    // Add to update list if we have a valid question ID
                    if (questionId != null) {
                      Question__c questionToUpdate = new Question__c();
                      questionToUpdate.Id = questionId;
                      questionToUpdate.Question_Parent__c = parentQuestionId;
                      questionsToUpdateParent.add(questionToUpdate);
                      quesIdforST.add(questionId);
                    }
                  }
                }
              }
            }
          }
        }

        // Update parent relationships in bulk
        if (!questionsToUpdateParent.isEmpty()) {
          update questionsToUpdateParent;
        }
        for (Question__c q : questionsToInsert) {
          formIdToRecordIdMap.put(q.Form_Identifier__c, q.Id);
        }
        for (String key : filteredMap.keySet()) {
          String value = filteredMap.get(key);
          if (formIdToRecordIdMap.containsKey(key)) {
            Question__c ques = new Question__c();
            ques.Id = formIdToRecordIdMap.get(key);
            Map<String, Object> subTextStr = (Map<String, Object>) JSON.deserializeUntyped(
              questionMap.get(ques.Id).Sub_Text__c
            );
            System.debug('subTextStr -->' + subTextStr);
            if (
              subTextStr != null && subTextStr.containsKey('sourceQuestionId')
            ) {
              String sourceId = String.valueOf(
                subTextStr.get('sourceQuestionId')
              );
              if (
                sourceId != null &&
                sourceId.trim() != '' &&
                sourceId.length() < 10 &&
                formIdToRecordIdMap.containsKey(value)
              ) {
                subTextStr.put(
                  'sourceQuestionId',
                  formIdToRecordIdMap.get(value)
                );
                ques.Sub_Text__c = JSON.serialize(subTextStr);
                updateSubTextQuestionList.add(ques);
              }
            }
          }
        }
        if (updateSubTextQuestionList.size() > 0) {
          update updateSubTextQuestionList;
        }

        if (bookquestionIdCollection.size() > 0) {
          for (Question__c q : quesList) {
            if (q.Question_No__c > 1) {
              System.debug('type check--->' + q.Type__c);
              question__c ques = new Question__c();
              ques.Id = q.ID;
              ques.Question_Parent__c = bookquestionIdCollection.get(
                q.Question_Book__c
              );
              updateQuestionList.add(ques);
              quesIdforST.add(ques.Id);
            }
          }
        }
        // VD 15july25 - avoid book and table type field meta
        List<Question__c> nonBookTableQuestions = new List<Question__c>();
        for (Question__c q : questionsToInsert) {
          if (q.Type__c != 'Book' && q.Type__c != 'Table') {
            nonBookTableQuestions.add(q);
          }
        }
        //FielMeta data creation
        processFieldMetaDataCreation(
          nonBookTableQuestions,
          fieldMetaDataMap,
          null
        );
        ProcessAppliedStyles(questionsToInsert, StyleDataMap);
      }

      if (updateQuestionList.size() > 0) {
        update updateQuestionList;
      }
      system.debug('questionsToInsert' + questionsToInsert);
      // Update existing questions in bulk
      if (!questionsToUpsert.isEmpty()) {
        update questionsToUpsert.values();
        List<Question__c> nonBookTableQuestionsUpsert = new List<Question__c>();
        for (Question__c q : questionsToUpsert.values()) {
          if (q.Type__c != 'Book' && q.Type__c != 'Table') {
            nonBookTableQuestionsUpsert.add(q);
          }
        }
        processFieldMetaDataCreation(
          nonBookTableQuestionsUpsert,
          fieldMetaDataMap,
          null
        );
        ProcessAppliedStyles(questionsToUpsert.values(), StyleDataMap);
      }
      //Handle table and column logic to insert
      if (!tableQuestionsToProcess.isEmpty()) {
        string rdType = recordTypeIdByName.get('UNCONDITIONAL');
        processTableElement(tableQuestionsToProcess, pageArray, rdType);

        // --- FIX: Update Question_Parent__c for Table Questions after all inserts ---
        // Map section Id to Book question Id
        Map<Id, Id> sectionToBookQuestionId = new Map<Id, Id>();
        for (Question__c q : [
          SELECT Id, Question_Book__c
          FROM Question__c
          WHERE
            Type__c = 'Book'
            AND Question_Book__c != NULL
            AND Question_No__c = 1
        ]) {
          sectionToBookQuestionId.put(q.Question_Book__c, q.Id);
        }
        List<Question__c> tableQuestionsToUpdateParent = new List<Question__c>();
        for (Question__c tableQ : tableQuestionsToProcess) {
          if (
            tableQ.Question_Book__c != null &&
            sectionToBookQuestionId.containsKey(tableQ.Question_Book__c)
          ) {
            tableQuestionsToUpdateParent.add(
              new Question__c(
                Id = tableQ.Id,
                Question_Parent__c = sectionToBookQuestionId.get(
                  tableQ.Question_Book__c
                )
              )
            );
          }
        }
        if (!tableQuestionsToUpdateParent.isEmpty()) {
          update tableQuestionsToUpdateParent;
        }
        // --- END FIX ---
      }

      // Add after table processing
      // processFileConfigurations(pageArray);

      List<Input__c> inputRecordsToUpsert = new List<Input__c>();
      List<Input__c> inputRecordsToDelete = new List<Input__c>();
      // Update all questions with valid IDs
      for (Object pageObj : pageArray) {
        Map<String, Object> pageData = (Map<String, Object>) pageObj;
        List<Object> sectionsArray = (List<Object>) pageData.get(
          'sectionsArray'
        );

        for (Object sectionObj : sectionsArray) {
          Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
          Question_Book__c sectionQB = (Question_Book__c) sectionData.get(
            'sectionQB'
          );

          // Update First_Question__c for each section
          for (Object item : (List<Object>) sectionData.get('subQuestions')) {
            Map<String, Object> questionData = (Map<String, Object>) item;
            String element = (String) questionData.get('element');
            Decimal fieldNo = (Decimal) questionData.get('fieldNo');

            if (fieldNo < 2) {
              Question__c bookques = (Question__c) questionData.get(
                'bookQuestion'
              );
              if (bookques != null && bookques.Id != null) {
                // Add to tracking set
                questionIdList.add(bookques.Id);

                // Update the section's First_Question__c
                Question_Book__c quesBookUpdate = new Question_Book__c(
                  Id = sectionQB.Id,
                  First_Question__c = bookques.Id
                );
                questionBooksToUpdate.add(quesBookUpdate);
              }
            }
          }
          // Process options for each question
          for (Object item : (List<Object>) sectionData.get('subQuestions')) {
            Map<String, Object> questionData = (Map<String, Object>) item;
            String element = (String) questionData.get('element');
            Boolean isDependent = questionData.containsKey('isDependent')
              ? (Boolean) questionData.get('isDependent')
              : false;
            Boolean isDependentLogic = questionData.containsKey(
                'isDependentLogic'
              )
              ? (Boolean) questionData.get('isDependentLogic')
              : false;
            // Boolean isDependent = (Boolean) questionData.get('isDependent');
            //System.debug('ques.Input__c-->'+ (object) questionData.get('input'));
            // Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped((String) questionData.get('input'));
            Question__c ques = (Question__c) questionData.get('question');

            if (ques != null && ques.Id != null) {
              // Add to tracking set
              questionIdList.add(ques.Id);
              try {
                // Map<String, Object> inputMap = (Map<String, Object>) JSON.deserializeUntyped(input);
                Map<String, Object> inputMap = (Map<String, Object>) questionData.get(
                  'inputDetail'
                );
                if (inputMap != null && isDependent == true) {
                  System.debug('ques.Input__c-->' + inputMap);
                  Boolean isDeleted =
                    inputMap.containsKey('isdeleted') &&
                    (Boolean) inputMap.get('isdeleted');

                  // Handle delete scenario
                  if (isDeleted) {
                    if (
                      inputMap.containsKey('id') &&
                      !String.isBlank((String) inputMap.get('id'))
                    ) {
                      inputRecordsToDelete.add(
                        new Input__c(Id = (String) inputMap.get('id'))
                      );
                    }
                    continue; // Skip rest for deleted
                  }

                  Input__c inputRec = new Input__c();

                  // Assign Id if it exists, else leave null (insert mode)
                  if (
                    inputMap.containsKey('id') &&
                    !String.isBlank((String) inputMap.get('id'))
                  ) {
                    inputRec.Id = (String) inputMap.get('id');
                  }

                  inputRec.Question__c = ques.Id;

                  if (inputMap.containsKey('logics')) {
                    inputRec.Logics__c = isDependentLogic == true
                      ? JSON.serialize(inputMap.get('logics'))
                      : '';
                  }

                  if (inputMap.containsKey('hidden')) {
                    inputRec.Hidden__c = (Boolean) inputMap.get('hidden');
                  }

                  if (inputMap.containsKey('sourceQuestionId')) {
                    inputRec.Source_Question_Id__c = (String) inputMap.get(
                      'sourceQuestionId'
                    );
                  }

                  inputRecordsToUpsert.add(inputRec);
                }
              } catch (Exception e) {
                System.debug(
                  '❌ Error parsing input for Question ' +
                    ques.Id +
                    ': ' +
                    e.getMessage()
                );
              }

              // Handle option-based elements
              if (
                (element == 'Dropdown' ||
                element == 'Radio' ||
                element == 'Checkbox') && questionData.containsKey('options')
              ) {
                List<Object> optionsList = (List<Object>) questionData.get(
                  'options'
                );
                if (optionsList != null && !optionsList.isEmpty()) {
                  List<Option__c> questionOptions = new List<Option__c>();
                  Integer optionNo = 1;

                  for (Object ops : optionsList) {
                    Map<String, Object> optionData = (Map<String, Object>) ops;
                    String opValue = (String) optionData.get('value');
                    String optId = (String) optionData.get('Id');

                    Option__c op = new Option__c();
                    if (optId != null && optId instanceof Id) {
                      op.Id = optId;
                      optionIdsToKeep.add(optId);
                      optionsToUpsert.put(optId, op);
                    } else {
                      op.Question__c = ques.Id;
                      optionsToInsert.add(op);
                    }

                    op.Value__c = opValue;
                    op.Order__c = optionNo++;
                    questionOptions.add(op);
                  }
                }
              }
            }
          }
        }
      }

      // Update all section Question_Books in bulk
      if (!questionBooksToUpdate.isEmpty()) {
        update questionBooksToUpdate;
      }

      // Insert new options in bulk
      if (!optionsToInsert.isEmpty()) {
        insert optionsToInsert;
        for (Option__c opt : optionsToInsert) {
          optionIdsToKeep.add(opt.Id);
        }
      }

      // Update existing options in bulk
      if (!optionsToUpsert.isEmpty()) {
        update optionsToUpsert.values();
      }

      // Perform insert/update and delete inputs
      if (!inputRecordsToUpsert.isEmpty()) {
        upsert inputRecordsToUpsert;
      }

      if (!inputRecordsToDelete.isEmpty()) {
        delete inputRecordsToDelete;
      }

      // Bulk delete options that are no longer in the form
      System.debug('optionIdsToKeep-->' + optionIdsToKeep);

      List<Option__c> optionsToDelete = [
        SELECT Id
        FROM Option__c
        WHERE Question__c IN :questionIdList AND Id NOT IN :optionIdsToKeep
      ];

      System.debug('options to delete: ' + optionsToDelete);
      if (
        !optionsToDelete.isEmpty() &&
        Option__c.SObjectType.getDescribe().isDeletable()
      ) {
        delete optionsToDelete;
      }

      // Bulk delete questions that are no longer in the form
      for (Question__c ques : allExistingQuestions) {
        if (
          !questionIdList.contains(ques.Id) &&
          currentSectionIds.contains(ques.Question_Book__c)
        ) {
          questionsToDelete.add(ques);
          System.debug(
            'Adding to delete list: ' +
              ques.Id +
              ' (Type: ' +
              ques.Type__c +
              ')'
          );
        }
      }

      System.debug('Questions to delete count: ' + questionsToDelete.size());
      if (!questionsToDelete.isEmpty()) {
        // First delete all styles associated with these questions
        List<Style__c> QuestionsstylesToDelete = [
          SELECT Id
          FROM Style__c
          WHERE Question__c IN :questionsToDelete
          WITH SECURITY_ENFORCED
        ];

        if (
          !QuestionsstylesToDelete.isEmpty() &&
          Style__c.SObjectType.getDescribe().isDeletable()
        ) {
          delete QuestionsstylesToDelete;
        }

        // Now delete the questions
        if (Question__c.SObjectType.getDescribe().isDeletable()) {
          delete questionsToDelete;
        }
      }

      // Actions/23Apr25/Thangarasu- process all section actions here
      List<Actions__c> secActionsToUpsert = new List<Actions__c>();
      Set<Id> secActionsToDeleteIds = new Set<Id>();
      // Action handling changes VD 22Jul25
      try {
        handleActionsAndStyles(pageArray, 'section');
      } catch (Exception e) {
        System.debug('Inside the exception section ' + e.getMessage());
        System.debug('Stack trace: ' + e.getStackTraceString());
        jsonGen.writeObjectField('error', e.getMessage());
        jsonGen.writeObjectField('stackTrace', e.getStackTraceString());
      }
      // Identify and delete sections that are no longer in the form
      List<Question_Book__c> sectionsToDelete = new List<Question_Book__c>();
      for (Question_Book__c section : allExistingSections) {
        if (!currentSectionIds.contains(section.Id)) {
          sectionsToDelete.add(section);
          System.debug('Adding section to delete list: ' + section.Id);
        }
      }

      System.debug('Sections to delete count: ' + sectionsToDelete.size());
      if (!sectionsToDelete.isEmpty()) {
        // First delete all questions associated with these sections
        List<Question__c> sectionsQuestionsToDelete = [
          SELECT Id
          FROM Question__c
          WHERE Question_Book__c IN :sectionsToDelete
          WITH SECURITY_ENFORCED
        ];

        if (!sectionsQuestionsToDelete.isEmpty()) {
          List<Style__c> wholesectionstylesToDelete = [
            SELECT Id
            FROM Style__c
            WHERE
              Question__c IN :sectionsQuestionsToDelete
              OR Question_Book__c IN :sectionsToDelete
            WITH SECURITY_ENFORCED
          ];

          // Now delete the sections questions
          if (
            !wholesectionstylesToDelete.isEmpty() &&
            Style__c.SObjectType.getDescribe().isDeletable()
          ) {
            delete wholesectionstylesToDelete;
          }
        }

        // Actions/23Apr25/Thangarasu/delete all the related actions when the parent section is deleted
        List<Actions__c> secActionsToDelete = [
          SELECT Id
          FROM Actions__c
          WHERE Question_Book__c IN :sectionsToDelete
        ];
        System.debug(
          'Section actions to delete count: ' + secActionsToDelete.size()
        );
        // Actions2/19May25/Thangarasu-Styles to delete
        List<Style__c> stylesToDelete = [
          SELECT Id, Name
          FROM Style__c
          WHERE Action__c IN :secActionsToDelete
        ];
        if (!stylesToDelete.isEmpty()) {
          delete stylesToDelete;
        }

        if (!secActionsToDelete.isEmpty()) {
          delete secActionsToDelete;
        }

        // Now delete the sections
        if (Question_Book__c.SObjectType.getDescribe().isDeletable()) {
          delete sectionsToDelete;
        }
      }

      // Update records that need their Sub_Text__c modified
      List<Question__c> questionsToUpdate = new List<Question__c>();
      List<Question__c> quesListofST = [
        SELECT
          Id,
          Name,
          Question_Book__c,
          Type__c,
          Question_No__c,
          Question_Text__c,
          Sub_Text__c,
          Form_Identifier__c
        FROM Question__c
        WHERE Id IN :quesIdforST
        WITH SECURITY_ENFORCED
      ];
      for (Question__c q : quesListofST) {
        system.debug(q);
        system.debug('sourceQuestionId ==> ' + q.Sub_Text__c);

        if (q.Sub_Text__c != null) {
          try {
            // Parse the JSON in Sub_Text__c
            Map<String, Object> subTextMap = (Map<String, Object>) JSON.deserializeUntyped(
              q.Sub_Text__c
            );
            String sourceQuestionId = (String) subTextMap.get(
              'sourceQuestionId'
            );
            // If we have a sourceQuestionId that matches a Form_Identifier__c
            if (
              sourceQuestionId != null && !sourceQuestionId.startsWith('a0')
            ) {
              system.debug('sourceQuestionId ==> ' + sourceQuestionId);
              system.debug('formIdToQuestionId ==> ' + formIdToQuestionId);
              system.debug(
                'formIdToQuestionId ==> ' +
                formIdToQuestionId.containsKey(sourceQuestionId)
              );
              // Replace the form identifier with the actual Salesforce Id
              subTextMap.put(
                'sourceQuestionId',
                formIdToQuestionId.get(sourceQuestionId)
              );

              // Create a new question with updated Sub_Text__c
              Question__c updatedQuestion = new Question__c(
                Id = q.Id,
                Sub_Text__c = JSON.serialize(subTextMap)
              );
              questionsToUpdate.add(updatedQuestion);
            }
          } catch (Exception e) {
            System.debug(
              'Error processing Sub_Text__c for question ' +
                q.Id +
                ': ' +
                e.getMessage()
            );
          }
        }
      }

      // Update the records if there are any to update
      if (!questionsToUpdate.isEmpty()) {
        update questionsToUpdate;
      }

      jsonGen.writeObjectField('questionsToDelete list', questionsToDelete);
      jsonGen.writeObjectField('sectionsToDelete list', sectionsToDelete);
      jsonGen.writeObjectField(
        'question book all question list',
        allExistingQuestions
      );
      jsonGen.writeObjectField('current question set id', questionIdList);
      jsonGen.writeObjectField('current section set id', currentSectionIds);
    } catch (Exception e) {
      System.debug('Inside the exception section ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
      jsonGen.writeObjectField('error', e.getMessage());
      jsonGen.writeObjectField('stackTrace', e.getStackTraceString());
    }

    jsonGen.writeObjectField('ques', qList);
    jsonGen.writeEndObject();
    return jsonGen.getAsString();
  }

  // VD 22Jul25 Action handling changes
  public static void handleActionsAndStyles(
    List<Object> containerArray,
    String contextType
  ) {
    List<Actions__c> actionsToUpsert = new List<Actions__c>();
    Set<Id> actionIdsToDelete = new Set<Id>();
    List<Style__c> stylesToUpsert = new List<Style__c>();

    // Temporarily map actionData → Actions__c
    Map<Map<String, Object>, Actions__c> actionDataToActionMap = new Map<Map<String, Object>, Actions__c>();

    for (Object containerObj : containerArray) {
      Map<String, Object> containerData = (Map<String, Object>) containerObj;

      // Get page or section level items
      List<Object> itemsArray = new List<Object>();
      if (
        contextType == 'section' && containerData.containsKey('sectionsArray')
      ) {
        itemsArray = (List<Object>) containerData.get('sectionsArray');
      } else if (contextType == 'page') {
        itemsArray.add(containerData); // Treat as single "page-level"
      } else if (contextType == 'single') {
        itemsArray.add(containerData); // contains actions and questionBookId
      }

      for (Object itemObj : itemsArray) {
        Map<String, Object> itemData = (Map<String, Object>) itemObj;
        // Question_Book__c qb = (Question_Book__c) itemData.get(contextType == 'section' ? 'sectionQB' : 'pageQB');
        Id qbId;
        if (contextType == 'section') {
          qbId = ((Question_Book__c) itemData.get('sectionQB')).Id;
        } else if (contextType == 'page') {
          qbId = ((Question_Book__c) itemData.get('pageQB')).Id;
        } else if (contextType == 'single') {
          qbId = (Id) itemData.get('questionBookId');
        }

        List<Object> actions = itemData.containsKey('actions')
          ? (List<Object>) itemData.get('actions')
          : new List<Object>();

        for (Object actObj : actions) {
          Map<String, Object> actionData = (Map<String, Object>) actObj;

          String actionId = actionData.containsKey('id')
            ? (String) actionData.get('id')
            : '';
          Boolean isDeleted = actionData.containsKey('isDeleted')
            ? (Boolean) actionData.get('isDeleted')
            : false;

          if (isDeleted && String.isNotBlank(actionId)) {
            actionIdsToDelete.add(actionId);
            continue;
          }

          // Build Action record
          Actions__c action = new Actions__c();
          if (String.isNotBlank(actionId) && actionId instanceof Id) {
            action.Id = actionId;
          }
          action.Question_Book__c = qbId;
          action.Name = actionData.containsKey('buttonLabel')
            ? (String) actionData.get('buttonLabel')
            : '';
          action.Event_to_Emit__c = actionData.containsKey('eventToEmit')
            ? (String) actionData.get('eventToEmit')
            : '';
          action.IsActive__c = actionData.containsKey('isActive')
            ? (Boolean) actionData.get('isActive')
            : false;
          action.Order__c = actionData.containsKey('order')
            ? (Decimal) actionData.get('order')
            : null;

          actionDataToActionMap.put(actionData, action);
          actionsToUpsert.add(action);
        }
      }
    }

    // ✅ Upsert actions first
    if (!actionsToUpsert.isEmpty()) {
      upsert actionsToUpsert;
    }

    // ✅ Build styles after actions are inserted
    for (Map<String, Object> actionData : actionDataToActionMap.keySet()) {
      Actions__c action = actionDataToActionMap.get(actionData);
      if (action == null || action.Id == null)
        continue;

      Boolean isDeleted = actionData.containsKey('isDeleted')
        ? (Boolean) actionData.get('isDeleted')
        : false;
      String styleId = actionData.containsKey('styleId')
        ? (String) actionData.get('styleId')
        : '';

      if (!isDeleted) {
        Style__c style = new Style__c();
        if (String.isNotBlank(styleId) && styleId instanceof Id) {
          style.Id = styleId;
        }

        Decimal btnColSize = actionData.containsKey('btnColSize')
          ? (Decimal) actionData.get('btnColSize')
          : 6;
        String btnColStyleClass = actionData.containsKey('btnColStyleClass')
          ? (String) actionData.get('btnColStyleClass')
          : 'slds-size_6-of-12';
        String variant = actionData.containsKey('variant')
          ? (String) actionData.get('variant')
          : 'slds-button slds-button_brand';
        Decimal btnWidth = actionData.containsKey('btnWidth')
          ? (Decimal) actionData.get('btnWidth')
          : 12;
        String btnStyleClass = actionData.containsKey('btnStyleClass')
          ? (String) actionData.get('btnStyleClass')
          : 'slds-button slds-button_brand slds-size_12-of-12';
        Decimal btnHeight = actionData.containsKey('btnHeight')
          ? (Decimal) actionData.get('btnHeight')
          : 40;
        String btnStyle = actionData.containsKey('btnStyle')
          ? (String) actionData.get('btnStyle')
          : 'box-shadow:none;height:40px';
        String btnPosStyle = actionData.containsKey('btnPosStyle')
          ? (String) actionData.get('btnPosStyle')
          : 'text-align:left;';

        Map<String, Object> btnStyleData = new Map<String, Object>{
          'btnHeight' => btnHeight,
          'btnPosStyle' => btnPosStyle,
          'btnStyle' => btnStyle
        };
        Map<String, Object> btnStyleClassData = new Map<String, Object>{
          'variant' => variant,
          'btnWidth' => btnWidth,
          'btnStyleClass' => btnStyleClass
        };

        style.Size__c = btnColSize;
        style.Style_Class__c = btnColStyleClass;
        style.Button_Style__c = JSON.serialize(btnStyleData);
        style.Button_Style_Class__c = JSON.serialize(btnStyleClassData);
        style.Action__c = action.Id;

        stylesToUpsert.add(style);
      }
    }

    // ✅ Delete removed actions & styles
    if (!actionIdsToDelete.isEmpty()) {
      List<Style__c> stylesToDelete = [
        SELECT Id
        FROM Style__c
        WHERE Action__c IN :actionIdsToDelete
      ];
      if (!stylesToDelete.isEmpty())
        delete stylesToDelete;

      List<Actions__c> actionsToDelete = [
        SELECT Id
        FROM Actions__c
        WHERE Id IN :actionIdsToDelete
      ];
      if (!actionsToDelete.isEmpty())
        delete actionsToDelete;
    }

    // ✅ Upsert styles
    if (!stylesToUpsert.isEmpty()) {
      upsert stylesToUpsert;
    }
  }

  // MR 18MAY25 QB Builder Changes
  // RT 24JUN25 - Style Updation fix for New records
  // RT 21AUG25 - QB Style Handling
  // VD 15Sep25 - preview mode handling
  @AuraEnabled
  public static String saveQuestions(
    String qbId,
    String subQuestionsWrapper,
    String qbChange,
    String query,
    string actions,
    string selRecordId
  ) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    Id referenceQbId = QuestionBookService.getQBReferenceQuestion(qbId) ?? null; // RT 25OCT25 - Get reference QB Id
    System.debug('Inside QBID--->' + qbId);
    // VD 22jul24  action Handling
    if (String.isNotBlank(actions)) {
      List<Object> singleBookActionData = new List<Object>{
        new Map<String, Object>{
          'questionBookId' => qbId,
          'actions' => (List<Object>) JSON.deserializeUntyped(actions)
        }
      };
      handleActionsAndStyles(singleBookActionData, 'single');
    }
    // RT 21AUG25 - QB Style Handling
    Object qbChangeObj = JSON.deserializeUntyped(qbChange);
    Map<String, Object> qbChangeMap = (Map<String, Object>) qbChangeObj;
    Object inputObj = qbChangeMap.get('input');
    Object styleObj = qbChangeMap.get('style');
    String input;
    if (inputObj == null) {
      input = null;
    } else if (inputObj instanceof String) {
      input = (String) inputObj;
    } else {
      input = JSON.serialize(inputObj);
    }
    String qbStyle;
    if (styleObj == null) {
      qbStyle = null;
    } else if (styleObj instanceof String) {
      qbStyle = (String) styleObj;
    } else {
      qbStyle = JSON.serialize(styleObj);
    }
    // VD 22Oct25 - book style changes
    // Fetch and update Question_Book__c with query
    if (String.isNotBlank(qbStyle)) {
      Question_Book__c qb = [
        SELECT Id, Query__c, Style__c
        FROM Question_Book__c
        WHERE Id = :qbId
        LIMIT 1
      ];
      qb.Query__c = query;
      qb.Style__c = qbStyle; // RT 21AUG25 - Style Updation
      update qb;
    }
    // RT 29MAY25 - QB Builder Style
    Map<String, Map<String, Object>> styleDataMap1 = new Map<String, Map<String, Object>>();
    // VD 18Jun25 field Meta Handling changes
    Map<String, List<Object>> fmRawByKey = new Map<String, List<Object>>();
    Set<String> fmKeysToDelete = new Set<String>();
    Map<String, String> questionTypesByKey = new Map<String, String>();
    //VD 20Jun25 update field meta handling
    List<Field_Meta__c> fmInsertList = new List<Field_Meta__c>();
    List<Field_Meta__c> fmUpdateList = new List<Field_Meta__c>();
    List<Field_Meta__c> fmDeleteList = new List<Field_Meta__c>();

    // RT 20AUG25 - Dependency Handling
    List<Map<String,Map<String, Object>>> inputDetails = new List<Map<String,Map<String, Object>>>();
    Map<String, Map<String, Object>> inputDetailMap = new Map<String, Map<String, Object>>();


    try {
      List<Object> subQuestions = (List<Object>) JSON.deserializeUntyped(
        subQuestionsWrapper
      );

      // System.debug('Processing ' + subQuestions.size() + ' questions from wrapper');


      for (Object obj : subQuestions) {
        Map<String, Object> jsonObj = (Map<String, Object>) obj;
        String key = (String) jsonObj.get('key');
        String questionId = (String) jsonObj.get('id');
        String element = (String) jsonObj.get('element');

        if (String.isNotBlank(element)) {
          questionTypesByKey.put(key, element);
        }

        // System.debug('Processing question key: ' + key + ', id: ' + questionId);

        // RT 24JUN25 - Add null check for stylestring
        String stylestring = (String) jsonObj.get('style');
        if (String.isNotBlank(stylestring)) {
          try {
            Object styleField = (Object) JSON.deserializeUntyped(stylestring);
            if (
              styleField != null && styleField instanceof Map<String, Object>
            ) {
              Map<String, Object> styleMap1 = (Map<String, Object>) styleField;
              styleDataMap1.put(key, styleMap1);
              // System.debug('Style data processed for key: ' + key + ' -> ' + JSON.serialize(styleMap1));
            }
          } catch (Exception styleEx) {
            jsonGen.writeStringField(
              'styleParseError_' + key,
              styleEx.getMessage()
            );
          }
        }

        // VD 18Jun25 field Meta Handling changes
        // RT 25OCT25 - Multiple Field meta handling 
        // RT 11NOV25 - Fix for Book type handling
        String metafield = (String) jsonObj.get('fieldsMeta');
        if (
          String.isNotBlank(metafield) &&
          // !jsonObj.containsKey('columns') &&
          metafield != '""' &&
          metafield.trim() != ''
        ) {
          if (element != 'Table') {
            try {
              System.debug('Processing fieldsMeta for key: ' + metafield);
              Object fmBlob = (Object) JSON.deserializeUntyped(metafield);
              
              if (fmBlob == null) {
                // UI removed the block  –> schedule delete later
                fmKeysToDelete.add(key);
              } else {
                List<Object> fmArray = (List<Object>) fmBlob;
                fmRawByKey.put(key, fmArray);
                System.debug('field meta size'+ fmArray.size());
              }
              System.debug('Processed fieldsMeta list for key: ' + key + 
                ' -> ' + JSON.serialize(fmRawByKey.get(key))
              );
            } catch (Exception metaEx) {
              System.debug(
                'Error parsing fieldsMeta for key ' +
                  key +
                  ': ' +
                  metaEx.getMessage()
              );
            }
          }
        }
        // VD 16jul25 removed unused comment lines
      }
    } catch (Exception e) {
      // System.debug('Error parsing JSON: ' + e.getMessage());
      jsonGen.writeStringField('parseError', e.getMessage());
    }

    System.debug('Input inside Save Questions ' + input);
    // RT 14AUG25 - Value Field for Input JSON
    List<Input__c> existingInputs = [
      SELECT Id, API_Name__c, Value_Field__c, Type__c, Source_Question_Id__c, Hidden__c, Logics__c, Question_Book__c, Unique_Identifier__c, Question__c
      FROM Input__c
      WHERE Question_Book__c = :qbId
    ];

    //Input Upsertion
    // RT 03JUN25 - Null check
    if (input == null || input == '{}') {
      if (existingInputs != null && !existingInputs.isEmpty()) {
        delete existingInputs;
      }
    } else {
      try {
        // Get the input data
        Map<String, Object> inp = (Map<String, Object>) JSON.deserializeUntyped(
          input
        );

        if (existingInputs != null && !existingInputs.isEmpty()) {
          // Update existing record
          Input__c i = existingInputs[0];
          i.API_Name__c = (String) inp.get('apiName');
          i.Type__c = 'String'; // use (String) inp.get('type') if needed
          update i;
        } else {
          // Insert new record
          Input__c i = new Input__c(
            API_Name__c = (String) inp.get('apiName'),
            Type__c = 'String',
            Question_Book__c = qbId,
            Unique_Identifier__c = qbId
          );
          insert i;
        }
      } catch (Exception e) {
        jsonGen.writeStringField('parseError', e.getMessage());
      }
    }
// VD 22Oct25 - added before process the questions changes


    // Fetch the form
    Form__c form = new Form__c();
    try {
      // RT 12JUN25 - Anchor Object for QB
      form = [
        SELECT Id, Name, Type__c, Anchor_Object__c, Question_Book__c
        FROM Form__c
        WHERE Question_Book__c = :qbId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ];
    } catch (Exception e) {
      form = new Form__c();
      form.Name = 'dummy';
      form.Type__c = 'QuestionBook'; // 12JUN25 - ObjectApi Name come from Table, Book Question
      // VD 25jun25 sample anchor object to avoid the forwrapper exception
      form.Anchor_Object__c = 'Account';
      form.Question_Book__c = qbId;
    }
    FormWrapper formWrapper = new FormWrapper(form);

    List<String> callTree = new List<String>();
    try {
      // Step 01: Get Existing QB Data
      List<Question__c> allExistingQuestions = [
        SELECT Id, Form_Identifier__c, Type__c
        FROM Question__c
        WHERE Question_Book__c = :qbId
      ];

      List<QuestionWrapper> sqList = new List<QuestionWrapper>();
      try {
        sqList = (List<QuestionWrapper>) JSON.deserialize(
          subQuestionsWrapper,
          List<QuestionWrapper>.class
        );
        callTree.add('deserialized ' + sqList.size() + ' questions');
      } catch (Exception e) {
        callTree.add('deserialize exception ' + e.getMessage());
        Object formDataObj = JSON.deserializeUntyped(subQuestionsWrapper);
        List<Object> sqWrapList = (List<Object>) formDataObj;
        for (Object sqWrap : sqWrapList) {
          QuestionWrapper qw = (QuestionWrapper) JSON.deserialize(
            JSON.serialize(sqWrap),
            QuestionWrapper.class
          );
          sqList.add(qw);
        }
      }

      // Step 03: Analyze Questions to be added, changed and removed
      List<Question__c> qUpsertList = new List<Question__c>();
      List<Question__c> qDeleteList = new List<Question__c>();
      List<Option__c> oUpsertList = new List<Option__c>();
      List<Option__c> oDeleteList = new List<Option__c>();

      Set<String> qIdsInInput = new Set<String>();
      // // VD 29Jul25 options handling changes
      Map<String, Question__c> keyToQuestionMap = new Map<String, Question__c>(); // key -> Question__c
      Map<Id, List<Option__c>> existingOptionsMap = new Map<Id, List<Option__c>>();

      // Load existing options for all existing questions
      for (Question__c q : allExistingQuestions) {
        if (
          q.Id != null && q.Type__c == 'Dropdown' ||
          q.Type__c == 'Radio' ||
          q.Type__c == 'Checkbox'
        ) {
          List<Option__c> opts = [
            SELECT Id
            FROM Option__c
            WHERE Question__c = :q.Id
          ];
          existingOptionsMap.put(q.Id, opts);
        }
      }

      // Add/Update Logic
      for (QuestionWrapper qw : sqList) {
        if (String.isBlank(qw.id) || (qw.id != null && qw.id instanceof Id)) {
          // Check Complex Types for QB Reference
          callTree.add(
            'processing ' +
              qw.key +
              ' - ' +
              qw.id +
              ' - ' +
              String.isBlank(qw.qbReference)
          );
          // VD 15july25 - Stop the qbreference book creation for list type
          if (
            (qw.element == 'Book' || qw.element == 'Table') &&
            String.isBlank(qw.qbReference)
          ) {
            callTree.add('inserting QB Reference for ' + qw.key);
            // Need to Create QB for Reference
            Question_Book__c refQB = new Question_Book__c();
            refQB.Title__c = qw.element + ' for ' + qw.key;
            refQB.Category__c = 'Simple';
            refQB.Unique_Identifier__c = qw.key;
            refQB.Anchor_Object__c = qw.objectApiName; // RT 12JUN25 - Anchor Object for QB
            insert refQB;

            qw.qbReference = refQB.Id;
          } else if (qw.element == 'Table' && !String.isBlank(qw.qbReference)) {
            // RT 08OCT25 - Anchor Object Update
            try {
              Question_Book__c existingQB = [
                SELECT Id, Anchor_Object__c
                FROM Question_Book__c
                WHERE Id = :qw.qbReference
                LIMIT 1
              ];
              if(existingQB != null) {
                existingQB.Anchor_Object__c = qw.objectApiName; // RT 08OCT25 - Anchor Object for QB
                update existingQB;
              }
            } catch (Exception e) {
              System.debug('Error fetching existing QB: ' + e.getMessage());
            }
          }
          // VD 15July25 store object apin name for list
          if (qw.element == 'List') {
            qw.title = qw.objectApiName;
          }

          // RT 20AUG25 - Dependency handling in Input
          Map<String, Object> inputDetail = new Map<String, Object>();
          if (qw.inputDetail != null && qw.inputDetail != '{}') {
            String inputDetailStr = (String) qw.inputDetail;
            System.debug('Input Detail1 : ' + inputDetailStr);
            if (inputDetailStr != null && inputDetailStr.trim() != '') {
              Object deserialized = JSON.deserializeUntyped(inputDetailStr);
              if (deserialized instanceof Map<String, Object>) {
                inputDetail = (Map<String, Object>) deserialized;
              } else {
                inputDetail = new Map<String, Object>();
              }
            } else {
              inputDetail = new Map<String, Object>();
            }
            System.debug('Input Detail : ' + inputDetail);
          }

          if (inputDetail != null && !inputDetail.isEmpty()) {
            inputDetailMap.put(qw.key, inputDetail);
          }

          Question__c questionRecord = QuestionWrapper.loadQuestionWrapper(qw);

          qUpsertList.add(questionRecord);
          keyToQuestionMap.put(qw.key, questionRecord);
        }
        qIdsInInput.add(qw.id);
      }

      // Delete Logic
      for (Question__c q : allExistingQuestions) {
        if (!qIdsInInput.contains(q.Id)) {
          qDeleteList.add(q);
        }
      }

      // Maintain original upsert logic for field meta compatibility
      if (!qUpsertList.isEmpty()) {
        upsert qUpsertList;
        // VD 29Jul25 options handling changes
        // Update question Ids in the map (after upsert returns real Ids)
        for (Question__c q : qUpsertList) {
          Question__c qInMap = keyToQuestionMap.get(q.Form_Identifier__c);
          if (qInMap != null) {
            qInMap.Id = q.Id;
          }
        }
      }
      try {
        for (QuestionWrapper qw : sqList) {
          if (
            qw.options != null &&
            (qw.element == 'Dropdown' ||
            qw.element == 'Radio' ||
            qw.element == 'Checkbox')
          ) {
            Question__c parentQ = keyToQuestionMap.get(qw.key);
            System.debug('qw.key-->' + qw.key);
            if (parentQ == null || parentQ.Id == null)
              continue;
            Set<Id> inputOptionIds = new Set<Id>();

            for (OptionWrapper ow : qw.options) {
              Option__c opt = OptionWrapper.loadOptionWrapper(ow, parentQ.Id);
              opt.Is_Default__c = false;
              oUpsertList.add(opt);
              if (String.isNotBlank(ow.id)) {
                inputOptionIds.add((Id) ow.id);
              }
            }
            // Delete existing options not in input
            List<Option__c> existingOpts = existingOptionsMap.get(parentQ.Id);
            if (existingOpts != null) {
              for (Option__c existingOpt : existingOpts) {
                if (!inputOptionIds.contains(existingOpt.Id)) {
                  oDeleteList.add(existingOpt);
                }
              }
            }
          }
        }
      } catch (Exception e) {
        System.debug('message' + e.getMessage());
        System.debug('stackTrace' + e.getStackTraceString());
        System.debug('lineNumber' + e.getLineNumber());
      }

      // === UPSERT OPTIONS ===
      if (!oUpsertList.isEmpty()) {
        upsert oUpsertList;
      }

      List<Id> upsertedIds = new List<Id>();
      // VD 18Jun25 field Meta Handling changes
      Map<String, Id> keyToQId = new Map<String, Id>();

      // RT 20AUG25 - Dependency Handling in Input 
      for (Question__c q : qUpsertList) {
        Map<String, Map<String, Object>> inputDetailId = new Map<String, Map<String, Object>>();
        if (inputDetailMap.containsKey(q.Form_Identifier__c)) {
          inputDetailId.put(q.Form_Identifier__c, inputDetailMap.get(q.Form_Identifier__c));
        }
        upsertedIds.add(q.Id);
        inputDetails.add(inputDetailId);

        // VD 18Jun25 field Meta Handling changes
        keyToQId.put(q.Form_Identifier__c, q.Id);
      }
      
      if(!inputDetails.isEmpty()) {
        processInputDetails(inputDetails, keyToQId);
      }

      List<Question__c> formulaUpdates = new List<Question__c>();

      for (QuestionWrapper qw : sqList) {
        if (!String.isBlank(qw.subText)) {
          String updatedFormula = qw.subText;

          // Use regex to find all {key} placeholders
          Pattern p = Pattern.compile('\\{([^}]+)\\}');
          Matcher m = p.matcher(qw.subText);

          while (m.find()) {
            String key = m.group(1); // the inside of { }
            if (keyToQId.containsKey(key)) {
                String actualId = (String) keyToQId.get(key);
                // replace {key} with {actualId}
                updatedFormula = updatedFormula.replace('{' + key + '}', '{' + actualId + '}');
            }
          }

          if (updatedFormula != qw.subText) {
            formulaUpdates.add(new Question__c(
                Id = (String) keyToQId.get(qw.key), // current question’s Id
                Sub_Text__c = updatedFormula
            ));
          }
        }
      }

      // Update all questions with replaced formulas
      if (!formulaUpdates.isEmpty()) {
          update formulaUpdates;
      }

      // VD 15July25 handle List field metas
      List<Object> subQues = (List<Object>) JSON.deserializeUntyped(
        subQuestionsWrapper
      );
      // After `keyToQId` map is populated from upserted questions
      for (Object obj : subQues) {
        Map<String, Object> jsonObj = (Map<String, Object>) obj;
        String key = (String) jsonObj.get('key');
        String element = (String) jsonObj.get('element');
        String questionId = keyToQId.get(key); // Now we have the actual question Id

        if (element == 'List' && jsonObj.containsKey('columns')) {
          Object columnsObj = jsonObj.get('columns');
          if (columnsObj instanceof List<Object>) {
            List<Object> columns = (List<Object>) columnsObj;
            for (Object col : columns) {
              Map<String, Object> colMap = (Map<String, Object>) col;
              Boolean isDeleted = (Boolean) colMap.get('isdeleted');
              String colId = (String) colMap.get('id');

              if (isDeleted == true && String.isNotBlank(colId)) {
                fmDeleteList.add(new Field_Meta__c(Id = colId));
              } else if (isDeleted != true) {
                try {
                  // RCustomFieldMeta fmWrap = (RCustomFieldMeta) JSON.deserialize(
                  //   JSON.serialize(colMap),
                  //   RCustomFieldMeta.class
                  // );
                  // Field_Meta__c fm = RCustomFieldMeta.loadFieldMetaWrapper(
                  //   fmWrap
                  // );

                  Field_Meta__c fm = new Field_Meta__c(
                    API_Name__c = (String) colMap.get('apiName'),
                    Label__c = (String) colMap.get('label'),
                    fld_type__c = (String) colMap.get('fldType'),
                    searchFlag__c = (Boolean) colMap.get('searchflag'),
                    orderByFlag__c = (Boolean) colMap.get('orderbyflag'),
                    filterFlag__c = (Boolean) colMap.get('filterflag'),
                    Colspan__c = (Decimal) colMap.get('colspan'),
                    Output_Flag__c = (Boolean) colMap.get('outputFlag'),
                    Table_Head_Style__c = (String) colMap.get('tableHeadStyle'),
                    Table_Data_Style__c = (String) colMap.get('tableDataStyle'),
                    Is_Foot__c = (Boolean) colMap.get('isFoot'),
                    Order__c = (Decimal) colMap.get('order'),
                    resultantFlag__c = (Boolean) colMap.get('resultantflag')
                  );

                  if (String.isNotBlank(fm.API_Name__c)) {
                    if (String.isNotBlank(colId)) {
                      fm.Id = colId;
                      fm.Question__c = questionId;
                      fmUpdateList.add(fm);
                    } else {
                      fm.Question__c = questionId;
                      fmInsertList.add(fm);
                    }
                  }
                } catch (Exception e) {
                  jsonGen.writeStringField('parseError', e.getMessage());
                }
              }
            }
          }
        }
      }
      // RT 25JUN25 - Apply styles to ALL questions, but prioritize new records
      if (!qUpsertList.isEmpty() && !styleDataMap1.isEmpty()) {
        // Apply styles to all upserted records
        ProcessAppliedStyles(qUpsertList, styleDataMap1);
      }

      jsonGen.writeObjectField('qUpsertList', qUpsertList);
      // jsonGen.writeObjectField('qNewRecords', qNewRecords);

      // VD 18Jun25 field Meta Handling changes
      // Gather every possible (Question__c, Question_Reference__c) pair we may need
      // RT 25OCT25 - Multiple Field meta handling
      Set<Id> allPossibleQuestionIds = new Set<Id>();
      Set<Id> allPossibleRefIds = new Set<Id>();

      for (String k : fmRawByKey.keySet()) {
        List<Object> rawMap = fmRawByKey.get(k);
        for(Object fmob : rawMap) {
          String qbRefQId = (String) referenceQbId;
        if (keyToQId.containsKey(k))
          allPossibleQuestionIds.add(keyToQId.get(k));
        if (String.isNotBlank(qbRefQId))
          allPossibleQuestionIds.add((Id) qbRefQId);
        if (String.isNotBlank(qbRefQId) && keyToQId.containsKey(k)) {
          allPossibleRefIds.add(keyToQId.get(k));
          allPossibleRefIds.add((Id) qbRefQId);
        }
      }
      }

      // Query every FM that could be the reference target
      Map<String, Field_Meta__c> existingRefByPair = new Map<String, Field_Meta__c>();
      if (!allPossibleQuestionIds.isEmpty()) {
        for (Field_Meta__c fmExisting : [
          SELECT Id, Question__c, Question_Reference__c
          FROM Field_Meta__c
          WHERE
            Question__c IN :allPossibleQuestionIds
            OR Question_Reference__c IN :allPossibleQuestionIds
        ]) {
          String pairKey =
            (String) fmExisting.Question__c +
            '_' +
            (String) fmExisting.Question_Reference__c;
          existingRefByPair.put(pairKey, fmExisting);
        }
      }

      //VD 20Jun25 update field meta handling - Updated to handle multiple field metas
      for (String k : fmRawByKey.keySet()) {
        List<Object> rawMap = fmRawByKey.get(k);
        String element = questionTypesByKey.get(k); // <-- Get element type for this key
        /* Build wrapper -> sObject */
        for(Object fmob : rawMap) {
          System.debug('fmob ' + fmob);
          Map<String, Object> colMap = (Map<String, Object>) fmob;

          String qbRefQId = (String) referenceQbId;
        //   RCustomFieldMeta fmWrapped = (RCustomFieldMeta) JSON.deserialize(
        //   JSON.serialize(fmob),
        //   RCustomFieldMeta.class
        // );
        // Field_Meta__c fm = RCustomFieldMeta.loadFieldMetaWrapper(fmWrapped);
        Field_Meta__c fm = new Field_Meta__c(
          Id = colMap.containsKey('id') ? (String) colMap.get('id') : null,
          API_Name__c = (String) colMap.get('apiName'),
          Label__c = (String) colMap.get('label'),
          fld_type__c = (String) colMap.get('fldType'),
          searchFlag__c = (Boolean) colMap.get('searchflag'),
          orderByFlag__c = (Boolean) colMap.get('orderbyflag'),
          filterFlag__c = (Boolean) colMap.get('filterflag'),
          Colspan__c = (Decimal) colMap.get('colspan'),
          Output_Flag__c = (Boolean) colMap.get('outputFlag'),
          Table_Head_Style__c = (String) colMap.get('tableHeadStyle'),
          Table_Data_Style__c = (String) colMap.get('tableDataStyle'),
          Is_Foot__c = (Boolean) colMap.get('isFoot'),
          Order__c = (Decimal) colMap.get('order'),
          resultantFlag__c = (Boolean) colMap.get('resultantflag')
        );
        if (String.isNotBlank(fm.API_Name__c)) {
          /* new record → set parent */
          if (fm.Id == null) {
            fm.Question__c = keyToQId.get(k);
            fmInsertList.add(fm);
          } else {
            /* existing → DO NOT change Question__c */
            fmUpdateList.add(fm);
          }
        }

        /* ---------- REFERENCE CLONE ---------- */
        if (String.isNotBlank(qbRefQId)) {
          String pairKey = qbRefQId + '_' + keyToQId.get(k);
          List<Field_Meta__c> fmClone = new List<Field_Meta__c>();

          if (existingRefByPair.containsKey(pairKey)) {
            fmClone.add(existingRefByPair.get(pairKey)); // existing row
          } else {
            fmClone = new List<Field_Meta__c>(); // new row
          }

          // /* copy wrapper values */
          // Field_Meta__c fromWrap = RCustomFieldMeta.loadFieldMetaWrapper(
          //   fmWrapped
          // );
          Field_Meta__c fmwrapped = new Field_Meta__c(
            Id = colMap.containsKey('id') ? (String) colMap.get('id') : null,
            API_Name__c = (String) colMap.get('apiName'),
            Label__c = (String) colMap.get('label'),
            fld_type__c = (String) colMap.get('fldType'),
            searchFlag__c = (Boolean) colMap.get('searchflag'),
            orderByFlag__c = (Boolean) colMap.get('orderbyflag'),
            filterFlag__c = (Boolean) colMap.get('filterflag'),
            Colspan__c = (Decimal) colMap.get('colspan'),
            Output_Flag__c = (Boolean) colMap.get('outputFlag'),
            Table_Head_Style__c = (String) colMap.get('tableHeadStyle'),
            Table_Data_Style__c = (String) colMap.get('tableDataStyle'),
            Is_Foot__c = (Boolean) colMap.get('isFoot'),
            Order__c = (Decimal) colMap.get('order'),
            resultantFlag__c = (Boolean) colMap.get('resultantflag')
          );

            // Handle each cloned record in list
            if (!fmClone.isEmpty()) {
            // Update existing clones
            for (Field_Meta__c clone : fmClone) {
              Field_Meta__c cloneCopy = fmwrapped.clone(false, true, false, false);
              cloneCopy.Id = clone.Id; // keep existing Id
              // DO NOT change parent on update
              fmUpdateList.add(cloneCopy);
            }
            } else {
            // Create new clone
            Field_Meta__c newClone = fmwrapped.clone(false, true, false, false);
            newClone.Question__c = (Id) qbRefQId; // parent
            newClone.Question_Reference__c = keyToQId.get(k); // link back
            fmInsertList.add(newClone); 
            }
        }
        }

        /* ---------- PRIMARY RECORD ---------- */
        //VD 16jul25 for list type meta handling
      }

      /* ---------- DML ---------- */
      // RT 06NOV25 - Deduplicate before DML
      fmInsertList = deduplicateFieldMetas(fmInsertList);
      fmUpdateList = deduplicateFieldMetas(fmUpdateList);

      if (!fmInsertList.isEmpty())
        insert fmInsertList;
      if (!fmUpdateList.isEmpty())
        update fmUpdateList;

      if (!qDeleteList.isEmpty()) {
        Set<Id> goneQIds = new Set<Id>();
        for (Question__c qRec : qDeleteList) {
          goneQIds.add(qRec.Id);
        }
        List<Field_Meta__c> cascadeFMs = [
          SELECT Id
          FROM Field_Meta__c
          WHERE Question__c IN :goneQIds OR Question_Reference__c IN :goneQIds
        ];
        
        // Use Set to prevent duplicates when adding cascade deletes
        Set<Id> deleteIds = new Set<Id>();
        for (Field_Meta__c fm : fmDeleteList) {
          if (fm.Id != null) {
            deleteIds.add(fm.Id);
          }
        }
        for (Field_Meta__c fm : cascadeFMs) {
          deleteIds.add(fm.Id);
        }
        
        // Rebuild fmDeleteList with unique Ids
        fmDeleteList.clear();
        for (Id fmId : deleteIds) {
          fmDeleteList.add(new Field_Meta__c(Id = fmId));
        }
      }

      // Final Field‑Meta delete
      if (!fmDeleteList.isEmpty() && 
        Field_Meta__c.SObjectType.getDescribe().isDeletable()) {
        delete fmDeleteList;
      }
      jsonGen.writeObjectField('fmDeleteList', fmDeleteList);

      // Step 05: Delete removed Questions
      if (Question__c.SObjectType.getDescribe().isDeletable()) {
        delete qDeleteList;
      }

      // === VD 29JUL25 DELETE OPTIONS ===
      if (!oDeleteList.isEmpty()) {
        delete oDeleteList;
      }

      jsonGen.writeObjectField('qDeleteList', qDeleteList);
    } catch (Exception e) {
      System.debug('Error: ' + e.getMessage() + ' at line ' + e.getLineNumber() + '\n' + e.getStackTraceString());
      callTree.add(
        'Exception at ' + e.getLineNumber() + ' due to ' + e.getMessage()
      );
      callTree.add(e.getStackTraceString());
      jsonGen.writeFieldName('error');
      jsonGen.writeStartObject(); // Start error object
      jsonGen.writeStringField('message', e.getMessage());
      jsonGen.writeStringField('stackTrace', e.getStackTraceString());
      jsonGen.writeObjectField('lineNumber', e.getLineNumber());
      jsonGen.writeEndObject(); // End error object
    }

    jsonGen.writeStringField('callTree', JSON.serialize(callTree));
    FormWrapper qbfw = QuestionBookService.getQuestions(qbId, 'All');
    formWrapper.qbMap = qbfw.qbMap;
    formWrapper.oMap = qbfw.oMap;
    formWrapper.qMap = qbfw.qMap;
    formWrapper.tMap = qbfw.tMap;
    formWrapper.qbId = qbId;
    // VD 15Sep25 - preview mode handling
    // pass the selected recordId to fetch with values
    QuestionBookHandler qh = new QuestionBookHandler();
    if(String.isNotBlank(selRecordId)){
      qh.setContext('c__record_id', selRecordId);
      qh.setContext('createAnswerBookFlag', false);
    }
    // System.debug('qbId before calling readRecords' + qbId);
    formWrapper.qhResponse = qh.readRecords(qbId, 'All');

    jsonGen.writeObjectField('formWrapper', formWrapper);
    jsonGen.writeEndObject();

    return jsonGen.getAsString();
  }

  // RT 20AUG25 - Method to process input details
  @TestVisible
  private static void processInputDetails (List<Map<String, Map<String, Object>>> inputs, Map<String, Id> sourceIds) {
    List<Input__c> inputsToUpsert = new List<Input__c>();

    for (Map<String, Map<String, Object>> input : inputs) {
      for (String key : input.keySet()) {
        Map<String, Object> inputData = input.get(key);

        // RT 20SEP25 - Salesforce Id check
        Input__c inp = new Input__c();
        String sourceQuestionKey = (String) inputData.get('sourceQuestionId');
        System.debug('sourceids'+ sourceQuestionKey);
        if (String.isNotEmpty(sourceQuestionKey)) {
          if (Utility.isSalesforceId(sourceQuestionKey)) {
            inp.Source_Question_Id__c = sourceQuestionKey;
          } else if (sourceIds.containsKey(sourceQuestionKey)) {
            inp.Source_Question_Id__c = sourceIds.get(sourceQuestionKey);
          }
        }
        // Fix: Assign Question__c as Id type, not String
        if (sourceIds.containsKey(key)) {
          inp.Question__c = sourceIds.get(key);
        }
        if(String.isNotEmpty((String) inputData.get('id'))) {
          inp.Id = (String) inputData.get('id');
        }
        inp.Type__c = 'String'; // Default type, can be changed based on your logic
        inp.Value_Field__c = (String) inputData.get('valueField');
        inp.Hidden__c = inputData.containsKey('hidden') && inputData.get('hidden') != null ? (Boolean)inputData.get('hidden') : true;
        inp.Logics__c = JSON.serialize(inputData.get('logics')) ?? null; // RT 20SEP25 - List to JSON string
        inputsToUpsert.add(inp);
      }
    }

    if(!inputsToUpsert.isEmpty()) {
      try {
        upsert inputsToUpsert;
      } catch (Exception e) {
        System.debug('Error during input upsert: ' + e.getMessage());
      }
    }
  }

  // ASM 09Apr25 Delete Page
  // AT 18Apr25 optimized to deltes pages in bulk
  private static Boolean deletePage(List<String> pageIds, String formId) {
    System.debug('formId' + formId);
    System.debug('Attempting to delete page with ID: ' + pageIds);

    try {
      List<Question_Book__c> pageToDelete = [
        SELECT Id, Name
        FROM Question_Book__c
        WHERE Id IN :pageIds AND Form__c = :formId
        WITH SECURITY_ENFORCED
      ];
      System.debug('pageToDelete' + pageToDelete);

      List<Question_Book__c> sectionsToDelete = [
        SELECT Id
        FROM Question_Book__c
        WHERE Parent_Booklet_QB__c IN :pageIds AND Category__c = 'Simple'
        WITH SECURITY_ENFORCED
      ];

      Set<Id> sectionIds = new Set<Id>();
      for (Question_Book__c section : sectionsToDelete) {
        sectionIds.add(section.Id);
      }

      // Actions/23Apr25/Thangarasu/ActionsToDelete(Related to Pages & Sections)
      List<Actions__c> ActionsToDelete = [
        SELECT Id
        FROM Actions__c
        WHERE Question_Book__c IN :sectionIds OR Question_Book__c IN :pageIds
      ];
      // Actions2/19May25/Thangarasu-Styles to delete
      List<Style__c> stylesToDelete = [
        SELECT Id, Name
        FROM Style__c
        WHERE Action__c IN :ActionsToDelete
      ];
      if (!stylesToDelete.isEmpty()) {
        delete stylesToDelete;
      }

      List<Question__c> questionsToDelete = [
        SELECT Id
        FROM Question__c
        WHERE Question_Book__c IN :sectionIds
        WITH SECURITY_ENFORCED
      ];

      Set<Id> questionIds = new Set<Id>();
      for (Question__c q : questionsToDelete) {
        questionIds.add(q.Id);
      }

      List<Option__c> optionsToDelete = [
        SELECT Id
        FROM Option__c
        WHERE Question__c IN :questionIds
        WITH SECURITY_ENFORCED
      ];

      //to delete styles of page
      List<Style__c> wholestylesToDelete = [
        SELECT Id
        FROM Style__c
        WHERE Question__c IN :questionIds OR Question_Book__c IN :sectionIds
        WITH SECURITY_ENFORCED
      ];
      if (
        !wholestylesToDelete.isEmpty() &&
        Style__c.SObjectType.getDescribe().isDeletable()
      ) {
        Database.DeleteResult[] styleResults = Database.delete(
          wholestylesToDelete,
          false
        );
        for (Database.DeleteResult styleResult : styleResults) {
          if (!styleResult.isSuccess()) {
            System.debug('Failed to delete page: ' + styleResult.getErrors());
          }
        }
      }

      // Delete options
      if (
        !optionsToDelete.isEmpty() &&
        Option__c.SObjectType.getDescribe().isDeletable()
      ) {
        Database.DeleteResult[] optionResults = Database.delete(
          optionsToDelete,
          false
        );
        for (Database.DeleteResult dr : optionResults) {
          if (!dr.isSuccess()) {
            System.debug('Failed to delete option: ' + dr.getErrors());
          }
        }
        System.debug('Deleted ' + optionsToDelete.size() + ' options');
      }

      // Delete questions
      if (
        !questionsToDelete.isEmpty() &&
        Question__c.SObjectType.getDescribe().isDeletable()
      ) {
        Database.DeleteResult[] questionResults = Database.delete(
          questionsToDelete,
          false
        );
        for (Database.DeleteResult dr : questionResults) {
          if (!dr.isSuccess()) {
            System.debug('Failed to delete question: ' + dr.getErrors());
          }
        }
        System.debug('Deleted ' + questionsToDelete.size() + ' questions');
      }

      // Actions/23Apr25/Thangarasu/ Delete Actions (Related to Pages & Sections)
      if (!ActionsToDelete.isEmpty()) {
        System.debug('ActionsToDelete' + ActionsToDelete);
        delete ActionsToDelete;
      }

      // Delete sections
      if (
        !sectionsToDelete.isEmpty() &&
        Question_Book__c.SObjectType.getDescribe().isDeletable()
      ) {
        Database.DeleteResult[] sectionResults = Database.delete(
          sectionsToDelete,
          false
        );
        for (Database.DeleteResult dr : sectionResults) {
          if (!dr.isSuccess()) {
            System.debug('Failed to delete section: ' + dr.getErrors());
          }
        }
        System.debug('Deleted ' + sectionsToDelete.size() + ' sections');
      }

      // Delete the page itself
      if (Question_Book__c.SObjectType.getDescribe().isDeletable()) {
        Database.DeleteResult[] pageResults = Database.delete(
          pageToDelete,
          false
        );
        for (Database.DeleteResult pageResult : pageResults) {
          if (!pageResult.isSuccess()) {
            System.debug('Failed to delete page: ' + pageResult.getErrors());
            return false;
          }
        }
        System.debug('Successfully deleted page: ' + pageIds);
      }

      return true;
    } catch (Exception e) {
      System.debug('Error deleting page: ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
      return false;
    }
  }

  private static void processFieldMetaDataCreation(
    List<Question__c> insertedQuestions,
    Map<String, Map<String, Object>> fieldMetaDataMap,
    String type
  ) {
    List<Field_Meta__c> fieldMetaToInsert = new List<Field_Meta__c>();
    List<Field_Meta__c> fieldMetaToUpdate = new List<Field_Meta__c>();
    List<Field_Meta__c> fieldMetaToDelete = new List<Field_Meta__c>();
    Map<Id, Question__c> qbRefMap = new Map<Id, Question__c>();
    List<Question__c> updateTableQuesParent = new List<Question__c>();
    Set<Id> processedMetaIds = new Set<Id>();

    // Track all existing field metadata
    Map<String, Field_Meta__c> existingFieldMetaByKey = new Map<String, Field_Meta__c>();
    Map<Id, Set<String>> existingApiNamesByQuestionId = new Map<Id, Set<String>>();
    Map<Id, Set<Id>> existingTableRefsByQuestionId = new Map<Id, Set<Id>>();
    Set<Id> questionIds = new Set<Id>();

    // Collect question IDs and initialize tracking maps
    for (Question__c q : insertedQuestions) {
      if (q != null && q.Id != null) {
        questionIds.add(q.Id);
        existingApiNamesByQuestionId.put(q.Id, new Set<String>());
        existingTableRefsByQuestionId.put(q.Id, new Set<Id>());
      }
    }

    if (!questionIds.isEmpty()) {
      // Query all field meta (including deleted) for these questions
      for (Field_Meta__c fm : [
        SELECT
          Id,
          Question__c,
          api_name__c,
          Question_Reference__c,
          IsDeleted,
          order__c
        FROM Field_Meta__c
        WHERE
          Question__c IN :questionIds
          OR Question_Reference__c IN :questionIds
        ALL ROWS
      ]) {
        if (fm.IsDeleted)
          continue;

        String cleanApiName = String.isBlank(fm.api_name__c)
          ? '__none__'
          : fm.api_name__c;
        String key = fm.Question__c + '::' + cleanApiName;
        existingFieldMetaByKey.put(key, fm);

        // Track API names for regular fields
        if (fm.Question__c != null) {
          existingApiNamesByQuestionId.get(fm.Question__c).add(cleanApiName);
        }

        // Track table references
        if (fm.Question_Reference__c != null) {
          String tableRefKey =
            fm.Question__c +
            '::' +
            fm.Question_Reference__c +
            '::' +
            cleanApiName;
          existingFieldMetaByKey.put(tableRefKey, fm);

          if (!existingTableRefsByQuestionId.containsKey(fm.Question__c)) {
            existingTableRefsByQuestionId.put(fm.Question__c, new Set<Id>());
          }
          existingTableRefsByQuestionId.get(fm.Question__c)
            .add(fm.Question_Reference__c);
        }
      }
    }

    try {
      // Handle Table type questions (existing logic)
      if (type == 'Table') {
        List<Question__c> qbRef = [
          SELECT
            Id,
            QB_Reference__c,
            Type__c,
            Question_Book__c,
            Question_Book__r.First_Question__c,
            Question_Parent__c
          FROM Question__c
          WHERE QB_Reference__c != NULL AND Type__c = 'Table'
          LIMIT 10000
        ];

        if (!qbRef.isEmpty()) {
          for (Question__c qb : qbRef) {
            if (qb.QB_Reference__c != null) {
              qbRefMap.put(qb.QB_Reference__c, qb);
            }
            if (
              qb.Question_Parent__c == null &&
              qb.Question_Book__r != null &&
              qb.Question_Book__r.First_Question__c != null
            ) {
              updateTableQuesParent.add(
                new Question__c(
                  Id = qb.Id,
                  Question_Parent__c = qb.Question_Book__r.First_Question__c
                )
              );
            }
          }
        }
      }

      if (!updateTableQuesParent.isEmpty()) {
        update updateTableQuesParent;
      }

      // Process all questions from JSON
      Set<String> jsonApiNames = new Set<String>();
      Map<Id, Set<String>> jsonApiNamesByQuestionId = new Map<Id, Set<String>>();
      Map<Id, Set<Id>> jsonTableRefsByQuestionId = new Map<Id, Set<Id>>();

      // RT 01JUL25 - Added type
      for (Question__c insertedQ : insertedQuestions) {
        if (insertedQ == null || insertedQ.Form_Identifier__c == null)
          continue;

        // Initialize tracking maps for this question
        if (!jsonApiNamesByQuestionId.containsKey(insertedQ.Id)) {
          jsonApiNamesByQuestionId.put(insertedQ.Id, new Set<String>());
        }
        if (!jsonTableRefsByQuestionId.containsKey(insertedQ.Id)) {
          jsonTableRefsByQuestionId.put(insertedQ.Id, new Set<Id>());
        }

        Map<String, Object> metaData = fieldMetaDataMap != null
          ? fieldMetaDataMap.get(insertedQ.Form_Identifier__c)
          : null;
        if (metaData == null)
          continue;

        if (insertedQ.Type__c != 'Table' && insertedQ.Type__c != 'List') {
          // Process regular field types
          String apiName = metaData.containsKey('fieldApiName')
            ? (String) metaData.get('fieldApiName')
            : null;
          Boolean output = metaData.containsKey('outputFlag')
            ? (Boolean) metaData.get('outputFlag')
            : false;
          Boolean orderBy = metaData.containsKey('orderbyflag')
            ? (Boolean) metaData.get('orderbyflag')
            : false;
          Boolean search = metaData.containsKey('searchflag')
            ? (Boolean) metaData.get('searchflag')
            : false;
          Decimal orderNo = metaData.containsKey('fieldNo')
            ? (Decimal) metaData.get('fieldNo')
            : null;
          String metaId = metaData.containsKey('fieldMetaId')
            ? (String) metaData.get('fieldMetaId')
            : null;
          String fieldLabel = metaData.containsKey('label')
            ? (String) metaData.get('label')
            : insertedQ.Question_Text__c;
          String fldType = insertedQ.Type__c != null
            ? insertedQ.Type__c
            : 'Text'; // Default to String if Type is null
          Integer fileCount = metaData.containsKey('fileCount')
            ? (Integer) metaData.get('fileCount')
            : 0;
          Integer fileSize = metaData.containsKey('fileSize')
            ? (Integer) metaData.get('fileSize')
            : 0;
          String fileTypeStr = metaData.containsKey('fileType')
            ? (String) metaData.get('fileType')
            : '';
          Boolean resultant = metaData.containsKey('resultantflag')
            ? (Boolean) metaData.get('resultantflag')
            : false;
          Boolean filterflag = metaData.containsKey('filterflag')
            ? (Boolean) metaData.get('filterflag')
            : false;

          List<Object> fileTypes = fileTypeStr != null
            ? fileTypeStr.split(',')
            : new List<Object>();
          String cleanApiName = String.isBlank(apiName) ? '__none__' : apiName;

          // Track this API name in JSON
          jsonApiNames.add(cleanApiName);
          jsonApiNamesByQuestionId.get(insertedQ.Id).add(cleanApiName);
          // VD 20Sep25 - line element Fix
          if(fldType != 'Line'){
            Field_Meta__c fieldMetaWithQuestion = new Field_Meta__c(
              Question__c = insertedQ.Id,
              api_name__c = apiName,
              Count__c = fileCount,
              File_Size__c = fileSize,
              File_Type__c = String.join(fileTypes, ';'),
              orderByFlag__c = orderBy,
              output_flag__c = output,
              searchFlag__c = search,
              label__c = fieldLabel,
              fld_type__c = fldType,
              filterFlag__c = filterflag,
              resultantFlag__c = resultant,
              order__c = orderNo
            );
  
            String lookupKey = insertedQ.Id + '::' + cleanApiName;
            if (existingFieldMetaByKey.containsKey(lookupKey)) {
              Field_Meta__c existingMeta = existingFieldMetaByKey.get(lookupKey);
              fieldMetaWithQuestion.Id = existingMeta.Id;
              if (!processedMetaIds.contains(existingMeta.Id)) {
                fieldMetaToUpdate.add(fieldMetaWithQuestion);
                processedMetaIds.add(existingMeta.Id);
              }
            } else {
              fieldMetaToInsert.add(fieldMetaWithQuestion);
            }

          }

          // Table reference logic
          if (
            type == 'Table' &&
            insertedQ.Question_Book__c != null &&
            qbRefMap.containsKey(insertedQ.Question_Book__c)
          ) {
            Question__c tableQuestion = qbRefMap.get(
              insertedQ.Question_Book__c
            );
            if (tableQuestion != null) {
              //String tableRefKey = tableQuestion.Id + '::' + insertedQ.Id + '::' + cleanApiName;

              // Track this table reference in JSON
              if (!jsonTableRefsByQuestionId.containsKey(tableQuestion.Id)) {
                jsonTableRefsByQuestionId.put(tableQuestion.Id, new Set<Id>());
              }
              jsonTableRefsByQuestionId.get(tableQuestion.Id).add(insertedQ.Id);
              String orderKey = String.valueOf(orderNo != null ? orderNo : 0);
              String tableRefKey =
                tableQuestion.Id +
                '::' +
                insertedQ.Id +
                '::' +
                cleanApiName +
                '::' +
                orderKey;

              // RT 16MAY25 - Added table head style and table data style
              Map<String, Object> tableFM = fieldMetaDataMap != null
                ? fieldMetaDataMap.get(insertedQ.Form_Identifier__c)
                : null;
              if (tableFM == null)
                continue;

              String tableHeadStyle = tableFM.containsKey('tableHeadStyle')
                ? (String) tableFM.get('tableHeadStyle')
                : '';
              String tableDataStyle = tableFM.containsKey('tableDataStyle')
                ? (String) tableFM.get('tableDataStyle')
                : '';

              Field_Meta__c tableMeta = new Field_Meta__c(
                Question__c = tableQuestion.Id,
                Question_Reference__c = insertedQ.Id,
                api_name__c = apiName,
                orderByFlag__c = orderBy,
                output_flag__c = output,
                searchFlag__c = search,
                label__c = fieldLabel,
                filterFlag__c = filterflag, // VD 22Oct25 - removed unused coode
                fld_type__c = fldType,
                resultantFlag__c = resultant,
                order__c = orderNo,
                Table_Head_Style__c = tableHeadStyle,
                Table_Data_Style__c = tableDataStyle
              );

              if (existingFieldMetaByKey.containsKey(tableRefKey)) {
                tableMeta.Id = existingFieldMetaByKey.get(tableRefKey).Id;
                if (!processedMetaIds.contains(tableMeta.Id)) {
                  fieldMetaToUpdate.add(tableMeta);
                  processedMetaIds.add(tableMeta.Id);
                }
              } else {
                fieldMetaToInsert.add(tableMeta);
              }
            }
          }
        } else if (insertedQ.Type__c == 'List') {
          Map<String, Object> fieldMap1 = (Map<String, Object>) fieldMetaDataMap.get(
            insertedQ.Form_Identifier__c
          );
          // VD 16jul25 for list type - removed unnecessary meta creation

          // Process List type questions
          List<Object> columns = metaData.containsKey('columns')
            ? (List<Object>) metaData.get('columns')
            : new List<Object>();
          for (Object field : columns) {
            if (field == null)
              continue;

            Map<String, Object> fieldMap = (Map<String, Object>) field;
            String apiName = fieldMap.containsKey('fieldApiName')
              ? (String) fieldMap.get('fieldApiName')
              : null;
            if (apiName == null)
              continue;

            Boolean output = fieldMap.containsKey('outputFlag')
              ? (Boolean) fieldMap.get('outputFlag')
              : false;
            Boolean orderBy = fieldMap.containsKey('orderbyflag')
              ? (Boolean) fieldMap.get('orderbyflag')
              : false;
            Boolean resultant = fieldMap.containsKey('resultantflag')
              ? (Boolean) fieldMap.get('resultantflag')
              : false;
            Boolean filterflag = fieldMap.containsKey('filterflag')
              ? (Boolean) fieldMap.get('filterflag')
              : false;
            Boolean isDeleted = fieldMap.containsKey('isdeleted')
              ? (Boolean) fieldMap.get('isdeleted')
              : false;
            Boolean search = fieldMap.containsKey('searchflag')
              ? (Boolean) fieldMap.get('searchflag')
              : false;
            Decimal orderNo = fieldMap.containsKey('fieldNo')
              ? (Decimal) fieldMap.get('fieldNo')
              : null;
            String metaId = fieldMap.containsKey('fieldMetaId')
              ? (String) fieldMap.get('fieldMetaId')
              : null;
            String fieldLabel = fieldMap.containsKey('label')
              ? (String) fieldMap.get('label')
              : null;
            String fieldType = fieldMap.containsKey('type')
              ? (String) fieldMap.get('type')
              : null;
            String tableHeadStyle = fieldMap.containsKey('tableHeadStyle')
              ? (String) fieldMap.get('tableHeadStyle')
              : '';
            String tableDataStyle = fieldMap.containsKey('tableDataStyle')
              ? (String) fieldMap.get('tableDataStyle')
              : '';

            String cleanApiName = String.isBlank(apiName)
              ? '__none__'
              : apiName;

            // Track this API name in JSON
            jsonApiNames.add(cleanApiName);
            jsonApiNamesByQuestionId.get(insertedQ.Id).add(cleanApiName);

            Field_Meta__c fieldMetas = new Field_Meta__c(
              Id = metaId,
              Question__c = insertedQ.Id,
              api_name__c = apiName,
              orderByFlag__c = orderBy,// VD 22Oct25 - removed unused codes
              output_flag__c = output,
              searchFlag__c = search,
              filterFlag__c = filterflag,
              Table_Data_Style__c = tableDataStyle,
              Table_Head_Style__c = tableHeadStyle,
              order__c = orderNo,
              label__c = fieldLabel,
              fld_type__c = fieldType,
              resultantFlag__c = resultant
            );

            if (String.isNotBlank(metaId)) {
              if (!processedMetaIds.contains(metaId)) {
                if (isDeleted) {
                  fieldMetaToDelete.add(fieldMetas);
                } else {
                  fieldMetaToUpdate.add(fieldMetas);
                }
                processedMetaIds.add(metaId);
              }
            } else if (!isDeleted) {
              fieldMetaToInsert.add(fieldMetas);
            }
          }
        } else if (insertedQ.Type__c == 'Table') {
        }
      }

      // Identify orphaned field metadata (exists in DB but not in JSON)
      for (Id questionId : existingApiNamesByQuestionId.keySet()) {
        Set<String> dbApiNames = existingApiNamesByQuestionId.get(questionId);
        Set<String> jsonApiNamesForQuestion = jsonApiNamesByQuestionId.containsKey(
            questionId
          )
          ? jsonApiNamesByQuestionId.get(questionId)
          : new Set<String>();

        // Find API names in DB but not in JSON
        for (String apiName : dbApiNames) {
          if (!jsonApiNamesForQuestion.contains(apiName)) {
            String key = questionId + '::' + apiName;
            if (existingFieldMetaByKey.containsKey(key)) {
              Field_Meta__c fmToDelete = existingFieldMetaByKey.get(key);
              if (!processedMetaIds.contains(fmToDelete.Id)) {
                fieldMetaToDelete.add(fmToDelete);
                processedMetaIds.add(fmToDelete.Id);
              }
            }
          }
        }
      }

      // Identify orphaned table references
      for (Id questionId : existingTableRefsByQuestionId.keySet()) {
        Set<Id> dbTableRefs = existingTableRefsByQuestionId.get(questionId);
        Set<Id> jsonTableRefs = jsonTableRefsByQuestionId.containsKey(
            questionId
          )
          ? jsonTableRefsByQuestionId.get(questionId)
          : new Set<Id>();

        // Find table references in DB but not in JSON
        for (Id refId : dbTableRefs) {
          if (!jsonTableRefs.contains(refId)) {
            // Need to find all field meta for this question+reference combination
            for (Field_Meta__c fm : existingFieldMetaByKey.values()) {
              if (
                fm.Question__c == questionId &&
                fm.Question_Reference__c == refId &&
                !processedMetaIds.contains(fm.Id)
              ) {
                fieldMetaToDelete.add(fm);
                processedMetaIds.add(fm.Id);
              }
            }
          }
        }
      }

      // Perform all DML operations
      if (!fieldMetaToDelete.isEmpty()) {
        List<Database.DeleteResult> deleteResults = Database.delete(
          fieldMetaToDelete,
          false
        );
        for (Database.DeleteResult dr : deleteResults) {
          if (!dr.isSuccess()) {
            for (Database.Error err : dr.getErrors()) {
              if (err.getStatusCode() != StatusCode.ENTITY_IS_DELETED) {
                System.debug('Error deleting field meta: ' + err.getMessage());
              }
            }
          }
        }
      }

      if (!fieldMetaToUpdate.isEmpty())
        update fieldMetaToUpdate;
      if (!fieldMetaToInsert.isEmpty())
        insert fieldMetaToInsert;
    } catch (Exception e) {
      System.debug('Error in processFieldMetaDataCreation: ' + e.getMessage());
      System.debug('Stack trace: ' + e.getStackTraceString());
      throw e;
    }
  }

  private static void processTableElement(
    List<Question__c> tableQuestionsToProcess,
    List<Object> pageArray,
    String rdType
  ) {
    system.debug('table ques' + tableQuestionsToProcess);

    // Fetch existing Question_Book__c if available
    Map<Id, Id> existingTableBookMap = new Map<Id, Id>();
    // VD 10jul25 anchor object save
    for (Question__c q : [
      SELECT Id, QB_Reference__c, Title__c
      FROM Question__c
      WHERE Id IN :tableQuestionsToProcess
    ]) {
      if (q.QB_Reference__c != null) {
        existingTableBookMap.put(q.Id, q.QB_Reference__c);
      }
    }

    List<Question_Book__c> tableBooksToInsert = new List<Question_Book__c>();
    List<Question__c> newTableQuestions = new List<Question__c>();
    Map<Id, Id> tableQuesToTableBookMap = new Map<Id, Id>();

    for (Question__c tableQues : tableQuestionsToProcess) {
      if (existingTableBookMap.containsKey(tableQues.Id)) {
        tableQuesToTableBookMap.put(
          tableQues.Id,
          existingTableBookMap.get(tableQues.Id)
        );
      } else {
        // VD 10jul25 anchor object save
        Question_Book__c tableBook = new Question_Book__c(
          Title__c = 'Table - ' + tableQues.Id,
          Category__c = 'Simple',
          Anchor_Object__c = tableQues.Title__c
        );
        tableBooksToInsert.add(tableBook);
        newTableQuestions.add(tableQues);
      }
    }

    if (!tableBooksToInsert.isEmpty()) {
      insert tableBooksToInsert;
      for (Integer i = 0; i < newTableQuestions.size(); i++) {
        tableQuesToTableBookMap.put(
          newTableQuestions[i].Id,
          tableBooksToInsert[i].Id
        );
      }
    }

    List<Question__c> tableQuestionsToUpdate = new List<Question__c>();
    for (Question__c tableQues : tableQuestionsToProcess) {
      tableQues.QB_Reference__c = tableQuesToTableBookMap.get(tableQues.Id);
      tableQuestionsToUpdate.add(tableQues);
    }
    if (!tableQuestionsToUpdate.isEmpty()) {
      update tableQuestionsToUpdate;
    }

    Map<String, Map<String, Object>> fieldMetaDataMap = new Map<String, Map<String, Object>>();

    for (Object pageObj : pageArray) {
      Map<String, Object> pageData = (Map<String, Object>) pageObj;
      List<Object> sectionsArray = (List<Object>) pageData.get('sectionsArray');

      for (Object sectionObj : sectionsArray) {
        Map<String, Object> sectionData = (Map<String, Object>) sectionObj;
        List<Object> subQuestions = (List<Object>) sectionData.get(
          'subQuestions'
        );

        for (Object item : subQuestions) {
          Map<String, Object> questionData = (Map<String, Object>) item;

          if ('Table'.equals(questionData.get('element'))) {
            String tableQuesKey = (String) questionData.get('key');
            Id tableBookId = null;
            Id matchedQuestionId = null;
            for (Question__c q : tableQuestionsToProcess) {
              if (q.Form_Identifier__c == tableQuesKey) {
                matchedQuestionId = q.Id;
                tableBookId = tableQuesToTableBookMap.get(q.Id);
                break;
              }
            }

            // If still not found (new JSON case), create new book and link
            if (tableBookId == null && matchedQuestionId != null) {
              Question_Book__c newBook = new Question_Book__c(
                Title__c = 'Table - ' + matchedQuestionId,
                Category__c = 'Simple'
              );
              insert newBook;
              tableBookId = newBook.Id;
              tableQuesToTableBookMap.put(matchedQuestionId, tableBookId);

              Question__c matchedQues = [
                SELECT Id, QB_Reference__c
                FROM Question__c
                WHERE Id = :matchedQuestionId
                LIMIT 1
              ];
              matchedQues.QB_Reference__c = tableBookId;
              update matchedQues;
              System.debug(
                'Created new Question_Book__c for Table with ID: ' + tableBookId
              );
            }

            if (tableBookId == null) {
              System.debug(
                'Unable to resolve tableBookId for Table Question Key: ' +
                tableQuesKey
              );
              continue;
            }
          }
        }
      }
    }

    // Update table question parent
  }

  public static Boolean isQuestionObject(String recordId, String targetObject) {
    // Validate record ID
    if (recordId == null || recordId.length() < 3) {
      return false;
    }

    try {
      // Extract prefix from record ID
      String prefix = recordId.substring(0, 3);

      String namespace = [
        SELECT NamespacePrefix
        FROM ApexClass
        WHERE Name = 'RCustomFieldMeta'
        LIMIT 1
      ]
      .NamespacePrefix;

      if (namespace != null) {
        targetObject = namespace + '__' + targetObject;
      }

      // Get the describe information for your specific object
      Schema.SObjectType questionType = Schema.getGlobalDescribe()
        .get(targetObject);
      if (questionType == null) {
        System.debug('Managed Question__c object not found in org');
        return false;
      }

      // Compare key prefixes
      String questionPrefix = questionType.getDescribe().getKeyPrefix();
      System.debug('Expected prefix for RNXT__Question__c: ' + questionPrefix);

      // Check if the record ID matches your managed object's prefix
      if (prefix == questionPrefix) {
        System.debug('Valid RNXT__Question__c record ID: ' + recordId);
        return true;
      }
    } catch (Exception e) {
      System.debug('Error in isQuestionObject: ' + e.getMessage());
      return false;
    }
    return false;
  }
  // AS 21Apr25 - Process applied styles for questions and question books
  // RT 26MAY25 - Added key for Style
  // RT 29MAY25 - Label Class, Label Style, Input Class, Input Style replaced
  private static void ProcessAppliedStyles(
    List<SObject> insertedQuestions,
    Map<String, Map<String, Object>> StyleDataMap
  ) {
    List<Style__c> styleDataToInsert = new List<Style__c>();
    //VD 24OCT25 book style update parent issue fix
    Set<Id> qIds = new Set<Id>();
    for (SObject insertedQ : insertedQuestions) {
      Map<string, Object> styleData = new Map<string, Object>();
      Style__c styleObj = new Style__c();
      if (insertedQ instanceof Question__c) {
        styleData = StyleDataMap.get(
          (string) insertedQ.get('Form_Identifier__c')
        );
        styleObj.Question__c = (string) insertedQ.get('Id');
        //VD 24OCT25 book style update parent issue fix
        qIds.add((string) insertedQ.get('Id'));
      } else if (insertedQ instanceof Question_Book__c) {
        styleData = StyleDataMap.get((string) insertedQ.get('Id'));
        styleObj.Question_Book__c = (string) insertedQ.get('Id');
      }

      System.debug('styleData--->' + styleData);
      if (styleData != null) {
        Map<String, Object> style1 = null;
        if (styleData.get('style') instanceof Map<String, Object>) {
          style1 = (Map<String, Object>) styleData.get('style');
        } else {
          style1 = styleData;
        }
        system.debug('style1--->' + style1);
        // RT 10JUN25 - Style Upsertions and height and width added
        if (style1 != null) {
          String stylekey = (String) style1.get('key');
          styleObj.Id = (string) style1.get('id');
          styleObj.Label_Class__c = (String) style1.get('labelClass');
          styleObj.height__c = (String) style1.get('height');
          styleObj.width__c = (String) style1.get('width');
          styleObj.Label_Style__c = (String) style1.get('labelStyle');
          styleObj.Input_Class__c = (String) style1.get('inputClass');
          styleObj.Input_Style__c = (String) style1.get('inputStyle');
          styleObj.Input_Align__c = (String) style1.get('inputAlign');
          // VD 26Sep25 signPad changes
          styleObj.Stroke_Thickness__c = (Decimal) style1.get('strokeThickness');
          styleObj.Pad_Color__c = (String) style1.get('padColor');
          styleObj.Pen_Color__c = (String) style1.get('penColor');
          styleObj.Sno_Head_Style__c = (String) style1.get('snoHeadStyle');
          styleObj.Sno_Data_Style__c = (String) style1.get('snoDataStyle');
          styleObj.Font__c = (String) style1.get('font');
          styleObj.labelValueStyle__c = (String) style1.get('labelValueStyle');
          styleObj.classHeadFoot__c = (String) style1.get('classHeadFoot');
          styleObj.headerSpaceStyle__c = (String) style1.get(
            'headerSpaceStyle'
          );
          styleObj.footerSpaceStyle__c = (String) style1.get(
            'footerSpaceStyle'
          );
          if (style1.get('showLabel') instanceof Boolean) {
            styleObj.showLabel__c = (Boolean) style1.get('showLabel');
          }
          if (style1.get('isHead') instanceof Boolean) {
            styleObj.isHead__c = (Boolean) style1.get('isHead');
          }
          if (style1.get('isFoot') instanceof Boolean) {
            styleObj.isFoot__c = (Boolean) style1.get('isFoot');
          }
          styleObj.bookStyle__c = (String) style1.get('bookStyle');
          styleObj.ElementStyle__c = (String) style1.get('elementStyle');
          styleObj.CheckboxStyle__c = (String) style1.get('CheckboxStyle');
          // VD jun1025 - removed unhandled style
          styleObj.Label_Color__c = (String) style1.get('fontColor');
          if (
            style1.containsKey('fontSize') && style1.get('fontSize') != null
          ) {
            styleObj.label_font_size__c = Decimal.valueOf(
              String.valueOf(style1.get('fontSize'))
            );
          }
          // VD 20Sep25 - line element Fix
          styleObj.Field_Border_Color__c = (String) style1.get(
            'elementBorderColor'
          );
          styleObj.Field_Input_Color__c = (String) style1.get(
            'elementInputcolor'
          );

          styleDataToInsert.add(styleObj);
          system.debug('styleDataToInsert--->' + styleDataToInsert);
        }
      }
    }
    if (!styleDataToInsert.isEmpty()) {
      upsert styleDataToInsert;
    }
    // VD 24OCT25 book style update parent issue fix
     if (!qIds.isEmpty()) {
      set<Id> QBRefIds = new set<Id>();
      for(Question__c ques : [SELECT Id, Question_Book__c from Question__c where Id IN: qIds]){
        QBRefIds.add(ques.Question_Book__c);
      }
      Map<String, String> qmQuesBookMap = new Map<String, String>();
      for (Question__c ques : [
        SELECT Id, Question_Book__c, QB_Reference__c
        FROM Question__c
        WHERE QB_Reference__c IN :QBRefIds
      ]) {
        if (!QBRefIds.contains(ques.Question_Book__c)) {
          qmQuesBookMap.put(ques.Id, ques.QB_Reference__c);
        }
      }

      if (!qmQuesBookMap.isEmpty()) {
        QuestionService.updateQuestionMeta(qmQuesBookMap.keySet(), qmQuesBookMap);
      }
     }
  }

  // RT 06NOV25 - Deduplicate Field_Meta__c records before DML
  private static List<Field_Meta__c> deduplicateFieldMetas(List<Field_Meta__c> fmList) {
      Map<Id, Field_Meta__c> uniqueMap = new Map<Id, Field_Meta__c>();
      List<Field_Meta__c> result = new List<Field_Meta__c>();
      
      for (Field_Meta__c fm : fmList) {
          if (fm.Id != null) {
              // For records with Id, keep last occurrence (overwrites duplicates)
              uniqueMap.put(fm.Id, fm);
          } else {
              // For new records (no Id), add all
              result.add(fm);
          }
      }
      
      // Add all unique records with Ids
      result.addAll(uniqueMap.values());
      return result;
  }

  /**
   * VD 26jul25 - Added method to handle SPA Page
   * @description
   * Handles creation, update, and deletion of dynamic parent and child records
   * based on a JSON payload passed from LWC. Also resolves temporary IDs used
   * for client-side reference mapping between parent and child records
   */
   @AuraEnabled
   public static String createRecords(String jsonPayload) {
    JSONGenerator jsonGen = JSON.createGenerator(true);
    jsonGen.writeStartObject();
    try {
      Map<String, Object> payload = (Map<String, Object>) JSON.deserializeUntyped(
        jsonPayload
      );
      Map<String, Id> tempIdMap = new Map<String, Id>();
        // VD 26Sep25 signPad changes
        // Track parent Ids by objectName
        Map<String, Id> parentIds = new Map<String, Id>();

      // Step 1: Handle Parent Record
      for (String objectName : payload.keySet()) {
        Object data = payload.get(objectName);
        if (data instanceof Map<String, Object>) {
          Map<String, Object> fields = (Map<String, Object>) data;
          // VD 26Sep25 signPad changes
          // Extract __files__ (don’t let them interfere with insert/update)
          List<Object> files = new List<Object>();
          if (fields.containsKey('__files__')) {
              files = (List<Object>) fields.remove('__files__');
          }
          // VD 03Oct25 - location changes
          List<Object> dtObjList = new List<Object>();
          List<String> dateTimeFields = new List<String>();
          if (fields.containsKey('__dateTimes__')) {
              dtObjList = (List<Object>) fields.remove('__dateTimes__');
              for (Object o : dtObjList) {
                  dateTimeFields.add(String.valueOf(o));
              }
          }

          String tempId = (String) fields.remove('temp__local_id');
          SObject sObj = (SObject) Type.forName('Schema.' + objectName)
            .newInstance();

            // VD 24Sep25 - safe assignment with type handling
            SObjectType parentType = Schema.getGlobalDescribe().get(objectName);
            Map<String, Schema.SObjectField> parentFieldMap = parentType.getDescribe().fields.getMap();
            
            for (String f : fields.keySet()) {
                if (!parentFieldMap.containsKey(f)) continue;
            
                Schema.DescribeFieldResult fieldDesc = parentFieldMap.get(f).getDescribe();
                assignFieldValue(sObj, f, fields.get(f), fieldDesc);
            }
            // VD 03Oct25 - location changes
            // ✅ Assign current Datetime to all deferred fields
            for (String dtField : dateTimeFields) {
              if (parentFieldMap.containsKey(dtField)) {
                  Schema.DescribeFieldResult fieldDesc = parentFieldMap.get(dtField).getDescribe();
                  if (fieldDesc.getType() == Schema.DisplayType.Datetime) {
                      sObj.put(dtField, System.now());
                  } else if (fieldDesc.getType() == Schema.DisplayType.Date) {
                      sObj.put(dtField, Date.today());
                  }
              }
          }
          if (sObj.get('Id') == null) {
            insert sObj;
          } else {
            update sObj;
          }

          if (tempId != null) {
            tempIdMap.put(tempId, sObj.Id);
          }
          // VD 26Sep25 signPad changes
          parentIds.put(objectName, (Id) sObj.get('Id'));

          // ✅ Handle Signature files
          if (!files.isEmpty()) {
              saveSignatureFiles(files, parentIds.get(objectName));
          }
        }
      }
      // Step 2: Handle Children
      List<SObject> toInsert = new List<SObject>();
      List<SObject> toUpdate = new List<SObject>();
      List<Id> toDelete = new List<Id>();
      for (String objectName : payload.keySet()) {
        Object data = payload.get(objectName);
        if (data instanceof List<Object>) {
          SObjectType sObjType = Schema.getGlobalDescribe().get(objectName);
          Map<String, Schema.SObjectField> fieldMap = sObjType.getDescribe()
            .fields.getMap();

          for (Object row : (List<Object>) data) {
            Map<String, Object> fields = (Map<String, Object>) row;
            Boolean isDeleted = (fields.containsKey('isDeleted') &&
            fields.get('isDeleted') == true);
            String recordId = (String) fields.get('Id');

            if (
              isDeleted &&
              String.isNotBlank(recordId) &&
              !recordId.startsWith('new')
            ) {
              toDelete.add((Id) recordId);
              continue;
            }

            SObject child = (SObject) sObjType.newSObject();
            Boolean isUpdate =
              String.isNotBlank(recordId) && Utility.isSalesforceId(recordId);

            for (String f : fields.keySet()) {
              if (f == 'isDeleted')
                continue;

              // Always allow Id
              if (f == 'Id' && isUpdate) {
                child.put(f, fields.get(f));
                continue;
              }

              // Skip unknown fields
              if (!fieldMap.containsKey(f)) {
                System.debug('Skipping unknown field: ' + f);
                continue;
              }

              Object val = fields.get(f);
              if (
                val != null &&
                val instanceof String &&
                ((String) val).startsWith('tempId_')
              ) {
                val = tempIdMap.get((String) val);
              }

              Schema.DescribeFieldResult fieldDesc = fieldMap.get(f)
                .getDescribe();

              if (isUpdate && !fieldDesc.isUpdateable()) {
                System.debug(
                  '⛔ Skipping non-updateable field during update: ' + f
                );
                continue;
              }

              if (!isUpdate && !fieldDesc.isCreateable()) {
                System.debug(
                  '⛔ Skipping non-creatable field during insert: ' + f
                );
                continue;
              }
              // VD 24Sep25 - safe assignment with type handling
              assignFieldValue(child, f, val, fieldDesc);
            }

            if (isUpdate) {
              toUpdate.add(child);
            } else {
              toInsert.add(child);
            }
          }
        }
      }
      if (!toInsert.isEmpty())
        insert toInsert;
      if (!toUpdate.isEmpty())
        update toUpdate;
      if (!toDelete.isEmpty())
        Database.delete(toDelete, false);
      jsonGen.writeStringField('status', 'success');
    } catch (Exception e) {
      // Exception Response
      jsonGen.writeStringField('status', 'error');
      jsonGen.writeFieldName('error');
      jsonGen.writeStartObject();
      jsonGen.writeStringField('message', e.getMessage());
      jsonGen.writeStringField('stackTrace', e.getStackTraceString());
      jsonGen.writeNumberField('lineNumber', e.getLineNumber());
      jsonGen.writeEndObject();
    }
    jsonGen.writeEndObject(); // End root
    return jsonGen.getAsString();
  }

  // VD 24Sep25 - Utility method for type-safe assignment
@TestVisible
  private static void assignFieldValue(
    SObject sObj,
    String fieldName,
    Object val,
    Schema.DescribeFieldResult fieldDesc
) {
    if (val == null) return;

    try {
        Schema.DisplayType fType = fieldDesc.getType();

        if (val instanceof String) {
            String strVal = ((String) val).trim();

            // 🔹 Try ISO 8601 first (standard JSON date format)
            if (fType == Schema.DisplayType.Date) {
                try {
                    sObj.put(fieldName, Date.valueOf(strVal));
                    return;
                } catch (Exception ignore) {}
            } else if (fType == Schema.DisplayType.Datetime) {
                try {
                    sObj.put(fieldName, Datetime.valueOf(strVal));
                    return;
                } catch (Exception ignore) {}
            }

            // 🔹 If ISO parsing fails, try JS-style parsing
            if (fType == Schema.DisplayType.Date || fType == Schema.DisplayType.Datetime) {
                try {
                    Datetime parsedDT = parseFlexibleDate(strVal);

                    if (fType == Schema.DisplayType.Date) {
                        sObj.put(fieldName, parsedDT.date());
                        return;
                    } else {
                        sObj.put(fieldName, parsedDT);
                        return;
                    }
                } catch (Exception ex) {
                    System.debug('⚠️ Could not parse date for ' + fieldName + ': ' + strVal);
                }
            }

            // RT 07JAN26 - Currency and Percentage field handling
            if (fType == Schema.DisplayType.Boolean) {
                sObj.put(fieldName, Boolean.valueOf(strVal));
                return;
            } else if (fType == Schema.DisplayType.Integer) {
                sObj.put(fieldName, Integer.valueOf(strVal));
                return;
            } else if (fType == Schema.DisplayType.Double) {
                sObj.put(fieldName, Double.valueOf(strVal));
                return;
            } else if (fType == Schema.DisplayType.Currency || fType == Schema.DisplayType.Percent) {
                sObj.put(fieldName, Decimal.valueOf(strVal));
                return;
            }
        }

        // Default assignment if no special handling
        sObj.put(fieldName, val);

    } catch (Exception ex) {
        System.debug('⚠️ Failed to assign field: ' + fieldName + ' value: ' + val + ' - ' + ex.getMessage());
    }
}

@TestVisible
private static Datetime parseFlexibleDate(String strVal) {
  // Remove parentheses part e.g. (India Standard Time)
  if (strVal.contains('(')) {
      strVal = strVal.split('\\(')[0].trim();
  }

  // Split parts → "Wed Sep 24 2025 17:56:35 GMT+0530"
  List<String> parts = strVal.split(' ');

  if (parts.size() < 6) {
      throw new AuraHandledException('Unsupported date format: ' + strVal);
  }

  Map<String,Integer> monthMap = new Map<String,Integer>{
      'Jan'=>1,'Feb'=>2,'Mar'=>3,'Apr'=>4,'May'=>5,'Jun'=>6,
      'Jul'=>7,'Aug'=>8,'Sep'=>9,'Oct'=>10,'Nov'=>11,'Dec'=>12
  };

  Integer day    = Integer.valueOf(parts[2]);
  Integer month  = monthMap.get(parts[1]);
  Integer year   = Integer.valueOf(parts[3]);

  String[] timeParts = parts[4].split(':');
  Integer hour   = Integer.valueOf(timeParts[0]);
  Integer minute = Integer.valueOf(timeParts[1]);
  Integer second = Integer.valueOf(timeParts[2]);

  // Handle offset (last part → GMT+0530 or UTC+0530 or IST)
  String offsetPart = parts[5];
  Integer offsetHours = 0;
  Integer offsetMinutes = 0;

  if (offsetPart.contains('+') || offsetPart.contains('-')) {
      String cleanOffset = offsetPart.replace('GMT','').replace('UTC','');
      offsetHours = Integer.valueOf(cleanOffset.substring(0,3));     // +05
      offsetMinutes = Integer.valueOf(cleanOffset.substring(0,1) + cleanOffset.substring(3)); // +30
  }

  // Build as GMT then adjust
  Datetime dt = Datetime.newInstanceGMT(year, month, day,
      hour - offsetHours, minute - offsetMinutes, second);

  return dt;
}

// VD 26Sep25 signPad changes
// VD 29Sep25 signpad datetime/url update changes
private static void saveSignatureFiles(List<Object> files, Id parentId) {
    if (files == null || files.isEmpty() || parentId == null) return;

    // 1️⃣ Collect file metadata
    Map<String, String> fileNameToBase64 = new Map<String, String>();
    Map<String, String> fileNameToUrlField = new Map<String, String>();
    Map<String, String> fileNameToSignDateTimeField = new Map<String, String>();

    for (Object f : files) {
        Map<String, Object> fileMap = (Map<String, Object>) f;

        String base64Data = (String) fileMap.get('base64');
        if (String.isBlank(base64Data)) continue;
        if (base64Data.startsWithIgnoreCase('data:image')) {
            base64Data = base64Data.substringAfter(',');
        }

        String fileName = (String) fileMap.get('fileName');
        if (String.isBlank(fileName)) continue;

        fileNameToBase64.put(fileName, base64Data);

        String urlField = (String) fileMap.get('urlField');
        String signDateTimeField = (String) fileMap.get('signDateTimeField');

        if (String.isNotBlank(urlField)) {
            fileNameToUrlField.put(fileName, urlField);
        }
        if (String.isNotBlank(signDateTimeField)) {
            fileNameToSignDateTimeField.put(fileName, signDateTimeField);
        }
    }
    if (fileNameToBase64.isEmpty()) return;

    // 2️⃣ Insert ContentVersions
    List<ContentVersion> contentVersions = new List<ContentVersion>();
    for (String fileName : fileNameToBase64.keySet()) {
        contentVersions.add(new ContentVersion(
            Title = fileName,
            PathOnClient = fileName,
            VersionData = EncodingUtil.base64Decode(fileNameToBase64.get(fileName)),
            FirstPublishLocationId = parentId
        ));
    }
    insert contentVersions;

    // 3️⃣ Fetch ContentDocuments
    List<ContentDocument> docs = [
        SELECT Id, LatestPublishedVersionId, Title
        FROM ContentDocument
        WHERE Id IN (SELECT ContentDocumentId FROM ContentVersion WHERE Id IN :contentVersions)
    ];

    // 4️⃣ Create ContentDistributions
    List<ContentDistribution> distList = new List<ContentDistribution>();
    for (ContentDocument doc : docs) {
        distList.add(new ContentDistribution(
            Name = doc.Title,
            ContentVersionId = doc.LatestPublishedVersionId,
            PreferencesAllowOriginalDownload = true,
            PreferencesAllowViewInBrowser = true
        ));
    }
    insert distList;

    // 5️⃣ Map fileName → URL
    Map<String, String> fileNameToUrl = new Map<String, String>();
    for (ContentDistribution dist : [
        SELECT Id, Name, DistributionPublicUrl, ContentVersionId
        FROM ContentDistribution
        WHERE Id IN :distList
    ]) {
        String url = dist.DistributionPublicUrl;
        if (String.isBlank(url)) {
            String baseUrl = System.URL.getOrgDomainUrl().toExternalForm();
            url = baseUrl + '/sfc/servlet.shepherd/version/download/' + dist.ContentVersionId;
        }
        fileNameToUrl.put(dist.Name, url);
    }

    // 6️⃣ Update parent record
    SObject parentRecord = Database.query(
        'SELECT Id FROM ' + parentId.getSObjectType() + ' WHERE Id = :parentId LIMIT 1'
    );
    Map<String, Schema.SObjectField> fieldsMap = parentId.getSObjectType().getDescribe().fields.getMap();
    System.debug('fieldsMap-->' + fieldsMap);
    for (String fileName : fileNameToUrl.keySet()) {
        // Update URL field
        if (fileNameToUrlField.containsKey(fileName)) {
            String targetField = fileNameToUrlField.get(fileName);
            if (fieldsMap.containsKey(targetField)) {
                try {
                    Schema.DescribeFieldResult fDesc = fieldsMap.get(targetField).getDescribe();
                    if (fDesc.isUpdateable()) {
                        parentRecord.put(targetField, fileNameToUrl.get(fileName));
                    }
                } catch (Exception e) {
                    System.debug('⚠️ Skipping urlField ' + targetField + ': ' + e.getMessage());
                }
            }
        }
        // Update Signature DateTime field
        if (fileNameToSignDateTimeField.containsKey(fileName)) {
            String dtField = fileNameToSignDateTimeField.get(fileName);
            if (fieldsMap.containsKey(dtField)) {
                try {
                    Schema.DescribeFieldResult fDesc = fieldsMap.get(dtField).getDescribe();
                    if (fDesc.isUpdateable() && fDesc.getType() == Schema.DisplayType.DateTime) {
                        parentRecord.put(dtField, System.now());
                    }
                } catch (Exception e) {
                    System.debug('⚠️ Skipping signDateTimeField ' + dtField + ': ' + e.getMessage());
                }
            }
        }
    }

    update parentRecord;
    System.debug('✅ Parent updated with URL + signature date/time');
}

}