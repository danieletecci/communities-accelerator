public class LookupController {
    
    @AuraEnabled(cacheable=false)
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName) {
        String searchKey = searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
      
        // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5   
        String sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by createdDate DESC limit 5';
        List < sObject > lstOfRecords = Database.query(GeneralUtils.prefix(sQuery));
        
        for (sObject obj: lstOfRecords) {
            returnList.add(obj);
        }
        return returnList;
    }

    @AuraEnabled(cacheable=false)
    public static sObject getInitialValue(String recordId, String ObjectName) {
        String sQuery =  'select id, Name from ' +ObjectName + ' where Id = :recordId';
        List < sObject > lstOfRecords = Database.query(GeneralUtils.prefix(sQuery));
        
        if(!lstOfRecords.isEmpty()){
            return lstOfRecords.get(0);
        }
        return null;
    }
}