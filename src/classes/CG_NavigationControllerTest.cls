@isTest
public class CG_NavigationControllerTest {
    @testSetup
    static void setup(){
        // Given in all cases
        MockupFactory.generateAcceleratorSetting();
		MockupFactory.createCluster('global', null, 1, 'ClusterRoot');
    }
    @isTest
    static void CASE_1(){
        //Comment: recuperar el ComponentWrapper de Navigation a partir de un ComponentExternalId, un ClasterId y un Device 
        //Given
        Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1];
        List<Component__c> component = MockupFactory.createComponent('Banner',1);
        //When
        test.startTest();
        CG_NavigationController.ComponentWrapper componentWrapper = CG_NavigationController.getNavWrapper(component[0].ExternalId__c, cluster.id, 'DESKTOP');
        test.stopTest();
        //Then
        System.assertNotEquals(null, componentWrapper);
        System.assertEquals(component[0].ExternalId__c, componentWrapper.component.ExternalId__c);
        System.assertEquals(cluster.id, componentWrapper.clusterId);
        System.assertEquals('DESKTOP', componentWrapper.device);
    }
}