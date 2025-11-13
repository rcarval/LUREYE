global class LUREYE_ElectroMC_SAP_Products_Synch_Sch implements Schedulable {

    global void execute(SchedulableContext sc) {
        LUREYE_ElectroMC_SAP_Products_Synch.syncProductsWithSAP();
    }

}