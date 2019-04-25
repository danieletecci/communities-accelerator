global with sharing class SharingUtils{
    
    global static SharingWrapper generateSharingForRecordsOnCluster(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){
        
        lookupField = GeneralUtils.prefix(lookupField);
        nameObjectShare = GeneralUtils.prefix(nameObjectShare);
        sharingReason = GeneralUtils.prefix(sharingReason);

        Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
        Boolean excecuteTrigger = true;
        Map<String,Id> groupNameToGroupIdMap = new Map<String,Id>();
        Map<Id,List<Id>> mapRecordsByCluster = new Map<Id,List<Id>>();
        List<String> groupNameList = new List<String>();
        List<SObject> listOfSharesToInsert = new List<SObject>();

        for(SObject record: records){
            Id clusterId = (Id) record.get(lookupField);
            Id recordId = (Id) record.get('Id');
            if(!mapRecordsByCluster.containsKey(clusterId)){
                mapRecordsByCluster.put(clusterId, new List<Id>{recordId});
            }else{
                mapRecordsByCluster.get(clusterId).add(recordId);
            }
        }

        Map<Id,Cluster__c> mapClusters = new Map<Id,Cluster__c>([SELECT Id, PublicGroupRWName__c, PublicGroupROUpName__c, PublicGroupRODownName__c  FROM Cluster__c WHERE Id IN: mapRecordsByCluster.keyset()]); 
        
        for(Id clusterId: mapClusters.keySet()){
            Cluster__c cluster = mapClusters.get(clusterId);

            groupNameList.add(cluster.PublicGroupRWName__c);
            groupNameList.add(cluster.PublicGroupRODownName__c);
            groupNameList.add(cluster.PublicGroupROUpName__c);
        }

        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name IN :groupNameList];


        for(Group groupItem: groupList){

            if(!groupNameToGroupIdMap.containsKey(groupItem.Name)){
                 groupNameToGroupIdMap.put(groupItem.Name, groupItem.Id);
            }
        }

        Map<String,String> fieldNamesAndSecLevel = new Map<String,String>{
            GeneralUtils.prefix('[CMS]PublicGroupRWName__c') => 'Edit',
            GeneralUtils.prefix('[CMS]PublicGroupROUpName__c') => 'Read',
            GeneralUtils.prefix('[CMS]PublicGroupRODownName__c') => 'Read'
        };
        
        
        for(Id clusterId : mapRecordsByCluster.keySet()){
            if(mapClusters.containsKey(clusterId)){
                for(Id recordId: mapRecordsByCluster.get(clusterId)){
                    for(String fieldName: fieldNamesAndSecLevel.keySet()){
                        if(String.isNotBlank((String) mapClusters.get(clusterId).get(fieldName))){
                            
                            String objectName = recordId.getSobjectType().getDescribe().getName();
                            String shareObjectName = nameObjectShare;
                            Schema.SObjectType shareType = Schema.getGlobalDescribe().get(shareObjectName);
                            SObject shareRecord = shareType.newSObject();
                            shareRecord.put('ParentId', recordId);

                            if(groupNameToGroupIdMap.containsKey((String) mapClusters.get(clusterId).get(fieldName))){

                                shareRecord.put('UserOrGroupId', groupNameToGroupIdMap.get( (String) mapClusters.get(clusterId).get(fieldName)) );
                                shareRecord.put('RowCause', sharingReason);
                                shareRecord.put('AccessLevel', fieldNamesAndSecLevel.get(fieldName));
                                listOfSharesToInsert.add(shareRecord);
                            }else{

                                objectIdToMessageErrosMap.put(recordId,Label.ClusterDoesntHaveRequiredGroups);
                            }

                        }else{
                            objectIdToMessageErrosMap.put(recordId,Label.ClusterHaveGroupsInBlanks);
                        }
                    }
                }
            }
        }

        SharingWrapper sharingWrapper = new SharingWrapper(objectIdToMessageErrosMap, listOfSharesToInsert);
        return sharingWrapper;
    }

    public static SharingWrapper generateSharingForCluster(List<SObject> records, String lookupField, String nameObjectShare, String sharingReason, Boolean isCluster){

        lookupField = GeneralUtils.prefix(lookupField);
        nameObjectShare = GeneralUtils.prefix(nameObjectShare);
        sharingReason = GeneralUtils.prefix(sharingReason);

        Map<Id,String> objectIdToMessageErrosMap = new Map<Id,String>();
        Boolean excecuteTrigger = true;
        Map<String,Id> groupNameToGroupIdMap = new Map<String,Id>();
        Map<Id,List<Id>> mapRecordsByCluster = new Map<Id,List<Id>>();
        List<String> groupNameList = new List<String>();
        List<SObject> listOfSharesToInsert = new List<SObject>();

        for(Sobject recordItem: records){
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupRWName__c);
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupRODownName__c);
            groupNameList.add( ((Cluster__c) recordItem).PublicGroupROUpName__c);
        }
        //System.debug('TagTriggers dataPreparing groupNameList: ' + groupNameList);
        List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name IN :groupNameList];

        for(Group groupItem: groupList){

            if(!groupNameToGroupIdMap.containsKey(groupItem.Name)){
                 groupNameToGroupIdMap.put(groupItem.Name, groupItem.Id);
            }
        }

        Map<String,String> fieldNamesAndSecLevel = new Map<String,String>{
            GeneralUtils.prefix('[CMS]PublicGroupRWName__c') => 'Edit',
            GeneralUtils.prefix('[CMS]PublicGroupROUpName__c') => 'Read',
            GeneralUtils.prefix('[CMS]PublicGroupRODownName__c') => 'Read'
        };
        for(SObject record: records){
            for(String fieldName: fieldNamesAndSecLevel.keySet()){
                String shareObjectName = nameObjectShare;
                Schema.SObjectType shareType = Schema.getGlobalDescribe().get(shareObjectName);
                SObject shareRecord = shareType.newSObject();
                shareRecord.put('ParentId', record.Id);
                shareRecord.put('UserOrGroupId', groupNameToGroupIdMap.get( (String) record.get(fieldName)) );
                shareRecord.put('RowCause', sharingReason);
                shareRecord.put('AccessLevel', fieldNamesAndSecLevel.get(fieldName));
                listOfSharesToInsert.add(shareRecord);
            }
        }

        SharingWrapper sharingWrapper = new SharingWrapper(objectIdToMessageErrosMap, listOfSharesToInsert);
        return sharingWrapper;
    }

    global class SharingWrapper{
        global Map<Id,String> objectIdToMessageErrosMap{get;set;}
        global List<SObject> listOfSharesToInsert{get;set;}
        global SharingWrapper(Map<Id,String> objectIdToMessageErrosMap, List<SObject> listOfSharesToInsert){
            this.objectIdToMessageErrosMap = objectIdToMessageErrosMap;
            this.listOfSharesToInsert = listOfSharesToInsert;
        }
    }

}