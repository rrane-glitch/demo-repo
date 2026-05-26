trigger ServiceRequestTrigger on BE_Service_Request__c (before insert, before update) {
    if (Trigger.isBefore && Trigger.isInsert) {
        ServiceRequestHandler.handleBeforeInsert(Trigger.new);
    }
    if (Trigger.isBefore && Trigger.isUpdate) {
        ServiceRequestHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
    }
}
