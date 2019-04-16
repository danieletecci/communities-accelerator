public with sharing class CategoryTriggers extends TriggersHandler {


    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public CategoryTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_BeforeInsert = true;
        allow_masterLoop_BeforeUpdate = true;
        allow_dataPreparing = true;
        allow_finalLoop_BeforeInsert = true;
        allow_finalLoop_BeforeUpdate = true;

        //PA-177 CMA: Clustering: Apex Sharing
        allow_masterLoop_AfterUpdate = true;
        allow_masterLoop_AfterInsert = true;
        allow_masterLoop_AfterDelete = true;
        allow_executeDMLs = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        
        setExternalId((Category__c)recNew);
        validateCategoryName((Category__c)recNew, null, true);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        
        setExternalId((Category__c)recNew);
        validateCategoryName((Category__c)recNew, (Category__c)recOld, true);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Category__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Category__c) recNew, (Category__c) recOld, true);
    }
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Category__c) recNew,null,false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Category__c) recNew, (Category__c) recOld,false);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<Category__Share> categoryShareList = new List<Category__Share>();
    Boolean toContinueTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();

    //Data Preparing
    public override void dataPreparing(){

        if(!recordList.isEmpty() && toContinueTrigger){
            List<SObject> listSO = new List<SObject>();
            //listSO = SharingUtils﻿.generateSharingForRecordsOnCluster(recordList, 'Cluster__c');
            SharingUtils﻿.SharingWrapper sharingWrapper = SharingUtils﻿.generateSharingForRecordsOnCluster(recordList, 'Cluster__c', 'Category__Share', 'Clustering__c', false);           
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                toContinueTrigger = false;
            }else{
                categoryShareList  = (List<Category__Share>) sharingWrapper.listOfSharesToInsert;
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

            for(Category__c category : [SELECT Id, Name, ExternalId__c, Cluster__c, Cluster__r.ParentCluster__c, CLuster__r.ParentCluster__r.ParentCluster__c, CLuster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c  
                                    From Category__c where Id !=: catNew.Id and Cluster__c in: allClusters]){  
                setMapaClusterIdCategoryEnDB(category.CLuster__c, category.Name);
                setMapaClusterIdCategoryEnDB(category.Cluster__r.ParentCluster__c, category.Name);
                setMapaClusterIdCategoryEnDB(category.Cluster__r.ParentCluster__r.ParentCluster__c, category.Name);
                setMapaClusterIdCategoryEnDB(category.Cluster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c, category.Name);
                  
            }
        }
    }

    //Final Loops
    public override void finalLoop_BeforeInsert(SObject recNew) {
        validateCategoryName((Category__c)recNew, null, false);
    }
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        validateCategoryName((Category__c)recNew, (Category__c)recOld, false);
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/
    private void setExternalId(Category__c recNew){
        if(!canMethod('setExternalId')){return;}
        
        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }
    
//PA-182 COA: Controlar la administración y el uso de Tags y Categories

    private Set<String> clustersInTrigger;
    private Category__c catNew;
    private void validateCategoryName(Category__c recNew, Category__c recOld, Boolean isMaster){
        if(recNew.Cluster__c!=null){
            if((recOld == null) || (!recNew.Name.equalsIgnoreCase(recOld.Name))  || (recNew.Cluster__c != recOld.Cluster__c)) {
                if(isMaster){
                    catNew = recNew;
                    if(clustersInTrigger==null){
                        clustersInTrigger= new Set<String>(); 
                    }
                    clustersInTrigger.add(recNew.Cluster__c);
                }else{
                    
                    if((mapaClusterIdCategoryEnDB != null) && (
                        (mapaClusterIdCategoryEnDB.containsKey(recNew.Cluster__c) && 
                        mapaClusterIdCategoryEnDB.get(recNew.Cluster__c).contains(recNew.Name))
                         ||
                        (mapaClusterIdCategoryEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__c) &&
                        mapaClusterIdCategoryEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__c).contains(recNew.Name))
                         || 
                        (mapaClusterIdCategoryEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__c) &&
                        mapaClusterIdCategoryEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__c).contains(recNew.Name))
                         ||
                        (mapaClusterIdCategoryEnDB.containsKey(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__r.ParentCluster__c) &&
                        mapaClusterIdCategoryEnDB.get(mapClusters.get(recNew.Cluster__c).ParentCluster__r.ParentCluster__r.ParentCluster__c).contains(recNew.Name))
                        )){
                        recNew.adderror(Label.RepeatedCategoryName);
                    }
                }
            }
        }    
    }


    public override void executeDMLs() {
        if(!categoryShareList.isEmpty() && toContinueTrigger){
            try{
                insert categoryShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
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
    private Map<Id,Set<String>> mapaClusterIdCategoryEnDB;
    private void setMapaClusterIdCategoryEnDB(Id clusterId, String categoryName){
       
        if(clusterId != null && String.isNotEmpty(categoryName)){
            if(mapaClusterIdCategoryEnDB==null){
                mapaClusterIdCategoryEnDB= new Map<Id,Set<String>>();
            }
            
            if(mapaClusterIdCategoryEnDB.containsKey(clusterId)){
                mapaClusterIdCategoryEnDB.get(clusterId).add(categoryName);
            }else{
                Set<String> categoriesNameSet = new Set<String>();
                categoriesNameSet.add(categoryName);
                mapaClusterIdCategoryEnDB.put(clusterId, categoriesNameSet);
            }
        }
    }

    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Category__c recNew, Category__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}

        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey('Category__Share')) {

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


}