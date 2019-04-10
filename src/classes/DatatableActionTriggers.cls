public class DatatableActionTriggers extends TriggersHandler {
    
    public DatatableActionTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
		super(p_triggerNew, p_triggerOld);
		
        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
	}
	
	// Master loops
	// Trigger de externalID para el objeto DatatableAction__c
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((DatatableAction__c)recNew);
    }
    
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((DatatableAction__c)recNew);    
    } 
	
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
    
    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    // Trigger de externalID para el objeto DatatableAction__c
    private void setExternalId(DatatableAction__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
}