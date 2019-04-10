public class DatatableTriggers extends TriggersHandler {
    
	public DatatableTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);
        
        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;

        //PA-177 CMA: Clustering: Apex Sharing
        allow_masterLoop_AfterUpdate = true;
        allow_masterLoop_AfterInsert = true;

        allow_dataPreparing = true;
        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;
    }
	
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((Datatable__c)recNew);
        validateObjectApiName((Datatable__c)recNew);
    }
    
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Datatable__c)recNew);
        validateObjectApiName((Datatable__c)recNew);
    }    
	
    // Clustering: Apex Sharing
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

    //PA-177 CMA: Clustering: Apex Sharing
    List<Datatable__Share> datatableShareList = new List<Datatable__Share>();
    
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrorsMap = new Map<Id,String>();
    
    public override void dataPreparing() {
        if(!recordList.isEmpty() && excecuteTrigger){
            
            ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForRecordsOnCluster(recordList, 'Cluster__c', 'Datatable__Share', 'Clustering__c', false);
            
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrorsMap = sharingWrapper.objectIdToMessageErrosMap;
                excecuteTrigger = false;
            }else{
                datatableShareList = (List<Datatable__Share>) sharingWrapper.listOfSharesToInsert;
            }
        }
    }

    public override void executeDMLs() {
        
        if( !datatableShareList.isEmpty() && excecuteTrigger){
            try{
                insert datatableShareList;
            }catch(Exception e){
                System.debug('e:' + e);
                objectIdToMessageErrorsMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }
    }
	
    public void validateObjectApiName(Datatable__c recNew) {
        if(!GeneralUtils.isSafeObject(recNew.ObjectApiName__c, false)) {
            recNew.addError('The Object ' + recNew.ObjectApiName__c + ' is not valid.');
        }
    }
    
    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>();
    
    private void addSharing(Datatable__c recNew, Datatable__c recOld, Boolean isMaster) {
        
        if( !canMethod('addSharing')) {return;}
        
        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey('Datatable__Share')) {
                
                if(recOld != null){
                    if(recNew.Cluster__c !=  recOld.Cluster__c){
                        if(recNew.Cluster__c == null){ 
                            excecuteTrigger = false;
                        }else{
                            recordList.add(recNew);
                        }
                    }
                }else{
                    if(recNew.Cluster__c == null){ 
                        excecuteTrigger = false;
                    }else{
                        recordList.add(recNew);
                    }
                }
            }
        }else{
            if(objectIdToMessageErrorsMap.containsKey(recNew.Id)){
                recNew.addError(objectIdToMessageErrorsMap.get(recNew.Id));
            }
        }
    }

    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(Datatable__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
}