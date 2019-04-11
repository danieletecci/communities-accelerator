@isTest(seeAllData = false)
public class CMSTest {
	
    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest 
	static void updateUserSettings(){
		/* Comment: Checks if the settings is created and the audiences are calculated */

		//Given
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest;
        audienceTest.Status__c = 'Active';
        update audienceTest;

		//When
		Test.startTest();
		CMS.updateUserSettings(u.Id, clusterList[0].Id, null, null, null, u.Id);
		Test.stopTest();

		//Then
		CMSUserSettings__c CMSUserSettings = [SELECT Audiencies__c FROM CMSUserSettings__c];
        Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertEquals(audienceTestPost.ExternalId__c, CMSUserSettings.Audiencies__c);
	}

    @isTest 
	static void getUserSettings(){
		/* Comment: Checks if the the methods getUserSettings returns the CMS User Settings from a User Id */

		//Given
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest;
        audienceTest.Status__c = 'Active';
        update audienceTest;
        CMS.updateUserSettings(u.Id, clusterList[0].Id, null, null, null, u.Id);

		//When
		Test.startTest();
		CMSUserSettings__c CMSUserSettings = CMS.getUserSettings(u.Id);
		Test.stopTest();

		//Then
		System.assertEquals(u.Id, CMSUserSettings.User__c);
	}

	@isTest 
	static void getUserAudiences(){
		/* Comment: Checks if the methods getUserAudiences returns a set of Audiences External Ids of a User */

		//Given
        User u = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'User', Operator__c = 'equals', Order__c = 1, Value__c = u.Name, ValueType__c = 'Text');
        insert audCriterionTest;
        audienceTest.Status__c = 'Active';
        update audienceTest;
        CMS.updateUserSettings(u.Id, clusterList[0].Id, null, null, null, u.Id);

		//When
		Test.startTest();
		Set<String> audiencesSet = CMS.getUserAudiences(u.Id);
		Test.stopTest();

		//Then
		Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertEquals(1, audiencesSet.size());
		System.assert(audiencesSet.contains(audienceTestPost.ExternalId__c));
	}

}