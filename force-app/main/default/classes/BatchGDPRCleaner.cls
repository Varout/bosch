/**
 * @class: BatchGDPRCleaner
 * @test: BatchGDPRCleanerTest
 * @desc: Batch job for cleaning data from records linked to and including a base Case record.
 *        Related SObjects include: Account and Contact
 */
global class BatchGDPRCleaner implements Database.Batchable<sObject>, Database.Stateful {

    Date filterClosedDate = Date.today().addYears(-1);

    /**
     * Query to get the records to work with
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        String databaseQuery = '';
        databaseQuery += 'SELECT Id, AccountId, ContactId\n';
        databaseQuery += 'FROM Case\n';
        databaseQuery += 'WHERE TestClosedDate__c < :filterClosedDate\n';
        databaseQuery += '  AND (AccountId != null OR ContactId != null)\n';

        return Database.getQueryLocator( databaseQuery );
    }

    /**
     * Logic goes here
     */
    global void execute(Database.BatchableContext bc, List<Case> queriedCases) {
        Set<Id> caseIds = (new Map<Id, Case>(queriedCases)).keySet();
        Set<Id> accountIds = new Set<Id>();
        Set<Id> contactIds = new Set<Id>();

        //  Get related Account and Contact record Ids
        for (Case caseToClean : queriedCases) {
            accountIds.add(caseToClean.AccountId);
            contactIds.add(caseToClean.ContactId);
        }

        //  Clean data
        List<Case> updatedCases = UtilityGDPRCleaner.cleanDataCases(queriedCases);
        List<Account> updatedAccounts = UtilityGDPRCleaner.cleanDataAccounts([
            SELECT Id FROM Account WHERE Id IN :accountIds
        ]);
        List<Contact> updatedContacts = UtilityGDPRCleaner.cleanDataContacts([
            SELECT Id FROM Contact WHERE Id IN :contactIds
        ]);

        //  Updating records
        List<Database.SaveResult> saveResults = Database.update(updatedCases, false);
        saveResults.addAll( Database.update(updatedAccounts, false) );
        saveResults.addAll( Database.update(updatedContacts, false) );
        System.debug(saveResults);

        //  Create additional Debug Logs
        List<Debug_Log__c> newDebugLogs = UtilityGDPRCleaner.retrieveGeneratedDebugRecords();
        for (Database.SaveResult sr : saveResults) {
            if (!sr.isSuccess()) {
                for (Database.Error dbErr : sr.getErrors()) {
                    String customErrorMessage = '';
                    customErrorMessage += 'Status Code: ' + String.valueOf(dbErr.getStatusCode()) + '\n';
                    customErrorMessage += 'Affeccted fields: ' + dbErr.getFields() + '\n';
                    customErrorMessage += 'Error Message: ' + dbErr.getMessage() + '\n';

                    newDebugLogs.add(new Debug_Log__c(
                        Class_Name__c = 'BatchGDPRCleaner',
                        Error_Message__c = customErrorMessage
                    ));
                }
            }
        }
        if (!newDebugLogs.isEmpty()) {
            insert newDebugLogs;
        }
    }

    /**
     * Reporting goes here. E.g. Sending emails, create new records to report on batch
     */
    global void finish(Database.BatchableContext bc) {
        //  Could add email notification here
    }
}