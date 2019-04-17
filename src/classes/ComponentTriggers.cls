public with sharing class ComponentTriggers extends TriggersHandler {

    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ComponentTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
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
        allow_finalLoop_BeforeUpdate = true;

        //PA-266 Trigger que elimine los registros generados en Assignment cuando no es master detail
        allow_masterLoop_BeforeDelete = true;          
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_BeforeInsert(SObject recNew) {
        validateTagCriteria((Component__c)recNew);
        setExternalId((Component__c)recNew);
        customSort((Component__c)recNew, null);
    }
    public override void masterLoop_BeforeUpdate(SObject recNew, SObject recOld) {
        validateTagCriteria((Component__c)recNew);
        setExternalId((Component__c)recNew);
        customSort((Component__c)recNew, (Component__c)recOld);
        //PA-206 Governance de Componentes(Reparenting)
        errorClusterFieldChange((Component__c)recNew, (Component__c)recOld, true);
    }

    //PA-266
    public override void masterLoop_BeforeDelete (SObject recOld){
        setDeleteIdsList((Component__c) recOld);
    }

    //PA-177 CMA: Clustering: Apex Sharing
    public override void masterLoop_AfterInsert(SObject recNew) {
        addSharing((Component__c) recNew, null, true);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addSharing((Component__c) recNew, (Component__c) recOld, true);
    }
    //Final loops
    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Component__c) recNew,null,false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Component__c) recNew, (Component__c) recOld, false);
    }

    //PA-206 Governance de Componentes(Reparenting)
    public override void finalLoop_BeforeUpdate(SObject recNew, SObject recOld){
        errorClusterFieldChange((Component__c)recNew, (Component__c)recOld, false);   
    } 

    List<Component__Share> componentShareList = new List<Component__Share>();
    Boolean excecuteTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();


    public override void executeDMLs() {
        
        if(!componentShareList.isEmpty() && excecuteTrigger){
            try{
                insert componentShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }

        //PA-266
        if(!contentAssignmentList.isEmpty()){
            delete contentAssignmentList;
        }
        if(!menuAssignmentList.isEmpty()){
            delete menuAssignmentList;
        }
        if(!tagAssignmentList.isEmpty()){
            delete tagAssignmentList;
        }
        if(!categoryAssignmentList.isEmpty()){
            delete categoryAssignmentList;
        }
    }
    
    //PA-266
    List<ContentAssignment__c> contentAssignmentList = new List<ContentAssignment__c>();
    List<MenuAssignment__c> menuAssignmentList = new List<MenuAssignment__c>();
    List<TagAssignment__c> tagAssignmentList = new List<TagAssignment__c>();
    List<CategoryAssignment__c> categoryAssignmentList = new List<CategoryAssignment__c>();   
    public override void dataPreparing() {

        //PA-177 CMA: Clustering: Apex Sharing
        if(!recordList.isEmpty() && excecuteTrigger){
            List<SObject> listSO = new List<SObject>();

            //listSO = SharingUtils.generateSharingForRecordsOnCluster(recordList, 'Cluster__c');
            SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForRecordsOnCluster(recordList, GeneralUtils.prefix('[CMS]Cluster__c'), GeneralUtils.prefix('[CMS]Component__Share'), GeneralUtils.prefix('[CMS]Clustering__c'), false);           
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                excecuteTrigger = false;
            }else{
                componentShareList  = (List<Component__Share>) sharingWrapper.listOfSharesToInsert;
            }

        }

        //PA-206 Governance de Componentes(Reparenting)
        if(!componentIds.isEmpty() && excecuteTrigger){
            for(ContentAssignment__c contentList : [SELECT Id, Component__r.Id FROM ContentAssignment__c WHERE Component__c IN :componentIds]){
                componentIdsWithAssignment.add(contentList.Component__r.Id);    
            }
            for(CategoryAssignment__c categoryList : [SELECT Id, Component__r.Id FROM CategoryAssignment__c WHERE Component__c IN :componentIds]){
                componentIdsWithAssignment.add(categoryList.Component__r.Id);
            }
            for(TagAssignment__c tagList : [SELECT Id, Component__r.Id FROM TagAssignment__c WHERE Component__c IN :componentIds]){
                componentIdsWithAssignment.add(tagList.Component__r.Id);    
            }
        }

        //PA-266
        if(!deleteIdsList.isEmpty()){
            contentAssignmentList = [SELECT ID FROM ContentAssignment__c WHERE Component__c  in : deleteIdsList];
            menuAssignmentList = [SELECT ID FROM MenuAssignment__c WHERE Component__c  in : deleteIdsList];
            tagAssignmentList = [SELECT ID FROM TagAssignment__c WHERE Component__c in : deleteIdsList];
            categoryAssignmentList = [SELECT ID FROM CategoryAssignment__c WHERE Component__c in : deleteIdsList];
        }
        
    }


    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    private void setExternalId(Component__c recNew){
        if(!canMethod('setExternalId')){return;}

        if(recNew.ExternalID__c == null){
            recNew.ExternalID__c = GeneralUtils.generateExternalId(recNew.Name, recNew.Cluster__c, recNew.getSObjectType().getDescribe().getName());
        }
    }

    private void validateTagCriteria(Component__c recNew){
        if(!canMethod('validateTagCriteria')){return;}

        if(recNew.TagCriteria__c != null){
            String value = recNew.TagCriteria__c.deleteWhitespace().toUpperCase().replaceAll('AND', ' AND ').replaceAll('OR', ' OR ');
            value = value.replaceAll('\\d', 'TRUE');
            if(value.replaceAll('TRUE|\\(|\\)|AND|OR| ', '').length() > 0 || !BooleanExpressionUtils.eval(value)){
                recNew.TagCriteria__c.AddError(Label.General_InvalidFormulaFormat);
            }
        }
    }

    private void customSort(Component__c recNew, Component__c recOld){
        if(!canMethod('customSort')){return;}
        
        if(recNew.OrderBy__c == 'Custom Sorting' && recNew.OrderByAdvance__c != null && Limits.getQueries() < 50){
            if(trigger.isInsert || (trigger.isUpdate && (recNew.OrderByAdvance__c != recOld.OrderByAdvance__c) || recNew.OrderBy__c != recOld.OrderBy__c)){
                try{
                    Database.query(GeneralUtils.prefix('SELECT Id FROM [CMS]Content__c ORDER BY ' + recNew.OrderByAdvance__c + ' LIMIT 1'));
                }catch(Exception e){
                    recNew.OrderByAdvance__c.AddError(Label.OrderByInvalidFormat + ' ' + e.getMessage());
                }
            }
        }  
    }

    //PA-206 Governance de Componentes(Reparenting)
    Set<Id> componentIds = new Set<Id>();
    Set<Id> componentIdsWithAssignment = new Set<Id>();
    private void errorClusterFieldChange(Component__c recNew, Component__c recOld, Boolean isMaster){
        if(!canMethod('errorClasterFieldChange')){return;}
        if(isMaster){
            if(recNew.Cluster__c != recOld.Cluster__c){
                componentIds.add(recNew.Id);
            }
        }else{
            if(recNew.Cluster__c != recOld.Cluster__c && componentIdsWithAssignment.contains(recNew.Id)){
                recNew.Cluster__c.AddError(Label.CannotReassignComponent);
            }
        }
    }


    //PA-177 CMA: Clustering: Apex Sharing
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Component__c recNew, Component__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        
        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey(GeneralUtils.prefix('[CMS]Component__Share'))) {

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
    private void setDeleteIdsList(Component__c recOld){
        deleteIdsList.add(recOld.Id);
    }
}