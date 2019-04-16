({
	onInit 	: function(component,event,helper){
		var result 			= component.get("v.result");
		var record 			= component.get("v.record");
		var url 			= '/' + result.navigation + '?' + result.urlParameterName + '=' + record[result.urlParameterField];
		

		component.set("v.url", url);
	}
})