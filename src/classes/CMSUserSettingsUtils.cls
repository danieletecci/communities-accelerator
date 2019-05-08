global with sharing class CMSUserSettingsUtils {
    
    //This methods updates the CMS User Settings with the audiences calculation
    global static void updateUserSettings(Id userId, Id clusterId, Id accountId, Id contactId, Id customRecordId){
        User user;
        try{user = [SELECT Id, UserName FROM User WHERE Id =: userId];}catch(Exception e){}
        

        if(user != null){
            if(Pattern.compile('[a-zA-Z0-9]{15}|[a-zA-Z0-9]{18}').matcher(String.valueOf(clusterId)).matches()){
                Schema.SObjectType sobjectType = clusterId.getSObjectType();
                String sobjectName = sobjectType.getDescribe().getName();
                
                if(GeneralUtils.prefix('[CMS]Cluster__c').equalsIgnoreCase(sobjectName)){
                    CMSUserSettings__c userSettings = getUserSettings(userId);
                    
                    //CMS User Settings creation
                    if(userSettings == null){
                        userSettings = new CMSUserSettings__c(
                            Name = user.UserName,
                            User__c = user.Id
                        );
                    }
                    userSettings.Cluster__c = clusterId;
                    userSettings.AudienceAccount__c = accountId;
                    userSettings.AudienceContact__c = contactId;
                    userSettings.CustomRecordId__c = customRecordId;

                    //Upsert CMS User Settings
                    upsert userSettings;

                    CMSUsersSettingsMap.put(user.Id, userSettings);
                }else{
                    throw new CMSException('CLUSTER_NOT_FOUND: ' + Label.ExceptionMessageClusterNotFound);
                }
            }else{
                throw new CMSException('CLUSTER_NOT_FOUND: ' + Label.ExceptionMessageClusterNotFound);
            }
        }else{
            throw new CMSException('USER_NOT_FOUND' + Label.ExceptionMessageUserNotFound);
        }
    }

    //This methods returns the CMS User Settings from a User Id
    private static Map<Id, CMSUserSettings__c> CMSUsersSettingsMap;
    global static CMSUserSettings__c getUserSettings(Id userId){
        if(CMSUsersSettingsMap == null){
            CMSUsersSettingsMap = new Map<Id, CMSUserSettings__c>();
        }
        if(!CMSUsersSettingsMap.containsKey(userId)){
            try{CMSUsersSettingsMap.put(userId, [SELECT Id, User__c, Cluster__c, Audiences__c FROM CMSUserSettings__c WHERE User__c =: userId]);}catch(Exception e){}
        }
        
        return CMSUsersSettingsMap.get(userId);
    }

    //This methods returns a set of Audiences External Ids of a User
    global static Set<String> getUserAudiences(Id userId){
        Set<String> userAudiencesSet = new Set<String>();
        if(getUserSettings(userId).Audiences__c != null){
            userAudiencesSet.addAll(getUserSettings(userId).Audiences__c.split(';'));
        }
        return userAudiencesSet;
    }
}