({
	handleOrientation : function(component) {
        //TRUE = Portrait
        var device = $A.get("$Browser.formFactor");
        component.set("v.orientation" , (device === "DESKTOP") ? '' : (screen.orientation.angle === 0) ? ' PORTRAIT' :' LANDSCAPE');
	},
})