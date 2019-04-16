({
    doInit: function (component, event, helper) {
        helper.getClusterName(component, event, helper);
        helper.getRecord(component, event, helper);
    },
    
    hideModal : function(component, event, helper){
        document.getElementById("clusterSelectorModal").style.display = "none";
        document.getElementById("mainDiv").style.opacity = "1";
    },
    
    showModal : function(component, event, helper){
        document.getElementById("clusterSelectorModal").style.display = "block";
        document.getElementById("mainDiv").style.opacity = "0.25";
    },
    
    doClusterChange : function(component, event, helper){
        var cookieOld = component.get("v.clusterCookie");
        var cookieNew = helper.getCookie("CG_clusterId");
        if(cookieOld != undefined && cookieNew != undefined && cookieOld != cookieNew){
            document.getElementById("clusterSelectorModal").style.display = "none";
            helper.getClusterName(component, event, helper);
            helper.getRecord(component, event, helper);
        }
    }
})