public with sharing class ComponentUtils {

	public static Component__c getComponent(String componentUniqueId, set<String> fieldSet, String device){
        String queryString = 'SELECT ' + GeneralUtils.joinFields(fieldSet) + ' FROM [CMS]Component__c WHERE Id =: componentUniqueId OR [CMS]ExternalId__c = \'' + componentUniqueId + '\' LIMIT 1';
        queryString = GeneralUtils.prefix(queryString);
        List<Component__c> queryResult = Database.query(queryString);
        
        Component__c component;
        if(!queryResult.isEmpty()){
        	component = queryResult[0];
        }

        return component;
    }

}