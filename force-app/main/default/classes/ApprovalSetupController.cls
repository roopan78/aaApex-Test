public with sharing class ApprovalSetupController {
    public class ConfigWrapper {
        @AuraEnabled
        public String id;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public Boolean isActive;
        @AuraEnabled
        public String objectApiName;
        @AuraEnabled
        public String triggerName;
        @AuraEnabled
        public String apporvalStep;
        @AuraEnabled
        public Boolean createTrigger;
    }
    
    @AuraEnabled
    public static ConfigWrapper fetchConfig(String configId) {
        Notification_Config__c conf = [
      SELECT
        Id,
        Name,
        Is_Active__c,
        Object_Name__c,
        Approval_Step__c,
        Trigger_Name__c,
        Do_you_want_to_create_a_trigger__c
      FROM Notification_Config__c
      WHERE Id = :configId
      LIMIT 1
    ];
        ConfigWrapper wrap = new ConfigWrapper();
        wrap.id = conf.Id;
        wrap.name = conf.Name;
        wrap.isActive = conf.Is_Active__c;
        wrap.objectApiName = conf.Object_Name__c;
        wrap.triggerName = conf.Trigger_Name__c;
        wrap.apporvalStep = conf.Approval_Step__c;
        wrap.createTrigger = conf.Do_you_want_to_create_a_trigger__c;
        return wrap;
    }
    
    @AuraEnabled
    public static Id saveConfig(String inputJson) {
        ConfigWrapper input = (ConfigWrapper)JSON.deserialize(inputJson, ConfigWrapper.class);
        System.debug('⚠️ before input ' + input);
        Notification_Config__c conf;
        if (input.id != null) {
            conf = [
        SELECT Id
        FROM Notification_Config__c
        WHERE Id = :input.id
        LIMIT 1
      ];
        } else {
            conf = new Notification_Config__c();
        }
        
        conf.Name = input.name;
        conf.Is_Active__c = input.isActive == true ? true : false;
        conf.Object_Name__c = input.objectApiName;
        conf.Trigger_Name__c = input.triggerName;
        conf.Do_you_want_to_create_a_trigger__c = input.createTrigger == true ? true : false;
        System.debug('⚠️ before conf ' + conf);
        upsert conf;
        return conf.Id;
    }
    
    @AuraEnabled
    public static Id updateApprovalStep(String step, String configId) {
        Notification_Config__c conf = [
      SELECT Id, Approval_Step__c
      FROM Notification_Config__c
      WHERE Id = :configId
      LIMIT 1
    ];
        conf.Approval_Step__c = step;
        update conf;
        return conf.Id;
        
    }
    
    @AuraEnabled
    public static String getProcessConfig(Id parentConfigId, String status) {
        try {
            ConfigProcessWrapper wrapperData = new ConfigProcessWrapper();
            wrapperData.processConfig = new List<ConfigProcessWrapper.ProcessConfigWrapper>();
            
            // === Get Notification Process Config for given parent + status ===
            List<Notification_Process_Config__c> npcList = [
            SELECT Id, Name, Status__c, Is_Active__c, Order__c,
                   Action_Template__c, Action_Center_Template__c,
                   (SELECT Id, Api_Name__c, Object_Name__c, Order__c, fld_type__c, Is_Active__c, Question__c,
                   RecordTypeId, Operation_Type__c, Logical_Criteria__c,
                   Condition__c, FilterValue__c
            FROM Field_Metas__r)
            FROM Notification_Process_Config__c
            WHERE Notification_Config__c = :parentConfigId
              AND Status__c = :status
            LIMIT 1
        ];
            
            if (npcList.isEmpty()) {
                return JSON.serialize(wrapperData);
            }
            
            Notification_Process_Config__c npc = npcList[0];
            
            ConfigProcessWrapper.ProcessConfigWrapper pc = new ConfigProcessWrapper.ProcessConfigWrapper();
            pc.id = npc.Id;
            pc.status = npc.Status__c;
            pc.configName = npc.Name;
            pc.isActive = npc.Is_Active__c;
            pc.order = npc.Order__c;
            pc.actionTemplateId = npc.Action_Template__c;
            pc.actionCenterTemplateId = npc.Action_Center_Template__c;
            pc.fieldMetas = new List<ConfigProcessWrapper.FieldMetaWrapper>();
            
            
            for (Field_Meta__c fm : npc.Field_Metas__r) {
                ConfigProcessWrapper.FieldMetaWrapper fmw = new ConfigProcessWrapper.FieldMetaWrapper();
                fmw.id = fm.Id;
                fmw.apiName = fm.Api_Name__c;
                fmw.objectApiName = fm.Object_Name__c;
                fmw.recordType = fm.RecordTypeId != null
                    ? Schema.SObjectType.Field_Meta__c.getRecordTypeInfosById().get(fm.RecordTypeId).getName()
                    : null;
                fmw.question = fm.Question__c;
                fmw.order = Integer.valueOf(fm.Order__c);
                fmw.type = fm.fld_type__c;
                fmw.isActive = fm.Is_Active__c;
                fmw.operationalType = fm.Operation_Type__c;
                fmw.logicalCriteria = fm.Logical_Criteria__c;
                fmw.condition = fm.Condition__c;
                fmw.filterValue = fm.FilterValue__c;
                pc.fieldMetas.add(fmw);
            }
            
            // === Template Config Wrapper ===
            ConfigProcessWrapper.TemplateConfigWrapper tConfig = new ConfigProcessWrapper.TemplateConfigWrapper();
            
            // === Action Template (query by ID) ===
            if (npc.Action_Template__c != null) {
                List<Action_Template__c> atList = [
                SELECT Id, Name, Flow_Type__c,
                       (SELECT Id, Name, Action_Owner__c, Action_Owner_Type__c, Is_Active__c,
                               Is_Optional__c, Order__c, Parent_Action_Template__c
                        FROM Action_Template__r)
                FROM Action_Template__c
                WHERE Id = :npc.Action_Template__c
                LIMIT 1
            ];
                
                if (!atList.isEmpty()) {
                    Action_Template__c parentAT = atList[0];
                    ConfigProcessWrapper.ActionTemplateWrapper atw = new ConfigProcessWrapper.ActionTemplateWrapper();
                    atw.id = parentAT.Id;
                    atw.name = parentAT.Name;
                    atw.flowType = parentAT.Flow_Type__c;
                    atw.templates = new List<ConfigProcessWrapper.TemplateWrapper>();
                    
                    for (Action_Template__c child : parentAT.Action_Template__r) {
                        ConfigProcessWrapper.TemplateWrapper tw = new ConfigProcessWrapper.TemplateWrapper();
                        tw.id = child.Id;
                        tw.name = child.Name;
                        tw.isActive = child.Is_Active__c;
                        tw.isOptional = child.Is_Optional__c;
                        tw.order = Integer.valueOf(child.Order__c);
                        tw.actionOwnerType = child.Action_Owner_Type__c;
                        tw.actionOwnerName = String.valueOf(child.Action_Owner__c);
                        tw.parentActionTemplateId = parentAT.Id;
                        atw.templates.add(tw);
                    }
                    
                    tConfig.actionTemplate = atw;
                }
            }
            
            // === Action Center Template (query by ID) ===
            if (npc.Action_Center_Template__c != null) {
                List<Action_Center_Template__c> actList = [
                SELECT Id, Name, Object_Name__c, Is_Active__c,
                       Task_Comments__c, Task_Subject__c,
                       Post_to_Chatter_Email__c, Post_to_Chatter_Push_Notification__c,
                       Email_Body__c, Email_Subject__c,
                       Notification_Title__c, Notification_Body__c, Post_Body__c, Org_Wide_Email_Address__c,
                       (SELECT Id, Api_Name__c, Object_Name__c, Order__c, fld_type__c, Is_Active__c, Question__c,
                               RecordTypeId, Operation_Type__c, Logical_Criteria__c,
                               Condition__c, FilterValue__c
                        FROM Field_Metas__r)
                FROM Action_Center_Template__c
                WHERE Id = :npc.Action_Center_Template__c
                LIMIT 1
            ];
                
                if (!actList.isEmpty()) {
                    Action_Center_Template__c act = actList[0];
                    ConfigProcessWrapper.ActionCenterTemplateWrapper actw = new ConfigProcessWrapper.ActionCenterTemplateWrapper();
                    actw.id = act.Id;
                    actw.name = act.Name;
                    actw.objectApiName = act.Object_Name__c;
                    actw.isActive = act.Is_Active__c;
                    actw.taskComments = act.Task_Comments__c;
                    actw.taskSubject = act.Task_Subject__c;
                    actw.isPostChatterEmail = act.Post_to_Chatter_Email__c;
                    actw.isPostChatterPushNotification = act.Post_to_Chatter_Push_Notification__c;
                    actw.emailBody = act.Email_Body__c;
                    actw.emailSubject = act.Email_Subject__c;
                    actw.notificationTitle = act.Notification_Title__c;
                    actw.notificationBody = act.Notification_Body__c;
                    actw.postBody = act.Post_Body__c;
                    actw.orgWideEmailAddress = act.Org_Wide_Email_Address__c;
                    actw.fieldMetas = new List<ConfigProcessWrapper.FieldMetaWrapper>();
                    
                    for (Field_Meta__c fm : act.Field_Metas__r) {
                        ConfigProcessWrapper.FieldMetaWrapper fmw = new ConfigProcessWrapper.FieldMetaWrapper();
                        fmw.id = fm.Id;
                        fmw.apiName = fm.Api_Name__c;
                        fmw.objectApiName = fm.Object_Name__c;
                        fmw.recordType = fm.RecordTypeId != null
                            ? Schema.SObjectType.Field_Meta__c.getRecordTypeInfosById().get(fm.RecordTypeId).getName()
                            : null;
                        fmw.question = fm.Question__c;
                        fmw.order = Integer.valueOf(fm.Order__c);
                        fmw.type = fm.fld_type__c;
                        fmw.isActive = fm.Is_Active__c;
                        fmw.operationalType = fm.Operation_Type__c;
                        fmw.logicalCriteria = fm.Logical_Criteria__c;
                        fmw.condition = fm.Condition__c;
                        fmw.filterValue = fm.FilterValue__c;
                        actw.fieldMetas.add(fmw);
                    }
                    
                    tConfig.actionCenterTemplate = actw;
                }
            }
            
            // Attach templateConfig
            pc.templateConfig = tConfig;
            wrapperData.processConfig.add(pc);
            
            return JSON.serialize(wrapperData);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error in getProcessConfig: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveProcessConfig(String wrapperJson, Id parentConfigId) {
        try {
            ConfigProcessWrapper wrapperData =
                (ConfigProcessWrapper) JSON.deserialize(wrapperJson, ConfigProcessWrapper.class);
            
            if (wrapperData == null || wrapperData.processConfig == null) {
                System.debug('⚠️ No process config to save');
                return;
            }
            
            // === Collectors ===
            List<Notification_Process_Config__c> npcsToUpsert = new List<Notification_Process_Config__c>();
            List<Action_Template__c> atsToUpsert = new List<Action_Template__c>();
            List<Action_Template__c> atsToDelete = new List<Action_Template__c>();
            List<Action_Center_Template__c> actsToUpsert = new List<Action_Center_Template__c>();
            List<Field_Meta__c> fmsToUpsert = new List<Field_Meta__c>();
            List<Field_Meta__c> fmsToDelete = new List<Field_Meta__c>();
            Set<Id> deleteIds = new Set<Id>();
            
            // === Temporary Maps ===
            Map<String, Notification_Process_Config__c> npcKeyMap = new Map<String, Notification_Process_Config__c>();
            Map<String, Action_Template__c> actionKeyMap = new Map<String, Action_Template__c>();
            Map<String, Action_Center_Template__c> actCenterKeyMap = new Map<String, Action_Center_Template__c>();
            Map<String, ConfigProcessWrapper.ProcessConfigWrapper> pcWrapperMap = new Map<String, ConfigProcessWrapper.ProcessConfigWrapper>();
            
            // === PASS 1: Build parent records (no children yet) ===
            for (ConfigProcessWrapper.ProcessConfigWrapper pc : wrapperData.processConfig) {
                pcWrapperMap.put(pc.id, pc);
                
                // --- NPC ---
                Notification_Process_Config__c npc = new Notification_Process_Config__c(
                    Id = Utility.isSalesforceId(pc.id) ? pc.id : null,
                Name = pc.configName,
                Status__c = pc.status,
                Notification_Config__c = parentConfigId,
                Is_Active__c = pc.isActive == true ? true : false,
                Order__c = pc.order
                    );
                npcKeyMap.put(pc.id, npc);
                
                // --- ACTION TEMPLATE ---
                if (pc.templateConfig?.actionTemplate != null && !String.isBlank(pc.templateConfig.actionTemplate.name)) {
                    ConfigProcessWrapper.ActionTemplateWrapper atw = pc.templateConfig.actionTemplate;
                    Action_Template__c parentAt = new Action_Template__c(
                        Id = Utility.isSalesforceId(atw.id) ? atw.id : null,
                    Name = atw.name,
                    Flow_Type__c = atw.flowType
                        );
                    actionKeyMap.put(pc.id, parentAt);
                    atsToUpsert.add(parentAt);
                }
                
                // --- ACTION CENTER TEMPLATE ---
                if (pc.templateConfig?.actionCenterTemplate != null && !String.isBlank(pc.templateConfig.actionCenterTemplate.name)) {
                    ConfigProcessWrapper.ActionCenterTemplateWrapper actw = pc.templateConfig.actionCenterTemplate;
                    Action_Center_Template__c parentAct = new Action_Center_Template__c(
                        Id = Utility.isSalesforceId(actw.id) ? actw.id : null,
                    Name = actw.name,
                    Object_Name__c = actw.objectApiName,
                    Is_Active__c = actw.isActive == true ? true : false,
                    Task_Subject__c = actw.taskSubject,
                    Task_Comments__c = actw.taskComments,
                    Post_to_Chatter_Email__c = actw.isPostChatterEmail == true ? true : false,
                    Post_to_Chatter_Push_Notification__c = actw.isPostChatterPushNotification == true ? true : false,
                    Email_Body__c = actw.emailBody,
                    Email_Subject__c = actw.emailSubject,
                    Notification_Title__c = actw.notificationTitle,
                    Notification_Body__c = actw.notificationBody,
                    Post_Body__c = actw.postBody,
                    Org_Wide_Email_Address__c = actw.orgWideEmailAddress
                        );
                    actCenterKeyMap.put(pc.id, parentAct);
                    actsToUpsert.add(parentAct);
                }
            }
            
            // === DML for parents ===
            if (!atsToUpsert.isEmpty()) upsert atsToUpsert;
            if (!actsToUpsert.isEmpty()) upsert actsToUpsert;
            
            // Reconnect NPCs with Action / ActionCenter parents
            for (String pcId : npcKeyMap.keySet()) {
                Notification_Process_Config__c npc = npcKeyMap.get(pcId);
                if (actionKeyMap.containsKey(pcId)) {
                    npc.Action_Template__c = actionKeyMap.get(pcId).Id;
                }
                if (actCenterKeyMap.containsKey(pcId)) {
                    npc.Action_Center_Template__c = actCenterKeyMap.get(pcId).Id;
                }
                npcsToUpsert.add(npc);
            }
            if (!npcsToUpsert.isEmpty()) upsert npcsToUpsert;
            
            // === PASS 2: Handle children now (using real parent Ids) ===
            for (String pcId : pcWrapperMap.keySet()) {
                ConfigProcessWrapper.ProcessConfigWrapper pc = pcWrapperMap.get(pcId);
                
                // Child Action Templates
                if (pc.templateConfig?.actionTemplate?.templates != null) {
                    Action_Template__c parentAt = actionKeyMap.get(pcId);
                    if (parentAt != null) {
                        handleActionTemplateChildren(pc.templateConfig.actionTemplate, parentAt, atsToUpsert, atsToDelete);
                    }
                }
                
                // Action Center Field Metas
                if (pc.templateConfig?.actionCenterTemplate?.fieldMetas != null) {
                    Action_Center_Template__c parentAct = actCenterKeyMap.get(pcId);
                    if (parentAct != null) {
                        handleFieldMetas(pc.templateConfig.actionCenterTemplate.fieldMetas, parentAct.Id, true, fmsToUpsert, fmsToDelete, deleteIds);
                    }
                }
                
                // NPC Field Metas
                if (pc.fieldMetas != null) {
                    Notification_Process_Config__c npc = npcKeyMap.get(pcId);
                    if (npc != null) {
                        handleFieldMetas(pc.fieldMetas, npc.Id, false, fmsToUpsert, fmsToDelete, deleteIds);
                    }
                }
            }
            
            // === Final Child DML ===
            if (!atsToUpsert.isEmpty()) upsert atsToUpsert;
            if (!atsToDelete.isEmpty()) delete atsToDelete;
            if (!fmsToUpsert.isEmpty()) upsert fmsToUpsert;
            if (!fmsToDelete.isEmpty()) delete fmsToDelete;
            
            // === Relink Submitted -> Approved/Rejected ===
            List<Notification_Process_Config__c> submittedRecords = [
            SELECT Id
            FROM Notification_Process_Config__c
            WHERE Notification_Config__c = :parentConfigId
            AND Status__c = 'Submitted For Approval'
            LIMIT 1
        ];
            if (!submittedRecords.isEmpty()) {
                Id parentSubmittedId = submittedRecords[0].Id;
                List<Notification_Process_Config__c> approvedRejectedToUpdate = [
                SELECT Id
                FROM Notification_Process_Config__c
                WHERE Notification_Config__c = :parentConfigId
                AND Status__c IN ('Approved','Rejected')
            ];
                for (Notification_Process_Config__c rec : approvedRejectedToUpdate) {
                    rec.Parent_Notification_Process_Config__c = parentSubmittedId;
                }
                if (!approvedRejectedToUpdate.isEmpty()) {
                    update approvedRejectedToUpdate;
                }
            }
            
        } catch (Exception e) {
            throw new AuraHandledException(
                'Error in saveProcessConfig: ' + e.getMessage() +
                ' | Line: ' + e.getLineNumber()
                );
        }
    }
    
    // ====================== HELPERS ======================
    
    // Handle Action_Template children (upsert + delete)
    private static void handleActionTemplateChildren(
        ConfigProcessWrapper.ActionTemplateWrapper atw,
    Action_Template__c parentAt,
    List<Action_Template__c> atsToUpsert,
    List<Action_Template__c> atsToDelete
    ) {
        if (parentAt == null || parentAt.Id == null) return;
        
        // Query existing children only now that parent has an Id
        List<Action_Template__c> existingChildren = [
        SELECT Id
        FROM Action_Template__c
        WHERE Parent_Action_Template__c = :parentAt.Id
    ];
        Map<Id, Action_Template__c> existingMap = new Map<Id, Action_Template__c>(existingChildren);
        
        Set<Id> keepIds = new Set<Id>();
        
        if (atw.templates != null) {
            for (ConfigProcessWrapper.TemplateWrapper tw : atw.templates) {
                Action_Template__c child = new Action_Template__c(
                    Id = Utility.isSalesforceId(tw.id) ? tw.id : null,
                Parent_Action_Template__c = Utility.isSalesforceId(tw.parentActionTemplateId)
                    ? tw.parentActionTemplateId
                    : parentAt.Id, // fallback to parent
                Name = tw.name,
                Is_Active__c = tw.isActive == true ? true : false,
                Is_Optional__c = tw.isOptional,
                Order__c = tw.order,
                Action_Owner_Type__c = tw.actionOwnerType,
                Action_Owner__c = tw.actionOwnerName
                    );
                atsToUpsert.add(child);
                
                if (child.Id != null) keepIds.add(child.Id);
            }
        }
        
        // Mark any children not in JSON for deletion
        for (Id exId : existingMap.keySet()) {
            if (!keepIds.contains(exId)) atsToDelete.add(existingMap.get(exId));
        }
    }
    
    
    // Handle Field_Meta children (upsert + delete)
    private static void handleFieldMetas(
        List<ConfigProcessWrapper.FieldMetaWrapper> fmWrappers,
    Id parentId,
    Boolean isActionCenter,
    List<Field_Meta__c> fmsToUpsert,
    List<Field_Meta__c> fmsToDelete,
    Set<Id> deleteIds // 🔑 global delete tracker
    ) {
        String namespace = Utility.nameSpace();
        if (parentId == null) return;
        
        String parentField = isActionCenter ? namespace + 'Action_Center_Template__c' : namespace + 'Notification_Process_Config__c';
        
        // Query existing Field Metas
        List<Field_Meta__c> fmList = Database.query(
            'SELECT Id FROM Field_Meta__c WHERE ' + parentField + ' = :parentId'
            );
        Map<Id, Field_Meta__c> existingFms = new Map<Id, Field_Meta__c>(fmList);
        
        // RT 20JAN26 - Get Conditional RecordType Id
        Id conditionalRecordTypeId = Schema.SObjectType.Field_Meta__c.getRecordTypeInfosByDeveloperName().get('Conditional')?.getRecordTypeId();
        
        Set<Id> keepIds = new Set<Id>();
        
        if (fmWrappers != null) {
            for (ConfigProcessWrapper.FieldMetaWrapper fmw : fmWrappers) {
                Boolean isRealId = Utility.isSalesforceId(fmw.id);
                
                Field_Meta__c fm = new Field_Meta__c(
                    Id = isRealId ? fmw.id : null,
                Api_Name__c = fmw.apiName,
                Object_Name__c = fmw.objectApiName,
                Order__c = fmw.order,
                fld_type__c = fmw.type,
                Is_Active__c = fmw.isActive == true ? true : false,
                Operation_Type__c = fmw.operationalType,
                Logical_Criteria__c = fmw.logicalCriteria,
                Condition__c = fmw.condition,
                FilterValue__c = fmw.filterValue,
                RecordTypeId = conditionalRecordTypeId ?? null, // RT 20JAN26 - Always set RecordTypeId to Conditional
                Question__c = fmw.question ?? getMocQuestion()
                    );
                
                if (isActionCenter) { fm.Action_Center_Template__c = parentId; }
                else  { fm.Notification_Process_Config__c = parentId; }
                
                fmsToUpsert.add(fm);
                if (isRealId) { keepIds.add(fm.Id); }
            }
        }
        
        // Mark missing records for deletion
        for (Id exId : existingFms.keySet()) {
            if (!keepIds.contains(exId) && !deleteIds.contains(exId)) {
                fmsToDelete.add(existingFms.get(exId));
                deleteIds.add(exId); // prevent double delete
            }
        }
    }
    
    // RT 20JAN26 - Fetch Org-Wide Email Addresses for combobox
    @AuraEnabled(cacheable=true)
    public static List<OrgWideEmailWrapper> getOrgWideEmailAddresses() {
        List<OrgWideEmailWrapper> options = new List<OrgWideEmailWrapper>();
        for (OrgWideEmailAddress owea : [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE IsAllowAllProfiles = true ORDER BY DisplayName]) {
            OrgWideEmailWrapper wrapper = new OrgWideEmailWrapper();
            wrapper.label = owea.DisplayName != null ? owea.DisplayName + ' <' + owea.Address + '>' : owea.Address;
            wrapper.value = owea.Address;
            options.add(wrapper);
        }
        return options;
    }
    
    public class OrgWideEmailWrapper {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
    }
    
    private static Id getMocQuestion() {
        Question_Book__c mocQBook = new Question_Book__c(
            Title__c = 'MOC QBook'
            );
        insert mocQBook;
        Question__c mocQuestion = new Question__c(
            Question_No__c = 1,
        recordTypeId = Schema.SObjectType.Question__c.getRecordTypeInfosByName().get('UNCONDITIONAL').getRecordTypeId(),
        Type__c = 'Text',
        Question_Book__c = mocQBook.Id
            );
        insert mocQuestion;
        
        return mocQuestion.Id;
    }
    
    
    
}