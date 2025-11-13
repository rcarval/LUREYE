public with sharing class LUREYE_Servicios_SAP {

    public static SAP__mdt login;
    public static String developerName;
    public static Integer branchCodeForTest; 

    public static SL_Login_JSON callLogin(){
        if(login == null) {
            setLogin();
        }
        return performLoginRequest();
    }

    public static SL_Login_JSON callLogin(Integer branch){
        if(login == null) {
            setLogin(branch);
        }
        return performLoginRequest();
    }

    public static void setLoginByDeveloperName(String developerNameParam) {
        developerName = developerNameParam;
        System.debug('DeveloperName***: ' + developerName);
        login = [
            SELECT CompanyDB__c, Content_Type__c, Endpoint__c, Method__c, Username__c, Password__c, InventoryParams__c
            FROM SAP__mdt WHERE DeveloperName = :developerName LIMIT 1
        ];
        System.debug('Login usuario***: ' + login.CompanyDB__c);
    }

    public static void setLogin() {
        Integer branchCode;

        if (Test.isRunningTest() && branchCodeForTest != null) {
            branchCode = branchCodeForTest;
        } else {
            String idUsuario = UserInfo.getUserId();
            User currentUser = [SELECT Branch__c FROM User WHERE Id = :idUsuario LIMIT 1];
            system.debug('Branch usuario: ' + currentUser.Branch__c);
            branchCode = Integer.valueOf(currentUser.Branch__c.intValue());
        }

        // Asignar developerName en base a branchCode
        if (branchCode == 1) {
            developerName = 'LoginGE';
        } else if (branchCode == 2) {
            developerName = 'LoginEM';
        } else {
            developerName = 'Login';
        }

        // Recuperar el registro SAP__mdt
        login = [
            SELECT CompanyDB__c, Content_Type__c, Endpoint__c, Method__c, Username__c, Password__c, InventoryParams__c
            FROM SAP__mdt WHERE developerName = :developerName LIMIT 1
        ];
        system.debug('Login usuario: ' + login.CompanyDB__c);
    }    

    public static void setLogin(Integer branch) {
        // Asignar developerName en base a Branch__c
        if (branch == 1) {
            developerName = 'LoginGE';
        } else if (branch == 2) {
            developerName = 'LoginEM';
        } else {
            developerName = 'Login';
        }

        // Recuperar el registro SAP__mdt
        login = [
            SELECT CompanyDB__c, Content_Type__c, Endpoint__c, Method__c, Username__c, Password__c, InventoryParams__c
            FROM SAP__mdt WHERE developerName = :developerName LIMIT 1
        ];
    }

    private static SL_Login_JSON performLoginRequest() {
        String body = '{"CompanyDB": "' + login.CompanyDB__c + '", "UserName": "' + login.Username__c +
                      '", "Password": "' + login.Password__c + '"}';
        system.debug('LOGIN BODY: ' + body);

        Http http = new Http();
        HttpRequest request = new HttpRequest();

        request.setTimeout(120000);
        request.setEndpoint(login.Endpoint__c + 'Login');
        request.setMethod(login.Method__c);
        request.setHeader('Content-Type', login.Content_Type__c);
        request.setHeader('Accept', '*/*');
        request.setBody(body);

        HttpResponse response;
        response = http.send(request);

        if (response.getStatusCode() == 200) {
            SL_Login_JSON resp = (SL_Login_JSON)JSON.deserialize(response.getBody(), SL_Login_JSON.class);
            system.debug('LOGIN EXITOSO');
            return resp;
        } else {
            system.debug('Response: ' + response.getBody());
            system.debug('FALLO LOGIN');
            return null;
        }
    }

    //Logout
    public static void callLogout(String sessionId){

        if (sessionId == null) {
            return;
        }
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(login.Endpoint__c+'Logout');
        request.setMethod(login.Method__c);
        request.setHeader('Content-Type', login.Content_Type__c);
        request.setHeader('Cookie', 'B1SESSION='+sessionId+'; ROUTEID=.node1');
        if (sessionId!=null){
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 204){
                system.debug('LOGOUT EXITOSO');
            }else{
                system.debug('FALLO LOGOUT');
            }
        }
    }

    //Flujo de creación de clientes en la unidad de crédito
    public static SL_Client_JSON ConsultaClienteSAP(String RutCode) {
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

    //Flujo de creación de clientes en la unidad de crédito SAPSF
    public static SL_Client_JSON CrearClienteSFSAP(String Body) {
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
            request.setEndpoint(login.Endpoint__c+'BusinessPartners');
            request.setMethod('POST');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
            request.setHeader('Content-Type', 'application/json');

            request.setBody(Body);
            //System.debug('request: ' +request);
            response = http.send(request);      
            
            if(response.getStatusCode() == 201){
                //System.debug('Respuesta exitosa: '+response.getBody());
                system.debug('CUENTA CREADA EN SAP');
                SL_Client_JSON resp = (SL_Client_JSON)JSON.deserialize(response.getBody(),SL_Client_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                system.debug('FALLO LA CREACION DE CLIENTE');
                system.debug('Mensaje desde SAP: '+failresp);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return null;
            }
        }
        return null;
    } 

    //Estado de bloqueo del cliente
    public static String ClienteExistente(String Body, String RutCode) {
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
            //system.debug('Endpoint'+login.Endpoint__c+'BusinessPartners');
            request.setMethod('PATCH');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
            request.setHeader('Content-Type', 'application/json');

            request.setBody(Body);
            System.debug('Body: ' +Body);
            response = http.send(request);      
            
            if(response.getStatusCode() == 204){
                //System.debug('Respuesta exitosa: '+response.getBody());
                system.debug('CUENTA ACTUALIZADA EN SAP');
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return 'CUENTA ACTUALIZADA EN SAP';
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                system.debug('FALLO LA ACTUALIZACIÓN DE CLIENTE');
                system.debug('Mensaje desde SAP: '+failresp);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return null;
            }
        }
        return null;
    } 

    //Lista de precios base
    public static SL_Price_List_JSON ListaPrecios() {
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        if(login_c!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            request.setEndpoint(login.Endpoint__c+'PriceLists');
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            //request.setBody(Body);
            //System.debug('request: ' +request);
            response = http.send(request);
            
            if(response.getStatusCode() == 200){
                //System.debug('Respuesta exitosa: '+response.getBody());
                System.debug('Respuesta exitosa ');
                SL_Price_List_JSON resp = (SL_Price_List_JSON)JSON.deserialize(response.getBody(),SL_Price_List_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                system.debug('FALLO LA ACTUALIZACIÓN DE LAS LISTAS DE PRECIOS');
                system.debug('Mensaje desde SAP: '+failresp);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return null;
            }
        }
        return null;
    }

    //Entrada de Lista de precios base 
    public static SL_Price_List_Items_JSON ListaPreciosItems() {
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
            request.setEndpoint(login.Endpoint__c+'SQLQueries(\'ListaPrecioItems3\')/List?ListNum=1');
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            //request.setBody(Body);
            //System.debug('request: ' +request);
            response = http.send(request);
            
            if(response.getStatusCode() == 200){
                //System.debug('Respuesta exitosa: '+response.getBody());
                System.debug('Respuesta exitosa ');
                bodyjson = response.getBody().replace('"Currency"', '"Currencys"');
                SL_Price_List_Items_JSON resp = (SL_Price_List_Items_JSON)JSON.deserialize(bodyjson,SL_Price_List_Items_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                system.debug('FALLO LA ACTUALIZACIÓN DE LAS ENTRADAS DE LISTAS DE PRECIOS');
                system.debug('Mensaje desde SAP: '+failresp);
                return null;
            }
        }
        return null;
    }

    //Stock disponible para la venta, desde SAP incluye el on hand + en transito
    public static SL_Inventory_JSON InventarioDisponible(String idProd) {
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
            request.setEndpoint(login.Endpoint__c + login.InventoryParams__c+'\''+idProd+'\'');
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
            request.setHeader('Content-Type', 'application/json');
            
            system.debug('request '+request);
            response = http.send(request);      
            
            if(response.getStatusCode() == 200){

                System.debug('Respuesta exitosa: '+response.getBody());
                bodyjson = response.getBody().replace('"Items/ItemWarehouseInfoCollection"', '"itemsitemwarehouseinfocollection"');
                SL_Inventory_JSON resp = (SL_Inventory_JSON)JSON.deserialize(bodyjson,SL_Inventory_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                system.debug(response.getBody());
                
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                system.debug('FALLO LA OBTENCIÓN DE LOS DATOS DE INVENTARIO');
                system.debug('Mensaje desde SAP: '+failresp);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return null;
            }
        }
        return null;
    }

    //Crear nota de venta en el ERP que entre en el ciclo natural de ventas definido en SAP Business One.
    public static SL_Drafts_JSON CreaDrafts(String Body) { 
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        
        if(login_c==null){
            return null;
        }

        system.debug('BODY: '+Body);
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        HttpResponse response = new HttpResponse();
        request.setTimeout(120000);
        request.setEndpoint(login.Endpoint__c+'Orders');
        request.setMethod('POST');
        request.setHeader('Accept', '*/*');
        request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
    
        request.setBody(Body);
        System.debug('REQ Crear Draft: ' +request);
        response = http.send(request);
        
        if(response.getStatusCode() == 404){
            System.debug('Respuesta exitosa: '+response.getBody());
            System.debug('Respuesta exitosa ');
            //SL_Drafts_JSON resp = (SL_Drafts_JSON)JSON.deserialize(response.getBody(),SL_Drafts_JSON.class);
            LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
            return null;
            //return resp;
        }else{
            SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
            LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
            system.debug('FALLO LA CREACIÓN DE LA ORDEN DE VENTA');
            system.debug('Mensaje desde SAP: '+failresp);
        }
        return null;
    }

    //Obtiene el numero del Draft en SAP.
    public static SL_Drafts_JSON GetDocEntryDrafts(String CotId) { 
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        if(login_c!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            //request.setEndpoint(login.Endpoint__c+'Drafts?$filter=Comments%20eq%20\'SF:'+CotId+'\'');
            request.setEndpoint(login.Endpoint__c + 'Drafts?$select=DocEntry&$filter=contains(Comments,\'SF:' + CotId + '\')%20or%20contains(U_IDCajaHisto,\'SF:' + CotId + '\')');

            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            //request.setBody(Body);
            System.debug('REQUEST: ' +request);
            response = http.send(request);
            
            if(response.getStatusCode() == 200){
                System.debug('Respuesta exitosa: '+response.getBody());
                System.debug('Respuesta exitosa ');
                SL_Drafts_JSON resp = (SL_Drafts_JSON)JSON.deserialize(response.getBody(),SL_Drafts_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                system.debug('FALLO LA CONSULTA DE LA ORDEN DE VENTA');
                system.debug('Mensaje desde SAP: '+failresp);
                return null;
            }
        }
        return null;
    }

     // Obtiene el numero del Documento en SAP.
     public static SL_Drafts_JSON GetDocEntryQuote(String idQuote) { 
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        if(login_c!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            //request.setEndpoint(login.Endpoint__c+'Orders?$filter=Comments%20eq%20\'SF:'+idQuote+'\'');
            request.setEndpoint(login.Endpoint__c+'Orders?$filter=contains(Comments,\'SF:\'+\''+idQuote+'\')%20or%20contains(U_IDCajaHisto,\'SF:\'+\''+idQuote+'\')');

            System.debug('ENDPOINT: '+request.getEndpoint());
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            //request.setBody(Body);
            System.debug('request: ' +request);
            response = http.send(request);
            
            if(response.getStatusCode() == 200){
                System.debug('Respuesta exitosa: '+response.getBody());
                System.debug('Respuesta exitosa ');
                SL_Drafts_JSON resp = (SL_Drafts_JSON)JSON.deserialize(response.getBody(),SL_Drafts_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                system.debug('FALLO LA CONSULTA DE LA ORDEN DE VENTA');
                system.debug('Mensaje desde SAP: '+failresp);
                return null;
            }
        }
        return null;
    }

    //Campos del detalle de la Orden de Venta
    public static SL_Drafts_JSON CreaOV(String Body) {
        SL_Login_JSON login_c = new SL_Login_JSON();
        if(!Test.isRunningTest()){
            login_c = LUREYE_Servicios_SAP.callLogin();
        }else{
            login_c = (SL_Login_JSON)JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',SL_Login_JSON.class);
        }
        if(login_c!=null){
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response = new HttpResponse();
            request.setTimeout(120000);
            request.setEndpoint(login.Endpoint__c+'Orders');
            request.setMethod('POST');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION='+login_c.sessionId+'; ROUTEID=.node1');
        
            request.setBody(Body);
            System.debug('request: ' +request);
            response = http.send(request);
            
            
            if(response.getStatusCode() == 201){
                //System.debug('Respuesta exitosa: '+response.getBody());
                System.debug('Respuesta exitosa ');
                SL_Drafts_JSON resp = (SL_Drafts_JSON)JSON.deserialize(response.getBody(),SL_Drafts_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return resp;
            }else{
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(response.getBody(),SL_Client_Err_JSON.class);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                system.debug('FALLO LA CREACIÓN DE LA ORDEN DE VENTA');
                system.debug('Mensaje desde SAP: '+failresp);
                return null;
            }
        }
        return null;
    }
}