({
    openCloseMenu: function(component){
        var opened = component.get("v.opened");

		if(opened){
			component.set('v.opened', false);
		}else{
			component.set('v.opened', true);
		}
    },
	stopScroll: function(component, event, helper) {
        setInterval(function(){
            var isIE11 = false;
        if(navigator.userAgent.indexOf('MSIE')!==-1 || navigator.appVersion.indexOf('Trident/') > 0){isIE11 = true;}

        if(!isIE11) {
            window.onscroll = function() {
                if($A.get("$Browser.isPhone")) {
                    return;
                }else {
                    if(document.getElementById('desktopSidebarContent')) {
                        var divContent = document.getElementById('desktopSidebarContent');
                        if(document.getElementById('desktopSidebarContainer')) {
                            var divContainer = document.getElementById('desktopSidebarContainer');
                            if( (divContent.offsetHeight) > (divContainer.offsetHeight - 30)){
                                divContent.style.position = "absolute";
                                divContent.style.overflowY = "scroll";
                            }else{
                                if(window.scrollY > (divContainer.offsetHeight - divContent.offsetHeight)){
                                    divContent.style.position = "absolute";
                                    divContent.style.overflowY = "hidden";
                                }else{
                                    divContent.style.position = "absolute";
                                    divContent.style.overflowY = "hidden";
                                }
                            }
                        }
                    }
                }
            }
        }
            
        }, 1000);
        
    }
})