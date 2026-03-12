/**
 * @description Queueable class to handle notification request creation in async mode.
 * @author Mohamed Abdul Kadher N
 * @date 06/02/2025
 *
 * Version    Date          Author                 Description
 * 1.0        06/02/2025    Mohamed Abdul Kadher   Initial version
 * 2.0        22/01/2026    Roopan Thangam A       RT 22JAN26 - Code optimised
 */
public with sharing class NotificationQueueableHandler implements Queueable {

    private final List<SObject> records;
    private final Set<Id> configIds;

    /**
     * @description Constructor to initialize queueable with records and config IDs
     * @param records List of SObjects to process
     * @param configIds Set of configuration IDs to apply
     */
    public NotificationQueueableHandler(List<SObject> records, Set<Id> configIds) {
        this.records = records;
        this.configIds = configIds;
    }

    /**
     * @description Execute method called by the Queueable framework
     * @param context QueueableContext provided by the system
     */
    public void execute(QueueableContext context) {
        NotificationProcessHandler.processRecords(this.records, this.configIds);
    }
}