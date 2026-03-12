/**
 * @description Blocks user deactivation when user is still assigned as approver in active child Action Templates.
 * @author Roopan Thangam
 * @since 02-03-2026
 */
public without sharing class CommCenterInactiveApproverHandler {
    private static final String DEACTIVATION_BLOCK_MESSAGE =
        'This user is assigned as an approver in Action Template. Reassign approver ownership, then deactivate the user.';

    public static void execute(System.TriggerOperation operationType, List<User> newList, Map<Id, User> oldMap) {
        if (operationType == System.TriggerOperation.BEFORE_UPDATE) {
            handleBeforeUserUpdate(newList, oldMap);
        }
    }

    public static void handleBeforeUserUpdate(List<User> newUsers, Map<Id, User> oldUserMap) {
        Set<Id> newlyInactiveUserIds = getNewlyInactiveUserIds(newUsers, oldUserMap);
        if (newlyInactiveUserIds.isEmpty()) {
            return;
        }

        Map<Id, User> deactivatingUsersById = new Map<Id, User>();
        for (User usr : newUsers) {
            if (usr != null && usr.Id != null && newlyInactiveUserIds.contains(usr.Id)) {
                deactivatingUsersById.put(usr.Id, usr);
            }
        }
        if (deactivatingUsersById.isEmpty()) { return; }

        // Query user identity fields to support token-based owner matching.
        Map<Id, User> canonicalUsersById = new Map<Id, User>([
            SELECT Id, Name, Username, Email, Alias
            FROM User
            WHERE Id IN :deactivatingUsersById.keySet()
            WITH SECURITY_ENFORCED
        ]);
        if (canonicalUsersById.isEmpty()) { return; }

        Map<String, Set<Id>> userIdsByLookupKey = buildUserLookupKeyMap(canonicalUsersById.values());
        if (userIdsByLookupKey.isEmpty()) { return; }

        Map<Id, Set<Id>> blockedTemplateIdsByUserId = new Map<Id, Set<Id>>();
        Set<Id> allImpactedTemplateIds = new Set<Id>();
        for (Action_Template__c template : [
            SELECT Id, Action_Owner__c, Parent_Action_Template__c
            FROM Action_Template__c
            WHERE Parent_Action_Template__c != null
            AND Is_Active__c = true
            AND Action_Owner__c != null
            WITH SECURITY_ENFORCED
        ]) {
            List<String> ownerTokens = splitOwnerTokens(template.Action_Owner__c);
            if (ownerTokens.isEmpty()) {
                continue;
            }

            for (String token : ownerTokens) {
                String lookupKey = token.toLowerCase();
                if (!userIdsByLookupKey.containsKey(lookupKey)) {
                    continue;
                }
                for (Id userId : userIdsByLookupKey.get(lookupKey)) {
                    if (!blockedTemplateIdsByUserId.containsKey(userId)) {
                        blockedTemplateIdsByUserId.put(userId, new Set<Id>());
                    }
                    blockedTemplateIdsByUserId.get(userId).add(template.Id);
                    allImpactedTemplateIds.add(template.Id);
                    if (template.Parent_Action_Template__c != null) {
                        blockedTemplateIdsByUserId.get(userId).add(template.Parent_Action_Template__c);
                        allImpactedTemplateIds.add(template.Parent_Action_Template__c);
                    }
                }
            }
        }

        Map<Id, Set<String>> configNamesByTemplateId = getNotificationConfigNamesByActionTemplateId(allImpactedTemplateIds);
        for (Id userId : blockedTemplateIdsByUserId.keySet()) {
            User deactivatingUser = deactivatingUsersById.get(userId);
            if (deactivatingUser == null) {
                continue;
            }

            Set<String> configNames = new Set<String>();
            for (Id templateId : blockedTemplateIdsByUserId.get(userId)) {
                if (configNamesByTemplateId.containsKey(templateId)) {
                    configNames.addAll(configNamesByTemplateId.get(templateId));
                }
            }

            String errorMessage = DEACTIVATION_BLOCK_MESSAGE;
            if (!configNames.isEmpty()) {
                List<String> sortedConfigNames = new List<String>();
                sortedConfigNames.addAll(configNames);
                sortedConfigNames.sort();
                errorMessage += ' Approval Process(es): ' + String.join(sortedConfigNames, ', ') + '.';
            }
            deactivatingUser.addError(errorMessage);
        }
    }

    @TestVisible
    private static Set<Id> getNewlyInactiveUserIds(List<User> newUsers, Map<Id, User> oldUserMap) {
        Set<Id> newlyInactiveUserIds = new Set<Id>();
        if (newUsers == null || newUsers.isEmpty() || oldUserMap == null) {
            return newlyInactiveUserIds;
        }

        for (User newUser : newUsers) {
            if (newUser == null || newUser.Id == null) {
                continue;
            }
            User oldUser = oldUserMap.get(newUser.Id);
            if (oldUser == null) {
                continue;
            }
            if (oldUser.IsActive == true && newUser.IsActive == false) {
                newlyInactiveUserIds.add(newUser.Id);
            }
        }
        return newlyInactiveUserIds;
    }

    private static Map<String, Set<Id>> buildUserLookupKeyMap(List<User> users) {
        Map<String, Set<Id>> userIdsByLookupKey = new Map<String, Set<Id>>();
        if (users == null || users.isEmpty()) {
            return userIdsByLookupKey;
        }

        for (User usr : users) {
            if (usr == null || usr.Id == null) {
                continue;
            }
            String longId = String.valueOf(usr.Id);
            addUserLookupKey(userIdsByLookupKey, longId, usr.Id);
            if (longId.length() >= 15) {
                addUserLookupKey(userIdsByLookupKey, longId.substring(0, 15), usr.Id);
            }
            addUserLookupKey(userIdsByLookupKey, usr.Name, usr.Id);
            addUserLookupKey(userIdsByLookupKey, usr.Username, usr.Id);
            addUserLookupKey(userIdsByLookupKey, usr.Email, usr.Id);
            addUserLookupKey(userIdsByLookupKey, usr.Alias, usr.Id);
        }
        return userIdsByLookupKey;
    }

    private static void addUserLookupKey(Map<String, Set<Id>> userIdsByLookupKey, String value, Id userId) {
        if (String.isBlank(value) || userId == null) {
            return;
        }
        String key = value.toLowerCase();
        if (!userIdsByLookupKey.containsKey(key)) {
            userIdsByLookupKey.put(key, new Set<Id>());
        }
        userIdsByLookupKey.get(key).add(userId);
    }

    @TestVisible
    private static List<String> splitOwnerTokens(String ownerFieldValue) {
        List<String> ownerTokens = new List<String>();
        if (String.isBlank(ownerFieldValue)) {
            return ownerTokens;
        }

        String normalized = ownerFieldValue.replace('\n', ',').replace(';', ',');
        Set<String> uniqueTokens = new Set<String>();
        for (String token : normalized.split(',')) {
            String cleaned = token == null ? null : token.trim();
            if (String.isBlank(cleaned)) {
                continue;
            }
            if (!uniqueTokens.contains(cleaned)) {
                uniqueTokens.add(cleaned);
                ownerTokens.add(cleaned);
            }
        }
        return ownerTokens;
    }

    private static Map<Id, Set<String>> getNotificationConfigNamesByActionTemplateId(Set<Id> actionTemplateIds) {
        Map<Id, Set<String>> configNamesByTemplateId = new Map<Id, Set<String>>();
        if (actionTemplateIds == null || actionTemplateIds.isEmpty()) {
            return configNamesByTemplateId;
        }

        for (Notification_Process_Config__c npc : [
            SELECT Action_Template__c, Notification_Config__r.Name
            FROM Notification_Process_Config__c
            WHERE Action_Template__c IN :actionTemplateIds
            AND Notification_Config__c != null
            WITH SECURITY_ENFORCED
        ]) {
            if (npc.Action_Template__c == null || npc.Notification_Config__r == null || String.isBlank(npc.Notification_Config__r.Name)) {
                continue;
            }
            if (!configNamesByTemplateId.containsKey(npc.Action_Template__c)) {
                configNamesByTemplateId.put(npc.Action_Template__c, new Set<String>());
            }
            configNamesByTemplateId.get(npc.Action_Template__c).add(npc.Notification_Config__r.Name);
        }
        return configNamesByTemplateId;
    }
}