public with sharing class CG_CommunityComponentFrameController {



    //WRAPPERS
    public class ContentRecordTypeWrapper{
		@auraEnabled public Boolean haveContentRecordType;
		@auraEnabled public String contentRecordTypeId;
		public ContentRecordTypeWrapper(){
			this.haveContentRecordType = false;
            this.contentRecordTypeId = '';
		}
	}


	@auraEnabled
	public static ContentRecordTypeWrapper getContentRecordtypeId(String componentRecordType) {
		// List of fields
		ContentRecordTypeWrapper contentRecordTypeWP =  new ContentRecordTypeWrapper();

		String contentRecordType = ContentUtils.getRecordTypeContentFromRTComponent(componentRecordType);

		RecordType recordType = [select Id, Name from RecordType where sObjectType =: GeneralUtils.prefix('[CMS]Content__c') and DeveloperName = :contentRecordType LIMIT 1]; 
		
		if(recordType != null){
			contentRecordTypeWP.contentRecordTypeId = String.valueOf(recordType.Id);
			contentRecordTypeWP.haveContentRecordType = true;
			return contentRecordTypeWP;
		}else{
			return contentRecordTypeWP;
		}
	}



	@auraEnabled
	public static String getNavigationId(String navigationUrl) {
		String url = navigationUrl.split('/')[navigationUrl.split('/').size()-1];
		Navigation__c nav = [SELECT Id From Navigation__c WHERE Url__c =: url]; 
		if (nav != null){
			return nav.Id;
		}
		else{
			return '';
		}
	}

}