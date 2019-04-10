public with sharing class ContentTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ContentTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
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

        //PA-266 Trigger que elimine los registros generados en Assignment cuando no es master detail
        allow_masterLoop_BeforeDelete = true;    
    }

    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/

    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((Content__c)recNew);
        checkAdvanceContentBinding((Content__c)recNew);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Content__c)recNew);
        checkAdvanceContentBinding((Content__c)recNew);
    }

    //PA-266
    public override void masterLoop_BeforeDelete (SObject recOld){
        setDeleteIdsList((Content__c) recOld);

    }

    //PA-177 CMA: Clustering: Apex Sharing
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Content__c) recNew, null, true);
        insertContentAssignment((Content__c) recNew);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Content__c) recNew, (Content__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Content__c) recNew,null, false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Content__c) recNew, (Content__c) recOld, false);
    }
    

    
    //PA-177 CMA: Clustering: Apex Sharing
    List<Content__Share> contentShareList = new List<Content__Share>();
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
    //PA-266
    List<MediaElementAssignment__c> mediaElementAssignmentList = new List<MediaElementAssignment__c>();
    List<TagAssignment__c> tagAssignmentList = new List<TagAssignment__c>();
    public override void dataPreparing() {
        if(excecuteTrigger){
            if(!recordList.isEmpty()){
                ObjectSharingUtil.SharingWrapper sharingWrapper = ObjectSharingUtil.generateSharingForRecordsOnCluster(recordList, 'Cluster__c', 'Content__Share', 'Clustering__c', false);
                if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                    objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                    excecuteTrigger = false;
                }else{
                    contentShareList  = (List<Content__Share>) sharingWrapper.listOfSharesToInsert;
                }
            }
            //PA-266
            if(!deleteIdsList.isEmpty()){
                mediaElementAssignmentList = [SELECT ID FROM MediaElementAssignment__c WHERE Content__c in : deleteIdsList];
                tagAssignmentList = [SELECT ID FROM TagAssignment__c WHERE Content__c in : deleteIdsList];
            }
        }
    }
    
    public override void executeDMLs() {

        if(!contentShareList.isEmpty() && excecuteTrigger){
            try{
                insert contentShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }

        //PA-266
        if(!mediaElementAssignmentList.isEmpty()){
            delete mediaElementAssignmentList;
        }
        if(!tagAssignmentList.isEmpty()){
            delete tagAssignmentList;
        }  

    }
    
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
    private void setExternalId(Content__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }

    private void checkAdvanceContentBinding(Content__c recNew){
        if(!canMethod('checkAdvanceContentBinding')){return;}

        if(recNew.HTMLContent__c != null && recNew.HTMLContent__c.substringBetween('[!', ']') != null){

            //Replace binding by lower case
            List<String> bindingsList = new List<String>();
            String auxTextToReplace = recNew.HTMLContent__c;
            while(auxTextToReplace.substringBetween('[!', ']') != null) {
                String bind = auxTextToReplace.substringBetween('[!', ']');
                bindingsList.add('[!' + bind + ']');
                auxTextToReplace = auxTextToReplace.replace('[!' + bind + ']', '');
            }
            for(String binding: bindingsList){
                recNew.HTMLContent__c = recNew.HTMLContent__c.replace(binding, binding.toLowerCase());
            }

            //Check consistency
            if(Limits.getQueries() < 50){
                String replacedValue = GeneralUtils.replaceDynamicFields(recNew.HTMLContent__c, 'User', UserInfo.getUserId(), false);
                if(replacedValue.substringBetween('[!', ']') != null){
                    String fieldApiName = replacedValue.substringBetween('[!', ']');
                    recNew.HTMLContent__c.addError('Dynamic user fields error. Some relationship or field doesn\'t exists: ' + bindingsList);
                }
            }
        }
    }
    
    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Content__c recNew, Content__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        System.debug('Method addSharing');

        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey('Content__Share')) {
                
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

    //PA-266
    List<String> deleteIdsList = new List<String>(); 
    private void setDeleteIdsList(Content__c recOld){
        deleteIdsList.add(recOld.Id);
    }

    private void insertContentAssignment(Content__c recNew){
        if(recNew.StructureComponent__c != null){
            Component__c component = [SELECT Id, DataSource__c FROM Component__c WHERE Id =: recNew.StructureComponent__c];
            if(component.dataSource__c == 'ManualAssignment'){
                ContentAssignment__c contentAssignment = new ContentAssignment__c(Component__c = recNew.StructureComponent__c, Content__c = recNew.Id);
                insert contentAssignment;
            }
        }
    }

}