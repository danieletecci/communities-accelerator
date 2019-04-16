({
    doInit: function (component, event, helper) {
       helper.getLanguageMenu(component, event, helper);
    },

    handleChanges: function (component, event,helper) {
        var cookieValue = event.currentTarget.id;
        var currentCountryCode = component.get("v.currentCountryCode");
        var currentCountryCodeLowerValue = component.get("v.currentCountryCodeLowerValue");
        var lists = document.getElementById("CountryCodeSelect");
        var items = lists.getElementsByTagName("li");
        for (var i = 0; i < items.length; i++) {
            if(items[i].id == cookieValue){
            	items[i].classList.add('slds-hide');
            }
        }
        
        component.set("v.currentCountryCode", cookieValue);
        component.set("v.currentCountryCodeLowerValue", cookieValue.toLowerCase());
        helper.setCountryCodeCookie(cookieValue);
        var eUrl= $A.get("e.force:navigateToURL");
        eUrl.setParams({
          "url": "/"
        });
        eUrl.fire();
    },

    handleChanges1: function (component, event,helper) {
       
        var languageValue = event.currentTarget.getAttribute("data-langValue"); 
      
        var isGuest = component.get("v.MenuWrapper.isGuestUser");

        if(isGuest){
            helper.setCountryCodeCookie(component, event,helper,languageValue);
        }else{
            helper.setCountryCodeUser(component, event,helper,languageValue);
        }


        
    },
    handleChangesHide: function (component, event, helper) {
        var arrowicon = component.find('arrowicon');
        if(component.get("v.renderLangMenu")){
            helper.closeSelector(component, event, helper, arrowicon);
        } else {
            helper.openSelector(component, event, helper, arrowicon);
        }
    },



    showMenuItems: function(component, event, helper){  
        
        var arrowicon = component.find('menuLanguajeItems');
        console.log(arrowicon);
        $A.util.toggleClass(arrowicon, 'hideItems');

       
        
        
        
    }
 
})