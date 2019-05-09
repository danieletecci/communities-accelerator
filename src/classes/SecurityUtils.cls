public class SecurityUtils {

	//RECORD USER ACCESS
	public static UserRecordAccess getUserRecordAccess(String recordId){
        UserRecordAccess ura = [SELECT RecordId, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :recordId];
        return ura;
    }

    //USER CUSTOM PERMISSION
    public static Boolean hasCustomPermission(String permissionName){
    	return FeatureManagement.checkPermission(permissionName);
    }

	//OBJECT USER PERMISSION
    public static Boolean isObjectAccessible(String objName){
        Boolean result = false;
        
        SObjectType myObj = Schema.getGlobalDescribe().get(objName);
        
        if(myObj != null) {
            result = myObj.getDescribe().isAccessible();
        }
        
        return result;
    }

    public static Boolean isObjectCreateable(String objName){
        Boolean result = false;
        
        SObjectType myObj = Schema.getGlobalDescribe().get(objName);
        
        if(myObj != null) {
            result = myObj.getDescribe().isCreateable();
        }
        
        return result;
    }

    public static Boolean isObjectUpdateable(String objName){
        Boolean result = false;
        
        SObjectType myObj = Schema.getGlobalDescribe().get(objName);
        
        if(myObj != null) {
            result = myObj.getDescribe().isUpdateable();
        }
        
        return result;
    }

    //FIELD USER PERMISSION
    public static Boolean isFieldAccessible(String objName, String fieldName){
        Boolean result = false;
        
        if(isObjectAccessible(objName)) {
            SObjectField myField = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName);
            
            if(myField != null) {
                result = myField.getDescribe().isAccessible();
            }    
        }
        return result;
    }

    public static Boolean isFieldCreateable(String objName, String fieldName){
        Boolean result = false;
        
        if(isObjectCreateable(objName)) {
            SObjectField myField = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName);
            
            if(myField != null) {
                result = myField.getDescribe().isCreateable();
            }
        }
        return result;
    }

    public static Boolean isFieldUpdateable(String objName, String fieldName){
        Boolean result = false;
        
        if(isObjectUpdateable(objName)) {
            SObjectField myField = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap().get(fieldName);
            
            if(myField != null) {
                result = myField.getDescribe().isUpdateable();
            }    
        }
        return result;
    }

    public static Boolean isRecordTypeAvailable(String objName, String recordTypeDeveloperName){
        Boolean result = false;
        if(isObjectAccessible(objName)) {
        	RecordTypeInfo myRecordType = Schema.getGlobalDescribe().get(objName).getDescribe().getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName);
        	if(myRecordType != null){
        		result = myRecordType.isAvailable();
        	}
        }
    	return result;
    }
}