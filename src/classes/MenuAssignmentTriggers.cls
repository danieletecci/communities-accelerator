public with sharing class MenuAssignmentTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public MenuAssignmentTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

		allow_masterLoop_AfterInsert = true;
		allow_masterLoop_AfterUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_AfterInsert(SObject recNew) {
    	setExternalId((MenuAssignment__c)recNew);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
    	setExternalId((MenuAssignment__c)recNew);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
	private void setExternalId(MenuAssignment__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
        	recordSelfUpdate(recNew.id, GeneralUtils.prefix('[CMS]ExternalID__c'), recNew.Name);
    	}
	}
}