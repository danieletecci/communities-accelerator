@isTest(seeAllData = false)
public class AudienceTriggersTest {
	
    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest
	static void setExternalId_Insert(){
		/* Comment: Checks if in the Audience__c creation the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		
		//When
		Test.startTest();
		insert audienceTest;
		Test.stopTest();

		//Then
		Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertNotEquals(null, audienceTestPost.ExternalId__c);
	}

	@isTest 
	static void setExternalId_Update(){
		/* Comment: Checks if in the Audience__c update the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;

		//When
		Test.startTest();
		audienceTest.ExternalId__c = null;
        update audienceTest;
		Test.stopTest();

		//Then
		Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertNotEquals(null, audienceTestPost.ExternalId__c);
	}

    @isTest
	static void setExternalIdAudienceGroup_Insert(){
		/* Comment: Checks if in the Audience__c creation the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, RecordTypeId = AudienceUtils.rtAudienceGroup);
		
		//When
		Test.startTest();
		insert audienceTest;
		Test.stopTest();

		//Then
		Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertNotEquals(null, audienceTestPost.ExternalId__c);
	}

    @isTest
	static void setExternalIdAudienceGroup_Update(){
		/* Comment: Checks if in the Audience__c update the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, RecordTypeId = AudienceUtils.rtAudienceGroup);
		insert audienceTest;

		//When
		Test.startTest();
		audienceTest.ExternalId__c = null;
        update audienceTest;
		Test.stopTest();

		//Then
		Audience__c audienceTestPost = [SELECT ExternalId__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertNotEquals(null, audienceTestPost.ExternalId__c);
	}

    @isTest
	static void convertExternalIdsToSFIds(){
		/* Comment: Checks if the convertion of External Ids to SF Ids on Reference Audiences for Audience Groups works as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		
        Audience__c audienceTest1 = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test1', RecordTypeId = AudienceUtils.rtAudience);
        Audience__c audienceTest2 = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test2', RecordTypeId = AudienceUtils.rtAudience);
        insert new List<Audience__c>{audienceTest1, audienceTest2};
        List<Audience__c> audiencesTestList = [SELECT Id, ExternalId__c FROM Audience__c];

        Audience__c audienceTestGroup = new Audience__c(
            Cluster__c = clusterList[0].Id,
            Name = 'Test Group',
            RecordTypeId = AudienceUtils.rtAudienceGroup,
            ReferenceAudienceExternalIds__c = audiencesTestList[0].ExternalId__c + ';' + audiencesTestList[1].ExternalId__c
        );

		//When
		Test.startTest();
		insert audienceTestGroup;
		Test.stopTest();

		//Then
		Audience__c audienceTestGroupPost = [SELECT ReferenceAudience__c FROM Audience__c WHERE Id =: audienceTestGroup.Id];
        System.assertEquals(String.ValueOf(audiencesTestList[0].Id).substring(0, 15) + ';' + String.ValueOf(audiencesTestList[1].Id).substring(0, 15), audienceTestGroupPost.ReferenceAudience__c);
	}

    @isTest
	static void checkCustomCriteria(){
		/* Comment: Checks the validation of Audience Custom Criteria */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest1 = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'Account', Operator__c = 'equals', Order__c = 1, Value__c = 'Test', ValueType__c = 'Text');
        AudienceCriterion__c audCriterionTest2 = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'Account', Operator__c = 'equals', Order__c = 2, Value__c = 'Test', ValueType__c = 'Text');
        AudienceCriterion__c audCriterionTest3 = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'Account', Operator__c = 'equals', Order__c = 3, Value__c = 'Test', ValueType__c = 'Text');
        insert new List<AudienceCriterion__c>{audCriterionTest1, audCriterionTest2, audCriterionTest3};
		
        //When
		Test.startTest();
        List<String> errorMessages = new List<String>();
		audienceTest.MatchCriteria__c = 'Custom';
        audienceTest.AudienceCriteria__c = '1 OR (2 AND 4)';
        try{
            update audienceTest;
        }catch(DMLException e){
            errorMessages.add(e.getMessage());
        }
		audienceTest.AudienceCriteria__c = '1 A OR (2 AND 3)';
        try{
            update audienceTest;
        }catch(DMLException e){
            errorMessages.add(e.getMessage());
        }
		audienceTest.AudienceCriteria__c = '(1 OR (2 AND 3)';
        try{
            update audienceTest;
        }catch(DMLException e){
            errorMessages.add(e.getMessage());
        }
		audienceTest.AudienceCriteria__c = '1 OR (2 AND 3)';
		update audienceTest;
		Test.stopTest();

		//Then
		System.assertEquals(3, errorMessages.size());
		System.assert(errorMessages[0].contains(Label.CustomCriteriaValidation));
		System.assert(errorMessages[1].contains(Label.CustomCriteriaValidation));
		System.assert(errorMessages[2].contains(Label.CustomCriteriaValidation));
		Audience__c audienceTestPost = [SELECT AudienceCriteria__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertEquals('1 OR (2 AND 3)', audienceTestPost.AudienceCriteria__c);
	}

	@isTest
	static void checkCriteriaOnActivation(){
		/* Comment: Checks of validate activation of audience with criteria */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		
        //When
		Test.startTest();
		String errorMessage;
		audienceTest.Status__c = 'Active';
        try{
            update audienceTest;
        }catch(DMLException e){
            errorMessage = e.getMessage();
        }
		AudienceCriterion__c audCriterionTest1 = new AudienceCriterion__c(Audience__c = audienceTest.Id, FieldAPIName__c = 'Name', MainObjectType__c = 'Account', Operator__c = 'equals', Order__c = 1, Value__c = 'Test', ValueType__c = 'Text');
        insert new List<AudienceCriterion__c>{audCriterionTest1};
		audienceTest.Status__c = 'Active';
		update audienceTest;
		Test.stopTest();

		//Then
		System.assert(errorMessage.contains(Label.AudienceValidationOnStatusActivate));
		Audience__c audienceTestPost = [SELECT Status__c FROM Audience__c WHERE Id =: audienceTest.Id];
		System.assertEquals('Active', audienceTestPost.Status__c);
	}

}