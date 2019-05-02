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
    },
    hasClusterCookie : function(component, event, helper) {
        var clusterCookieValue = helper.getCookie('CG_clusterId');
        if(clusterCookieValue && clusterCookieValue != 'undefined') {
            return clusterCookieValue;
        }
        
        return false;
    },
    setClusterCookie : function(component, event, helper) {
        var params = event.getParam('arguments');
        if (params) {
            var cookieValue = params.cookieValue;
            helper.setCookie('CG_clusterId', cookieValue, 365);
            return true;
        }
        return false;
    },
})