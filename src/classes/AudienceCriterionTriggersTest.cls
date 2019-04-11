@isTest(seeAllData = false)
public class AudienceCriterionTriggersTest {
	
    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}

	@isTest 
	static void setExternalIdTest_1(){
		/* Comment: Checks if in the AudienceCriterion__c creation the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(
            Audience__c = audienceTest.Id,
            FieldAPIName__c = 'Name',
            MainObjectType__c = 'Account',
            Operator__c = 'equals',
            Order__c = 1,
            Value__c = 'Test',
            ValueType__c = 'Text'
        );

		//When
		Test.startTest();
		insert(audCriterionTest);
		Test.stopTest();

		//Then
		AudienceCriterion__c audCriterionTestPost = [SELECT ExternalId__c FROM AudienceCriterion__c WHERE Id =: audCriterionTest.Id];
		System.assertNotEquals(audCriterionTestPost.ExternalId__c, null);
	}

	@isTest 
	static void setExternalIdTest_2(){
		/* Comment: Checks if in the AudienceCriterion__c update the ExternalId__c is completed as required */

		//Given
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c cg = clusterRootList[0];
        List<Cluster__c> clusterList = MockupFactory.createCluster('BuenosAires', cg.Id, 1, 'ClusterGroup', 'CGT');
		Audience__c audienceTest = new Audience__c(Cluster__c = clusterList[0].Id, Name = 'Test', RecordTypeId = AudienceUtils.rtAudience);
		insert audienceTest;
		AudienceCriterion__c audCriterionTest = new AudienceCriterion__c(
            Audience__c = audienceTest.Id,
            FieldAPIName__c = 'Name',
            MainObjectType__c = 'Account',
            Operator__c = 'equals',
            Order__c = 1,
            Value__c = 'Test',
            ValueType__c = 'Text'
        );
        insert audCriterionTest;

		//When
		Test.startTest();
        audCriterionTest.ExternalId__c = null;
        update audCriterionTest;
		Test.stopTest();

		//Then
		AudienceCriterion__c audCriterionTestPost = [SELECT ExternalId__c FROM AudienceCriterion__c WHERE Id =: audCriterionTest.Id];
		System.assertNotEquals(audCriterionTestPost.ExternalId__c, null);
	}
}