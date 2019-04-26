@isTest(seeAllData = false)
public class FormSectionTriggersTest {
	
	@isTest 
	static void insertFormSectionTest(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 1, 'ClusterRoot', 'CRT')[0];
		//When
		Test.startTest();
		MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);		
		Test.stopTest();
		//Then
		Form__c form = [SELECT id, ExternalId__c FROM Form__c];
        System.assert(form.ExternalId__c != null);

	}

	@isTest
	static void updateFormSection(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        Cluster__c cluster = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', cluster.id);
		//When
		Test.startTest();
		FormSection__c formSection = [SELECT id, name FROM FormSection__c LIMIT 1];
        formSection.name = 'updated';
        update formSection;
        Test.stopTest();
		//Then
		formSection = [SELECT id, ExternalId__c FROM FormSection__c];
        System.assert(formSection.ExternalId__c != null);

	}
}