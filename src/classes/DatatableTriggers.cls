public class DatatableTriggers extends TriggersHandler {
    
    public List<Datatable__c> objectApiNameChangedList;
    public List<Datatable__c> objectApiNameChangedWithElementsList;
    private static final String DATATABLE_SHARE = '[CMS]Datatable__Share';

	public DatatableTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);
        
        allow_masterLoop_BeforeInsert = true;

        allow_masterLoop_BeforeUpdate = true;
        allow_masterLoop_AfterUpdate = true;
        
        allow_dataPreparing = true;

        allow_finalLoop_BeforeUpdate = true;

        objectApiNameChangedList = new List<Datatable__c>();
        objectApiNameChangedWithElementsList = new List<Datatable__c>();

        // CMS-315 Apex Sharing on Datatable
        allow_masterLoop_AfterInsert = true;

        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;
    }

    public override void dataPreparing() {
        if(objectApiNameChangedList.size() > 0) {
            objectApiNameChangedWithElementsList = [SELECT Id, (SELECT Id FROM DatatableElements__r) FROM Datatable__c WHERE Id IN :objectApiNameChangedList];

            System.debug('CG objectApiNameChangedWithElementsList - ');
            System.debug(objectApiNameChangedWithElementsList);
        }

        // CMS-315 Apex Sharing on Datatable
        if(!recordList.isEmpty() && excecuteTrigger){
            
            SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForRecordsOnCluster(recordList, '[CMS]Cluster__c', DATATABLE_SHARE, '[CMS]Clustering__c',false);
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                excecuteTrigger = false;
            }else{
                datatableShareList  = (List<Datatable__Share>) sharingWrapper.listOfSharesToInsert;
            }
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

    // CMS-315 Apex Sharing on Datatable
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Datatable__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Datatable__c) recNew, (Datatable__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Datatable__c) recNew,null, false);
    }    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Datatable__c) recNew, (Datatable__c) recOld, false);
    }

    List<Datatable__Share> datatableShareList = new List<Datatable__Share>();
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();

    public override void executeDMLs() {
        
        if(!datatableShareList.isEmpty() && excecuteTrigger){
            try{
                insert datatableShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }
    }

    //CMS-315 Apex Sharing on Datatable
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Datatable__c recNew, Datatable__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        
        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey(GeneralUtils.prefix(DATATABLE_SHARE))){                
                if(recOld != null){
                    if(recNew.Cluster__c !=  recOld.Cluster__c){
                        if(recNew.Cluster__c == null){ 
                            excecuteTrigger = false;
                        }
                        else{
                            recordList.add(recNew);
                        }
                    }
                }
                else{                    
                    if(recNew.Cluster__c == null){ 
                        excecuteTrigger = false;
                    }
                    else{
                        recordList.add(recNew);
                    }
                }
            }
        }
        else{
            if(objectIdToMessageErrosMap.containsKey(recNew.Id)){
                recNew.addError(objectIdToMessageErrosMap.get(recNew.Id));
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