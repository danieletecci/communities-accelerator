public with sharing class ContentCreateModalController {

    @AuraEnabled(cacheable=false)
    public static String getRecordTypeName(String recordTypeId){
        if(String.isBlank(recordTypeId)){
            return null;
        }
        return Schema.SObjectType.Content__c.getRecordTypeInfosById().get(recordTypeId).getName();
    }

    @AuraEnabled(cacheable=false)
    public static String createNewContent(String recordTypeId, Boolean isTemplate, String componentId, String navigationUrl, String recordName, String clusterId, String templateId){
        try{
            String responseId;
            if(templateId == null){
                Content__c newContent = new Content__c(
                    Name = recordName.left(60),
                    RecordTypeId = recordTypeId,
                    IsTemplate__c = isTemplate,
                    StructureComponent__c = componentId,
                    StructureNavigation__c = getNavigationByUrl(navigationUrl),
                    Cluster__c = clusterId
                );
                insert newContent;
                responseId = newContent.Id;
            }else{
                responseId = ContentUtils.createFromTemplate(templateId, recordName, clusterId);
            }
            return responseId;
        }catch(DMLException e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getDMLMessage(0));
        }catch(Exception e){
            System.debug(e.getMessage());
            System.debug(e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } 
    }

    @AuraEnabled(cacheable=false)
    public static String getClusters(){
        // Prepare results
        List<LookupWrapper> results     = new List<LookupWrapper>();
        List<Cluster__c> clusters    = ClusterUtils.getClustersBelowList(getClusterUserId());
        String clusterIcon = 'custom:custom26';
        String sobjectName = GeneralUtils.prefix('[CMS]Cluster__c');

        for (Cluster__c cluster : clusters) {
            results.add(new LookupWrapper(cluster.Id, sobjectName, clusterIcon, cluster.Name, cluster.ExternalId__c + ' • '+ cluster.RecordType.Name));
        }

        return JSON.serialize(results);
    }

    public static Id getClusterUserId(){
        List<ClusterUser__c> clusterUser = [SELECT Id, Cluster__c FROM ClusterUser__c WHERE User__c =:UserInfo.getUserId() AND AccessLevel__c = 'Read/Write'];
        if(clusterUser.size() == 0)
         //   throw new AuraException('You have no cluster associated');
            throw new AuraHandledException('You have no cluster associated');
        return clusterUser.get(0).Cluster__c;
    }

    public static Id getNavigationByUrl(String url){
        List<Navigation__c> navs = [SELECT Id FROM Navigation__c WHERE URL__c = :url];
        if(!navs.isEmpty())
            return navs.get(0).Id;

        return null;
    }

}