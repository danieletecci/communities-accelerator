@isTest(seeAllData = false)
public class FormValidationTriggersTest {
	
	@isTest 
	static void insertFormValidationTest(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT')[0];
		//When
		Test.startTest();
		MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);		
		Test.stopTest();
		//Then
		FormValidation__c formValidation = [SELECT id, ExternalId__c FROM FormValidation__c LIMIT 1];
        System.assert(formValidation.ExternalId__c != null);

	}

	@isTest
	static void updateFormValidation(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);
		//When
		Test.startTest();
		FormValidation__c formValidation = [SELECT id, name FROM FormValidation__c LIMIT 1];
        formValidation.name = 'updated';
        update formValidation;
        Test.stopTest();
		//Then
		formValidation = [SELECT id, ExternalId__c FROM FormValidation__c LIMIT 1];
        System.assert(formValidation.ExternalId__c != null);

	}
}