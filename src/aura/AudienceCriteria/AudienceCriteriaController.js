({
    doInit : function(component, event, helper) {
        helper.getCriteria(component, event, helper);
	},
	doSave : function(component, event, helper) {
        helper.saveCriteria(component, event, helper);
    },
    doChangeField : function(component, event, helper) {
        helper.changeField(component, event, helper);
    },
    doAddCriterion : function(component, event, helper) {
        helper.addCriterion(component, event, helper);
    },
    doRemoveCriterion : function(component, event, helper) {
        helper.removeCriterion(component, event, helper);
    },
    doChangeMatchCriteria : function(component, event, helper) {
        helper.changeMatchCriteria(component, event, helper);
    }
})