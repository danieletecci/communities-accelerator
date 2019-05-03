trigger FormElementTriggers on FormElement__c (before insert, before update) {
	new FormElementTriggers(trigger.new, trigger.old).run();
}