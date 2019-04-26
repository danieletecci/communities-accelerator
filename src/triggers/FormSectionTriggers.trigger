trigger FormSectionTriggers on FormSection__c (before insert, before update) {
	new FormSectionTriggers(trigger.new, trigger.old).run();
}