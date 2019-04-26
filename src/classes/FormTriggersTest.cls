@isTest(seeAllData = false)
public class FormTriggersTest {
	
	@isTest 
	static void insertFormTest(){
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
	static void updateForm(){
		//Given
		MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterList = MockupFactory.createCluster('Argentina', null, 2, 'ClusterRoot', 'CRT');
        MockupFactory.createForm('testName', 'testName', 'testRetrieval', clusterList[0].id);
		//When
		Test.startTest();
		Form__c form = [SELECT id, name FROM form__c];
        form.name = 'updated';
        form.cluster__c = clusterList[1].id;
        update form;
        Test.stopTest();
		//Then
		form = [SELECT id, ExternalId__c FROM Form__c];
        System.assert(form.ExternalId__c != null);

	}
}