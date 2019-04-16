({
	doInit: function (component, event, helper) {
		helper.getLanguages(component);        
    },
    onChange: function (component, event, helper) {
		helper.changeLanguage(component);        
    },
    doSave: function (component, event, helper) {
		helper.saveTranslation(component);        
    },
	doCancel : function(component, event, helper) {
        helper.getLanguages(component);
	}
})