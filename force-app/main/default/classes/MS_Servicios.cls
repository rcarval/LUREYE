public with sharing class MS_Servicios {
    
/**
  * @author MindShore 
  * @description Método que Obtiene el nodo del Producto a través del codigo  
  * @param codigoProducto
  */
 public static String obtenerNodoProducto(String codigoProducto)
 {
     String nodoProducto = null;
     SL_Login_JSON loginJson = new SL_Login_JSON();
     SAP__mdt loginSAP = new SAP__mdt();
     if(!Test.isRunningTest())
     {
        loginJson = LUREYE_Servicios_SAP.callLogin();
     }else
     {
        loginJson = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
     }
     if(loginJson!=null)
     { 
        loginSAP = LUREYE_Servicios_SAP.login;
         Http http = new Http();
         HttpRequest request = new HttpRequest();
         HttpResponse response = new HttpResponse();
         request.setTimeout(120000);
         request.setEndpoint(loginSAP.Endpoint__c +'Items(\''+ codigoProducto + '\')');
         request.setMethod('GET');
         request.setHeader('Accept', '*/*');
         request.setHeader('Cookie', 'B1SESSION='+loginJson.sessionId+'; ROUTEID=.node1');
         response = http.send(request);

         if (response.getStatusCode()== 200) {
             System.debug('Respuesta exitosa ');
             Map<String, Object> responseMap = (Map<String, Object>) Json.deserializeUntyped(response.getBody()); 
             nodoProducto = responseMap.get('U_PoNo') != null ? (String)responseMap.get('U_PoNo'): null;
             LUREYE_Servicios_SAP.callLogout(loginJson.sessionId);
         }else {
             SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
             LUREYE_Servicios_SAP.callLogout(loginJson.sessionId);
             system.debug('Error al obtener los datos del producto');
             system.debug('Mensaje desde SAP: '+failresp);
             return null; 
         }
     }

     return nodoProducto; 

 }
    
    
    public static void consultaProductos(String fecha) {
        
        SL_Login_JSON loginJson = new SL_Login_JSON();
        //Obtener datos de Metadata
        SAP__mdt loginSAP = new SAP__mdt();
        if(!Test.isRunningTest()) {
            loginJson = LUREYE_Servicios_SAP.callLogin();
        } else {
            loginJson = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        
        if(loginJson!=null){ 
            loginSAP = LUREYE_Servicios_SAP.login;
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            request.setEndpoint(loginSAP.Endpoint__c+'/Items?$select=Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_Categoria,Manufacturer,U_FamCod2&$filter='+EncodingUtil.urlEncode('UpdateDate gt \''+fecha+'\'', 'UTF-8'));
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+loginJson.sessionId+'; ROUTEID=.node1');
            response = http.send(request);
            System.debug('req->'+request.getEndpoint());
            if (response.getStatusCode()== 200) {
                System.debug('Respuesta exitosa ');
                System.debug(response.getBody()); 
                LUREYE_Servicios_SAP.callLogout(loginJson.sessionId);
            }else {
                system.debug('Error al obtener los datos del producto');
                system.debug('response.getBody(): '+response.getBody());
                // return null; 
            }
        }
        
        
        
    }


}