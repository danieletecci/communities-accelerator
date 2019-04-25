public with sharing class ComponentPreviewController {
    
    @AuraEnabled(cacheable=false)
    public static ObjectComponentWrapper getRecord(String recordId){
        Component__c comp = [SELECT Id, Name, ExternalId__c, RecordType.DeveloperName FROM Component__c WHERE Id =: recordId];
        return new ObjectComponentWrapper(comp);
    }
    
    @AuraEnabled(cacheable=false)
    public static String getClusterName(String recordId){
        Cluster__c cluster = [SELECT Id, Name FROM Cluster__c WHERE Id =: recordId LIMIT 1];
        return cluster.Name;
    }

}