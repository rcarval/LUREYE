@isTest
private class LUREYE_GE_Product_Sync_from_SAP_Sch_Tst {
    @isTest
    static void testExecuteScheduledJob() {
        LUREYE_GE_Product_Sync_from_SAP_Schedule job = new LUREYE_GE_Product_Sync_from_SAP_Schedule();

        Test.startTest();
        String jobId = System.schedule(
            'Test GE Schedule Job',
            '0 0 12 * * ?',
            job
        );
        Test.stopTest();

        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE Id = :jobId];

        System.assertEquals('0 0 12 * * ?', ct.CronExpression);
        System.assertEquals(0, ct.TimesTriggered);
    }
}