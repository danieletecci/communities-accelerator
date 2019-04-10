public with sharing class ContentCartItemTriggers extends TriggersHandler{
	public ContentCartItemTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
		super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
    	
	}

	//Master loops
	//PA-288 Trigger de externalID para el objeto ContentCartItem__c
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((ContentCartItem__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((ContentCartItem__c)recNew);    
    } 




    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    //PA-288 Trigger de externalID para el objeto ContentCartItem__c
    private void setExternalId(ContentCartItem__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
}