trigger Audiences on Audience__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AudienceTriggers(trigger.new, trigger.old).run();
}