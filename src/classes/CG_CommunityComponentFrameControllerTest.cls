@isTest
private class CG_CommunityComponentFrameControllerTest
{
	@isTest
	static void getContentRecordtypeId()
	{
		// Given
		// Exist a sObject with recordType Article
		String rtAR = [SELECt id, name, SobjectType FROM RecordType WHERE SobjectType =: GeneralUtils.prefix('[CMS]Content__c') AND DeveloperName = 'Article'].id;

		// When
		test.startTest();
		String crtw = CG_CommunityComponentFrameController.getContentRecordtypeId('ArticleList');
		test.stopTest();

		// Then
		System.assertEquals(rtAR, crtw);

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