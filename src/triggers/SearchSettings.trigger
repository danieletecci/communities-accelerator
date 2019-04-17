trigger SearchSettings on SearchSetting__c (before insert, before update) {
  new  SearchSettingTriggers(trigger.new, trigger.old).run();
}