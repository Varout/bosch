/**
 * Class: ScheduleGDPRCleanerTest.cls
 * @desc: Testing ScheduleGDPRCleaner
 */
@isTest
private class ScheduleGDPRCleanerTest {

    @isTest
    static void testSchedule() {
        Test.startTest();
        ScheduleGDPRCleaner.schedule();
        Test.stopTest();

        Integer countCronJobDetails = [SELECT COUNT() FROM CronJobDetail WHERE Name LIKE '%TEST' AND JobType = '7'];
        System.assertEquals(1, countCronJobDetails, 'Only one record should be found that matches the criteria. Found: ' + String.valueOf(countCronJobDetails));
    }

}