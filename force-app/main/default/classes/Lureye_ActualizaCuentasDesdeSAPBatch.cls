global class Lureye_ActualizaCuentasDesdeSAPBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Schedulable{
    
    global Database.QueryLocator start(Database.BatchableContext info){ 
        String query=' SELECT  Id, CondicionPago__c, ParentId, Description, ShippingAddress, Condici_n_de_pago_EM__c,' +
                            ' BillingAddress, NumberOfEmployees, Fax, Giro__c, Industry,Name, ' +
                            ' Ownership,RUT_SD__c, Website, Phone, Type, CardType__c, GroupCode__c, ' +
                            ' CreditLine__c, DebtLine__c, SlpCode__c, CurrencyIsoCode, Country__c, NombreFantasia__c, ' +
                            ' BlockComm__c, RUT_DV__c, Email__c,EstadoSAP__c ' +
                    ' FROM    Account ' +
                    ' WHERE RUT_SD__c != null ';    
        System.debug('query->' + query);
        return Database.getQueryLocator(query); 
    }     

    //Ejecuta por lotes
    global void execute(Database.BatchableContext info, List<Account> scope){
        List<Account> listaUpd = new List<Account>();
        for(Account acc : scope){
            Boolean flag = false;
            //electromecanica
            SL_Client_JSON clienteSAP = ConsultaClienteSAP(String.valueof(acc.RUT_SD__c), 'loginEM');
            if(clienteSAP != null && clienteSAP.paytermsgrpcode != null){
                if(acc.Condici_n_de_pago_EM__c != LUREYE_SAP_Controller.switchIntCondition(clienteSAP.paytermsgrpcode)){
                    acc.Condici_n_de_pago_EM__c  = LUREYE_SAP_Controller.switchIntCondition(clienteSAP.paytermsgrpcode);
                    flag = true;
                }               
            }
            //Generacion
            clienteSAP = ConsultaClienteSAP(String.valueof(acc.RUT_SD__c), 'loginGE');
            if(clienteSAP != null && clienteSAP.paytermsgrpcode != null){
                if(acc.CondicionPago__c != LUREYE_SAP_Controller.switchIntCondition(clienteSAP.paytermsgrpcode)){
                    acc.CondicionPago__c  = LUREYE_SAP_Controller.switchIntCondition(clienteSAP.paytermsgrpcode);
                    flag = true;
                }               
            }
            if(flag){
                listaUpd.add(acc);
            }            
        }   
        if(listaUpd!= null && listaUpd.size() > 0){
            update listaUpd;
        }
    }

    global void finish(Database.BatchableContext info){     
    	System.debug('fin');
    }
    
    //Flujo de creación de clientes en la unidad de crédito
    public static SL_Client_JSON ConsultaClienteSAP(String RutCode, String negocio) {
        SAP__mdt login = SAP__mdt.getInstance(negocio);
        
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        if(login_c!=null){
            String bodyjson =null;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            request.setEndpoint(login.Endpoint__c+'BusinessPartners(\'C'+RutCode+'\')');
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            //System.debug('request: ' +request);
            response = http.send(request);      
            
            if(response.getStatusCode() == 200){
                //System.debug('Respuesta exitosa: '+response.getBody());
                system.debug('CLIENTE EXISTE');
                bodyjson = response.getBody().replace('"Currency"', '"Currencys"');
                SL_Client_JSON resp = (SL_Client_JSON)JSON.deserialize(bodyjson,SL_Client_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                system.debug('CLIENTE NO EXISTE');
                system.debug('Mensaje desde SAP: '+failresp);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return null;
            }
        }
        return null;
    } 
    
    global void execute(SchedulableContext sc) {
        Lureye_ActualizaCuentasDesdeSAPBatch b = new Lureye_ActualizaCuentasDesdeSAPBatch();
        Id batchId2 = Database.executeBatch(b,1);
    }

}