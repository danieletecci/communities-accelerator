public with sharing class MediaElementTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public MediaElementTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	setExternalId((MediaElement__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	setExternalId((MediaElement__c)recNew);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
	private void setExternalId(MediaElement__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }

}