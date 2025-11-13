@isTest
public class CS_ScheduleNotify_Test {
    @isTest
    static void testScheduleNotify() {
        List<CronTrigger> existingTriggers = [SELECT Id, CronExpression FROM CronTrigger 
        WHERE CronJobDetail.Name = 'Metalytics Data Loader Job for Org : 00DO500000ZARkM'];
        System.assertNotEquals(0, existingTriggers.size(), 'Se espera que el trabajo ya esté programado.');
    }
}