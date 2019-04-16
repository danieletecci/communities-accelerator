public with sharing class ContentPublishModalController {
	@auraEnabled
	public static Content__c schedulePublication(Content__c content){
		try{
			update content;
		} catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return content;
	}
}