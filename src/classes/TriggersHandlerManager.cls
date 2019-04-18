public without sharing class TriggersHandlerManager {
    
    private static User currentUser;
	private static User getUser(){
		if(currentUser == null){
			currentUser = [SELECT Id, TriggersByPass__c, TriggersDebugs__c FROM User WHERE Id =: UserInfo.getUserId()];
        }
		return currentUser;
	}

	public class TriggerFiltered {
		public map<String, List<SObject>> triggerNewFiltered;
		public map<String, List<SObject>> triggerOldFiltered;
		public triggerFiltered(map<String, List<SObject>> p_triggerNewFiltered, map<String, List<SObject>> p_triggerOldFiltered){
			this.triggerNewFiltered = p_triggerNewFiltered;
			this.triggerOldFiltered = p_triggerOldFiltered;
		}
	}

  	private static set<String> triggersBypassed = new set<String>();
    
    
    public static Boolean isByPassTrigger(String triggerName){
		return triggersBypassed.contains(triggerName);
    }

    public static void byPassTrigger(String triggerName){
		triggersBypassed.add(triggerName);
    }

    public static void removeByPassTrigger(String triggerName){
		triggersBypassed.remove(triggerName);
    }
    
    public static Boolean canAutoDebug(String triggerName){
        if(triggersBypassed.contains(triggerName)){
        	return false;
        }
        return getUser().TriggersDebugs__c != null ? (getUser().TriggersDebugs__c.contains(triggerName)) : false;
    }

    public static Boolean canTrigger(String triggerName){
        if(triggersBypassed.contains(triggerName)){
        	return false;
        }
        return getUser().TriggersByPass__c != null ? (!getUser().TriggersByPass__c.contains(triggerName)) : true;
    }

	@testVisible private static List<SObject> triggerNew;
	@testVisible private static List<SObject> triggerOld;

    public static TriggerFiltered getTriggerListFiltered(String filterFieldApiName){
    	map<String, List<SObject>> triggerNewFiltered = new map<String, List<SObject>>();
    	map<String, List<SObject>> triggerOldFiltered = new map<String, List<SObject>>();

		triggerNew = trigger.new != null ? trigger.new : triggerNew;  
		triggerOld = trigger.old != null ? trigger.old : triggerOld;  
		
		if(triggerNew != null){
			for(SObject rec: triggerNew){
				if(filterFieldApiName != null){
					if( String.valueOf(rec.get(filterFieldApiName)) != null && triggerNewFiltered.containsKey(String.valueOf(rec.get(filterFieldApiName))) ){
						triggerNewFiltered.get(String.valueOf(rec.get(filterFieldApiName))).add(rec);
					}else{
						triggerNewFiltered.put(String.valueOf(rec.get(filterFieldApiName)), new List<SObject>{rec});
					}
				}
			}
		}
		if(triggerOld != null){
			for(SObject rec: triggerOld){
				if(filterFieldApiName != null){
					if( String.valueOf(rec.get(filterFieldApiName)) != null && triggerOldFiltered.containsKey(String.valueOf(rec.get(filterFieldApiName))) ){
						triggerOldFiltered.get(String.valueOf(rec.get(filterFieldApiName))).add(rec);
					}else{
						triggerOldFiltered.put(String.valueOf(rec.get(filterFieldApiName)), new List<SObject>{rec});
					}
				}
			}
		}
    	return new TriggerFiltered(triggerNewFiltered, triggerOldFiltered);
    }

}