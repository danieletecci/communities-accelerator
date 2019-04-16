({

    getLanguageMenu : function(component, event, helper) {

    	var action = component.get("c.getLanguageMenu");
    	var clusterId = helper.getCookie("CG_clusterId");

        action.setParams({
            clusterId: clusterId
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.MenuWrapper", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);

    },

    setCountryCodeCookie: function(component, event, helper,languaje){
        
        this.setCookie('languaje',languaje,365);
        
        var eUrl= $A.get("e.force:navigateToURL");
        window.location.reload();
    },
    
    setCountryCodeUser: function(component, event, helper,languaje){
      
        var action = component.get("c.setLanguage");
        action.setParams({
            language: languaje
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                var eUrl= $A.get("e.force:navigateToURL");
                window.location.reload();
        
            }
        });
        $A.enqueueAction(action);
	},
    
  
    closeSelector: function (component, event, helper, arrowicon) {
        arrowicon.getElement().classList.remove("fa-angle-up");
        arrowicon.getElement().classList.add("fa-angle-down");
        component.set('v.renderLangMenu', false);
    },
    openSelector: function (component, event, helper, arrowicon) {
        arrowicon.getElement().classList.remove("fa-angle-down");
        arrowicon.getElement().classList.add("fa-angle-up");
        component.set('v.renderLangMenu', true);
        window.addEventListener('scroll', helper.bindedCloseSelector.bind({arrowicon: arrowicon, component: component}));
    },                                         
    bindedCloseSelector: function () {
        this.arrowicon.getElement().classList.remove("fa-angle-up");
        this.arrowicon.getElement().classList.add("fa-angle-down");
        this.component.set('v.renderLangMenu', false);
    },

	getCookie : function(cname){
    	var name = cname + "=";
	    var decodedCookie = decodeURIComponent(document.cookie);
	    var ca = decodedCookie.split(';');
	    for(var i = 0; i <ca.length; i++) {
	        var c = ca[i];
	        while (c.charAt(0) == ' ') {
	            c = c.substring(1);
	        }
	        if (c.indexOf(name) == 0) {
	            return c.substring(name.length, c.length);
	        }
	    }
	    return "";
    },
    setCookie : function(cname, cvalue, exdays) {
	    var d = new Date();
	    d.setTime(d.getTime() + (exdays*24*60*60*1000));
	    var expires = "expires="+ d.toUTCString();
	    document.cookie = cname + "=" + cvalue + ";" + expires + ";path=/";
	}

})