@isTest
private class CG_CommunityComponentFrameControllerTest
{
	@isTest
	static void getContentRecordtypeId()
	{
		// Given Exist a sObject with recordType ArticlesRelated


		// When
		test.startTest();
		CG_CommunityComponentFrameController.ContentRecordTypeWrapper crtw = CG_CommunityComponentFrameController.getContentRecordtypeId('ArticlesRelated');
		test.stopTest();


		// Then
		System.assert(crtw.haveContentRecordType);

	}

	@isTest
	static void getNavigationId()
	{
		// Given 
		//Navigation Record
        Navigation__c nav = new Navigation__c(Name = 'NavTest', URL__c = 'testNav');
        insert nav;


		// When
		test.startTest();
		String navId = CG_CommunityComponentFrameController.getNavigationId('/s/testNav');
		test.stopTest();


		// Then
		System.assertNotEquals(navId, null);

	}


}