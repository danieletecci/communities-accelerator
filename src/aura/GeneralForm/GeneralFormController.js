({
    doInit : function(component, event, helper) {
        try{
            component.get('v.form.formSettings.sections').sort(function(a, b) { 
                return a.order - b.order;
            })
        }catch(e){
            console.log('Error while ordering form sections');
        }
    },
    validateAllFields : function(component, event, helper) {
        component.set("v.hasValidationErrors", []);
        var inputFieldComponent = component.find("inputFieldComponent");
        for(var i = 0;i<inputFieldComponent.length ; i++)
            if(inputFieldComponent[i].isRendered()){
            	inputFieldComponent[i].validate();
            }
    }
})