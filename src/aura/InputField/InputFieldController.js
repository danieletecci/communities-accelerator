({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    },
    goToStep : function(component, event, helper) {
        var step = event.getSource().get('v.value');
        component.set('v.step', new Number(step).valueOf());
    },
    validate : function(component, event, helper) {
        helper.setValueOnFormData(component);
        helper.validate(component, event, helper);
    },
    setValuesForMultiPicklist : function(component, event, helper){
        helper.setValuesForMultiPicklist(component);
        helper.validate(component, event, helper);
    },
    
    validateConfirmationOnBlur : function(component, event, helper){
        helper.validateConfirmationOnBlur(component, event, helper);
    },
    
    validateWithoutErrorMessage : function(component, event, helper){
        helper.validateWithoutErrorMessage(component, event, helper);
    },
    
    
    doStyleConfirmationError : function(component, event, helper){
        helper.doStyleConfirmationError(component, event, helper);
    },
    
    changeRadioButton : function(component, event, helper){
        
        var selected = event.getSource().get("v.label");
        component.set("v.inputValue", selected);
        helper.setValueOnFormData(component);
        helper.validate(component, event, helper);
    },
    validateOnChange : function(component, event, helper){
    	var field = component.get("v.fieldConfiguration");
        if(field.maxLength && !field.readOnly){
            helper.maxLengthValidation(component, event,helper, field, false);
        }
    	helper.validateWithoutErrorMessage(component, event, helper);
	},
    phoneChanged : function(component, event, helper){
        if(component.get('v.fieldConfiguration.displayType') == 'Phone'){
            helper.setValueOnFormData(component);
            helper.validate(component, event, helper);
        }
    }
})