trigger SearchDetail on SearchDetail__c (before insert, before update) {
  new SearchSettingTriggers(trigger.new, trigger.old).run();
}