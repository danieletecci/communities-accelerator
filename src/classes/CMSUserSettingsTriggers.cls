public with sharing class CMSUserSettingsTriggers extends TriggersHandler {

    // CONSTRUCTOR
    public CMSUserSettingsTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld, false);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true;
        allow_dataPreparing = true;
        allow_finalLoop_BeforeInsert = true;
		allow_finalLoop_BeforeUpdate = true;
    }
    
    // TRIGGER METHODS
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setUserSettingsIds((CMSUserSettings__c) recNew, null);
    	recalculateAudiences((CMSUserSettings__c)recNew, true);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setUserSettingsIds((CMSUserSettings__c) recNew, (CMSUserSettings__c) recOld);
    	recalculateAudiences((CMSUserSettings__c)recNew, true);
    }
    //Data preparing
    public override void dataPreparing() {
        if(!mapClusterAudiences.isEmpty()){
            for(Audience__c aud: [SELECT Id, Cluster__c FROM Audience__c WHERE RecordType.DeveloperName = 'Audience' AND Cluster__c IN: mapClusterAudiences.keySet() AND Status__c = 'Active']){
                mapClusterAudiences.get(aud.Cluster__c).add(aud.Id);
            }
        }
        if(!accountsToSearchACRelationSet.isEmpty() && !contactsToSearchACRelationSet.isEmpty()){
            try{
                for(SObject acRelation: Database.query('SELECT Id, AccountId, ContactId FROM AccountContactRelation WHERE AccountId IN: accountsToSearchACRelationSet AND ContactId IN: contactsToSearchACRelationSet')){
                    mapAccountContactRelation.put(String.ValueOf(acRelation.get('AccountId')) + '-' + String.ValueOf(acRelation.get('ContactId')), (Id)acRelation.get('Id'));
                }
            }catch(Exception e){}
        }

        // CMS-474
        if (!usersSetId.isEmpty()){
            for (CMSUserSettings__c cms : [SELECT Id, User__c FROM CMSUserSettings__c WHERE User__c =: usersSetId]){
                duplicatedUsersMap.put(cms.User__c, cms);
            }
        }
    }

    //Final loops
    public override void finalLoop_BeforeInsert(SObject recNew) {
    	recalculateAudiences((CMSUserSettings__c)recNew, false);
        validateCMSUserDuplication((CMSUserSettings__c)recNew);
    }
    
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	recalculateAudiences((CMSUserSettings__c)recNew, false);
        validateCMSUserDuplication((CMSUserSettings__c)recNew);
    }
    
    // USE CASE METHODS
    Map<String, Set<Id>> mapClusterAudiences = new Map<String, Set<Id>>();
    Set<Id> accountsToSearchACRelationSet = new Set<Id>();
    Set<Id> contactsToSearchACRelationSet = new Set<Id>();
    Map<String, Id> mapAccountContactRelation = new Map<String, Id>();
	private void recalculateAudiences(CMSUserSettings__c recNew, Boolean isMaster){
        if(!canMethod('recalculateAudiences')){return;}

        if(isMaster){
            recNew.Audiences__c = null;

            if(recNew.Cluster__c != null){
                mapClusterAudiences.put(recNew.Cluster__c, new Set<Id>());
            }
            if(recNew.AudienceAccount__c != null){
                accountsToSearchACRelationSet.add(recNew.AudienceAccount__c);
            }
            if(recNew.AudienceContact__c != null){
                accountsToSearchACRelationSet.add(recNew.AudienceContact__c);
            }
        }else{
            Set<Id> audiencesSet = recNew.Cluster__c != null && mapClusterAudiences.containsKey(recNew.Cluster__c) ? mapClusterAudiences.get(recNew.Cluster__c) : null;
            Id acRelationId = recNew.AudienceAccount__c != null && recNew.AudienceContact__c != null && mapAccountContactRelation.containsKey(recNew.AudienceAccount__c + '-' + recNew.AudienceContact__c) ? mapAccountContactRelation.get(recNew.AudienceAccount__c + '-' + recNew.AudienceContact__c) : null;
            if(audiencesSet != null){
                List<String> userAudiences = AudienceUtils.audienceUserCalculation(audiencesSet, recNew.AudienceAccount__c, recNew.AudienceContact__c, mapAccountContactRelation.get(recNew.AudienceAccount__c + '-' + recNew.AudienceContact__c), recNew.CustomRecordId__c);
                recNew.Audiences__c = String.join(userAudiences, ';');
            }
        }        
	}
	
    // CMS-474
    Set<Id> usersSetId = new Set<Id>();
    Map<Id, CMSUserSettings__c> duplicatedUsersMap = new Map<Id, CMSUserSettings__c>();
    private void setUserSettingsIds(CMSUserSettings__c recNew, CMSUserSettings__c recOld){
        // Validate on update only if the user changed, and always on insert
        if (recNew.User__c != null && recOld == null || (recOld.User__c != recNew.User__c)) {
            usersSetId.add(recNew.User__c);
        }
    }
    
    private void validateCMSUserDuplication(CMSUserSettings__c recNew){
        if (duplicatedUsersMap.containsKey(recNew.User__c)){
            // Duplicated User
            recNew.addError(Label.DuplicatedUserValidation);
        }
    }
}