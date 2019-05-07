public class FormElementTriggers extends TriggersHandler{
    
    public FormElementTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
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
        setExternalId((FormElement__c)recNew);
        validateFieldApiName((FormElement__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((FormElement__c)recNew);
        validateFieldApiName((FormElement__c)recNew);
    }
    
    
    
    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(FormElement__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
    
    
    private void validateFieldApiName(FormElement__c recNew){
        if(!canMethod('validateFieldApiName')){return;}
        
        Map<String,Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();
        if(String.IsNotBlank(recNew.ObjectAPIName__c)){
            if(!globalDescribe.containsKey(recNew.ObjectAPIName__c)){
            	recNew.ObjectAPIName__c.addError(Label.NonExistentObjectName);
        	}
            if(globalDescribe.get(recNew.ObjectAPIName__c) != null && globalDescribe.get(recNew.ObjectAPIName__c).getDescribe().fields.getMap().get(recNew.fieldApiName__c) == null){
                recNew.FieldApiName__c.addError(Label.NonExistentFieldName);
            }
        }else if(String.IsNotBlank(recNew.FieldAPIName__c)){
            recNew.FieldApiName__c.addError(Label.NonExistentFieldName);
        }
            
        
        
    }
    
    
    
}
