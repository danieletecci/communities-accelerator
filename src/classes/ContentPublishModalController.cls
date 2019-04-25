public with sharing class ContentPublishModalController {
	
	@auraEnabled(cacheable=false)
	public static ObjectContentWrapper schedulePublication(Object content){
		ObjectContentWrapper ocw = (ObjectContentWrapper) JSON.deserialize(JSON.serialize(content), ObjectContentWrapper.class);
        Savepoint sp = Database.setSavepoint();
        Content__c contentVar = ocw.parse();

		try{
			update contentVar;
		} catch(Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return new ObjectContentWrapper(contentVar);
	}
}