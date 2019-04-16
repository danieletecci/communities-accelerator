({
	viewComponent : function(component, event, helper) {
		var sfDomain = component.get('v.salesforceDomain');
		var componentId = component.get('v.componentWrapper.meta.component.Id');
		var metaComponentId = component.get('v.componentWrapper.meta.objectId');

		var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/';
		
		if(componentId != null){
			url += componentId;
		}else{
			if(metaComponentId != null){
				url += metaComponentId;
			}
		}
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
		var sfDomain = component.get('v.salesforceDomain');
		var url = ((sfDomain === undefined || sfDomain == '') ? './detail' : sfDomain) + '/lightning/r/Content__c/' + recordId + '/view';
		window.open(url);
	},

	showHideEditFrame : function(component, helper, show) {
		var componentId = component.get('v.componentWrapper.meta.component.Id');
		var metaComponentId = component.get('v.componentWrapper.objectId');

		var idDom;
		if(componentId != null){
			idDom = componentId;			
		}
		if(metaComponentId != null){
			idDom += metaComponentId;
		}

		if(idDom != undefined){
			var mainPanel = document.getElementById(idDom);
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

	showHideNamePanel : function(component, event, show) {
		var componentId = component.get('v.componentWrapper.meta.component.Id');
		var metaComponentId = component.get('v.componentWrapper.objectId');

		var idDom;
		if(componentId != null){
			idDom = componentId;			
		}
		if(metaComponentId != null){
			idDom += metaComponentId;
		}

		if(idDom != undefined){
			var mainPanel = document.getElementById(idDom);
			//var divComponentNamePanel = mainPanel.getElementsByClassName('componentNamePanel')[0];
			var divComponentNamePanel = event.currentTarget;
			console.log("divComponentNamePanel.classList antes: " + JSON.stringify(divComponentNamePanel.classList));
			if(show){
				divComponentNamePanel.classList.remove('hidden');
				divComponentNamePanel.classList.add('show');
			}else{
				divComponentNamePanel.classList.remove('show');
				divComponentNamePanel.classList.add('hidden');
			}
			console.log("divComponentNamePanel.classList despues: " + JSON.stringify(divComponentNamePanel.classList));
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