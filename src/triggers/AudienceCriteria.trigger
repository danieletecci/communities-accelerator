trigger AudienceCriteria on AudienceCriterion__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    new AudienceCriterionTriggers(trigger.new, trigger.old).run();
}