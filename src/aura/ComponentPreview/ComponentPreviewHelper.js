({
    
    getRecord: function (component, event, helper) {
		component.set("v.isLoading", true);

        var action = component.get("c.getRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.record", action.getReturnValue());
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },
      
    getClusterName: function (component, event, helper) {
        var clusterId = helper.getCookie("CG_clusterId");
        component.set("v.clusterCookie", clusterId);
        var action = component.get("c.getClusterName");
        action.setParams({
            recordId: clusterId
        });        
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.clusterName", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    
    getCookie : function(cname) {
        var name = cname + "=";
        var ca = document.cookie.split(';');
        for(var i = 0; i < ca.length; i++) {
            var c = ca[i];
            while (c.charAt(0) == ' ') {
                c = c.substring(1);
            }
            if (c.indexOf(name) == 0) {
                return c.substring(name.length, c.length);
            }
        }
        return "";
    }
    
})