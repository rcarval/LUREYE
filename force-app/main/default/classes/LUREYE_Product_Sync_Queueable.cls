public class LUREYE_Product_Sync_Queueable implements Queueable, Database.AllowsCallouts {
    private String sapLoginDeveloperName;
    private Integer diasMenos;
    
    public LUREYE_Product_Sync_Queueable(String developerName, Integer dias) {
        this.sapLoginDeveloperName = developerName;
        this.diasMenos = dias;
    }
    
    public void execute(QueueableContext context) {
        System.debug('🎯 Ejecutando Queueable para: ' + sapLoginDeveloperName + ' - ' + DateTime.now());
        
        try {
            // Llamar a tu clase existente SIN modificaciones
            List<LUREYE_Product_Synch_from_SAP.Input> entradas = new List<LUREYE_Product_Synch_from_SAP.Input>();
            LUREYE_Product_Synch_from_SAP.Input entrada = new LUREYE_Product_Synch_from_SAP.Input();
            entrada.sapLoginDeveloperName = this.sapLoginDeveloperName;
            entrada.diasMenos = this.diasMenos;
            entradas.add(entrada);
            
            List<String> resultado = LUREYE_Product_Synch_from_SAP.syncProductsWithSAP(entradas);
            System.debug('✅ Queueable completado para ' + sapLoginDeveloperName + ': ' + resultado);
            
        } catch (Exception e) {
            System.debug('⛔❌ Error en Queueable: ' + e.getMessage());
            System.debug('⛔❌ Stack Trace: ' + e.getStackTraceString());
        }
    }
}