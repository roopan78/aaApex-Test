public with sharing class TranslationWrapper {
    public String uniqueIdentifier; // Unique_Identifier__c
    public String language;         // Language__c
    public Map<String, Object> translatedText; // Parsed Translated_Text__c (as JSON)

    public TranslationWrapper(Translation__c translation) {
        this.uniqueIdentifier = translation.Unique_Identifier__c;
        this.language = translation.Language__c;

        // Parse Translated_Text__c JSON into a Map
        if (translation.Translated_Text__c != null) {
            this.translatedText = (Map<String, Object>) JSON.deserializeUntyped(translation.Translated_Text__c);
        } else {
            this.translatedText = new Map<String, Object>();
        }
    }
}