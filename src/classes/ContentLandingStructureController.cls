public class ContentLandingStructureController {

	public class SitemapWrapper {
		@AuraEnabled public List<MenuWrapper> menus;
		@AuraEnabled public List<Navigation__c> navigations;

		public SitemapWrapper(List<MenuWrapper> menus, List<Navigation__c> navigations){
			this.menus			= menus;
			this.navigations 	= navigations;
		}
	}

	public class MenuWrapper{
		@AuraEnabled public Menu__c				menu;
		@AuraEnabled public List<MenuWrapper>	childsMenu;

		public MenuWrapper(Menu__c menu, List<MenuWrapper> childsMenu){
			this.menu 		= menu;
			this.childsMenu = childsMenu;
		}

		public MenuWrapper(Menu__c menu){
			this.menu 		= menu;
			this.childsMenu = new List<MenuWrapper>();
		}

		public void addMenuWrapper(MenuWrapper mw){
			childsMenu.add(mw);
		}
	}

	public class GeneralWrapper{
		@AuraEnabled public String				orgId;
		@AuraEnabled public String				communityName;
		@AuraEnabled public String 				communityPreviewDomain;
		@AuraEnabled public List<Cluster__c>	clusterLeafs;
		@AuraEnabled public String 				urlPathPrefix;

		public GeneralWrapper(String orgId, String communityName, String communityPreviewDomain, List<Cluster__c> clusterLeafs, String urlPathPrefix){
			this.orgId 					= orgId;
			this.communityName			= communityName;
			this.communityPreviewDomain	= communityPreviewDomain;
			this.clusterLeafs			= clusterLeafs;
			this.urlPathPrefix 			= urlPathPrefix;
		}
	}

	@AuraEnabled(cacheable=true)
	public static GeneralWrapper getGeneralData(){
		Cluster__c croot = getClusterRoot(getClusterUserId());
		return new GeneralWrapper(getOrgId(), croot.CommunityName__c.toLowerCase(), croot.CommunityPreviewDomain__c, getClusterLeafs(), getUrlPathPrefix(getClusterUserId()));
	}

	@AuraEnabled(cacheable=true)
	public static String getCommunityName(){
		return getClusterRoot(getClusterUserId()).CommunityName__c.toLowerCase();
	}

	@AuraEnabled(cacheable=true)
	public static SitemapWrapper getMenus(){
		Map<Id, Set<Id>> 		fatherChilds 	= new Map<Id, Set<Id>>();
		Map<Id, MenuWrapper> 	menuWrapperMap 	= new Map<Id, MenuWrapper>();
		List<MenuWrapper> 		menuWrappers 	= new List<MenuWrapper>();
		Set<Id>					navigations 	= new Set<Id>();
		Map<Id,Menu__c> 		menuMap 		= new Map<Id,Menu__c>([
									SELECT Id, Name, Navigation__c, Navigation__r.URL__c, RecordType.DeveloperName,
										ParentMenu__r.Name, ParentMenu__r.Navigation__r.URL__c, ParentMenu__r.RecordType.DeveloperName
									FROM Menu__c 
									WHERE (Navigation__r.Type__c = 'Internal' AND ParentMenu__c = null) OR (Navigation__r.Type__c = 'Internal' AND ParentMenu__r.Navigation__r.Type__c = 'Internal')]);

		for(Menu__c m : menuMap.values()){
			if(m.Navigation__c != null){
				navigations.add(m.Navigation__r.Id);
			}
			if(m.ParentMenu__r != null){
				if(fatherChilds.containsKey(m.ParentMenu__r.Id)){
					fatherChilds.get(m.ParentMenu__r.Id).add(m.Id);
				} else {
					Set<Id> fcs = new Set<Id>();
					fcs.add(m.Id);
					fatherChilds.put(m.ParentMenu__r.Id, fcs);
				}
			} else if(!fatherChilds.containsKey(m.Id)){
				fatherChilds.put(m.Id, new Set<Id>());
			}
			if(m.RecordType.DeveloperName == 'Menu'){
				MenuWrapper mw = new MenuWrapper(m);
				menuWrappers.add(mw);
				menuWrapperMap.put(m.Id, mw);
			}
		}


		for(Id menuId : fatherChilds.keySet()){
			if(!menuWrapperMap.containsKey(menuId)){
				menuWrapperMap.put(menuId, new MenuWrapper(menuMap.get(menuId)));
			}
			for(Id childIds : fatherChilds.get(menuId)){
				MenuWrapper mwChild = new MenuWrapper(menuMap.get(childIds));
				menuWrapperMap.get(menuId).addMenuWrapper(mwChild);
			}
		}



		return new SitemapWrapper(menuWrappers, getInternalNavigations(navigations));
	}

	public static List<Navigation__c> getInternalNavigations(Set<Id> notIncludedNavigations){
		return [SELECT Id, Name, URL__c FROM Navigation__c WHERE Type__c = 'Internal' AND Id NOT IN :notIncludedNavigations];
	}

	@AuraEnabled(cacheable=true)
	public static String getOrgId(){
		return String.valueOf(UserInfo.getOrganizationId()).substring(0, 15);
	}

	@AuraEnabled(cacheable=true)
	public static String getSiteId(String clusterId){
		String networkName = getClusterRoot(clusterId).CommunityName__c;
		String siteName1   = networkName.replaceAll('[^a-zA-Z0-9]', '_') + '1';
		String siteName_C  = networkName.replaceAll('[^a-zA-Z0-9]', '_') + '_C';

		List<Site> site = [SELECT Id, Name FROM Site WHERE Name =: siteName1 OR Name =: siteName_C];
		if(!site.isEmpty())
			return String.valueOf(site.get(0).Id).substring(0, 15);
		else
			throw new AuraException('The site does not exist');
	}

	@AuraEnabled(cacheable=true)
	public static String getUrlPathPrefix(String clusterId){
		String networkName = getClusterRoot(clusterId).CommunityName__c;
		List<Network> net = [SELECT UrlPathPrefix FROM Network WHERE Name = :networkName];
		if(net.isEmpty())
			throw new AuraException('The community does not exist');
		return net[0].UrlPathPrefix;
	}

	@AuraEnabled(cacheable=true)
	public static List<Cluster__c> getClusterLeafs(){
		return getSubordinateClusterLeafs(getClusterUserId());
	}

	public static Id getClusterUserId(){
		List<ClusterUser__c> clusterUser = [SELECT Id, Cluster__c FROM ClusterUser__c WHERE User__c =:UserInfo.getUserId()];
		if(clusterUser.size() == 0)
			throw new AuraException('You have no cluster associated');
		return clusterUser.get(0).Cluster__c;
	}

	public static Cluster__c getClusterRoot(String clusterId){
		Cluster__c cluster = [SELECT Id, CommunityName__c, CommunityPreviewDomain__c, ParentCluster__c FROM Cluster__c WHERE Id=:clusterId];
		while(cluster.ParentCluster__c != null){
			cluster = [SELECT Id, CommunityName__c, CommunityPreviewDomain__c, ParentCluster__c FROM Cluster__c WHERE Id=:cluster.ParentCluster__c];
		}
		return cluster;
	}

	public static List<Cluster__c> getSubordinateClusterLeafs(Id clusterId){
		List<Cluster__c> 	leafs 			= new List<Cluster__c>();
		Set<Id> 			parentIds 		= new Set<Id>();
		Set<Id> 			tempIds 		= new Set<Id>();
		Map<Id,Cluster__c>	clusterMap		= new Map<Id,Cluster__c>([SELECT Id, Name, ParentCluster__c, RecordType.DeveloperName FROM Cluster__c]);
		List<Cluster__c> 	clusterList 	= clusterMap.values();
		List<Cluster__c> 	tempList;
		if(clusterMap.get(clusterId).RecordType.DeveloperName == 'ClusterLeaf'){
			leafs.add(clusterMap.get(clusterId));
		} else {
			parentIds.add(clusterId);
			while(!parentIds.isEmpty()){
				tempList = new List<Cluster__c>();
				tempIds  = new Set<Id>();
				for(Cluster__c c : clusterList){
					if(parentIds.contains(c.ParentCluster__c)){
						if(c.RecordType.DeveloperName == 'ClusterLeaf')
							leafs.add(c);
						else{
							tempIds.add(c.Id);
						}
					} else {
						tempList.add(c);
					}
				}
				parentIds   = tempIds.clone();
				clusterList = tempList.clone();

			}
		}

		return leafs;
	}
}