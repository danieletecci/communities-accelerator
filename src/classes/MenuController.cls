public class MenuController {

	//WRAPPERS
    public class ComponentWrapper{
		@auraEnabled public CustomSettingWrapper acceleratorSettings;
        @auraEnabled public ObjectComponentWrapper component;
		@auraEnabled public String clusterId;
		@auraEnabled public List<NavWrapper> navWrapper;
		@auraEnabled public String device;
		@auraEnabled public Boolean isEnabledCommunityEditFrame;
		@auraEnabled public Boolean isEnabledCommunityViewFrame;

		public ComponentWrapper (){
			this.acceleratorSettings = new CustomSettingWrapper(CMSSettings__c.getInstance(), CMSContentSettings__c.getInstance(), CMSMediaElementSettings__c.getInstance());
			this.isEnabledCommunityEditFrame = FeatureManagement.checkPermission('CommunityEditFrame');
			this.isEnabledCommunityViewFrame = FeatureManagement.checkPermission('CommunityViewFrame');
			this.navWrapper = new List<NavWrapper>();
		}
	}

	public class NavWrapper {
        @auraEnabled public ObjectMenuWrapper menu {get;set;}
        @auraEnabled public List<NavWrapper> subMenus {get;set;}
        @auraEnabled public String behaviour {get;set;}
        @auraEnabled public String iconName {get;set;}

        public NavWrapper(Menu__c menu) {
            this.menu = new ObjectMenuWrapper(menu);
            this.subMenus = new List<NavWrapper>();
            this.behaviour = menu.Behaviour__c == 'New Tab' ? '_blank' : '_self';
            this.iconName = menu.MenuIcon__c;
    	}
	}

	@auraEnabled
	public static ComponentWrapper getNavWrapper(String componentExternalId, String clusterId, String device) {
		// List of fields
  		set<String> setFields = new set<String>{'Id','Name', GeneralUtils.prefix('[CMS]ExternalId__c'),'Recordtype.Developername', GeneralUtils.prefix('[CMS]NavigationMode__c'), GeneralUtils.prefix('[CMS]HasDelay__c'), GeneralUtils.prefix('[CMS]DelayTime__c'), GeneralUtils.prefix('[CMS]Cluster__c')};
  		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}

		set<String> setClusterIds = ClusterUtils.getClustersParents(clusterId);
		//Busqueda de componente
		Component__c component = ComponentUtils.getComponent(componentExternalId, setFields, device);
		//Armado del Component Wrapper
		ComponentWrapper cw = new ComponentWrapper();
		//verificar los custom permisions
		if(!cw.isEnabledCommunityEditFrame){
			if(FeatureManagement.checkPermission(component.RecordType.DeveloperName + 'EditFrame')){
				cw.isEnabledCommunityEditFrame = true;
			}else{
				cw.isEnabledCommunityEditFrame = false;
			}
		}

		if (!cw.isEnabledCommunityViewFrame){
			if(FeatureManagement.checkPermission(component.RecordType.DeveloperName + 'ViewFrame')){
				cw.isEnabledCommunityViewFrame = true;
			}else{
				cw.isEnabledCommunityViewFrame = false;
			}
		}
		cw.component = new ObjectComponentWrapper(component);
		cw.clusterId = clusterId;
		cw.device = device;

		cw.navWrapper = getWrapperFromComponent(component, cw.clusterId);
		return cw;
	}

	@auraEnabled
	public static List<NavWrapper> getWrapperFromComponent(Component__c component, String clusterId){
		// Busqueda de Menus con Assignments al Component
		List<MenuAssignment__c> menuAssignments = [SELECT Id, Component__c, Component__r.Cluster__c, Menu__c, Menu__r.Cluster__c 
		FROM MenuAssignment__c WHERE Component__c =: component.Id ORDER BY Order__c ASC];
        List<String> menuIds = new List<String>();
		Set<String> parentClusterIds = ClusterUtils.getClustersParents(clusterId);
		for(MenuAssignment__c ma : menuAssignments){
			if(parentClusterIds.contains(ma.Menu__r.Cluster__c)){
				menuIds.add(ma.Menu__c);
			}
		}
		List<NavWrapper> menuWrappers = new List<NavWrapper>();
		List<Menu__c> menuList = getMenuList(menuIds);
		for(String menuId : MenuIds){
            NavWrapper newWrapper = getMenuWrapper(menuId, menuList, parentClusterIds);
            if(newWrapper != null){
                menuWrappers.add(newWrapper);
            }                
		}
		return menuWrappers;
	}


	// Traemos todos los SubMenus relacionados a los Menus del Component	
	public static List<Menu__c> getMenuList(List<String> menuIds){
		return [SELECT Id, MenuLabel__c, ParentMenu__c, Cluster__c, Behaviour__c, Navigation__r.URL__c, MenuIcon__c FROM Menu__c 
					WHERE Id =: menuIds 
					OR ParentMenu__c =: menuIds 
    				OR ParentMenu__r.ParentMenu__c =: menuIds 
    				OR ParentMenu__r.ParentMenu__r.ParentMenu__c =: menuIds];
	}

	// Armamos los Wrappers
	public static NavWrapper getMenuWrapper(Id currentMenuId, List<Menu__c> allMenus, Set<String> parentClusterIds){
		// Armamos un mapa con el Wrapper de cada Menu
    	map<Id, NavWrapper> menuWrapperMap = new map<Id, NavWrapper>();
    	map<Id, Menu__c> menuMap = new map<Id, Menu__c>();
    	for(Menu__c menu : allMenus){
    		menuMap.put(menu.Id, menu);
    		menuWrapperMap.put(menu.Id, new NavWrapper(menu));
    	}
    	// Si el Cluster de child esta en la lista de Clusters
		// Para cada parent padre de child, agregamos child a los hijos de parent
		// El MenuWrapperMap toma forma de arbol
    	for(String parentId : menuWrapperMap.keySet()){
    		for(String childId : menuWrapperMap.keySet()){
                Menu__c parent = menuMap.get(parentId);
                Menu__c child = menuMap.get(childId);
    			if(child.ParentMenu__c == parent.Id && parentClusterIds.contains(child.Cluster__c)){
    				menuWrapperMap.get(parentId).subMenus.add(menuWrapperMap.get(childId));
    			}
    		}
    	}
    	//Devolvemos el nodo raiz del arbol creado
    	return menuWrapperMap.get(currentMenuId);
	}

}