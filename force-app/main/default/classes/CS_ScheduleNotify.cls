global class CS_ScheduleNotify implements Schedulable {
    private Integer branchId;
    public CS_ScheduleNotify(Integer branchId) {
        this.branchId = branchId;
    }

    global void execute(SchedulableContext sc) {
        CS_EventNotifyBatch batchJob = new CS_EventNotifyBatch(this.branchId);
        Database.executeBatch(batchJob, 500);
    }

    public static void scheduleNotify() {
        System.schedule('Actualización de Estados GEN 00', '0 0 * * * ?',  new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 05', '0 5 * * * ?',  new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 10', '0 10 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 15', '0 15 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 20', '0 20 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 25', '0 25 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 30', '0 30 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 35', '0 35 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 40', '0 40 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 45', '0 45 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 50', '0 50 * * * ?', new CS_ScheduleNotify(1));
        System.schedule('Actualización de Estados GEN 55', '0 55 * * * ?', new CS_ScheduleNotify(1));


        System.schedule('Actualización de Estados ELE 00', '0 0 * * * ?',  new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 05', '0 5 * * * ?',  new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 10', '0 10 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 15', '0 15 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 20', '0 20 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 25', '0 25 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 30', '0 30 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 35', '0 35 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 40', '0 40 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 45', '0 45 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 50', '0 50 * * * ?', new CS_ScheduleNotify(2));
        System.schedule('Actualización de Estados ELE 55', '0 55 * * * ?', new CS_ScheduleNotify(2));
    }
}