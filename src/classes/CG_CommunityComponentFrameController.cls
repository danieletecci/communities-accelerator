public with sharing class CG_CommunityComponentFrameController {

	@auraEnabled
	public static String getContentRecordtypeId(String componentRecordType) {
		String contentRecordTypeId;

		String contentRTDevName = ContentUtils.rtComponentToContent.get(componentRecordType);
        if(contentRTDevName != null){
            contentRecordTypeId = Schema.SObjectType.Content__c.getRecordTypeInfosByDeveloperName().get(GeneralUtils.prefix(contentRTDevName)).getRecordTypeId();
        }

		return contentRecordTypeId;
	}



	@auraEnabled
	public static String getNavigationId(String navigationUrl) {
		return GeneralUtils.getNavigationId(navigationUrl);
	}

}