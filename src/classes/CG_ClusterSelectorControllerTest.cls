@isTest
public with sharing class CG_ClusterSelectorControllerTest {
	
    @testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}
    
	@isTest 
	static void clusterSelectTest(){
		/* Comment: Comprueba que dado un ExternalId__c trae el cluster correspondiente*/

		//Given

		Cluster__c clusterToInsert = MockupFactory.createCluster('Argentina', null, 3, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createComponent('Banner', 1);

		Cluster__c cluster = [SELECT Id, ExternalId__c, Name FROM Cluster__c WHERE RecordType.DeveloperName='ClusterRoot' and Name like 'Argentina%' LIMIT 1];	
		Component__c component = [SELECT Id, ExternalId__c, FirstCluster__c, OnlyClusterLeaf__c From Component__c Limit 1];
        
		component.FirstCluster__c= cluster.Id;
		update component;
		//When
		Test.startTest();
        CG_ClusterSelectorController.TreeWrapper tree =CG_ClusterSelectorController.getClusterRootByExternalId(component.ExternalId__c);
		Test.stopTest();
		//Then
		System.assertEquals(tree.label, cluster.Name);
	}
    
    @isTest 
	static void clusterFromComponentSelectTest(){
		/* Comment: Comprueba que dado el Id de un componente trae el cluster correspondiente*/

		//Given

		Cluster__c clusterToInsert1 = MockupFactory.createCluster('Argentina', null, 3, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createComponent('Banner', 1);

		Cluster__c cluster = [SELECT Id, ExternalId__c, Name FROM Cluster__c WHERE RecordType.DeveloperName='ClusterRoot' and Name like 'Argentina%' LIMIT 1];	
		Component__c component = [SELECT Id, ExternalId__c, FirstCluster__c, OnlyClusterLeaf__c From Component__c Limit 1];
        
		component.Cluster__c = cluster.Id;
		update component;
		//When
		Test.startTest();
        CG_ClusterSelectorController.TreeWrapper tree = CG_ClusterSelectorController.getClusterRootForComponent(component.Id);
		Test.stopTest();
		//Then
		System.assertEquals(tree.label, cluster.Name);
	}

	@isTest 
	static void clusterLandingTest(){
		
		/* Comment: Comprueba que dado un cluster devuelve el url correspondiente*/

		//Given

		Cluster__c clusterToInsert = MockupFactory.createCluster('Argentina', null, 3, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createComponent('Banner', 1); 
        
		Cluster__c cluster = [SELECT Id, ExternalId__c, Name, ClusterLandingUrl__c FROM Cluster__c WHERE RecordType.DeveloperName='ClusterRoot' and Name like 'Argentina%' LIMIT 1];		
		Component__c component = [SELECT Id, ExternalId__c, FirstCluster__c, OnlyClusterLeaf__c From Component__c Limit 1];
		component.FirstCluster__c= cluster.Id;
		update component;

		Navigation__c nav = new Navigation__c();
		nav.Name = 'test';
		nav.URL__c = 'www.google.com';
		insert nav;

		cluster.ClusterLandingUrl__c = nav.Id;
		
		update cluster; 
        
		//When
		Test.startTest();
        string url = CG_ClusterSelectorController.getClusterRedirect(cluster.ClusterLandingUrl__c);
		Test.stopTest();
		//Then
		System.assertEquals(url, nav.URL__c);
		
		
	}

	@isTest 
	static void clusterSelectExternalIdNullTest(){
		/* Comment: Comprueba que sin un ExternalId devuelve null*/

		//Given
		Cluster__c clusterToInsert = MockupFactory.createCluster('Argentina', null, 3, 'ClusterRoot', 'CRT')[0];
        MockupFactory.createComponent('Banner', 1); 

		Cluster__c cluster = [SELECT Id, ExternalId__c, Name FROM Cluster__c WHERE RecordType.DeveloperName='ClusterRoot' and Name like 'Argentina%' LIMIT 1];
		
		Component__c component = [SELECT Id, ExternalId__c, FirstCluster__c, OnlyClusterLeaf__c From Component__c Limit 1];
		component.FirstCluster__c= cluster.Id;
		update component;
		//When
		Test.startTest();
        CG_ClusterSelectorController.TreeWrapper tree = CG_ClusterSelectorController.getClusterRootByExternalId(null);
		Test.stopTest();
		//Then
		System.assertEquals(tree, null);
	}

}