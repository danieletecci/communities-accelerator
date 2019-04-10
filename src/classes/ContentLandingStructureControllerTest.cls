@isTest
public class ContentLandingStructureControllerTest {

	@testSetup
    static void setup(){
    	Network net = [SELECT Id, Name FROM Network LIMIT 1];
        MockupFactory.generateAcceleratorSetting();
        List<Cluster__c> clusterRoot = MockupFactory.createCluster('CRootTest', null, 1, 'ClusterRoot', 'CRT');
        clusterRoot[0].CommunityName__c = net.Name;
        update clusterRoot;
        List<Cluster__c> clustersLevel2 = MockupFactory.createCluster('CL2Test', clusterRoot.get(0).Id, 2, 'ClusterGroup', 'CGT');
        Set<Id> level2Ids = (new Map<Id, SObject>(clustersLevel2)).keySet();
        List<Cluster__c> clustersLevel3 = MockupFactory.createCluster('CL3Test', new List<Id>(level2Ids), 2, 'ClusterGroup', 'es', '', 'CG2');
        Set<Id> level3Ids = (new Map<Id, SObject>(clustersLevel3)).keySet();
        List<Cluster__c> clustersLeaf = MockupFactory.createCluster('CLeafTest', new List<Id>(level3Ids), 2, 'ClusterLeaf', 'es', '', 'CLT');

        List<Navigation__c> navs = MockupFactory.createNavigation('testNav', 'testUrl', 3, clusterRoot.get(0).Id);
        for(Navigation__c n : navs)
        	n.Type__c = 'Internal';
        update navs;

        Menu__c mainMenu = MockupFactory.createMenu('mainMenu', 1, clusterRoot.get(0).Id)[0]; 
        mainMenu.RecordTypeId = Schema.SObjectType.Menu__c.getRecordTypeInfosByDeveloperName().get('Menu').getRecordTypeId();
    	mainMenu.Navigation__c = navs.get(0).Id;
    	update mainMenu;
       	
       	Menu__c subMenu1 = MockupFactory.createMenu('subMenu1', 1, clusterRoot.get(0).Id)[0]; 
        subMenu1.RecordTypeId = Schema.SObjectType.Menu__c.getRecordTypeInfosByDeveloperName().get('SubMenu').getRecordTypeId();
        subMenu1.ParentMenu__c = mainMenu.Id; 
        subMenu1.Navigation__c = navs.get(1).Id;
        update subMenu1;

        Menu__c subMenu2 = MockupFactory.createMenu('subMenu2', 1, clusterRoot.get(0).Id)[0]; 
        subMenu2.RecordTypeId = Schema.SObjectType.Menu__c.getRecordTypeInfosByDeveloperName().get('SubMenu').getRecordTypeId();
        subMenu2.ParentMenu__c = mainMenu.Id;
        subMenu2.Navigation__c = navs.get(2).Id;
        update subMenu2;

        List<user> userForTesting = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        ClusterUser__c cu = new ClusterUser__c(Cluster__c=clusterRoot.get(0).Id, AccessLevel__c = 'Read/Write', User__c = userForTesting.get(0).Id);
        insert cu;
    }

    @isTest
    public static void getMenus(){
    	ContentLandingStructureController.getMenus();
    }

    @isTest
    public static void getGeneralData(){
        List<user> userForTesting = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
    	system.runAs(userForTesting[0]) {
            try{
                ContentLandingStructureController.getGeneralData();
            } catch (AuraException e){
                System.assert(e.getMessage() == 'The site does not exist' || e.getMessage() == 'The community does not exist', 'error');
            }
    	}
    }

    @isTest
    public static void getSiteId(){
    	List<Cluster__c> clRoot = [SELECT Id FROM Cluster__c WHERE RecordType.DeveloperName = 'ClusterRoot'];
        try{
            ContentLandingStructureController.getSiteId(clRoot.get(0).Id);
        } catch (AuraException e){
            System.assertEquals('The site does not exist', e.getMessage(), 'error');
        }
    }

}