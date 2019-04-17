@isTest
public class MenuControllerTest {
    @testSetup
    static void setup(){
        // Given in all cases
        MockupFactory.generateAcceleratorSetting();
        MockupFactory.createCluster('global', null, 1, 'ClusterRoot', 'CRT');
    }
    @isTest
    static void CASE_1(){
        //Comment: recuperar el ComponentWrapper de Navigation a partir de un ComponentExternalId, un ClasterId y un Device 
        //Given
        Cluster__c cluster = [SELECT id FROM Cluster__c LIMIT 1][0];
        List<Component__c> component = MockupFactory.createComponent('Menu',1,cluster);
        List<RecordType> menuRTs = [SELECT Id FROM RecordType WHERE SObjectType =: GeneralUtils.prefix('[CMS]Menu__c') ORDER BY Name ASC];
        Menu__c mainMenu = MockupFactory.createMenu('mainMenu', 1, cluster.Id)[0]; 
        mainMenu.RecordTypeId = menuRTs[0].Id; update mainMenu;
        Menu__c subMenu1 = MockupFactory.createMenu('subMenu1', 1, cluster.Id)[0]; 
        subMenu1.RecordTypeId = menuRTs.get(1).Id; subMenu1.ParentMenu__c = mainMenu.Id; update subMenu1;
        Menu__c subMenu2 = MockupFactory.createMenu('subMenu2', 1, cluster.Id)[0]; 
        subMenu2.RecordTypeId = menuRTs.get(1).Id; subMenu2.ParentMenu__c = mainMenu.Id; update subMenu2;
        MenuAssignment__c menuAssignment = new MenuAssignment__c(component__c = component[0].Id, Menu__c = mainMenu.Id); 
        insert menuAssignment;

        //When
        test.startTest();
        MenuController.ComponentWrapper componentWrapper = MenuController.getNavWrapper(component[0].ExternalId__c, cluster.id, 'DESKTOP');
        test.stopTest();
        //Then
        System.assertNotEquals(null, componentWrapper);
        System.assertEquals(component[0].ExternalId__c, componentWrapper.component.ExternalId);
        System.assertEquals(cluster.id, componentWrapper.clusterId);
        System.assertEquals('DESKTOP', componentWrapper.device);
    }
}