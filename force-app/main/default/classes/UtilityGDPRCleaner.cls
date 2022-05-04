/**
 * Class: UtilityGDPRCleaner.cls
 * Test: UtilityGDPRCleanerTest.cls
 */
public without sharing class UtilityGDPRCleaner {

    private static List<Debug_Log__c> newDebugLogs;
    private final static String CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890';
    @TestVisible
    private static Map<String, String> metadataFieldsAccount;
    @TestVisible
    private static Map<String, String> metadataFieldsCase;
    @TestVisible
    private static Map<String, String> metadataFieldsContact;

    /**
     * Returns all generated Debug Log records
     */
    public static List<Debug_Log__c> retrieveGeneratedDebugRecords() {
        if (newDebugLogs == null) {
            newDebugLogs = new List<Debug_Log__c>();
        }
        return newDebugLogs;
    }

    /**
     * Create a basic Debug Log record
     */
    public static Debug_Log__c createBaseDebugLog(String className, Id recordId) {
        return new Debug_Log__c(
            Class_Name__c = className,
            Related_Record_Id__c = String.valueOf(recordId),
            Error_Message__c = '',
            Stack_Trace__c = ''
        );
    }

    /**
     * Cleans accounts and catches any errors
     */
    public static List<Account> cleanDataAccounts(List<Account> accountsToClean) {
        if (accountsToClean == null || accountsToClean.isEmpty()) {
            return new List<Account>();
        }
        if (newDebugLogs == null) {
            newDebugLogs = new List<Debug_Log__c>();
        }
        if (metadataFieldsAccount == null) {
            metadataFieldsAccount = getMDTFieldsAccount();
        }

        for (Account toClean : accountsToClean) {
            Debug_Log__c debugLog = new Debug_Log__c();
            for (String fieldName : metadataFieldsAccount.keySet()) {
                try {
                    if (metadataFieldsAccount.get(fieldName) == 'Lookup') {
                        toClean.put(fieldName, null);
                    } else if (metadataFieldsAccount.get(fieldName) == 'Text') {
                        toClean.put(fieldName, randString());
                    } else if (metadataFieldsAccount.get(fieldName) == 'Number') {
                        toClean.put(fieldName, randNumber());
                    } else {
                        //  Debug Log
                        if (debugLog.Related_Record_Id__c == null) {
                            debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                        }
                        debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    }
                } catch (Exception e) {
                    //  Debug Log
                    if (debugLog.Related_Record_Id__c == null) {
                        debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                    }
                    if (!debugLog.Error_Message__c.contains('An exception was raised.')) {
                        debugLog.Error_Message__c += 'An exception was raised. \n';
                    }
                    debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    debugLog.Stack_Trace__c += e.getStackTraceString() + '\n';
                }
            }

            if (debugLog.Related_Record_Id__c != null) {
                newDebugLogs.add(debugLog);
            }
        }

        return accountsToClean;
    }

    /**
     * Cleans cases and catches any errors
     */
    public static List<Case> cleanDataCases(List<Case> casesToClean) {
        if (casesToClean == null || casesToClean.isEmpty()) {
            return new List<Case>();
        }
        if (newDebugLogs == null) {
            newDebugLogs = new List<Debug_Log__c>();
        }
        if (metadataFieldsCase == null) {
            metadataFieldsCase = getMDTFieldsCase();
        }

        for (Case toClean : casesToClean) {
            Debug_Log__c debugLog = new Debug_Log__c();
            for (String fieldName : metadataFieldsCase.keySet()) {
                try {
                    if (metadataFieldsCase.get(fieldName) == 'Lookup') {
                        toClean.put(fieldName, null);
                    } else if (metadataFieldsCase.get(fieldName) == 'Text') {
                        toClean.put(fieldName, randString());
                    } else if (metadataFieldsCase.get(fieldName) == 'Number') {
                        toClean.put(fieldName, randNumber());
                    } else {
                        //  Debug Log
                        if (debugLog.Related_Record_Id__c == null) {
                            debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                        }
                        debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    }
                } catch (Exception e) {
                    //  Debug Log
                    if (debugLog.Related_Record_Id__c == null) {
                        debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                    }
                    if (!debugLog.Error_Message__c.contains('An exception was raised.')) {
                        debugLog.Error_Message__c += 'An exception was raised. \n';
                    }
                    debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    debugLog.Stack_Trace__c += e.getStackTraceString() + '\n';
                }
            }

            //  If the related record id field is null, the cleaning was successful
            if (debugLog.Related_Record_Id__c == null) {
                toClean.GDPR_Cleaned__c = true;
            } else {
                newDebugLogs.add(debugLog);
            }
        }

        return casesToClean;
    }

    /**
     * Cleans contacts and catches any errors
     */
    public static List<Contact> cleanDataContacts(List<Contact> contactsToClean) {
        if (contactsToClean == null || contactsToClean.isEmpty()) {
            return new List<Contact>();
        }
        if (newDebugLogs == null) {
            newDebugLogs = new List<Debug_Log__c>();
        }
        if (metadataFieldsContact == null) {
            metadataFieldsContact = getMDTFieldsContact();
        }

        for (Contact toClean : contactsToClean) {
            Debug_Log__c debugLog = new Debug_Log__c();
            for (String fieldName : metadataFieldsContact.keySet()) {
                try {
                    if (metadataFieldsContact.get(fieldName) == 'Lookup') {
                        toClean.put(fieldName, null);
                    } else if (metadataFieldsContact.get(fieldName) == 'Text') {
                        toClean.put(fieldName, randString());
                    } else if (metadataFieldsContact.get(fieldName) == 'Number') {
                        toClean.put(fieldName, randNumber());
                    } else {
                        //  Debug Log
                        if (debugLog.Related_Record_Id__c == null) {
                            debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                        }
                        debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    }
                } catch (Exception e) {
                    //  Debug Log
                    if (debugLog.Related_Record_Id__c == null) {
                        debugLog = createBaseDebugLog('UtilityGDPRCleaner', toClean.Id);
                    }
                    if (!debugLog.Error_Message__c.contains('An exception was raised.')) {
                        debugLog.Error_Message__c += 'An exception was raised. \n';
                    }
                    debugLog.Error_Message__c += 'Field: ' + fieldName + '\'s type is invalid. ';
                    debugLog.Stack_Trace__c += e.getStackTraceString() + '\n';
                }
            }

            if (debugLog.Related_Record_Id__c != null) {
                newDebugLogs.add(debugLog);
            }
        }

        return contactsToClean;
    }

    /**
     * Create map of field name to type for Account metadata to use for data cleaning
     */
    @TestVisible
    private static Map<String, String> getMDTFieldsAccount() {
        List<GDPR_Account_Field__mdt> metadataRecords = [
            SELECT Field_Name__c, Field_Type__c
            FROM GDPR_Account_Field__mdt
        ];

        Map<String, String> fieldsAccount = new Map<String, String>();

        for (GDPR_Account_Field__mdt mdt : metadataRecords) {
            fieldsAccount.put(mdt.Field_Name__c, mdt.Field_Type__c);
        }

        return fieldsAccount;
    }

    /**
     * Create map of field name to type for Case metadata to use for data cleaning
     */
    @TestVisible
    private static Map<String, String> getMDTFieldsCase() {
        List<GDPR_Case_Field__mdt> metadataRecords = [
            SELECT Field_Name__c, Field_Type__c
            FROM GDPR_Case_Field__mdt
        ];

        Map<String, String> fieldsCase = new Map<String, String>();

        for (GDPR_Case_Field__mdt mdt : metadataRecords) {
            fieldsCase.put(mdt.Field_Name__c, mdt.Field_Type__c);
        }

        return fieldsCase;
    }

    /**
     * Create map of field name to type for Contact metadata to use for data cleaning
     */
    @TestVisible
    private static Map<String, String> getMDTFieldsContact() {
        List<GDPR_Contact_Field__mdt> metadataRecords = [
            SELECT Field_Name__c, Field_Type__c
            FROM GDPR_Contact_Field__mdt
        ];

        Map<String, String> fieldsContact = new Map<String, String>();

        for (GDPR_Contact_Field__mdt mdt : metadataRecords) {
            fieldsContact.put(mdt.Field_Name__c, mdt.Field_Type__c);
        }

        return fieldsContact;
    }

    /**
     * Create a random string of length 50
     */
    @TestVisible
    private static String randString() {
        String randStr = '';
        while (randStr.length() < 25) {
            Integer strIndex = Math.mod(Math.abs(Crypto.getRandomInteger()), CHARS.length());
            randStr += CHARS.substring(strIndex, strIndex + 1);
        }
        return randStr;
    }

    /**
     * Create random number with 10 integers on the left of the decimal point
     */
    @TestVisible
    private static Decimal randNumber() {
        return Math.random() * 10;
    }
}