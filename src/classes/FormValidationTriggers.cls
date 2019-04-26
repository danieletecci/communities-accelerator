public class FormValidationTriggers extends TriggersHandler{

    public FormValidationTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);
     
        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
        allow_masterLoop_AfterUpdate = false;
        allow_dataPreparing = true;
        allow_finalLoop_BeforeUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((FormValidation__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((FormValidation__c)recNew);
    }
    
    
    
    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(FormValidation__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
    

    
}