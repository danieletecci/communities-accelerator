({
    getcountriesCode : function(component, event, helper) {

    	var action = component.get("c.getCountriesCodes");

        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.CountriesWrapper", action.getReturnValue());
                component.set("v.inputNumber",component.get("v.CountriesWrapper.selected.phoneCode"));
            }
        });
        $A.enqueueAction(action);

    }
})