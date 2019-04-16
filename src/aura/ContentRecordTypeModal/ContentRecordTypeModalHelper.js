({
	getObjectLabel : function(component, sObjectName) {
		if(component.get("v.sObjectLabel") == null){
			var action = component.get("c.getObjectLabel");
			action.setParams({
				sObjectType: sObjectName
			});

			action.setCallback(this, function(response) {
		        if(response.getState() === "SUCCESS") {
		           	var sObjectLabel = response.getReturnValue();
					component.set("v.sObjectLabel", sObjectLabel);
			    }
			});
			    
			$A.enqueueAction(action);
		}
	},
	getRecordTypes : function(component, sObjectName, rtList) {
		var action = component.get("c.getRecordTypes");

		action.setParams({
			sObjectType: sObjectName,
			recordTypes: rtList
		});

		action.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {
	           	var options = response.getReturnValue();
				component.set("v.options", options);
				var option = [];
				var structureContent = {Id: 'structureContent',
										Name: "Structure Content", 
	           							Description: $A.get("$Label.c.StructureContentDescription")};
	           	option.push(structureContent);
				component.set("v.option", option);
		    }
		});
			    
		$A.enqueueAction(action);
	},
	openModal : function(component){
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.addClass(modalBox, 'slds-fade-in-open');
		$A.util.addClass(modalBackdrop,'slds-backdrop--open');
	},
	closeModal : function(component){
		var modalBox = component.find('modalBox');
		var modalBackdrop = component.find('modalBackdrop');
		$A.util.removeClass(modalBox, 'slds-fade-in-open');
		$A.util.removeClass(modalBackdrop,'slds-backdrop--open');
	},
	goToNewRecord : function(component){	
		var helper = this;	
    	var action = component.get("c.getNoRedirectRecordTypes");
    	var recordTypeId = component.get("v.value");
		action.setCallback(this, function(response) {
	        if(response.getState() === "SUCCESS") {
	           	var noRedirectRecordTypes = response.getReturnValue();
	           	if(recordTypeId == 'structureContent'){
					helper.navigateTo(component, "/lightning/n/Sitemap");
	           	} else if(! noRedirectRecordTypes.includes(recordTypeId)){
					helper.navigateTo(component, "/lightning/n/NewContent?RecordTypeId=" + recordTypeId);
	    		}
			}
		});			    
		$A.enqueueAction(action);  
	},
	navigateTo : function(component, url){
		var urlEvent = $A.get("e.force:navigateToURL");
	   	urlEvent.setParams({
	      "url": url
	    });	
	    urlEvent.fire();
	}
})

