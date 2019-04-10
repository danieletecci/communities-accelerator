public with sharing class SocialNetworkTriggers extends TriggersHandler{
	public SocialNetworkTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;

        allow_masterLoop_AfterUpdate = true;
        allow_masterLoop_AfterInsert = true;

        allow_dataPreparing = true;
        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;

    }

    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/

    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((SocialNetwork__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((SocialNetwork__c)recNew);    
    }  

    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(SocialNetwork__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalId__c == null){
            recNew.ExternalId__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }

}