({
    doInit: function (component, event, helper) {
        helper.getComponentWrapper(component, helper);
    },
    
    handleChangeCluster: function (component, event, helper) {
        var clusterId = event.getParam("CLUSTERID");
        var clusterLandingId = event.getParam("CLUSTERLANDINGID");
        var clustertype = event.getParam("CLUSTERTYPE");
        var isBackend = component.get("v.isBackend");
		helper.changeCluster(component, helper, clusterId, clusterLandingId, clustertype);

        if(!isBackend){           	
            window.location.reload();
        } 
    }
    
})