({ 
    getMediaElementRecord: function (component, helper) {
        var action = component.get("c.getRecord");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(f){
            if(f.getState() === "SUCCESS") {
                component.set("v.mediaElementWrapper", action.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },

    retrieveFile: function (component, helper, fileId, fileName, device) {
        
        var action = component.get("c.getFileById");
        action.setParams({
            contentDocumentId: fileId
        });
        action.setCallback(this, function(f){
        	if(f.getState() === "SUCCESS") {
                var imgStr = f.getReturnValue();
                var image = document.getElementById("imageAux");
                image.src = "data:image/gif;base64," + imgStr;
                helper.saveFileAndUpdateMedia(component, helper, fileId, '', fileName, device, image.width, image.height);
                if(device == 'Desktop'){
                	if(String(component.find("resizeForTable").get('v.value')) == 'true'){
                		component.set("v.oldFileTablet", component.get("v.mediaElementWrapper.mediaElement.FileIdTablet"));
                		var tabletImg = new Image;
						tabletImg.src = "data:image/gif;base64," + imgStr;
						tabletImg.onload = function() {
							var widthResize = component.get("v.mediaElementWrapper.acceleratorSettings.MaxSizeTablet");
							var heightResize = component.get("v.mediaElementWrapper.acceleratorSettings.MaxSizeTablet");
							var t_base64String = helper.resizeImg(tabletImg, widthResize, heightResize, 0);

							helper.saveFileAndUpdateMedia(component, helper, '', t_base64String, '[TABLET]_' + fileName, 'Tablet', 500, 500);
						}
                	}
                	if(String(component.find("resizeForMobile").get('v.value')) == 'true'){
                		component.set("v.oldFileMobile", component.get("v.mediaElementWrapper.mediaElement.FileIdMobile"));
                		var mobileImg = new Image;
						mobileImg.src = "data:image/gif;base64," + imgStr;
						mobileImg.onload = function() {
							var widthResize = component.get("v.mediaElementWrapper.acceleratorSettings.MaxSizeMobile");
							var heightResize = component.get("v.mediaElementWrapper.acceleratorSettings.MaxSizeMobile");
							var m_base64String = helper.resizeImg(mobileImg, widthResize, heightResize, 0);

							helper.saveFileAndUpdateMedia(component, helper, '', m_base64String, '[MOBILE]_' + fileName, 'Mobile', 500, 500);
						}
                	}
                }
                helper
            }
        });
		$A.enqueueAction(action);
	},

    saveFileAndUpdateMedia: function(component, helper, fileId, base64Str, fileName, device, width, height) {
    	var action = component.get("c.createFile");
        action.setParams({
            recordId: component.get("v.recordId"),
            fileId: fileId,
            base64Str: base64Str,
            fileName: fileName,
            device: device,
            width: String(width),
            height: String(height)
        });
        
        action.setCallback(this, function(f){
        	if(f.getState() === "SUCCESS") { 

        		if(device == 'Desktop' && component.get("v.oldFileDesktop")!=null){
        			helper.editDesktop(component);
        		}
        		if(device == 'Tablet' && component.get("v.oldFileTablet")!=null){
        			helper.editTablet(component);
        		}
        		if(device == 'Mobile' && component.get("v.oldFileMobile")!=null){
        			helper.editMobile(component);
        		}

                $A.get('e.force:refreshView').fire();
            }
        });
		$A.enqueueAction(action);
    },

    editDesktop: function(component){
    	var action = component.get("c.deleteDocument");
        action.setParams({
            urlDocument: component.get("v.oldFileDesktop")
        });
        
        action.setCallback(this, function(f){
        	if(f.getState() === "SUCCESS") { 
        		component.set("v.showEditDesktop", false);
            }
        });
		$A.enqueueAction(action);
    },
    editTablet: function(component){  	
    	var action = component.get("c.deleteDocument");
        action.setParams({
            urlDocument: component.get("v.oldFileTablet")
        });
        
        action.setCallback(this, function(f){
        	if(f.getState() === "SUCCESS") { 
        		component.set("v.showEditTablet", false);
            }
        });
		$A.enqueueAction(action);
    },
    editMobile: function(component){ 	
     	var action = component.get("c.deleteDocument");
        action.setParams({
            urlDocument: component.get("v.oldFileMobile")
        });
        
        action.setCallback(this, function(f){
        	if(f.getState() === "SUCCESS") { 
        		component.set("v.showEditMobile", false);
            }
        });
		$A.enqueueAction(action);
    },

    resizeImg : function(img, maxWidth, maxHeight, degrees) {
        var imgWidth = img.width, imgHeight = img.height;

		var ratio = 1,
		ratio1 = 1,
		ratio2 = 1;
		ratio1 = maxWidth / imgWidth;
		ratio2 = maxHeight / imgHeight;

		// Use the smallest ratio that the image best fit into the maxWidth x maxHeight box.
		if (ratio1 < ratio2) {
			ratio = ratio1;
		} else {
			ratio = ratio2;
		}
		
		var canvas = document.createElement("canvas");
		var canvasContext = canvas.getContext("2d");
		var canvasCopy = document.createElement("canvas");
		var copyContext = canvasCopy.getContext("2d");
		var canvasCopy2 = document.createElement("canvas");
		var copyContext2 = canvasCopy2.getContext("2d");
		canvasCopy.width = imgWidth;
		canvasCopy.height = imgHeight;
		copyContext.drawImage(img, 0, 0);

		// init
		canvasCopy2.width = imgWidth;
		canvasCopy2.height = imgHeight;
		copyContext2.drawImage(canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvasCopy2.width, canvasCopy2.height);
		
		var rounds = 1;
		var roundRatio = ratio * rounds;
		for (var i = 1; i <= rounds; i++) {
			// tmp
			canvasCopy.width = imgWidth * roundRatio / i;
			canvasCopy.height = imgHeight * roundRatio / i;

			copyContext.drawImage(canvasCopy2, 0, 0, canvasCopy2.width, canvasCopy2.height, 0, 0, canvasCopy.width, canvasCopy.height);

			// copy back
			canvasCopy2.width = imgWidth * roundRatio / i;
			canvasCopy2.height = imgHeight * roundRatio / i;
			copyContext2.drawImage(canvasCopy, 0, 0, canvasCopy.width, canvasCopy.height, 0, 0, canvasCopy2.width, canvasCopy2.height);
		}

		canvas.width = imgWidth * roundRatio / rounds;
		canvas.height = imgHeight * roundRatio / rounds;
		canvasContext.drawImage(canvasCopy2, 0, 0, canvasCopy2.width, canvasCopy2.height, 0, 0, canvas.width, canvas.height);
		
		if (degrees == 90 || degrees == 270) {
			canvas.width = canvasCopy2.height;
			canvas.height = canvasCopy2.width;
		} else {
			canvas.width = canvasCopy2.width;
			canvas.height = canvasCopy2.height;
		}

		canvasContext.clearRect(0, 0, canvas.width, canvas.height);
		if (degrees == 90 || degrees == 270) {
			canvasContext.translate(canvasCopy2.height / 2, canvasCopy2.width / 2);
		} else {
			canvasContext.translate(canvasCopy2.width / 2, canvasCopy2.height / 2);
		}
		canvasContext.rotate(degrees * Math.PI / 180);
		canvasContext.drawImage(canvasCopy2, -canvasCopy2.width / 2, -canvasCopy2.height / 2);


		// 0.5 = quality, lower = lower quality. Range is [0.0, 1.0]
		var quality = 0.7;

		//The JPEG format support quality settings which reduce the size
		var dataURL = canvas.toDataURL('image/jpeg', quality);

		return dataURL;
    },

    menuSelected : function(component, helper, selected) {

    	if(selected=='Edit_Desktop'){
    		component.set("v.showEditDesktop", true);
    		component.set("v.oldFileDesktop", component.get("v.mediaElementWrapper.mediaElement.FileIdDesktop"));
    	}
    	if(selected=='Edit_Tablet'){
    		component.set("v.showEditTablet", true);
    		component.set("v.oldFileTablet", component.get("v.mediaElementWrapper.mediaElement.FileIdTablet"));
    	}
    	if(selected=='Edit_Mobile'){
    		component.set("v.showEditMobile", true);
    		component.set("v.oldFileMobile", component.get("v.mediaElementWrapper.mediaElement.FileIdMobile"));
    	}
    	if(selected=='Delete_Desktop'){
    		var action = component.get("c.deleteFileDesktop");
	        action.setParams({
	            recordId: component.get("v.recordId")
	        });
	        
	        action.setCallback(this, function(f){
	        	if(f.getState() === "SUCCESS") { 
	        		
	                $A.get('e.force:refreshView').fire();
	            }
	        });
			$A.enqueueAction(action);
    	}
    	if(selected=='Delete_Tablet'){
    		var action = component.get("c.deleteFileTablet");
	        action.setParams({
	            recordId: component.get("v.recordId")
	        });
	        
	        action.setCallback(this, function(f){
	        	if(f.getState() === "SUCCESS") { 
	        		
	                $A.get('e.force:refreshView').fire();
	            }
	        });
			$A.enqueueAction(action);
    	}
    	if(selected=='Delete_Mobile'){
    		var action = component.get("c.deleteFileMobile");
	        action.setParams({
	            recordId: component.get("v.recordId")
	        });
	        
	        action.setCallback(this, function(f){
	        	if(f.getState() === "SUCCESS") { 
	        		
	                $A.get('e.force:refreshView').fire();
	            }
	        });
			$A.enqueueAction(action);
    	}
    }
})