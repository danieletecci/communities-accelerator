public class SidebarMenuController extends ComponentManager{
    
	//WRAPPERS
    public class SidebarComponentWrapper extends ComponentManager.DataWrapper{
		@auraEnabled public List<NavWrapper> navWrapper;
        @AuraEnabled public String device;
        

		public SidebarComponentWrapper (String componentExternalId, String clusterId, String device){
			this.navWrapper = new List<NavWrapper>();
            this.device = device;
		}
	}

	public class NavWrapper {
        @auraEnabled public ObjectMenuWrapper menu {get;set;}
        @auraEnabled public String behaviour {get;set;}
        @auraEnabled public String iconName {get;set;}

        public NavWrapper(Menu__c menu) {
            this.menu = new ObjectMenuWrapper(menu);
            this.menu.MenuDynamicLabel = GeneralUtils.replaceDynamicFields(this.menu.MenuDynamicLabel, 'User', UserInfo.getUserId(), false);
            this.behaviour = menu.Navigation__r.Behaviour__c == 'New Tab' ? '_blank' : '_self';
            this.iconName = menu.MenuIcon__c;
    	}
	}
    
    @AuraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String clusterId, String device){
        SidebarMenuController ctrl = new SidebarMenuController();
        ctrl.customPermissionView = 'Menu View Frame';
        ctrl.customPermissionEdit = 'Menu Edit Frame';
        ctrl.componentFieldSet = new set<String>{
            'Id'};
        ctrl.componentExternalId = componentExternalId;
        ctrl.clusterId = clusterId;
        ctrl.device = device;

        return ctrl.getCW();
    }
    

	
	private static SidebarComponentWrapper getNavWrapper(String componentExternalId, String clusterId, String device) {
  		if(clusterId == null || clusterId.trim() == ''){
			clusterId = ClusterUtils.getClusterIdFromMappingObject(UserInfo.getUserId(), Network.getNetworkId());
		}
		//Armado del Component Wrapper
		SidebarComponentWrapper scw = new SidebarComponentWrapper(componentExternalId, clusterId, device);
		scw.navWrapper = getWrapperFromComponent(componentExternalId, clusterId, device);
		return scw;
	}

	
	private static List<NavWrapper> getWrapperFromComponent(String componentExternalId, String clusterId, String device){
		// Busqueda de Menus con Assignments al Component
		List<MenuAssignment__c> menuAssignments = [SELECT Id, Component__c, Component__r.Cluster__c, Menu__c, Menu__r.Cluster__c 
		FROM MenuAssignment__c WHERE Component__r.ExternalId__c =: componentExternalId ORDER BY Order__c ASC];
        List<String> menuIds = new List<String>();
		Set<String> parentClusterIds = ClusterUtils.getClustersParents(clusterId);
		for(MenuAssignment__c ma : menuAssignments){
			if(parentClusterIds.contains(ma.Menu__r.Cluster__c)){
				menuIds.add(ma.Menu__c);
			}
		}
		List<NavWrapper> menuWrappers = new List<NavWrapper>();
		List<Menu__c> menuList = getMenuList(menuIds, device);
		for(Menu__c menu : menuList){
            NavWrapper newWrapper = new NavWrapper(menu);
   			menuWrappers.add(newWrapper);      
		}
		return menuWrappers;
	}


	// Traemos todos los SubMenus relacionados a los Menus del Component	
	private static List<Menu__c> getMenuList(List<String> menuIds, String device){
        String displayOn;
        if(device.equals('DESKTOP')){
            displayOn = 'Desktop';
        }else{
            displayOn = 'Mobile';
        }
		return [SELECT Id, MenuLabel__c, MenuDynamicLabel__c, Cluster__c, Navigation__r.URL__c, MenuIcon__c, ComponentName__c, URLParameters__c, Navigation__r.Behaviour__c, Navigation__r.UrlMask__c, StyleClass__c FROM Menu__c 
                WHERE ParentMenu__c =: menuIds AND (DisplayOn__c = :displayOn OR DisplayOn__c = 'Both') 
    			];
	}
    
    
    public override DataWrapper getData() {
    	SidebarComponentWrapper scw = getNavWrapper(componentExternalId, clusterId, device);
        return scw;
    }

}