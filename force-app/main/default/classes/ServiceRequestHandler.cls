public with sharing class ServiceRequestHandler {

    // Entry point called by the trigger
    public static void handleBeforeInsert(List<BE_Service_Request__c> newRecords) {
        autoEscalateHighPriority(newRecords);
    }

    public static void handleBeforeUpdate(
        List<BE_Service_Request__c> newRecords,
        Map<Id, BE_Service_Request__c> oldMap
    ) {
        autoEscalateHighPriority(newRecords);
    }

    /**
     * Business rule: Critical or High priority requests that have no
     * assigned owner are automatically flagged as auto-assigned and their
     * status moved to In Progress so they are never left as New.
     *
     * Bulk-safe: operates entirely on the trigger list with no SOQL.
     */
    private static void autoEscalateHighPriority(List<BE_Service_Request__c> records) {
        for (BE_Service_Request__c sr : records) {
            if (sr.Priority__c == 'Critical' || sr.Priority__c == 'High') {
                if (sr.Assigned_To__c == null) {
                    sr.Auto_Assigned__c = true;
                }
                // Always escalate status to In Progress for High/Critical
                if (sr.Status__c == 'New') {
                    sr.Status__c = 'In Progress';
                }
            }
        }
    }
}
