public with sharing class TagTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public TagTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
        
        //PA-177 CMA: Clustering: Apex Sharing
        allow_masterLoop_AfterUpdate = true;
        allow_masterLoop_AfterInsert = true;
        allow_masterLoop_AfterDelete = true;
        allow_dataPreparing = true;
        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;

        //PA-182 COA: Controlar la administración y el uso de Tags y Categories
        allow_finalLoop_BeforeInsert = true;
        allow_finalLoop_BeforeUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        setExternalId((Tag__c)recNew);

        validateTagName((Tag__c)recNew, null, true);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        setExternalId((Tag__c)recNew);

        validateTagName((Tag__c)recNew, (Tag__c)recOld, true);
    }
    //PA-177 CMA: Clustering: Apex Sharing
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Tag__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Tag__c) recNew, (Tag__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Tag__c) recNew,null,false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Tag__c) recNew, (Tag__c) recOld,false);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<Tag__Share> tagShareList = new List<Tag__Share>();
    Boolean toContinueTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
    
    public override void dataPreparing() {
        if(!recordList.isEmpty() && toContinueTrigger){
            SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForRecordsOnCluster(recordList, '[CMS]Cluster__c', '[CMS]Tag__Share', '[CMS]Clustering__c', false);           
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                toContinueTrigger = false;
            }else{
                tagShareList  = (List<Tag__Share>) sharingWrapper.listOfSharesToInsert;
            }

        }

        //PA-182 COA: Controlar la administración y el uso de Tags y Categories
        if(clustersInTrigger!=null && clustersInTrigger.size()>0){

            for(Cluster__c cluster: [ SELECT Id, ParentCluster__c, ParentCluster__r.ParentCluster__c, ParentCluster__r.ParentCluster__r.ParentCluster__c 
                                        FROM Cluster__c
                                        WHERE Id IN :clustersInTrigger OR
                                            ParentCluster__c IN :clustersInTrigger OR
                                            ParentCluster__r.ParentCluster__c IN :clustersInTrigger OR
                                            ParentCluster__r.ParentCluster__r.ParentCluster__c IN :clustersInTrigger]){
                setAllClusters(cluster.id);
                setAllClusters(cluster.ParentCluster__c);
                setAllClusters(cluster.ParentCluster__r.ParentCluster__c);
                setAllClusters(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
                setMapCluster(cluster);
            }

            for(Tag__c tag : [SELECT Id, Name, ExternalId__c, Cluster__c, Cluster__r.ParentCluster__c, CLuster__r.ParentCluster__r.ParentCluster__c, CLuster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c  
                                    From Tag__c where Id !=: TagNew.Id and Cluster__c in: allClusters]){  
                setMapaClusterIdTagEnDB(tag.CLuster__c, tag.Name);
                setMapaClusterIdTagEnDB(tag.Cluster__r.ParentCluster__c, tag.Name);
                setMapaClusterIdTagEnDB(tag.Cluster__r.ParentCluster__r.ParentCluster__c, tag.Name);
                setMapaClusterIdTagEnDB(tag.Cluster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c, tag.Name);
                  
            }
        }

    }


    public override void executeDMLs() {
        if(!tagShareList.isEmpty() && toContinueTrigger){
            try{
                insert tagShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }
    }

    //Final Loops
    //PA-182 COA: Controlar la administración y el uso de Tags y Categories
    public override void finalLoop_BeforeInsert(SObject recNew) {
        validateTagName((Tag__c)recNew, null, false);
    }
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        validateTagName((Tag__c)recNew, (Tag__c)recOld, false);
    }

    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
    private void setExternalId(Tag__c recNew){
        if(!canMethod('setExternalId')){return;}
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Tag__c recNew, Tag__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}

        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey(GeneralUtils.prefix('[CMS]Tag__Share'))) {

                if(recOld != null){
                    if(recNew.Cluster__c !=  recOld.Cluster__c){
                        if(recNew.Cluster__c == null){ 
                            toContinueTrigger = false;
                            //recNew.addError('The object must containg a loockup relation to Cluster');
                        }else{
                            recordList.add(recNew);
                        }
                    }

                }else{
                    
                    if(recNew.Cluster__c == null){ 
                        toContinueTrigger = false;
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

//PA-182 COA: Controlar la administración y el uso de Tags y Categories

    private Set<String> clustersInTrigger;
    private Tag__c TagNew;
    private void validateTagName(Tag__c recNew, Tag__c recOld, Boolean isMaster){
        if(recNew.Cluster__c!=null){
            if((recOld == null) || (!recNew.Name.equalsIgnoreCase(recOld.Name)) || (recNew.Cluster__c != recOld.Cluster__c)) {
                if(isMaster){
                    TagNew = recNew;
                    if(clustersInTrigger==null){
                        clustersInTrigger= new Set<String>(); 
                    }
                    clustersInTrigger.add(recNew.Cluster__c);
                }else{
                    
                    if((mapaClusterIdTagEnDB != null) && (
                        (mapaClusterIdTagEnDB.containsKey(recNew.Cluster__c) && 
                        mapaClusterIdTagEnDB.get(recNew.Cluster__c).contains(recNew.Name))
                         ||
                        (mapaClusterIdTagEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__c) &&
                        mapaClusterIdTagEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__c).contains(recNew.Name))
                         || 
                        (mapaClusterIdTagEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__c) &&
                        mapaClusterIdTagEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__c).contains(recNew.Name))
                         ||
                        (mapaClusterIdTagEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__r.ParentCluster__c) &&
                        mapaClusterIdTagEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__r.ParentCluster__c).contains(recNew.Name))
                        )){
                        recNew.adderror(Label.RepeatedTagName);
                    }
                }
            }
        }    
    }

//PA-182
    private Map<Id, Cluster__c> mapClusters;
    private void setMapCluster(Cluster__c cluster){
        if(mapClusters == null){
            mapClusters = new Map<Id,Cluster__c>();
        }
        mapClusters.put(cluster.Id, cluster);
    }

//PA-182
    private Set<Id> allClusters;
    private void setAllClusters(Id clusterId){

        if (clusterId!=null){
            if(allClusters==null){
                allClusters= new Set<Id>(); 
            }
            allClusters.add(clusterId);
        }
    }

//PA-182
    private Map<Id,Set<String>> mapaClusterIdTagEnDB;
    private void setMapaClusterIdTagEnDB(Id clusterId, String tagName){
       
        if(clusterId != null && String.isNotEmpty(tagName)){
            if(mapaClusterIdTagEnDB==null){
                mapaClusterIdTagEnDB= new Map<Id,Set<String>>();
            }
            
            if(mapaClusterIdTagEnDB.containsKey(clusterId)){
                mapaClusterIdTagEnDB.get(clusterId).add(tagName);
            }else{
                Set<String> tagsNameSet = new Set<String>();
                tagsNameSet.add(tagName);
                mapaClusterIdTagEnDB.put(clusterId, tagsNameSet);
            }
        }
    }     
}