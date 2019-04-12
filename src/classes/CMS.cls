public with sharing class CMS {

    public static String prefix = '';

    //This methods updates the CMS User Settings with the audiences calculation
    public static void updateUserSettings(Id userId, Id clusterId, Id accountId, Id contactId, Id acRelationId, Id customRecordId){
        User user;
        try{user = [SELECT Id, UserName FROM User WHERE Id =: userId];}catch(Exception e){}
        
        Cluster__c cluster;
        try{cluster = [SELECT Id FROM Cluster__c WHERE Id =: clusterId];}catch(Exception e){}
        
        if(user != null){
            if(cluster != null){
                CMSUserSettings__c userSettings = getUserSettings(userId);
                
                //CMS User Settings creation
                if(userSettings == null){
                    userSettings = new CMSUserSettings__c(
                        Name = user.UserName,
                        User__c = user.Id
                    );
                }
                userSettings.Cluster__c = cluster.Id;
                userSettings.AudienceAccount__c = accountId;
                userSettings.AudienceContact__c = contactId;

                //Calculate User Audiences
                map<Id, Audience__c> audiencesMap = new map<Id, Audience__c>([SELECT Id FROM Audience__c WHERE RecordType.DeveloperName = 'Audience' AND Cluster__c =: userSettings.Cluster__c AND Status__c = 'Active']);
                List<String> userAudiences = AudienceUtils.audienceUserCalculation(audiencesMap.keySet(), userSettings.AudienceAccount__c, userSettings.AudienceContact__c, acRelationId, customRecordId);
                userSettings.Audiencies__c = String.join(userAudiences, ';');

                //Upsert CMS User Settings
                upsert userSettings;

                CMSUsersSettingsMap.put(user.Id, userSettings);
            }else{
                throw new CMSException('CLUSTER_NOT_FOUND: ' + Label.ExceptionMessageClusterNotFound);
            }
        }else{
            throw new CMSException('USER_NOT_FOUND' + Label.ExceptionMessageUserNotFound);
        }
    }

    //This methods returns the CMS User Settings from a User Id
    private static map<Id, CMSUserSettings__c> CMSUsersSettingsMap;
    public static CMSUserSettings__c getUserSettings(Id userId){
        if(CMSUsersSettingsMap == null){
            CMSUsersSettingsMap = new map<Id, CMSUserSettings__c>();
        }
        if(!CMSUsersSettingsMap.containsKey(userId)){
            try{CMSUsersSettingsMap.put(userId, [SELECT Id, User__c, Cluster__c, Audiencies__c FROM CMSUserSettings__c WHERE User__c =: userId]);}catch(Exception e){}
        }
        
        return CMSUsersSettingsMap.get(userId);
    }

    //This methods returns a set of Audiences External Ids of a User
    public static set<String> getUserAudiences(Id userId){
        set<String> userAudiencesSet = new set<String>();
        if(getUserSettings(userId).Audiencies__c != null){
            userAudiencesSet.addAll(getUserSettings(userId).Audiencies__c.split(';'));
        }
        return userAudiencesSet;
    }
}