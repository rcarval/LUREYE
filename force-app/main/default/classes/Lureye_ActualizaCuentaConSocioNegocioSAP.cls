public class Lureye_ActualizaCuentaConSocioNegocioSAP {
    
    @InvocableMethod
    public static void actualizarCondicionPagoCuenta(List<Id> ListIdCuenta){
        String idUsuario = UserInfo.getUserId();
        User currentUser = [SELECT Branch__c FROM User WHERE Id = :idUsuario LIMIT 1];
        system.debug('Branch usuario: ' + currentUser.Branch__c);
        integer branchCode = Integer.valueOf(currentUser.Branch__c.intValue());
        
        System.debug(ListIdCuenta);
        List<Account> listaCuentasUPD = new List<Account>();
        for(Id idCuenta: ListIdCuenta){
            Account acc = LUREYE_SAP_Controller.queryAccount(idCuenta);
            System.debug('CUenta->'+acc);
            if(acc != null){
                SL_Client_JSON socioNegocio = obtenerSocioNegocioSAP(acc);
                System.debug('socioNegocio->'+socioNegocio);
                if(socioNegocio != null){
                    List<Account> listaCuentas = obtenerCuentaUDP(acc, socioNegocio.paytermsgrpcode, branchCode);
                    System.debug('listaCuentas->'+listaCuentas);
                    if(listaCuentas != null && listaCuentas.size()>0){
                        listaCuentasUPD.addAll(listaCuentas);
                    }
                }
            }
        }

        if(listaCuentasUPD != null && listaCuentasUPD.size() > 0){
            System.debug('listaCuentasUPD->'+listaCuentasUPD);
            update listaCuentasUPD;
        }
    }
    
    public static SL_Client_JSON obtenerSocioNegocioSAP(Account acc){
        SL_Client_JSON socioNegocio = LUREYE_Servicios_SAP.ConsultaClienteSAP(String.valueof(acc.RUT_SD__c));
        return socioNegocio;
    }
    
    private static List<Account> obtenerCuentaUDP(Account acc, Integer condicionPago, integer branchCode){
        List<Account> listaCuentasUPD = new List<Account>();
        System.debug('acc.CondicionPago__c->'+acc.CondicionPago__c);
        System.debug('LUREYE_SAP_Controller.switchIntCondition(condicionPago)->'+LUREYE_SAP_Controller.switchIntCondition(condicionPago));
        
        if(branchCode == 1 && acc.CondicionPago__c != LUREYE_SAP_Controller.switchIntCondition(condicionPago)){
            acc.CondicionPago__c = LUREYE_SAP_Controller.switchIntCondition(condicionPago);
            listaCuentasUPD.add(acc);
        } else if(branchCode == 2 && acc.Condici_n_de_pago_EM__c != LUREYE_SAP_Controller.switchIntCondition(condicionPago) ) {
            acc.Condici_n_de_pago_EM__c  = LUREYE_SAP_Controller.switchIntCondition(condicionPago);
            listaCuentasUPD.add(acc);
        }	
                           
        return listaCuentasUPD;
    }
    
}