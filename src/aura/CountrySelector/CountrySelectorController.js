({
    doInit: function (component, event, helper) {
        helper.getcountriesCode(component, event, helper);
    },
    
    showMenuItems: function(component, event, helper){  
        
        var arrowicon = component.find('menuPhoneItems');
        console.log(arrowicon);
        $A.util.removeClass(arrowicon, 'hideItems');   
        
    },
    hideMenuItems: function(component, event, helper){  
        var arrowicon = component.find('menuPhoneItems');
        console.log(arrowicon);
        $A.util.addClass(arrowicon, 'hideItems');   
        
    },
    
    
    handleChanges: function (component, event, helper) {
        
        var phoneValue = event.currentTarget.getAttribute("data-phoneValue");
        var nameValue = event.currentTarget.getAttribute("data-nameValue"); 
        var isoValue = event.currentTarget.getAttribute("data-isoValue");  
        
        component.set("v.CountriesWrapper.selected.phoneCode",phoneValue);
        component.set("v.CountriesWrapper.selected.name",nameValue);
        component.set("v.CountriesWrapper.selected.iso",isoValue);
        component.set("v.inputNumber",phoneValue);
        
        $A.enqueueAction(component.get('c.showMenuItems'));
        
    }
    
})