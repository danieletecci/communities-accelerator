@isTest(seeAllData = false)
public with sharing class ClusterTriggersTest {


	@testSetup
	static void generateCustomSettings(){
		MockupFactory.generateAcceleratorSetting();
	}


	@isTest static void generateOneRootCluster() {
		// Comment: cuando se genera un cluster root se debe validar:
		// 1.- la creacion de solo dos grupos para ese cluster 
		// 2.- la actualización correcta de los campos en el cluster
		

		// Given: la Custom Settings ha sido seteada anteriormente en el testSetup

		// When
		Test.startTest();
		//Cluster__c clusterRoot = MockupFactory.createClusterRoot('ClusterRootTest');
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		Test.stopTest();

		// Then
		List<Group> groupList = [SELECT Id, Name FROM Group WHERE Name LIKE '%CRT%'];
		List<Group> getGroupList = new List<Group>();
		
		Group groupRW = new Group();
		Group groupROViewDown = new Group(); 
		Group groupROViewUp = new Group(); 
		for(Group groupItem: groupList){
			if(groupItem.name == 'CRT00_' + readAndWrite){
                groupRW = groupItem;
				getGroupList.add(groupRW);
			}
			if(groupItem.name == 'CRT00_' + readAndOnlyViewDown){
                groupROViewDown = groupItem;
				getGroupList.add(groupROViewDown);
			}
			if(groupItem.name == 'CRT00_' + readAndOnlyViewUp){
                groupROViewUp = groupItem;
				getGroupList.add(groupROViewUp);
			}
		}

		Cluster__c clusterRootGeted = [SELECT Id, name, PublicGroupRWName__c, PublicGroupRODownName__c, PublicGroupROUpName__c 
		FROM Cluster__c WHERE name = 'ClusterRootTest00' LIMIT 1];
		
		System.assertEquals(3, getGroupList.size());
		System.assertEquals(clusterRootGeted.PublicGroupRWName__c, groupRW.name);
		System.assertEquals(clusterRootGeted.PublicGroupRODownName__c, groupROViewDown.name);
		System.assertEquals(clusterRootGeted.PublicGroupROUpName__c, groupROViewUp.name);
	}

    private final static String readAndWrite = 'RW';
    private final static String readAndOnly = 'RO';
    private final static String readAndOnlyViewDown = 'ROViewDown';
    private final static String readAndOnlyViewUp = 'ROViewUp';

	@isTest static void generateClusterGroupFirstLevel(){

		// Comment: cuando se genera un arbol con cluster group de primer nivel se debe validar: 
		// 1.- la agregación de los grupos correspondientes al root
		// 2.- la creación de los grupos correspondientes a los clusters group
		// 3.- la agregacion los grupos RW y ROVD del root a los grupo RW y ROVD de los cluster groups hijos
		// 4.- la agregacion del grupo RODU de cada cluster hijo al grupo RODU de su cluster root padre
		
		// Given: la Custom Settings ha sido seteada anteriormente en el testSetup

		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeFirstLevel();
		Test.stopTest();

		// Then
		List<Group> groupRootList = [SELECT Id, name FROM Group WHERE name LIKE 'CRT%_R%' ];
		List<Group> groupsForClusterGroupsList = [SELECT Id, name FROM Group WHERE name LIKE '%CGT%'];
		List<Groupmember> groupMemberList = getGroupMembersByGroup(groupRootList,true);
		List<Groupmember> groupCGMemberList = getGroupMembersByGroup(groupsForClusterGroupsList,false);

		System.assertEquals(3, groupRootList.size());
		System.assertEquals(6, groupsForClusterGroupsList.size());
		System.assertEquals(2, groupMemberList.size());
		System.assertEquals(4, groupCGMemberList.size());
		
	}

    public static List<Cluster__C> generateClusterTreeFirstLevel(){
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name LIKE 'ClusterRootTest%' LIMIT 1];
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , (String) getClusterRoot.id ,2 ,'ClusterGroup', 'CGT');
        return clusterGroupList;
    }


	@isTest static void generateClusterGroupSecondLevel(){

		/*Comment: cuando se crea un arbol de segundo nivel se debe validar: 
		1.- la agregacion de los grupos correspondientes al cluster root
		2.- la agregacion de los grupos correspondientes a los clusters group del primer nivel
		3.- la agregacion de los grupos correspondientes a los clusters group del segundo nivel
		
		4.- la agregacion de los grupos RW y ROVD del padre Root a los cluster de primer nivel
		5.- la agregacion de los grupos RW y ROVD de los cluster de primer nivel a sus grupos correspondientes a los cluster de segundo nivel
		
		6.- la agregacion de los grupos ROVU de los clusters de primer nivel a al grupo ROUV del cluster root padre
		7.- la agregacion del grupo ROVU de los cluster de segundo nivel a los grupos ROVU de los cluster de primer nivel
		*/

		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeSecondLevel();
		Test.stopTest();


		// Then
		
		List<Group> groupRootList = [SELECT Id, name FROM Group WHERE name LIKE '%CRT%'];		
		List<Group> groupsForClustersFirstLevelList = [SELECT Id, name FROM Group 
		WHERE name LIKE '%CFT%'];
		List<Group> groupsForClustersSecondLevelList = [SELECT Id, name FROM Group 
		WHERE name LIKE '%CS%'];
		List<Groupmember> groupMembersByClusterGroupFirstLevelRWROVDList = getGroupMembersByGroup(groupsForClustersFirstLevelList,false);

		List<Groupmember> groupMembersByClusterGroupSecondLevelRWROVDList = getGroupMembersByGroup(groupsForClustersSecondLevelList,false);
		List<Groupmember> groupMembersByClusterRootROVUList = getGroupMembersByGroup(groupRootList,true);

		List<Groupmember> groupMembersByClusterFirstLevelROVUList = getGroupMembersByGroup(groupsForClustersFirstLevelList,true);

		System.assertEquals(3, groupRootList.size());
		System.assertEquals(6, groupsForClustersFirstLevelList.size());
		System.assertEquals(12, groupsForClustersSecondLevelList.size());
		
		System.assertEquals(4, groupMembersByClusterGroupFirstLevelRWROVDList.size());
		System.assertEquals(8, groupMembersByClusterGroupSecondLevelRWROVDList.size());

		System.assertEquals(2, groupMembersByClusterRootROVUList.size());
		System.assertEquals(4, groupMembersByClusterFirstLevelROVUList.size());
	}

	public static List<Groupmember> getGroupMembersByGroup(List<Group> groupList, Boolean isUp){

		List<Id> groupCGroupIdsList = new List<Id>();
		for(Group groupItem: groupList){
			//obtener el separador de la clase
	        List<String> groupKeyAndGroupType = groupItem.Name.split('_');
	        String groupType = '';
            
	        if(groupKeyAndGroupType.size()==3){
	        	groupType = groupKeyAndGroupType[2];
	        }else{
	        	groupType = groupKeyAndGroupType[1];
	        }

	        if(isUp){
				if(groupType == readAndOnlyViewUp){
					groupCGroupIdsList.add(groupItem.Id);
				}
	        }else{
				if(groupType == readAndOnlyViewDown || groupType == readAndWrite){
					groupCGroupIdsList.add(groupItem.Id);
				}
	        }
		}

		List<Groupmember> groupMemberClusterGroupList = [SELECT UserOrGroupId, GroupId FROM GroupMember 
			WHERE GroupId IN :groupCGroupIdsList];

		return groupMemberClusterGroupList;
	}



    public static List<Cluster__C> generateClusterTreeSecondLevel(){


        List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = 'ClusterRootTest00' LIMIT 1];

        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , (String) getClusterRoot.id ,2 ,'ClusterGroup', 'CFT');
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        integer i = 1;
        for(Cluster__c clusterItem : clusterGroupList){
        	List<Cluster__c> clusterGroupSecond = MockupFactory.createCluster('CGSTest'+i , (String) clusterItem.id ,2 ,'ClusterGroup', 'CS'+i);
        	clusterGroupSecondList.addAll(clusterGroupSecond);
        	i++;
        }
        
        return clusterGroupSecondList;
    }

	@isTest static void generateClusterGroupLeaf(){
		// Comment: cuando se crea un arbol de tercer nivel con hojas se debe validar que:
		// 1.- la agregacion de los grupos correspondientes al cluster root
		// 2.- la agregacion de los grupos correspondientes a los Clusters de primer nivel
		// 3.- la agregacion de los grupos correspondientes a los Clusters de segundo nivel
		// 4.- la agregacion de los grupos correspondientes a los Clusters leaf
		
		// 5.- la agregacion de los grupos RW y ROVD del padre Root a los cluster de primer nivel
		// 6.- la agregacion de los grupos RW y ROVD de los cluster de primer nivel a sus grupos correspondientes a los cluster de segundo nivel
		// 7.- la agregacion de los grupos RW y ROVD de los cluster de primer nivel a sus grupos correspondientes a los cluster de segundo nivel

		// 8.- la agregacion de estos Groups al Group RW del cluster root padre
		// 9.- la agregacion de estos Groups al Groupos RO de los clusters group padres de primer nivel
		// 10.- la agregacion de estos Groups al Groupos RO de los clusters group padres de primer nivel


		// Given: la Custom Settings ha sido seteada anteriormente en el testSetup
		

		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeFourLevelWithLeaf();
		Test.stopTest();

		// Then
		List<Group> groupRootList = [SELECT Id, name FROM Group WHERE name LIKE '%CRT%'];
		List<Group> groupsForClusterGroupsFirstLevelList = [SELECT Id, name FROM Group 
		WHERE name LIKE '%CGT%'];
		
		List<Group> groupsForClusterGroupsSecondLevelList = [SELECT Id, name FROM Group 
		WHERE name LIKE '%CS%'];

		List<Group> groupsForClusterGroupsLeafList = [SELECT Id, name FROM Group 
		WHERE name LIKE '%CL%'];
		
		List<Groupmember> groupMemberClusterGroupList = getGroupMembersByGroup(groupsForClusterGroupsFirstLevelList,false);

        List<Groupmember> groupMemberClusterGroupSecondList = getGroupMembersByGroup(groupsForClusterGroupsSecondLevelList,false);

        List<Groupmember> groupMemberClusterLeafList = getGroupMembersByGroup(groupsForClusterGroupsLeafList,false);

        List<Groupmember> groupMemberList = getGroupMembersByGroup(groupRootList,true);

        List<Groupmember> groupsForClusterGroupsFirstLevelList2 = getGroupMembersByGroup(groupsForClusterGroupsFirstLevelList,true);
        
        List<Groupmember> groupsForClusterGroupsFirstLevelList3 = getGroupMembersByGroup(groupsForClusterGroupsSecondLevelList,true);
        
        // 1.- la agregacion de los grupos correspondientes al cluster root
		System.assertEquals(3, groupRootList.size());
		// 2.- la agregacion de los grupos correspondientes a los Clusters de primer nivel
		System.assertEquals(6, groupsForClusterGroupsFirstLevelList.size());
		// 3.- la agregacion de los grupos correspondientes a los Clusters de segundo nivel
		System.assertEquals(12, groupsForClusterGroupsSecondLevelList.size());
		// 4.- la agregacion de los grupos correspondientes a los Clusters leaf
		System.assertEquals(24, groupsForClusterGroupsLeafList.size());
		
		// 5.- la agregacion de los grupos RW y ROVD del padre Root a los cluster de primer nivel
		System.assertEquals(4, groupMemberClusterGroupList.size());
		// 6.- la agregacion de los grupos RW y ROVD de los cluster de primer nivel a sus grupos correspondientes a los cluster de segundo nivel
		System.assertEquals(8, groupMemberClusterGroupSecondList.size());
		// 7.- la agregacion de los grupos RW y ROVD de los cluster de primer nivel a sus grupos correspondientes a los cluster de segundo nivel
		System.assertEquals(16, groupMemberClusterLeafList.size());

		// 8.- la agregacion de estos Groups al Group RW del cluster root padre
		System.assertEquals(2, groupMemberList.size());
		// 9.- la agregacion de estos Groups al Groupos RO de los clusters group padres de primer nivel
		System.assertEquals(4, groupsForClusterGroupsFirstLevelList2.size());
		// 10.- la agregacion de estos Groups al Groupos RO de los clusters group padres de primer nivel
		System.assertEquals(8, groupsForClusterGroupsFirstLevelList3.size());
	}

    public static List<Cluster__C> generateClusterTreeFourLevelWithLeaf(){

        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', null, 1, 'ClusterRoot', 'CRT');
        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = 'CRTest00' LIMIT 1];
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , (String) getClusterRoot.id ,2 ,'ClusterGroup', 'CGT');
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        for(Cluster__c clusterItem : clusterGroupList){
        	List<Cluster__c> clusterGroupSecond = MockupFactory.createCluster('CGSTest'+i , (String) clusterItem.id ,2 ,'ClusterGroup', 'CS'+i);
        	clusterGroupSecondList.addAll(clusterGroupSecond);
        	i++;
        }
        i = 1;
        List<Cluster__c> clusterLeafList = new List<Cluster__c>();
        for(Cluster__c clusterSecondItem: clusterGroupSecondList){
        	List<Cluster__c> clusterLeaf = MockupFactory.createCluster('CLeaf'+i , (String) clusterSecondItem.id ,2 ,'ClusterLeaf', 'CL'+i);
        	clusterLeafList.addAll(clusterLeaf);
        	i++;
        }

        return clusterLeafList;
    }


	@isTest static void generateClustersAndAfterDelete() {
		// Comment: cuando se genera un cluster root se debe validar y luego eliminarlo:
		// 1.- la eliminacion de los grupos asociados 
		

		// Given: la Custom Settings ha sido seteada anteriormente en el testSetup
		// Ha sido creado previamente un cluster ClusterTest
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');

		// When
		Test.startTest();
		MockupFactory.deleteClusterByName('ClusterRootTest00');
		Test.stopTest();


		// Then
		List<String> groupsNamesList = new List<String>();
		//REVISAR
		//groupsNamesList.add(clusterRootList[0].PublicGroupROName__c);
		//groupsNamesList.add(clusterRootList[0].PublicGroupROName__c);
		List<Group> groupList = [SELECT Id, name FROM Group WHERE name IN :groupsNamesList];

		System.assertEquals(0, groupList.size());
	}

	@isTest static void changeLanguageWithThirdLavelTree() {
		// Comment: cuando se crea un arbol de tercer nivel con hojas se debe validar que:
		// 1.- la agregacion de los grupos correspondientes al cluster root
		// 2.- Los cluster group de primer nivel deben tener sus idiomas correspondientes

		// Given: la Custom Settings ha sido seteada anteriormente en el testSetup
		

		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeThreeLevelWithLanguage();
		Test.stopTest();

		//Then
		List<Cluster__c> ClusterRootList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name = 'CRTest00'];
		List<Cluster__c> ClusterGroupFList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGFTest%'];
		List<Cluster__c> ClusterLeafSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLeaf%'];

		//Coment
		System.assert(contentAllLanguages(ClusterRootList[0].OtherLanguages__c, 'da;es_MX;pt_BR;es'));
		System.assert(contentAllLanguages(ClusterGroupFList[0].OtherLanguages__c, 'da;es;es_MX;pt_BR'));
	}

    public static List<Cluster__C> generateClusterTreeThreeLevelWithLanguage(){
		List<String> clusterList = new List<String>();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', clusterList, 1, 'ClusterRoot','da','da', 'CRT');

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = 'CRTest00' LIMIT 1];
        List<String> rootClusterList = new List<String>();
        rootClusterList.add((String) getClusterRoot.Id);
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , rootClusterList ,2 ,'ClusterGroup','en_US','da;es', 'CGT');
        
        List<Cluster__c> getClusterGroupList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGFTest%'];
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        List<String> listIdClusters = new List<String>();
        for(Cluster__c clusterItem : getClusterGroupList){
 			listIdClusters.add( (String) clusterItem.Id);
        }

       	List<Cluster__c> clusterLeafList = MockupFactory.createCluster('CLeaf', listIdClusters ,2 ,'ClusterLeaf','es_MX', 'es;pt_BR', 'CLT');
       	List<Cluster__c> getClusterLeafList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CLeaf%'];
       	return clusterLeafList;
    }
    //changeLanguageWithThirdLavelTree
	@isTest static void changeLanguageWithFourLevelTree() {
		// Comment: cuando se crea un arbol de cuarto nivel con hojas se debe validar que:
		// 1.- El cluster root contenga los lenguajes correspondientes 
		// 2.- Los cluster group de primer nivel deben tener sus idiomas correspondientes
		// 3.- Los cluster group de segundo nivel deben tener sus idiomas correspondientes


		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeFourLevelWithLanguage();
		Test.stopTest();

		// Then
		List<Cluster__c> ClusterRootList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name = 'CRTest00'];
		List<Cluster__c> ClusterGroupFList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGFTest%'];
		List<Cluster__c> ClusterGroupSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGSTest%'];
		List<Cluster__c> ClusterLeafList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];

		//Coment
		System.assert(contentAllLanguages(ClusterRootList[0].OtherLanguages__c, 'da;es_MX;pt_BR;es'));
		System.assert(contentAllLanguages(ClusterGroupFList[0].OtherLanguages__c, 'es;es_MX;pt_BR'));
		System.assert(contentAllLanguages(ClusterGroupSList[0].OtherLanguages__c, 'da;es;pt_BR;es_MX'));


	}




    public static List<Cluster__C> generateClusterTreeFourLevelWithLanguage(){


		List<String> parentClusterIdList = new List<String>();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', parentClusterIdList, 1, 'ClusterRoot','da','da', 'CRT');

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name = 'CRTest00' LIMIT 1];
        List<String> rootClusterList = new List<String>();
        rootClusterList.add((String) getClusterRoot.Id);
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , rootClusterList ,2 ,'ClusterGroup','en_US','es', 'CGT');
        
        List<Cluster__c> getClusterGroupList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGFTest%'];
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        List<String> listIdClusters = new List<String>();
        for(Cluster__c clusterItem : getClusterGroupList){
 			listIdClusters.add( (String) clusterItem.Id);
        }

       	List<Cluster__c> clusterGroupSList = MockupFactory.createCluster('CGSTest', listIdClusters ,2 ,'ClusterGroup','en_US', 'da;es', 'CST');
       	List<Cluster__c> getClusterGroupSList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGSTest%'];
       	
       	List<String> listIdClusters2 = new List<String>();
        for(Cluster__c clusterItem2 : getClusterGroupSList){
 			listIdClusters2.add( (String) clusterItem2.Id);
        }
		List<Cluster__c> clusterLeafList = MockupFactory.createCluster('CLTest', listIdClusters2 ,2 ,'ClusterLeaf','es_MX', 'es;pt_BR', 'CLT');
        return clusterLeafList;

    }


    //changeLanguageWithThirdLavelTree
	@isTest static void changeLanguageWithFourLevelTree2() {
		// Comment: cuando se crea un arbol de cuarto nivel con hojas se debe validar que:
		// 1.- El cluster root contenga los lenguajes correspondientes 
		// 2.- Los cluster group de primer nivel deben tener sus idiomas correspondientes
		// 3.- Los cluster group de segundo nivel deben tener sus idiomas correspondientes


		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = generateClusterTreeFourLevelWithLanguage2();
		Test.stopTest();

		// Then
		List<Cluster__c> ClusterRootList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CRTest%'];
		List<Cluster__c> ClusterGroupFList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGFTest%'];
		List<Cluster__c> ClusterGroupSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGSTest%'];
		List<Cluster__c> ClusterLeafList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];

		//Coment
		System.assert(contentAllLanguages(ClusterRootList[0].OtherLanguages__c, 'da;es_MX;pt_BR;es;en_US'));
		System.assert(contentAllLanguages(ClusterGroupFList[0].OtherLanguages__c, 'es;es_MX;pt_BR'));
		System.assert(contentAllLanguages(ClusterGroupSList[0].OtherLanguages__c, 'da;es;pt_BR;es_MX'));


	}

    public static List<Cluster__C> generateClusterTreeFourLevelWithLanguage2(){
		
        List<String> clusteridList = new List<String>();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', clusteridList, 1, 'ClusterRoot','da','da', 'CRT');

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name LIKE 'CRTest%' LIMIT 1];
        List<String> rootClusterList = new List<String>();
        rootClusterList.add((String) getClusterRoot.Id);
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , rootClusterList ,2 ,'ClusterGroup','en_US','es', 'CGT');
        
        List<Cluster__c> getClusterGroupList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGFTest%'];
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        List<String> listIdClusters = new List<String>();
        for(Cluster__c clusterItem : getClusterGroupList){
 			listIdClusters.add( (String) clusterItem.Id);
        }

       	List<Cluster__c> clusterGroupSList = MockupFactory.createCluster('CGSTest', listIdClusters ,2 ,'ClusterGroup','en_US', 'da;es', 'CST');
       	List<Cluster__c> getClusterGroupSList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGSTest%'];
       	
       	List<String> listIdClusters2 = new List<String>();
       	List<String> listIdClusters3 = new List<String>();
        
       	Integer count = 0;
       	Integer toCount = 2; 
        for(Cluster__c clusterItem2 : getClusterGroupSList){
 			if(count < toCount){
 				listIdClusters2.add( (String) clusterItem2.Id);
 			}else{
 				listIdClusters3.add( (String) clusterItem2.Id);
 			}
 			
 			count++;
        }

        List<Cluster__c> clusterLeafList = MockupFactory.createCluster('CLTest', listIdClusters2 ,2 ,'ClusterLeaf','es_MX', 'es;pt_BR', 'CL1');
        List<Cluster__c> clusterLeafList2 = MockupFactory.createCluster('CLTest2', listIdClusters3 ,2 ,'ClusterLeaf','en_US', 'es', 'CL2');
        return clusterLeafList;

    }

	@isTest static void updateLanguageWithFourLevelTree() {
		// Comment: cuando se crea un arbol de cuarto nivel con hojas se debe validar que:
		// 1.- El cluster root contenga los lenguajes correspondientes 
		// 2.- Los cluster group de primer nivel deben tener sus idiomas correspondientes
		// 3.- Los cluster group de segundo nivel deben tener sus idiomas correspondientes


		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = updateClusterLanguageWithFourLevelTree();
		Test.stopTest();

		// Then
		List<Cluster__c> ClusterRootList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CRTest%'];
		List<Cluster__c> ClusterGroupFList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGFTest%'];
		List<Cluster__c> ClusterGroupSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGSTest%'];
		List<Cluster__c> ClusterLeafList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];

		//Coment
		System.assert(contentAllLanguages(ClusterRootList[0].OtherLanguages__c, 'da;es_MX;pt_BR;es'));
		System.assert(contentAllLanguages(ClusterGroupFList[0].OtherLanguages__c, 'da;es;es_MX;pt_BR'));
		System.assert(contentAllLanguages(ClusterGroupSList[0].OtherLanguages__c, 'da;es;pt_BR;es_MX'));


	}

    public static List<Cluster__C> updateClusterLanguageWithFourLevelTree(){


		List<String> clusterIdList = new List<String>();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', clusterIdList, 1, 'ClusterRoot','da','da', 'CRT');

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name LIKE 'CRTest%' LIMIT 1];
        List<String> rootClusterList = new List<String>();
        rootClusterList.add((String) getClusterRoot.Id);
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , rootClusterList ,2 ,'ClusterGroup','en_US','es', 'CGT');
        
        List<Cluster__c> getClusterGroupList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGFTest%'];
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        List<String> listIdClusters = new List<String>();
        for(Cluster__c clusterItem : getClusterGroupList){
 			listIdClusters.add( (String) clusterItem.Id);
        }

       	List<Cluster__c> clusterGroupSList = MockupFactory.createCluster('CGSTest', listIdClusters ,2 ,'ClusterGroup','en_US', 'da;es', 'CST');
       	List<Cluster__c> getClusterGroupSList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGSTest%'];
       	
       	List<String> listIdClusters2 = new List<String>();
        for(Cluster__c clusterItem2 : getClusterGroupSList){
 			listIdClusters2.add( (String) clusterItem2.Id);
        }

        List<Cluster__c> clusterLeafList = MockupFactory.createCluster('CLTest', listIdClusters2 ,2 ,'ClusterLeaf','es_MX', 'es', 'CLT');
        
        //List<Cluster__c> getClusterLeafSList = [SELECT Id FROM Cluster__c WHERE name LIKE 'ClusterLeaf%'];
        List<Cluster__c> getClusterLeafSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];
        /*for(Cluster__c cl: getClusterLeafSList){
        	cl.OtherLanguages__c = cl.OtherLanguages__c + ';' + 'pt_BR;da';

        }*/
        for(integer j = 0; j<getClusterLeafSList.size();j++){
        	getClusterLeafSList[j].OtherLanguages__c = getClusterLeafSList[j].OtherLanguages__c + ';' + 'da';
        	getClusterLeafSList[j].DefaultLanguage__c = 'pt_BR';
        }
        update getClusterLeafSList;
        
        return getClusterLeafSList;

    }

	@isTest static void updateLanguageWithThreeLevelTree() {
		// Comment: cuando se crea un arbol de cuarto nivel con hojas se debe validar que:
		// 1.- El cluster root contenga los lenguajes correspondientes 
		// 2.- Los cluster group de primer nivel deben tener sus idiomas correspondientes
		// 3.- Los cluster group de segundo nivel deben tener sus idiomas correspondientes


		// When
		Test.startTest();
		List<Cluster__c> clusterGroupFirstLevelList = updateClusterLanguageWithThreeLevelTree();
		Test.stopTest();

		// Then
		List<Cluster__c> ClusterRootList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CRTest%'];
		List<Cluster__c> ClusterGroupFList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGFTest%'];
		List<Cluster__c> ClusterGroupSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CGSTest%'];
		List<Cluster__c> ClusterLeafList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];

		//Coment
		System.assert(contentAllLanguages(ClusterRootList[0].OtherLanguages__c, 'da;es_MX;pt_BR;es'));
		System.assert(contentAllLanguages(ClusterGroupFList[0].OtherLanguages__c, 'es;es_MX;pt_BR'));
		System.assert(contentAllLanguages(ClusterGroupSList[0].OtherLanguages__c, 'da;es;pt_BR;es_MX'));


	}

    public static List<Cluster__C> updateClusterLanguageWithThreeLevelTree(){


		List<String> clusterIdList = new List<String>();
        List<Cluster__c> clusterRootList = MockupFactory.createCluster('CRTest', clusterIdList, 1, 'ClusterRoot','da','da', 'CRT');

        Cluster__c getClusterRoot = [SELECT Id FROM Cluster__c WHERE name LIKE 'CRTest%' LIMIT 1];
        List<String> rootClusterList = new List<String>();
        rootClusterList.add((String) getClusterRoot.Id);
        List<Cluster__c> clusterGroupList = MockupFactory.createCluster('CGFTest' , rootClusterList ,2 ,'ClusterGroup','en_US','es', 'CGT');
        
        List<Cluster__c> getClusterGroupList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGFTest%'];
        List<Cluster__c> clusterGroupSecondList = new List<Cluster__c>();
        Integer i = 1;
        List<String> listIdClusters = new List<String>();
        for(Cluster__c clusterItem : getClusterGroupList){
 			listIdClusters.add( (String) clusterItem.Id);
        }

       	List<Cluster__c> clusterGroupSList = MockupFactory.createCluster('CGSTest', listIdClusters ,2 ,'ClusterGroup','en_US', 'da;es', 'CST');
       	List<Cluster__c> getClusterGroupSList = [SELECT Id FROM Cluster__c WHERE name LIKE 'CGSTest%'];
       	
       	List<String> listIdClusters2 = new List<String>();
        for(Cluster__c clusterItem2 : getClusterGroupSList){
 			listIdClusters2.add( (String) clusterItem2.Id);
        }

        List<Cluster__c> clusterLeafList = MockupFactory.createCluster('CLTest', listIdClusters2 ,2 ,'ClusterLeaf','es_MX', 'es', 'CLT');
        
        List<Cluster__c> getClusterLeafSList = [SELECT Id, Name, DefaultLanguage__c, OtherLanguages__c FROM Cluster__c WHERE name LIKE 'CLTest%'];

        for(integer j = 0; j<getClusterLeafSList.size();j++){
        	getClusterLeafSList[j].DefaultLanguage__c = 'pt_BR';
        }
        update getClusterLeafSList;
        
        return getClusterLeafSList;

    }

    public static boolean contentAllLanguages(String languageA, String languageB){

    	List<String> languageAList = languageA.split(';');
    	List<String> languageBList = languageB.split(';');
    	Boolean booleanReturn = true;
    	Boolean booleanReturn2 = true;
    	for(String laguage: languageAList){
    		if(!languageB.contains(laguage)){
    			booleanReturn = false;
    			break;
    		}
    	}

    	for(String laguage2: languageBList){
    		if(!languageA.contains(laguage2)){
    			booleanReturn2 = false;
    			break;
    		}
    	}

    	return booleanReturn && booleanReturn2;

    }

	@isTest
	static void insertClusterSharing()
	{
		// Given
		

		// When
		List<Cluster__c> clusterRootList = MockupFactory.createCluster('ClusterRootTest', null, 1, 'ClusterRoot', 'CRT');
		
		//Then
		List<Cluster__Share> shareList = [SELECT Id, ParentId FROM Cluster__Share WHERE ParentId = :clusterRootList[0].Id AND RowCause =: GeneralUtils.prefix('[CMS]Clustering__c')];
		
		System.assertEquals(3, shareList.size());


	}


}