public with sharing class RecipeIngredientTriggers extends TriggersHandler{
	public RecipeIngredientTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
		super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
    	
	}

	//Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((RecipeIngredient__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((RecipeIngredient__c)recNew);    
    } 


    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(RecipeIngredient__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
}