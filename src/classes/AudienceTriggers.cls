public with sharing class AudienceTriggers extends TriggersHandler{

    public AudienceTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
        allow_masterLoop_AfterInsert = true;
        allow_masterLoop_AfterUpdate = true;
        allow_dataPreparing = true;
        allow_finalLoop_BeforeInsert = true;
        allow_finalLoop_BeforeUpdate = true;
    }

    // MASTER LOOPS
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((Audience__c)recNew);
        convertExternalIdsToSFIds((Audience__c)recNew, null, true);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Audience__c)recNew);
        convertExternalIdsToSFIds((Audience__c)recNew, (Audience__c)recOld, true);
        checkCustomCriteria((Audience__c)recNew, (Audience__c)recOld, true);
        checkCriteriaOnActivation((Audience__c)recNew, (Audience__c)recOld, true);
    }
    public override void masterLoop_AfterInsert(SObject recNew) {
        setExternalIdAudienceGroup((Audience__c)recNew);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        setExternalIdAudienceGroup((Audience__c)recNew);
    }

    // DATA PREPARING
    public override void dataPreparing() {
        if(!audiencesExternalIdsSet.isEmpty()){
            for(Audience__c aud: [SELECT Id, ExternalId__c FROM Audience__c WHERE RecordType.DeveloperName = 'Audience' AND ExternalId__c IN: audiencesExternalIdsSet]){
                audiencesExternalIdsToSFIdMap.put(aud.ExternalId__c, String.ValueOf(aud.Id).substring(0, 15));
            }
        }
        if(!audienceCiteriaMap.isEmpty()){
            for(AudienceCriterion__c audc: [SELECT Id, Audience__c, Order__c FROM AudienceCriterion__c WHERE Audience__c IN: audienceCiteriaMap.keySet()]){
                audienceCiteriaMap.get(audc.Audience__c).add(Integer.ValueOf(audc.Order__c));
            }
        }
        if(!audienceActivated.isEmpty()){
            for(AudienceCriterion__c audc: [SELECT Id, Audience__c FROM AudienceCriterion__c WHERE Audience__c IN: audienceActivated]){
                audienceActivatedWithCriteria.add(audc.Audience__c);
            }
        }
    }

    // FINAL LOOPS
    public override void finalLoop_BeforeInsert(SObject recNew) {
        convertExternalIdsToSFIds((Audience__c)recNew, null, false);
    }
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        convertExternalIdsToSFIds((Audience__c)recNew, (Audience__c)recOld, false);
        checkCustomCriteria((Audience__c)recNew, (Audience__c)recOld, false);
        checkCriteriaOnActivation((Audience__c)recNew, (Audience__c)recOld, false);
    }

    // USE CASE METHODS

    //CMS-90: Definition and completion of External Id
    private void setExternalId(Audience__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.RecordTypeId == AudienceUtils.rtAudience && recNew.ExternalId__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
    private void setExternalIdAudienceGroup(Audience__c recNew){
        if(!canMethod('setExternalIdAudienceGroup')){return;}
        
        if(recNew.RecordTypeId == AudienceUtils.rtAudienceGroup && (recNew.Name == String.ValueOf(recNew.Id).substring(0, 15) || (recNew.ExternalId__c == null) )){
            recordSelfUpdate(recNew.id, 'Name', 'AG-' + recNew.AudienceNumber__c);
            recordSelfUpdate(recNew.id, 'ExternalId__c', GeneralUtils.generateExternalId('AG-' + recNew.AudienceNumber__c, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName()));
        }
    }

    //CMS-96: Convertion of External Ids to SF Ids on Reference Audiences for Audience Groups
    private Set<String> audiencesExternalIdsSet = new Set<String>();
    private Map<String, String> audiencesExternalIdsToSFIdMap = new Map<String, String>();
    private void convertExternalIdsToSFIds(Audience__c recNew, Audience__c recOld, Boolean isMasterLoop){
        if(!canMethod('convertExternalIdsToSFIds')){return;}
        
        if(isMasterLoop){
            if(recNew.RecordTypeId == AudienceUtils.rtAudienceGroup && recNew.ReferenceAudienceExternalIds__c != null && (recOld == null || recNew.ReferenceAudienceExternalIds__c == recOld.ReferenceAudienceExternalIds__c)){
                //Collection of externail Ids
                for(String extId: recNew.ReferenceAudienceExternalIds__c.split(';')){
                    audiencesExternalIdsSet.add(extId);
                }
            }
        }else{
            if(recNew.RecordTypeId == AudienceUtils.rtAudienceGroup && recNew.ReferenceAudienceExternalIds__c != null && (recOld == null || recNew.ReferenceAudienceExternalIds__c == recOld.ReferenceAudienceExternalIds__c)){
                if(recNew.ReferenceAudienceExternalIds__c == null){
                    //If the field with External Ids is empty then the fields with SF Ids must be empty
                    recNew.ReferenceAudience__c = null;
                }else{
                    //Get the SF Ids from the map with External Ids, sort them, and save in the SF Ids field
                    List<String> audienceReferenceSFIds = new List<String>();
                    for(String extId: recNew.ReferenceAudienceExternalIds__c.split(';')){
                        if(audiencesExternalIdsToSFIdMap.containsKey(extId)){
                            audienceReferenceSFIds.add(audiencesExternalIdsToSFIdMap.get(extId));
                        }   
                    }
                    audienceReferenceSFIds.sort();
                    recNew.ReferenceAudience__c = String.join(audienceReferenceSFIds, ';');
                }
            }
        }
    }

    //CMS-96: Validation of Audience Custom Criteria
    private Map<Id, Set<Integer>> audienceCiteriaMap = new map<Id, Set<Integer>>();
    private void checkCustomCriteria(Audience__c recNew, Audience__c recOld, Boolean isMasterLoop){
        if(!canMethod('checkCustomCriteria')){return;}
        
        if(isMasterLoop){
            if(recNew.RecordTypeId == AudienceUtils.rtAudience && recNew.MatchCriteria__c == 'Custom'){
                audienceCiteriaMap.put(recNew.Id, new Set<Integer>());
            }
        }else{
            if(recNew.RecordTypeId == AudienceUtils.rtAudience && recNew.MatchCriteria__c == 'Custom'){
                if(audienceCiteriaMap.containsKey(recNew.Id) && !BooleanExpression.validateExpression(recNew.AudienceCriteria__c, audienceCiteriaMap.get(recNew.Id))){
                    recNew.addError(Label.CustomCriteriaValidation);
                }
            }
        }
    }

    //CMS-96: Validate activation of audience with criteria
    private Set<Id> audienceActivated = new Set<Id>();
    private Set<Id> audienceActivatedWithCriteria = new Set<Id>();
    private void checkCriteriaOnActivation(Audience__c recNew, Audience__c recOld, Boolean isMasterLoop){
        if(!canMethod('checkCriteriaOnActivation')){return;}
        
        if(isMasterLoop){
            if(recNew.RecordTypeId == AudienceUtils.rtAudience && recNew.Status__c == 'Active' && recNew.Status__c != recOld.Status__c){
                audienceActivated.add(recNew.Id);
            }
        }else{
            if(recNew.RecordTypeId == AudienceUtils.rtAudience && recNew.Status__c == 'Active' && recNew.Status__c != recOld.Status__c && !audienceActivatedWithCriteria.contains(recNew.Id)){
                recNew.addError(Label.AudienceValidationOnStatusActivate);
            }
        }
    }
}