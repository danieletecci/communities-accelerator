({
    getComponentWrapper: function (component, helper) {
    	var cw = component.get("v.componentWrapper");
        var device = $A.get("$Browser.formFactor");

        var action = component.get("c.getComponentWrapper");        

        action.setParams({
            componentExternalId: component.get("v.componentExternalId"),
            componentId: component.get("v.componentId"),
            device: device
        });

        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.componentWrapper", action.getReturnValue());
            }

        });

        $A.enqueueAction(action);
    },
     
    changeCluster: function(component, helper, clusterId, clusterLandingId, clustertype){
        
        if(component.get("v.componentWrapper.TreeWrapper.leafOnly")){
            if(clustertype === "ClusterLeaf"){
                helper.setCookie("CG_clusterId", clusterId, 99);
                helper.getRedirect(component, clusterLandingId);
            }
        }else{
            helper.setCookie("CG_clusterId", clusterId, 99);
            helper.getRedirect(component, clusterLandingId);
        }
    },

    getRedirect : function(component, clusterLandingId) {
        var action = component.get("c.getClusterRedirect");

        action.setParams({
            clusterLandingUrl: clusterLandingId
        });

        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                var url = action.getReturnValue();
                if(url != null){
                    window.location.href = url;
                }
            }
        });

        $A.enqueueAction(action);
    },

    setCookie : function(cname, cvalue, exdays) {
        var d = new Date();
        d.setTime(d.getTime() + (exdays*24*60*60*1000));
        var expires = "expires="+ d.toUTCString();
        document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
    }  
})