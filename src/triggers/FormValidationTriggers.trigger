trigger FormValidationTriggers on FormValidation__c (before insert, before update) {
	new FormValidationTriggers(trigger.new, trigger.old).run();
}