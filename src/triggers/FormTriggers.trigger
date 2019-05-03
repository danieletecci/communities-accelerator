trigger FormTriggers on Form__c (before insert, before update, after insert, after update) {
	new FormTriggers(trigger.new, trigger.old).run();
}