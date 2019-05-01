({
	initContent : function(component, event, helper) {
		var cWrapper = component.get('v.componentWrapper');
		var componentRecordType = cWrapper.component.RecordTypeDeveloperName;
		var action = component.get('c.getContentRecordtypeId');
		action.setParams({
			componentRecordType: componentRecordType
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	component.set('v.contentRecordtypeId', action.getReturnValue());
	        }
	    });
	    $A.enqueueAction(action);
	}, 
	viewComponent : function(component, event, helper) {
		var cWrapper = component.get('v.componentWrapper');
		var sfDomain  = cWrapper.acceleratorSettings.SalesforceDomain;
		var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/lightning/r/' + cWrapper.namespace + 'Component__c/' + cWrapper.component.Id + '/view';
		
		window.open(url, '_blank');
	},
	viewContent : function(component, event, helper) {
		var contentDetail = component.find('contentDetail').getElement();
		if(contentDetail.classList.contains('hidden')){
			helper.showContentDetail(component, true);
		}else{
			helper.showContentDetail(component, false);
		}
	},
	newContent : function(component, recordId) {		
		var sfDomain = component.get('v.componentWrapper.acceleratorSettings.SalesforceDomain');
		var namespace = component.get('v.componentWrapper.namespace') === undefined ? '' : component.get('v.componentWrapper.namespace');
		var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/lightning/r/' + namespace + 'Content__c/' + recordId + '/view';
		window.open(url);
	},
	// the function that reads the url parameters
    getPageUrl: function() {
        var sPageURL = decodeURIComponent(window.location.search.substring(1));//,
			//sURLVariables = sPageURL.split('/'),
			//sParameterName,
			//i;
			sPageURL = sPageURL;
       
    },
	showHideEditFrame : function(component, helper, show) {
		var cWrapper = component.get('v.componentWrapper');
		var mainPanel = document.getElementById(component.get('v.componentWrapper.component.Id'));
		if (mainPanel){
		var divComponentNamePanel = mainPanel.getElementsByClassName('componentNamePanel')[0];
		var divButtonsPanel = mainPanel.getElementsByClassName('buttonsPanel')[0];
		var contentDetail = component.find('contentDetail');
			if(show){
				mainPanel.classList.add('borderColorBlue');
				divComponentNamePanel.classList.remove('hidden');
				divButtonsPanel.classList.remove('hidden');
				divComponentNamePanel.classList.add('show');
				divButtonsPanel.classList.add('show');

				if(contentDetail != undefined){
					if(component.get("v.contentActivated")){
						contentDetail.getElement().classList.remove('hidden');
						contentDetail.getElement().classList.add('show');
					}
				}
			}else{
				mainPanel.classList.remove('borderColorBlue');
				divComponentNamePanel.classList.remove('show');
				divButtonsPanel.classList.remove('show');
				divComponentNamePanel.classList.add('hidden');
				divButtonsPanel.classList.add('hidden');
			
				if(contentDetail != undefined){
					contentDetail.getElement().classList.remove('show');
					contentDetail.getElement().classList.add('hidden');
				}
			}
		}
	},
	showContentDetail : function(component, show) {
		var contentDetail = component.find('contentDetail').getElement();
		if(show){
			component.set("v.contentActivated", true);
			contentDetail.classList.remove('hidden');
			contentDetail.classList.add('show');
		}else{
			component.set("v.contentActivated", false);
			contentDetail.classList.remove('show');
			contentDetail.classList.add('hidden');
		}
	}
})