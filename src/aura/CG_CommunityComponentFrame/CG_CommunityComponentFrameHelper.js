({
	viewComponent : function(component, event, helper) {
		var cWrapper = component.get('v.componentWrapper');
		var sfDomain  = cWrapper.acceleratorSettings.SalesforceDomain;
		window.open(((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/' + cWrapper.component.Id, '_blank');
	},
	viewContent : function(component, event, helper) {
		var contentDetail = component.find('contentDetail').getElement();
		if(contentDetail.classList.contains('hidden')){
			helper.showContentDetail(component, true);
		}else{
			helper.showContentDetail(component, false);
		}
	},
	newContent : function(component, event, helper) {
		
		var cWrapper = component.get('v.componentWrapper');
		var componentRecordTypeId = cWrapper.component.RecordTypeDeveloperName;
		var navUrl = window.location.pathname;
		var navId;

		var act = component.get('c.getNavigationId');
		act.setParams({navigationUrl: navUrl});
		act.setCallback(this,function(f){
			if (f.getState()==="SUCCESS"){
				navId = act.getReturnValue();	
			}
		});

		var action = component.get('c.getContentRecordtypeId');
		action.setParams({
			componentRecordType: componentRecordTypeId,
		});

	    action.setCallback(this, function(f) {
            if(f.getState() === "SUCCESS") {
            	var contntRecordTypeWp = action.getReturnValue();

				var sfDomain  = cWrapper.acceleratorSettings.SalesforceDomain;
				if(contntRecordTypeWp.haveContentRecordType){

					var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/lightning/n/NewContent' + '?RecordTypeId=' + contntRecordTypeWp.contentRecordTypeId + '&ComponentId=' + cWrapper.component.Id + '&NavigationId=' + navId;
				}else{
					var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/lightning/n/NewContent';
				}
				
				window.open(url);

	        }
	    });
	    $A.enqueueAction(act);
	    $A.enqueueAction(action);
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