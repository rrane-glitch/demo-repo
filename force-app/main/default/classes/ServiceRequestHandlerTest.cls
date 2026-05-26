@IsTest
private class ServiceRequestHandlerTest {

    // ── Happy path: Critical record auto-escalated ────────────────────────
    @IsTest
    static void testCriticalPriorityEscalatesStatus() {
        BE_Service_Request__c sr = new BE_Service_Request__c(
            Priority__c = 'Critical',
            Status__c   = 'New',
            Description__c = 'Production system is down'
        );

        Test.startTest();
        insert sr;
        Test.stopTest();

        BE_Service_Request__c result = [
            SELECT Status__c, Auto_Assigned__c
            FROM BE_Service_Request__c
            WHERE Id = :sr.Id
        ];

        System.assertEquals('In Progress', result.Status__c,
            'Critical priority should escalate status to In Progress');
        System.assertEquals(true, result.Auto_Assigned__c,
            'Critical with no owner should be flagged Auto Assigned');
    }

    // ── Happy path: High priority auto-escalated ──────────────────────────
    @IsTest
    static void testHighPriorityEscalatesStatus() {
        BE_Service_Request__c sr = new BE_Service_Request__c(
            Priority__c = 'High',
            Status__c   = 'New'
        );

        Test.startTest();
        insert sr;
        Test.stopTest();

        BE_Service_Request__c result = [
            SELECT Status__c FROM BE_Service_Request__c WHERE Id = :sr.Id
        ];
        System.assertEquals('In Progress', result.Status__c,
            'High priority should escalate status to In Progress');
    }

    // ── Negative path: Medium priority untouched ─────────────────────────
    @IsTest
    static void testMediumPriorityNotEscalated() {
        BE_Service_Request__c sr = new BE_Service_Request__c(
            Priority__c = 'Medium',
            Status__c   = 'New'
        );

        Test.startTest();
        insert sr;
        Test.stopTest();

        BE_Service_Request__c result = [
            SELECT Status__c, Auto_Assigned__c
            FROM BE_Service_Request__c
            WHERE Id = :sr.Id
        ];
        System.assertEquals('New', result.Status__c,
            'Medium priority should remain New');
        System.assertEquals(false, result.Auto_Assigned__c,
            'Medium priority should not be flagged Auto Assigned');
    }

    // ── Negative path: Low priority untouched ────────────────────────────
    @IsTest
    static void testLowPriorityNotEscalated() {
        BE_Service_Request__c sr = new BE_Service_Request__c(
            Priority__c = 'Low',
            Status__c   = 'New'
        );
        insert sr;
        BE_Service_Request__c result = [
            SELECT Status__c FROM BE_Service_Request__c WHERE Id = :sr.Id
        ];
        System.assertEquals('New', result.Status__c, 'Low priority should remain New');
    }

    // ── Bulk test: 200 records at once ────────────────────────────────────
    @IsTest
    static void testBulkInsert200CriticalRecords() {
        List<BE_Service_Request__c> records = new List<BE_Service_Request__c>();
        for (Integer i = 0; i < 200; i++) {
            records.add(new BE_Service_Request__c(
                Priority__c    = 'Critical',
                Status__c      = 'New',
                Description__c = 'Bulk record ' + i
            ));
        }

        Test.startTest();
        insert records;
        Test.stopTest();

        List<BE_Service_Request__c> results = [
            SELECT Status__c FROM BE_Service_Request__c
            WHERE Priority__c = 'Critical'
        ];
        System.assertEquals(200, results.size(), 'All 200 records should have been inserted');
        for (BE_Service_Request__c r : results) {
            System.assertEquals('In Progress', r.Status__c,
                'All Critical bulk records should be In Progress');
        }
    }

    // ── Update path: escalation fires on update too ───────────────────────
    @IsTest
    static void testUpdateToCriticalEscalates() {
        BE_Service_Request__c sr = new BE_Service_Request__c(
            Priority__c = 'Low',
            Status__c   = 'New'
        );
        insert sr;

        sr.Priority__c = 'Critical';

        Test.startTest();
        update sr;
        Test.stopTest();

        BE_Service_Request__c result = [
            SELECT Status__c FROM BE_Service_Request__c WHERE Id = :sr.Id
        ];
        System.assertEquals('In Progress', result.Status__c,
            'Updating priority to Critical should escalate status');
    }
}
