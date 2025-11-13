global class LUREYE_EM_Product_Sync_from_SAP_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        System.debug('🚀 Iniciando job programado EM - ' + DateTime.now());
        
        // Encolar el trabajo real que necesita callouts
        System.enqueueJob(new LUREYE_Product_Sync_Queueable('LoginEM', -2));
    }
}