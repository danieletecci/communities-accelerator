public class DatatableElementTriggers extends TriggersHandler {
    
    public String objectApiName;
    public Map<Id, Datatable__c> datatablesMap = new Map<Id, Datatable__c>();
    public Map<Id, String> datatableElementsObjectMap = new Map<Id, String>();
    
	public DatatableElementTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
		super(p_triggerNew, p_triggerOld);
        
        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
        
        allow_finalLoop_BeforeUpdate = true;
	}
	/* Master loops */
	//PA-309 Trigger de externalID para el objeto DatatableElement__c 
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((DatatableElement__c)recNew);
        validateObjectFieldApiName((DatatableElement__c)recNew);
        validateSearchableField((DatatableElement__c)recNew);
        validateParentMaxQuantity((DatatableElement__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((DatatableElement__c)recNew);
        validateObjectFieldApiName((DatatableElement__c)recNew);
        validateSearchableField((DatatableElement__c)recNew);
    }
    
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        validateObjectFieldApiName((DatatableElement__c)recNew);
    }
    
    public override void triggerPreparing() {
        System.debug('in triggerPreparing');
        
        if(datatableElementsObjectMap.isEmpty()) {
            Set<Id> datatablesIdSet = new Set<Id>();
        	
            List<DatatableElement__c> triggerRecordsList = (List<SObject>) triggerNew;
            
            for(SObject tNew : triggerRecordsList) {
                DatatableElement__c de = (DatatableElement__c)tNew;
                datatablesIdSet.add(de.Datatable__c);
            }
            
            System.debug(datatablesIdSet);
            
            for(Datatable__c dt : [SELECT Id, ObjectApiName__c
                                            , NumberOfColumns__c, (SELECT Id FROM DatatableElements__r) 
                                    FROM Datatable__c WHERE Id IN :datatablesIdSet]) {
                datatablesMap.put(dt.Id, dt);
            }

            for(SObject tNew : triggerRecordsList) {
                DatatableElement__c de = (DatatableElement__c)tNew;
                datatableElementsObjectMap.put(de.Id, datatablesMap.get(de.Datatable__c).ObjectApiName__c);
            }
            
            System.debug('datatableElementsObjectMap: ' + datatableElementsObjectMap);
        }
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    public void validateParentMaxQuantity(DatatableElement__c recNew) {
        Datatable__c dt = datatablesMap.get(recNew.Datatable__c);

        System.debug('in validateParentMaxQuantity - dt.DatatableElements__r.size(): ' + dt.DatatableElements__r.size() + ' - dt.NumberOfColumns__c: ' + dt.NumberOfColumns__c);

        if((dt.DatatableElements__r.size() + 1) > Integer.valueOf(dt.NumberOfColumns__c)) {
            recNew.addError('Max. number of elements reached.');
        }
        
    }
    public void validateObjectFieldApiName(DatatableElement__c recNew) {
        String objectName = this.datatableElementsObjectMap.get(recNew.Id);
        
        if(GeneralUtils.isSafeField(this.datatableElementsObjectMap.get(recNew.Id), recNew.FieldApiName__c)) {
            Schema.DisplayType elementType = Schema.getGlobalDescribe().get(this.datatableElementsObjectMap.get(recNew.Id)).getDescribe().fields.getMap().get(recNew.FieldApiName__c).getDescribe().getType(); 
           	recNew.Type__c = String.valueOf(elementType);
        }else {
            recNew.addError(recNew.FieldApiName__c + ' is not a valid field for the ' + objectName + ' object');
        }
    }
    
    public void validateSearchableField(DatatableElement__c recNew) {
        System.debug('validateSearchableField - recNew.Searchable__c: ' + recNew.Searchable__c + ' - recNew.Type__c: ' + recNew.Type__c);
        
        if(recNew.Searchable__c && recNew.Type__c != String.valueOf(Schema.DisplayType.STRING)) {
            recNew.addError(recNew.FieldApiName__c + ' cannot be Searchable');
        }
    }
    
    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
	// Trigger de externalID para el objeto DatatableElement__c
    private void setExternalId(DatatableElement__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, null, recNew.getSObjectType().getDescribe().getName());
        }
    }
}