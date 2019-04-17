@isTest
public class LookupControllerTest {

    @testSetup
    static void setupTest(){
		MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('Cluster Root', '', 1, 'ClusterRoot', 'CRT');
        MockupFactory.createNavigation('testNav', 'testUrl', 2, clusterRoot.get(0).Id);
    }

    @isTest 
	static void fetchLookUpValuesTest() {
		//When
        String searchKeyword = 'testNav';
        String objectApiName = 'Navigation__c';
		//Given
		List<sObject> listObject = LookupController.fetchLookUpValues(searchKeyword, objectApiName);
		//Then
		System.assertEquals(listObject.size(), 2);
	}
    @isTest 
	static void getInitialValueTest() {
		//When
        Navigation__c nav = [SELECT id FROM Navigation__c LIMIT 1];
        String recordId = nav.id;
        String objectApiName = 'Navigation__c';
		//Given
		sObject obj = LookupController.getInitialValue(recordId, objectApiName);
		//Then
		system.assertEquals(((Navigation__c)obj).name, 'testNav0');
	}

    

}