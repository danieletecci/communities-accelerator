public class DatatableTriggers extends TriggersHandler {
    
    public List<Datatable__c> objectApiNameChangedList;
    public List<Datatable__c> objectApiNameChangedWithElementsList;

	public DatatableTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);
        
        allow_masterLoop_BeforeInsert = true;

        allow_masterLoop_BeforeUpdate = true;
        allow_masterLoop_AfterUpdate = false;
        
        allow_dataPreparing = true;

        allow_finalLoop_BeforeUpdate = true;

        objectApiNameChangedList = new List<Datatable__c>();
        objectApiNameChangedWithElementsList = new List<Datatable__c>();
    }
	
    public override void dataPreparing() {
        if(objectApiNameChangedList.size() > 0) {
            objectApiNameChangedWithElementsList = [SELECT Id, (SELECT Id FROM DatatableElements__r) FROM Datatable__c WHERE Id IN :objectApiNameChangedList];

            System.debug('CG objectApiNameChangedWithElementsList - ');
            System.debug(objectApiNameChangedWithElementsList);
        }
    }

    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    

    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((Datatable__c)recNew);
        validateObjectApiName((Datatable__c)recNew);
    }

    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Datatable__c)recNew);
        validateObjectApiName((Datatable__c)recNew);
        validateObjectApiNameChange((Datatable__c)recNew, (Datatable__c)recOld);
    }
    
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        System.debug('CG objectApiNameChangedWithElementsList - ');
        System.debug(objectApiNameChangedWithElementsList);

        for(Datatable__c dat : objectApiNameChangedWithElementsList) {
            if(recNew.Id == dat.Id && dat.DatatableElements__r.size() > 0) {
                recNew.addError('You cannot change a Datatable object if it has Elements asociated');
            }
        }
    }

    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    private void validateObjectApiName(Datatable__c recNew) {        
        if(!GeneralUtils.isSafeObject(recNew.ObjectApiName__c)) {
            recNew.addError(recNew.ObjectApiName__c + ' is not a valid Object name');
        }
    }

    private void validateObjectApiNameChange(Datatable__c recNew, Datatable__c recOld) {
         
        objectApiNameChangedList = new List<Datatable__c>();

        if((recNew != null && recOld != null) && (recNew.ObjectApiName__c != recOld.ObjectApiName__c)) {
            objectApiNameChangedList.add(recNew);
        }
    }

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(Datatable__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
}