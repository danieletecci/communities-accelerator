public with sharing class MenuTriggers extends TriggersHandler{
    public MenuTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld) {
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;

        //PA-247 CMA: Clustering: Apex Sharing on Menu
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
        setExternalId((Menu__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Menu__c)recNew);    
    }  

    //PA-247 CMA: Clustering: Apex Sharing on Menu
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Menu__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Menu__c) recNew, (Menu__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Menu__c) recNew,null, false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Menu__c) recNew, (Menu__c) recOld, false);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<Menu__Share> menuShareList = new List<Menu__Share>();
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
    
    public override void dataPreparing() {
        if(!recordList.isEmpty() && excecuteTrigger){
            
            ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForRecordsOnCluster(recordList, 'Cluster__c', 'Menu__Share', 'Clustering__c',false);
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                excecuteTrigger = false;
            }else{
                menuShareList  = (List<Menu__Share>) sharingWrapper.listOfSharesToInsert;
            }
        }

    }


    public override void executeDMLs() {
        
        if(!menuShareList.isEmpty() && excecuteTrigger){
            try{
                insert menuShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Menu__c recNew, Menu__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        
        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey('Menu__Share')) {
                
                if(recOld != null){
                    if(recNew.Cluster__c !=  recOld.Cluster__c){
                        if(recNew.Cluster__c == null){ 
                            excecuteTrigger = false;
                            //recNew.addError('The object must containg a loockup relation to Cluster');
                        }else{
                            recordList.add(recNew);
                        }
                    }

                }else{
                    
                    if(recNew.Cluster__c == null){ 
                        excecuteTrigger = false;
                        //recNew.addError('The object must containg a loockup relation to Cluster');
                    }else{
                        recordList.add(recNew);
                    }
                }
            }


        }else{
            if(objectIdToMessageErrosMap.containsKey(recNew.Id)){
                recNew.addError(objectIdToMessageErrosMap.get(recNew.Id));
            }
        }

    }

    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* DEFINITION AND COMPLETION OF EXTERNAL ID */
    private void setExternalId(Menu__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }

}