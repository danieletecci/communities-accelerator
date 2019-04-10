public with sharing class AudienceUserTriggers extends TriggersHandler{
	public AudienceUserTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
		super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
    	
	}

	//Master loops
	//PA-309 Trigger de externalID para el objeto AudienceUser__c
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((AudienceUser__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((AudienceUser__c)recNew);    
    } 




    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    //PA-309 Trigger de externalID para el objeto AudienceUser__c
    private void setExternalId(AudienceUser__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
}