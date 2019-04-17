public with sharing class ClusterTriggers extends TriggersHandler {

    private final static String readAndWrite = 'RW';
    private final static String readAndOnlyViewDown = 'ROViewDown';
    private final static String readAndOnlyViewUp = 'ROViewUp';
    private final static String separatorGroupName = '_';




    /*****************************************************************/
    /************************ CONSTRUCTOR ****************************/
    /*****************************************************************/
    public ClusterTriggers(List<SObject> p_triggerNew, List<SObject> p_triggerOld){
        super(p_triggerNew, p_triggerOld);

        allow_masterLoop_AfterInsert = true;
        allow_masterLoop_AfterDelete = true;
        allow_masterLoop_AfterUpdate = true;
        allow_executeDMLs = true;
        allow_dataPreparing = true;

        allow_finalLoop_AfterInsert = true;
        allow_finalLoop_AfterUpdate = true;
        
    }
    
    /*****************************************************************/
    /*********************** TRIGGER METHODS *************************/
    /*****************************************************************/
    
    //Master loops
    public override void masterLoop_AfterInsert(SObject recNew) {
        createGroups((Cluster__c)recNew);
        addLanguages((Cluster__c) recNew, null);
    }

    public override void masterLoop_AfterDelete(SObject recOld) {
        deleteGroups((Cluster__c)recOld);
    }
    public override void masterLoop_AfterUpdate(SObject recNew, SObject recOld) {
        addLanguages((Cluster__c) recNew, (Cluster__c) recOld);
        addSharing((Cluster__c) recNew, (Cluster__c) recOld, true);
    }

    public override void finalLoop_AfterInsert(SObject recNew) {
        addSharing((Cluster__c) recNew,null,false);
    }
    
    public override void finalLoop_AfterUpdate(SObject recNew, SObject recOld){
        addSharing((Cluster__c) recNew, (Cluster__c) recOld,false);
    }

    List<Cluster__c> clusterToUpdateLanguageList = new List<Cluster__c>();
    Map<Id,Cluster__c> clusterToUpdateLanguageMap = new Map<Id,Cluster__c>();
    

    //PA-177 CMA: Clustering: Apex Sharing
    List<Tag__Share> tagShareList = new List<Tag__Share>();



    /*PREPARING DATA FOR ADD LANGUAGE*/
    public override void dataPreparing() {

        //PA-177 CMA: Clustering: Apex Sharing
        if(!recordList.isEmpty() && toContinueTrigger){


            SharingUtils.SharingWrapper sharingWrapper = SharingUtils.generateSharingForCluster(recordList, '[CMS]Cluster__c', '[CMS]Cluster__Share', '[CMS]Clustering__c', true);           
            if(sharingWrapper.objectIdToMessageErrosMap.size()>0){
                objectIdToMessageErrosMap = sharingWrapper.objectIdToMessageErrosMap;
                toContinueTrigger = false;
            }else{
                tagShareList  = (List<Tag__Share>) sharingWrapper.listOfSharesToInsert;
            }

        }


        System.debug('dataPreparing: ');
        if(!clusterIdChildWithParentListLang.isEmpty() && !haveDefaultLanguage){
           List<Cluster__c> clusterList = [SELECT Id, Name, ParentCluster__c, ParentCluster__r.ParentCluster__c, ParentCluster__r.DefaultLanguage__c, ParentCluster__r.OtherLanguages__c, ParentCluster__r.Name, ParentCluster__r.ParentCluster__r.ParentCluster__c, ParentCluster__r.ParentCluster__r.DefaultLanguage__c, ParentCluster__r.ParentCluster__r.OtherLanguages__c, ParentCluster__r.ParentCluster__r.Name,ParentCluster__r.ParentCluster__r.ParentCluster__r.ParentCluster__c, ParentCluster__r.ParentCluster__r.ParentCluster__r.DefaultLanguage__c, ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c, ParentCluster__r.ParentCluster__r.ParentCluster__r.Name
            FROM Cluster__c 
            WHERE Id IN: clusterIdChildWithParentListLang];

           
            System.debug('dataPreparing clusterList: ' + clusterList);
            for(Cluster__c cluster: clusterList){
                
                if(cluster.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c = new Cluster__c(name=cluster.ParentCluster__r.Name,Id=cluster.ParentCluster__c);
                        c.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.DefaultLanguage__c);
                        clusterToUpdateLanguageList.add(c);

                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                                    

                                    //otherLanguage = otherLanguage + ';' + c.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c.OtherLanguages__c,otherLanguage, null);

                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = c.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__c,c);
                        }

                    }
                }

                if(cluster.ParentCluster__r.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c2 = new Cluster__c(name=cluster.ParentCluster__r.ParentCluster__r.Name,Id=cluster.ParentCluster__r.ParentCluster__c);
                        c2.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.ParentCluster__r.DefaultLanguage__c);
                        clusterToUpdateLanguageList.add(c2);




                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__r.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c2.OtherLanguages__c != null && c2.OtherLanguages__c != ''){

                                    //otherLanguage = otherLanguage + ';' + c2.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c2.OtherLanguages__c,otherLanguage, null);
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c2.OtherLanguages__c != null && c2.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__c).OtherLanguages__c = c2.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__r.ParentCluster__c,c2);
                        }




                    }
                }
                
                if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
                    if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
                        Cluster__c c3 = new Cluster__c(Name=cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.Name,Id=cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
                        c3.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.ParentCluster__r.ParentCluster__r.DefaultLanguage__c) ;
                        clusterToUpdateLanguageList.add(c3);




                        if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c)){
                            String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c;
                            if(otherLanguage != null && otherLanguage != ''){
                                if(c3.OtherLanguages__c != null && c3.OtherLanguages__c != ''){
                                    //otherLanguage = otherLanguage + ';' + c3.OtherLanguages__c;
                                    otherLanguage = writeOtherLanguage(c3.OtherLanguages__c,otherLanguage, null);
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }else{
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = otherLanguage;
                                }
                                
                                
                            }else{

                                if(c3.OtherLanguages__c != null && c3.OtherLanguages__c != ''){
                                    clusterToUpdateLanguageMap.get(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c).OtherLanguages__c = c3.OtherLanguages__c;
                                }
                            }
                        }else{
                            clusterToUpdateLanguageMap.put(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c,c3);
                        }


                    }
                }
            
            //fin
            

            }
            List<Cluster__c> clusterToUpdateLanguageList2 = new List<Cluster__c>();
            for(Id clusterId: clusterToUpdateLanguageMap.keySet()){
                Cluster__c clusterItem = clusterToUpdateLanguageMap.get(clusterId);
                clusterToUpdateLanguageList2.add(clusterItem);

            }
            clusterToUpdateLanguageList = clusterToUpdateLanguageList2;
        }
    }

    //TODO use this function to reduce code
    public void mergeOtherLanguage(Cluster__c cluster){

        if(cluster.ParentCluster__r.OtherLanguages__c != clusterIdToOtherLanguageMap.get(cluster.Id)){
            Cluster__c c = new Cluster__c(name=cluster.ParentCluster__r.Name,Id=cluster.ParentCluster__c);
            c.OtherLanguages__c = writeOtherLanguage(cluster.ParentCluster__r.OtherLanguages__c, clusterIdToOtherLanguageMap.get(cluster.Id), cluster.ParentCluster__r.DefaultLanguage__c);
            clusterToUpdateLanguageList.add(c);

            


            if(clusterToUpdateLanguageMap.containsKey(cluster.ParentCluster__c)){
                String otherLanguage = clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c;
                if(otherLanguage != null && otherLanguage != ''){
                    if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){

                        otherLanguage = otherLanguage + ';' + c.OtherLanguages__c;
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                    }else{
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = otherLanguage;
                    }
                    
                    
                }else{

                    if(c.OtherLanguages__c != null && c.OtherLanguages__c != ''){
                        clusterToUpdateLanguageMap.get(cluster.ParentCluster__c).OtherLanguages__c = c.OtherLanguages__c;
                    }
                }
            }else{
                clusterToUpdateLanguageMap.put(cluster.ParentCluster__c,c);
            }

        }

    }

    public String writeOtherLanguage(String parentOtherlanguage, String otherLanguage, String parentDefaultLanguage){
        Map<String,String> returnOtherLanguage= new Map<String,String>();

        if(parentOtherlanguage != null){
            List<String> parentOtherlanguageList = parentOtherlanguage.split(';');
            
            System.debug('ClusterTriggers parentOtherlanguageList: ' + parentOtherlanguageList);
            for(String pOtherL: parentOtherlanguageList){
                returnOtherLanguage.put(pOtherL,pOtherL);
                
            }
        }

        if(otherLanguage!=null){
            List<String> otherlanguageList = otherLanguage.split(';');

            for(String otherL: otherlanguageList){
                if(parentDefaultLanguage!=null){
                    if(parentDefaultLanguage != otherL){
                        returnOtherLanguage.put(otherL,otherL);
                    }
                }else{
                    returnOtherLanguage.put(otherL,otherL);
                }

                
            }            
        }

        List<String> otherlanguageList2 = new List<String>(returnOtherLanguage.keySet());

        String returnLanguage = '';
        if(!otherlanguageList2.isEmpty()){
            integer i = 1;
            
            for(String otherL: otherlanguageList2){
                if(returnLanguage != ''){
                    if(i == otherlanguageList2.size()){
                        returnLanguage =+ returnLanguage;
                    }else{
                        returnLanguage = returnLanguage + ';' + otherL;
                    }
                }else{
                    returnLanguage = otherL;
                }
                
            }
        }

        return returnLanguage;

    }

    //DMLs Execution
    public override void executeDMLs() {

        if(!clusterToUpdateLanguageList.isEmpty()){
            update clusterToUpdateLanguageList;
        }

        //FOR CREATION GROUPS
        if(!groupsList.isEmpty() && !haveException){

            insert groupsList;

            List<Cluster__c> clustersToUpdate = new List<Cluster__c>();
            for(Group groupItem : groupsList){

                List<String> GroupKeyAndGroupType = groupItem.Name.split(separatorGroupName);
                String groupKey = '';
                String groupType = '';
                //Verifica si el externald Id tiene un _
                if(GroupKeyAndGroupType.size()==3){
                    groupKey = groupKeyAndGroupType[0]+'_'+groupKeyAndGroupType[1];
                    groupType = groupKeyAndGroupType[2];
                }else{
                    groupKey = groupKeyAndGroupType[0];
                    groupType = groupKeyAndGroupType[1];
                }

                if(groupType.equals(readAndWrite) && mapGroupDevNameToClusterId.containsKey(groupKey)){
                    
                    Cluster__c clusterToUpdate = new Cluster__c(
                        Id = mapGroupDevNameToClusterId.get(groupKey),
                        PublicGroupRWName__c = groupKey + separatorGroupName + readAndWrite,
                        PublicGroupRODownName__c = groupKey + separatorGroupName + readAndOnlyViewDown,
                        PublicGroupROUpName__c = groupkey + separatorGroupName + readAndOnlyViewUp
                    );
                    
                    clustersToUpdate.add(clusterToUpdate);
                }
            }
            update clustersToUpdate;
        }

        if(!clusterIdChildWithParentList.isEmpty() && !haveException){

            Map<String, Id> parentGroupNameToGroupIdMap = new Map<String,Id>();
            Map<String, Id> childGroupNameToGroupIdMap = new Map<String,Id>();

            Map<String,String> mapParentGrupNames = new Map<String,String>();

            List<Cluster__c> clusterIdList = [SELECT Id, Name, ParentCluster__c, PublicGroupRWName__c, PublicGroupRODownName__c, PublicGroupROUpName__c, ParentCluster__r.PublicGroupRWName__c, ParentCluster__r.PublicGroupRODownName__c, ParentCluster__r.PublicGroupROUpName__c, ParentCluster__r.Name 
            FROM Cluster__c 
            WHERE Id IN: clusterIdChildWithParentList];

 

            for(Cluster__c cluster: clusterIdList){

                if(cluster.ParentCluster__c != null){

                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupRWName__c,cluster.ParentCluster__r.PublicGroupRWName__c);
                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupRODownName__c,cluster.ParentCluster__r.PublicGroupRODownName__c);
                    
                    //FOR VIEW UP
                    mapParentGrupNames.put(cluster.ParentCluster__r.PublicGroupROUpName__c,cluster.ParentCluster__r.PublicGroupROUpName__c);
                    
                }

            }
            List<Group> listTempGroup = [SELECT Id, Name FROM Group WHERE Name IN: mapParentGrupNames.keyset()];

            // POPULATE THE PARENT MAP
            for(Group grupItemParent: listTempGroup){
                parentGroupNameToGroupIdMap.put(grupItemParent.name, grupItemParent.Id);
            }

            // POPULATE THE CHILD MAP
            List<Group> groupListTemp2 = [SELECT Id, Name FROM Group WHERE Name IN: grupNamesList];
            for(Group grupItem: groupListTemp2){
                childGroupNameToGroupIdMap.put(grupItem.name, grupItem.Id);
            }
            
            Map<Id,Map<String,Id>> parentIdToAccessModeToGroupParentIdsMap = new Map<Id,Map<String,Id>>();
            Map<Id,Map<String,List<Id>>> parentIdToAccessModeToGroupClildIdsMap = new Map<Id,Map<String,List<Id>>>();
            for(Cluster__c clusterItem: clusterIdList){
                
                
                //For populate information for groups childs cluster map
                Id idRWChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupRWName__c);
                Id idROVDownChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupRODownName__c);
                //FOR VIEW UP
                Id idROVUpChild = childGroupNameToGroupIdMap.get(clusterItem.PublicGroupROUpName__c);

                if(!parentIdToAccessModeToGroupClildIdsMap.containsKey(clusterItem.ParentCluster__c)){
                    parentIdToAccessModeToGroupClildIdsMap.put(clusterItem.ParentCluster__c,new Map<String,List<Id>>());
                }

                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndWrite)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndWrite, new List<Id>());   
                }

                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndOnlyViewDown)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewDown, new List<Id>());
                }
                //FOR VIEW UP
                if(!parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).containsKey(readAndOnlyViewUp)){
                    parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewUp, new List<Id>());
                }

                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndWrite).add(idRWChild);
                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndOnlyViewDown).add(idROVDownChild);
                //FOR VIEW UP
                parentIdToAccessModeToGroupClildIdsMap.get(clusterItem.ParentCluster__c).get(readAndOnlyViewUp).add(idROVUpChild);

                //For populate information for groups parents cluster map
                Id idRWParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupRWName__c);
                Id idROVDownParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupRODownName__c);
                //FOR VIEW UP
                Id idROVUpParent = parentGroupNameToGroupIdMap.get(clusterItem.ParentCluster__r.PublicGroupROUpName__c);

                if(!parentIdToAccessModeToGroupParentIdsMap.containsKey(clusterItem.ParentCluster__c)){
                    parentIdToAccessModeToGroupParentIdsMap.put(clusterItem.ParentCluster__c,new Map<String,Id>());
                }

                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndWrite,idRWParent);
                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewDown,idROVDownParent);
                //FOR VIEW UP
                parentIdToAccessModeToGroupParentIdsMap.get(clusterItem.ParentCluster__c).put(readAndOnlyViewUp,idROVUpParent);
                
            }

                
                List <String> groupChildIdToParentIdsList = new List<String>();
                for(Id parentClusterId: parentIdToAccessModeToGroupParentIdsMap.keySet()){

                    String parentGroupIdRW = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndWrite);
                    String parentGroupIdRO = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndOnlyViewDown);
                    String parentGroupIdROVUp = (String) parentIdToAccessModeToGroupParentIdsMap.get(parentClusterId).get(readAndOnlyViewUp);

                    for(Id childGroupIdRW: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndWrite)){
                        //userOrGroup to target
                        groupChildIdToParentIdsList.add(parentGroupIdRW+'_'+childGroupIdRW);
                    }

                    for(Id childGroupIdRO: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndOnlyViewDown)){

                        groupChildIdToParentIdsList.add(parentGroupIdRO+'_'+childGroupIdRO);
                    }

                    //FOR VIEW UP
                    for(Id childGroupIdROVUp: parentIdToAccessModeToGroupClildIdsMap.get(parentClusterId).get(readAndOnlyViewUp)){
                        
                        groupChildIdToParentIdsList.add(childGroupIdROVUp+'_'+parentGroupIdROVUp);
                    }

                }
                matchGroupsWithParentCLusterGroups(groupChildIdToParentIdsList);

        }

        if(!groupNameToDeleteList.isEmpty()){
            List<Id> groupIdToDeleteList = new List<Id>();
            for(Group g: [SELECT Id, Developername, Name FROM Group Where Developername IN: groupNameToDeleteList]){
                groupIdToDeleteList.add(g.Id);
            }
            callFutureDeleteOfGroups(groupIdToDeleteList);
        }

        if(!tagShareList.isEmpty() && toContinueTrigger){
            try{

                insert tagShareList;
            }catch(Exception e){
                objectIdToMessageErrosMap.put(recordList[0].Id,Label.SharingWithOutReason);
            }
        }
    }
    
    /*****************************************************************/
    /********************** USE CASE METHODS *************************/
    /*****************************************************************/

    /* CREATION OF GROUPS FOR SECURITY */

    Boolean haveException = false;
    List<String> grupNamesList = new List<String>();

    List<Id> clusterIdChildWithParentList = new List<Id>();
    Map<String, Id> mapGroupDevNameToClusterId = new Map<String, Id>();
    List<Group> groupsList = new List<Group>();
    private void createGroups(Cluster__c recNew){
        if(!canMethod('createGroups')){return;}
        AcceleratorSettings__c acceleratorSettings = AcceleratorSettings__c.getOrgDefaults();

        String groupName = '';
        
        Map<String,Schema.SObjectField> sobjectDescribeMap = Schema.getGlobalDescribe().get(GeneralUtils.prefix('[CMS]Cluster__c')).getDescribe().fields.getMap();
        try{        
            String fieldName = acceleratorSettings.ClusterFieldForPublicGroups__c;
            Schema.DescribeFieldResult fieldDescribe = sobjectDescribeMap.get(fieldName).getDescribe();

            if(fieldName != null && fieldDescribe.getType() == Schema.DisplayType.STRING){

                groupName = (String) recNew.get(fieldName);
                //groupName = (String) recNew.get('ExternalId__c1');

            }else{

                recNew.AddError(System.Label.SetUpAcceleratorSetting);
                haveException = true;
            }
            

        }catch(Exception ex){
            recNew.AddError(System.Label.AcceleratorSettingWrongField);
            haveException = true;

        }
        
        groupName = groupName.replaceAll('[^a-zA-Z0-9]','');

        groupName = GeneralUtils.getSubstring(groupName, 29);
        mapGroupDevNameToClusterId.put(groupName, recNew.Id);
        if(recNew.ParentCluster__c != null){
            clusterIdChildWithParentList.add(recNew.Id);
        }

        String groupNameRW = groupName + separatorGroupName + readAndWrite;
        String groupNameROViewUp = groupName + separatorGroupName + readAndOnlyViewUp;
        String groupNameROViewDown = groupName + separatorGroupName + readAndOnlyViewDown;

        Group publicGroupRW = new Group(Name = groupNameRW, Developername = groupNameRW, DoesIncludeBosses = false);
        groupsList.add(publicGroupRW);

        Group publicGroupROViewUp = new Group(Name = groupNameROViewUp, Developername = groupNameROViewUp, DoesIncludeBosses = false);
        groupsList.add(publicGroupROViewUp);

        Group publicGroupROViewDown = new Group(Name = groupNameROViewDown, Developername = groupNameROViewDown, DoesIncludeBosses = false);
        groupsList.add(publicGroupROViewDown);
        grupNamesList.add(publicGroupRW.name);
        grupNamesList.add(publicGroupROViewUp.name);
        grupNamesList.add(publicGroupROViewDown.name);
    }
    


    /* ADD LANGUAGE TO PARENT UP */
    List<Id> clusterIdChildWithParentListLang = new List<Id>();
    Map<Id,String> clusterIdToOtherLanguageMap = new Map<Id,String>();
    Boolean haveDefaultLanguage = false;
    private void addLanguages(Cluster__c recNew, Cluster__c recOld){

        if(!canMethod('addLanguages')){return;}

        String developerName = recNew.name;
        string recordtypename = Schema.SObjectType.Cluster__c.getRecordTypeInfosById().get(recNew.recordtypeid).getname();


        if(recordtypename == 'Cluster Leaf'){

            if(recNew.OtherLanguages__c != null){
                
                List<String> otherLanguagesList = recNew.OtherLanguages__c.split(';');
                for(String lang: otherLanguagesList){
                    if(lang == recNew.DefaultLanguage__c){

                        String selectDefaultLanguage = '';
                        Schema.DescribeFieldResult fieldResult = Cluster__c.DefaultLanguage__c.getDescribe();
                        List<Schema.PicklistEntry> picklist = fieldResult.getPicklistValues();
                        for(Schema.PicklistEntry pick:picklist){
                            if(pick.getValue()==recNew.DefaultLanguage__c){
                                selectDefaultLanguage = pick.getLabel();
                            }
                        }
                        
                        recNew.AddError(selectDefaultLanguage+' '+System.Label.ExistByDefaultLanguage);
                        haveDefaultLanguage = true;
                        haveException = true;
                    }
                }
            }
            if(recOld!=null){
                clusterIdChildWithParentListLang.add(recNew.Id);

                if(recNew.OtherLanguages__c != recOld.OtherLanguages__c){

                    clusterIdToOtherLanguageMap.put(recNew.Id,recNew.OtherLanguages__c);
                    
                }

                if(recNew.DefaultLanguage__c != recOld.DefaultLanguage__c){
                    
                    String newOtherLanguagesPlusDefault = '';
                    
                    
                    if(recNew.OtherLanguages__c != null && recNew.OtherLanguages__c != ''){
                        
                        newOtherLanguagesPlusDefault = recNew.OtherLanguages__c + ';' + recNew.DefaultLanguage__c;       
                    
                    }else{
                        
                        newOtherLanguagesPlusDefault =  recNew.DefaultLanguage__c;
                    }
                    clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                }

            }else{

                clusterIdChildWithParentListLang.add(recNew.Id);
                String newOtherLanguagesPlusDefault = '';
                if(recNew.OtherLanguages__c != null && recNew.OtherLanguages__c != ''){
                    clusterIdToOtherLanguageMap.put(recNew.Id,recNew.OtherLanguages__c);
                    if(recNew.DefaultLanguage__c != null && recNew.DefaultLanguage__c != null){
                        newOtherLanguagesPlusDefault = recNew.OtherLanguages__c + ';' + recNew.DefaultLanguage__c;
                        clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                    }

                }else{
                    if(recNew.DefaultLanguage__c != null && recNew.DefaultLanguage__c != ''){
                        newOtherLanguagesPlusDefault = recNew.DefaultLanguage__c;
                        clusterIdToOtherLanguageMap.put(recNew.Id,newOtherLanguagesPlusDefault);
                    }

                }
                
            }
        }

    }

    /* DELETION GROUPS FOR SECURITY */
    List<String> groupNameToDeleteList = new List<String>();
    private void deleteGroups(Cluster__c recOld){
        if(!canMethod('deleteGroups')){return;}

        if(recOld.PublicGroupRWName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupRWName__c);
        }

        if(recOld.PublicGroupRODownName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupRODownName__c);
        }

        if(recOld.PublicGroupROUpName__c != null){
            groupNameToDeleteList.add(recOld.PublicGroupROUpName__c);
        }
    }

    //PA-177 CMA: Clustering: Apex Sharing
    Boolean toContinueTrigger = true;
    Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
    List<SObject> recordList = new List<SObject>(); 
    private void addSharing(Cluster__c recNew, Cluster__c recOld, Boolean isMaster){
        if(!canMethod('addSharing')){return;}
        System.debug('Method addSharing');

        if(isMaster){
            Map<String, Schema.SObjectType> sharing = Schema.getGlobalDescribe();
            if(sharing.containsKey(GeneralUtils.prefix('[CMS]Cluster__Share'))) {

                if(recNew.PublicGroupRWName__c!= recOld.PublicGroupRWName__c || recNew.PublicGroupROUpName__c!= recOld.PublicGroupROUpName__c || recNew.PublicGroupRODownName__c!= recOld.PublicGroupRODownName__c){
                    recordList.add(recNew);
                }

            }
        }else{
            if(objectIdToMessageErrosMap.containsKey(recNew.Id)){
                recNew.addError(objectIdToMessageErrosMap.get(recNew.Id));
            }

        }

    }

    /* UTILITY METHODS */
    @future
    public static void matchGroupsWithParentCLusterGroups(List<String> groupChaildIdToParentIdList){
        List<GroupMember> gropupMemberList = new List<GroupMember>();
        for(String groupChaildIdToParentId: groupChaildIdToParentIdList){
            GroupMember groupMemberItem = new GroupMember(
                UserOrGroupId = groupChaildIdToParentId.split('_')[0],
                GroupId = groupChaildIdToParentId.split('_')[1]
            );
            gropupMemberList.add(groupMemberItem);
        }
        insert gropupMemberList;
    }

    @future
    public static void callFutureDeleteOfGroups(List<Id> groupIds){
        delete [SELECT Id FROM Group WHERE Id IN: groupIds];
    }


}