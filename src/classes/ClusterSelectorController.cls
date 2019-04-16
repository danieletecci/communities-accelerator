public with sharing class ClusterSelectorController extends ComponentManager{
    
    //WRAPPER
    public class TreeWrapper extends ComponentManager.DataWrapper{
        @auraEnabled public String label;
        @auraEnabled public String name;
        @auraEnabled public Boolean expanded;
        @auraEnabled public String clusterLanding;
        @auraEnabled public String clustertype;
        @auraEnabled public List<TreeWrapper> items;
        @auraEnabled public Boolean leafOnly;

        public TreeWrapper(ClusterUtils.ClusterWrapper p_clusterWrapper, Boolean leaf){
            leafOnly = leaf;

            if(p_clusterWrapper != null && p_clusterWrapper.cluster != null){
                this.label = p_clusterWrapper.cluster.Name;
                this.name = p_clusterWrapper.cluster.Id;
                this.expanded = (p_clusterWrapper.relatedClusters != null && p_clusterWrapper.relatedClusters.size() > 0);
                this.clusterLanding = p_clusterWrapper.cluster.ClusterLandingUrl__c;
                this.clustertype = p_clusterWrapper.cluster.RecordType.DeveloperName;
                items = new List<TreeWrapper>();
            }
        }
    }


    @auraEnabled
    public static ComponentWrapper getComponentWrapper(String componentExternalId, String componentId, String device){
        ClusterSelectorController ctrl = new ClusterSelectorController();
        ctrl.customPermissionEdit = 'Cluster Selector Edit Frame';
        ctrl.customPermissionView = 'Cluster Selector View Frame';        
        ctrl.componentFieldSet = new Set<String>{
            'Datasource__c'
        };
        ctrl.componentExternalId = componentExternalId;
        ctrl.componentId = componentId;
        ctrl.device = device;
        return ctrl.getCW();
    }

    public override DataWrapper getData() {
    	TreeWrapper tw;
    	
    	if(String.isBlank(this.componentExternalId)){
    		tw = getClusterRootForComponent(this.componentId);
    	} else {
    		tw = getClusterRootByExternalId(this.componentExternalId);
    	}

        return tw;
    }    
    
    @AuraEnabled
    public static String getClusterRedirect (String clusterLandingUrl){
        String retURL = '';
        List<Navigation__c> navigationList = [SELECT Id, URL__c FROM Navigation__c WHERE Id =: clusterLandingUrl];
        
        if(!navigationList.isEmpty()){
            retURL = navigationList[0].URL__c;
        }    
        return retURL;
    }    
    
    @AuraEnabled
    public static TreeWrapper getClusterRootByExternalId(String externalId){
        Boolean leafOnly = false;
        Cluster__c clusterRoot;
        Component__c component = ClusterSelectorController.getComponent(externalId);
        List<Cluster__c> clusterList = new List<Cluster__c>();

        if(component != null ){
            leafOnly = component.OnlyClusterLeaf__c;
            clusterList = [SELECT Id, MappingObject__c, MappingObjectField__c, MappingClusterField__c, ClusterLandingUrl__c, RecordType.DeveloperName 
                            FROM Cluster__c 
                            WHERE RecordType.DeveloperName IN ('ClusterRoot','ClusterGroup') 
                                AND Id =: component.FirstCluster__c ];
        }
      
        if(!clusterList.isEmpty()){
            clusterRoot = clusterList[0];
	        ClusterUtils.ClusterWrapper clusterWrappper = ClusterUtils.getClustersBelow(clusterRoot.Id);
	        TreeWrapper tree = ClusterSelectorController.getTree(clusterWrappper, leafOnly);       
	        return tree;
        }

        return null;      
    }

    @AuraEnabled
    public static TreeWrapper getClusterRootForComponent(String componentId){
        String clusterId = getComponentClusterId(componentId);
        Boolean leafOnly = false;

        ClusterUtils.ClusterWrapper clusterWrappper = ClusterUtils.getClustersBelow(clusterId);
        TreeWrapper tree = ClusterSelectorController.getTree(clusterWrappper, leafOnly);     
        
        return tree;
    }
    
    public static String getComponentClusterId(String componentId){
        Boolean leafOnly = false;
        
        List<Component__c> component = [SELECT Id, Cluster__c, ClusterExternalId__c FROM Component__c WHERE Id =: componentId];
        if(component.size() > 0){
        	return component[0].Cluster__c;	
        }
        return '';
    }
       
    private static TreeWrapper getTree(ClusterUtils.ClusterWrapper clusterWrapper, Boolean leafOnly){
        if(clusterWrapper == null){
            return null;
        }

        TreeWrapper item = new TreeWrapper(clusterWrapper, (clusterWrapper.cluster.RecordType.DeveloperName.equalsIgnoreCase('ClusterLeaf'))?false:leafOnly);
        List<TreeWrapper> itemList = new List<TreeWrapper>();

        for (ClusterUtils.ClusterWrapper clusterW : clusterWrapper.relatedClusters) {
            itemList.add(ClusterSelectorController.getTree(clusterW, leafOnly));
        }
        item.items.addAll(itemList); 
        
        return item;
    } 

    private static Component__c getComponent(String externalId){
        List<Component__c> component = [SELECT FirstCluster__c, OnlyClusterLeaf__c 
                                        FROM Component__c WHERE ExternalId__c =: externalId];
        if(component.size() > 0){
        	return component[0];
        }
        return null;
    }

}
