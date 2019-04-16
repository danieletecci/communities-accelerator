({
	doOnclick: function (component, event, helper) {
        var clusterId = event.currentTarget.getAttribute('data-clusterId');
        var clusterLandingId = event.currentTarget.getAttribute('data-clusterLanding');
        var clustertype = event.currentTarget.getAttribute('data-clustertype');
        var compEvents = component.getEvent("changeCluster");

        compEvents.setParams({ 
                                "CLUSTERID" : clusterId,
                                "CLUSTERLANDINGID" :  clusterLandingId,
                                "CLUSTERTYPE" : clustertype
                            });
        compEvents.fire();
    }
})