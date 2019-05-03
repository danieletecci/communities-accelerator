global class ClusterUtils {

	@TestVisible private static String testNetworkName;

	global class ClusterWrapper {
		global Cluster__c cluster;
		global List<ClusterWrapper> relatedClusters;
		global ClusterWrapper(Cluster__c p_cluster){
			this.cluster = p_cluster;
			this.relatedClusters = new List<ClusterWrapper>();
		}
		//Esto es una modificacion para probar una historia
	}

	public static map<String, set<String>> mapClustersParents;
	global static set<String> getClustersParents(String clusterId) {
		if(mapClustersParents == null){
			mapClustersParents = new map<String, set<String>>();
		}

		if(!mapClustersParents.containsKey(clusterId)){
			mapClustersParents.put(clusterId, new set<String>{clusterId});
			
			List<Cluster__c> queryResult = [SELECT Id, ParentCluster__c, ParentCluster__r.ParentCluster__c, ParentCluster__r.ParentCluster__r.ParentCluster__c FROM Cluster__c WHERE Id =: clusterId];
			if(!queryResult.isEmpty()){
				Cluster__c cluster = queryResult[0];
				//The accelerator allows only 4 levels of depth of Clusters
				if(cluster.ParentCluster__c != null){
					mapClustersParents.get(clusterId).add(cluster.ParentCluster__c);
					if(cluster.ParentCluster__r.ParentCluster__c != null){
						mapClustersParents.get(clusterId).add(cluster.ParentCluster__r.ParentCluster__c);
						if(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c != null){
							mapClustersParents.get(clusterId).add(cluster.ParentCluster__r.ParentCluster__r.ParentCluster__c);
						}
					}
				}
			}
		}

		return mapClustersParents.get(clusterId);
	}
	
	public static map<String, ClusterWrapper> mapClustersBelow;
	global static ClusterWrapper getClustersBelow(String clusterId) {
		if(mapClustersBelow == null){
			mapClustersBelow = new map<String, ClusterWrapper>();
		}

		if(!mapClustersBelow.containsKey(clusterId)){
			Cluster__c cluster = [SELECT Id, Name, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE Id =: clusterId];
			
			mapClustersBelow.put(cluster.Id, new ClusterWrapper(cluster));
			
			//The accelerator allows only 4 levels of depth of Clusters
			set<Id> setClusterRelated = new set<Id>{cluster.Id};
			while(!setClusterRelated.isEmpty()){
				List<Cluster__c> clustersRelated = [SELECT Id, Name, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE ParentCluster__c IN: setClusterRelated];
				setClusterRelated.clear();
				for(Cluster__c rc: clustersRelated){
					setClusterRelated.add(rc.Id);
					ClusterWrapper crr = new ClusterWrapper(rc);
					mapClustersBelow.put(rc.Id, crr);
					mapClustersBelow.get(rc.ParentCluster__c).relatedClusters.add(crr);
				}
			}
		}

		return mapClustersBelow.get(clusterId);
	}

	public static map<String, String> mapMappingKeyCluster;
	global static String getClusterIdFromMappingObject(String recordId, String networkId){
		if(mapMappingKeyCluster == null){
			mapMappingKeyCluster = new map<String, String>();
		}
		
		String mappingKey = recordId + '-' + networkId;
		if(!mapMappingKeyCluster.containsKey(mappingKey)){
			try{
				String networkName = Test.isRunningTest() ? testNetworkName : GeneralUtils.getNetwork(networkId).Name;
				List<Cluster__c> clusterRoot = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c FROM Cluster__c WHERE RecordType.DeveloperName = 'ClusterRoot' AND CommunityName__c =: networkName];
				if(!clusterRoot.isEmpty()){
					List<SObject> rec = Database.query(GeneralUtils.prefix('SELECT Id, ' + clusterRoot[0].MappingObjectField__c + ' FROM ' + clusterRoot[0].MappingObject__c + ' WHERE Id =: recordId'));
					if(!rec.isEmpty()){
						List<Cluster__c> clusterRet = Database.query(GeneralUtils.prefix('SELECT Id FROM [CMS]Cluster__c WHERE RecordType.DeveloperName = \'ClusterLeaf\' AND ' + clusterRoot[0].MappingClusterField__c + ' = \'' + GeneralUtils.getFieldValue(rec[0], clusterRoot[0].MappingObjectField__c) + '\' LIMIT 1'));
						if(!clusterRet.isEmpty()){
							mapMappingKeyCluster.put(mappingKey, clusterRet[0].Id);
						}
					}
				}
			}catch(Exception e){}
		}

		return mapMappingKeyCluster.get(mappingKey);
	}

	public static Cluster__c getClusterRootFromNetwork(){
		Cluster__c clusterRoot;
		if (Network.getNetworkId() != null || Test.isRunningTest()){
			String networkName = Test.isRunningTest() ? testNetworkName : GeneralUtils.getNetwork(Network.getNetworkId()).Name;
			List<Cluster__c> queryResult = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c, ClusterLandingUrl__c, RecordType.DeveloperName FROM Cluster__c WHERE RecordType.DeveloperName = 'ClusterRoot' AND CommunityName__c =: networkName];
			if(!queryResult.isEmpty()){
				clusterRoot = queryResult[0];
			}
			return clusterRoot;
		}
		return null;
	}


	global static Set<Id> getEntireClusterBranch(String clusterId){
		List<Cluster__c> clusterList = [SELECT id, parentCluster__c FROM Cluster__c];
		//Map with id as key and cluster as value
		Map<String, Cluster__c> clusterMap = new Map<String, Cluster__c>();
		//Map with id as key and a list of the child clusters as value
		Map<String, List<Cluster__c>> parentClusterMap = new Map<String, List<Cluster__c>>();
		//Set with all the cluster ids of the branch
		Set<Id> clusterIdSet = new Set<Id>{clusterId};

		//Instantiate both maps
		for(Cluster__c cluster : clusterList){
			clusterMap.put(cluster.id, cluster);
			if(cluster.parentCluster__c != null){
				if(parentClusterMap.get(cluster.parentCluster__c) != null){
					List<Cluster__c> childList = parentClusterMap.get(cluster.parentCluster__c);
					childList.add(cluster);
					parentClusterMap.put(cluster.parentCluster__c, childList);
				}else{
					parentClusterMap.put(cluster.parentCluster__c, new List<Cluster__c>{cluster});
				}
			}
		}
		//Gets all the parent clusters
		Cluster__c currentCluster = clusterMap.get(clusterId);
		Boolean noMoreParents = false;
		while(currentCluster.parentCluster__c != null){
			currentCluster = clusterMap.get(currentCluster.parentCluster__c);
			clusterIdSet.add(currentCluster.id);
		}
		
		//Gets all the child clusters
		List<Cluster__c> childClusterList = parentClusterMap.get(clusterId);
		while(childClusterList != null && !childClusterList.isEmpty()){
			List<Cluster__c> subChildList = new List<Cluster__c>();
			for(Cluster__c childCluster : childClusterList){
				clusterIdSet.add(childCluster.id);
				if(parentClusterMap.get(childCluster.id) != null){
					subChildList.addAll(parentClusterMap.get(childCluster.id));
				}
			}
			childClusterList = subChildList;
		}
		return clusterIdSet;
	}

	public static List<Cluster__c> getClustersBelowList(String clusterId) {
		List<Cluster__c> 	clusterList 	= new List<Cluster__c>();
		Set<Id>				clusterRelatedSet	= new Set<Id>();

		Cluster__c cluster = [SELECT Id, Name, ExternalId__c, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName, RecordType.Name FROM Cluster__c WHERE Id =: clusterId];
		
		clusterList.add(cluster);
		List<Cluster__c> clustersRelated = new List<Cluster__c>{cluster};

		while(!clustersRelated.isEmpty()){			
			clustersRelated = [SELECT Id, Name, ExternalId__c, ParentCluster__c, ClusterLandingUrl__c, RecordType.DeveloperName, RecordType.Name FROM Cluster__c WHERE ParentCluster__c IN: clustersRelated ORDER BY Name];
			clusterList.addAll(clustersRelated);
		}
		
		return clusterList;
	}

}