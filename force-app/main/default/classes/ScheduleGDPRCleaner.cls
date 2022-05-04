/**
 * Class: ScheduleGDPRCleaner.cls
 * Test:  ScheduleGDPRCleanerTest.cls
 * @desc: Scheduler for GDPR cleaner batch job
 */
global class ScheduleGDPRCleaner implements Schedulable{
    public static String JOB_CRON = '0 0 2 * * ? *';     //  Run every day at 02:00
    @TestVisible
    private static String JOB_NAME = 'GDPR Daily Cleaner';

    /**
     * Public static scheduler so that we can schedule the job with ease
     * If running a test, appeands ' Test' to the end of the job name
     * If the scheduled job already exists, don't schedule a new job
     */
    public static void schedule() {
        if (Test.isRunningTest()) {
            JOB_NAME += ' Test';
        }
        System.schedule(JOB_NAME, JOB_CRON, new ScheduleGDPRCleaner());
    }

    /**
     * Execute scheduled job
     */
    global void execute(SchedulableContext sc) {
        Database.executeBatch(new BatchGDPRCleaner());
    }
}