@isTest
private with sharing class LUREYE_EM_Product_Sync_from_SAP_Sch_Tst {
    @isTest
    static void testExecuteScheduledJob() {
        LUREYE_EM_Product_Sync_from_SAP_Schedule job = new LUREYE_EM_Product_Sync_from_SAP_Schedule();

        Test.startTest();
        String jobId = System.schedule(
            'Test EM Schedule Job',
            '0 0 13 * * ?',
            job
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals('0 0 13 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}