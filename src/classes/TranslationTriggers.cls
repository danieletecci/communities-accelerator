public with sharing class TranslationTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public TranslationTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_BeforeInsert = true;
		allow_masterLoop_BeforeUpdate = true; 
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
    	setExternalId((Translation__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
    	setExternalId((Translation__c)recNew);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
	private void setExternalId(Translation__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }

}