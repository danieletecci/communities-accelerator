public with sharing class ComponentUtils {

	public static Component__c getComponent(String componentExternalId, set<String> fieldSet, String device){
        List<Component__c> queryResult = Database.query(GeneralUtils.prefix('SELECT ' + GeneralUtils.joinFields(fieldSet) + ' FROM [CMS]Component__c WHERE Id =: componentExternalId OR [CMS]ExternalId__c = \'' + componentExternalId + '\' LIMIT 1'));
        
        Component__c component;
        if(!queryResult.isEmpty()){
        	component = queryResult[0];
        }

        return component;
    }

}