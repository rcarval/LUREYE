global class LUREYE_Product_Synch_from_SAP_Schedule implements Schedulable {

    global void execute(SchedulableContext sc) {
        LUREYE_Product_Synch_from_SAP.syncProductsWithSAP('LoginGE');
    }

}