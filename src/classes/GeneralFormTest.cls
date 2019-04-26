@isTest
public class GeneralFormTest {

    @testSetup
    public static void setup() {
        MockupFactory.generateAcceleratorSetting();
        insert new Account(name='test');
        List<Cluster__c> clusterList = MockupFactory.createCluster('testCluster', null, 1, 'ClusterRoot', 'testExternal');
    	MockupFactory.createForm('testName', 'testName', 'testRetrieval', clusterList.get(0).id);
    }
  
    public static testMethod void testGetFormData() {
        //Given
        Cluster__c c = [SELECT id from Cluster__c];
        Account acc = [SELECT id FROM Account];
        //when
        GeneralForm generalForm = new GeneralForm('testName', new Set<Id>{c.id}, acc.id);
        //then
		System.assertEquals('testExternal', generalForm.formSettings.uniqueFormName);
        
    }
    
}