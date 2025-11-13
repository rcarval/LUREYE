public class CS_EventNotify {
    private static final String ENDPOINT        = 'https://lureye.exxiscloud.com:50000/b1s/v1/SQLQueries';
    private static final String DRAFT_TO_DOC    = 'https://lureye.exxiscloud.com:50000/b1s/v1/DraftsService_SaveDraftToDocument'; 

    public String getStatusQuote(String sQuoteId) {
        SL_Login_JSON login_c;
        String status = 'Documento Pendiente';
        
        if (!Test.isRunningTest()) {
            login_c = LUREYE_Servicios_SAP.callLogin();
        } else {
            login_c = (SL_Login_JSON) JSON.deserialize(
                '{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
                SL_Login_JSON.class
            );
        }
    
        if (login_c == null || sQuoteId == null) {
            System.debug('ERROR: Login nulo o sQuoteId nulo');
            return status;
        }
    
        Quote cot;
        try {
            cot = [SELECT Id, DocEntry__c, OVDocEntry__c, OVDocNum__c, Estado_en_SAP__c, CreatedBy.Branch__c, CodigoUN__c
                    FROM Quote
                    WHERE Opportunity.StageName IN ('Cotización', 'Propuesta', 'Negociación')
                    AND Status = 'Approved'
                    AND Estado_en_SAP__c NOT IN ('No Ingresado')
                    AND Owner.IsActive = true
                    AND CreatedDate >= 2024-01-01T00:00:00Z
                    AND Id = :sQuoteId
                    LIMIT 1];

        } catch (QueryException e) {
            System.debug('No se encontró ninguna cotización con el ID proporcionado: ' + e.getMessage());
            return status;
        }
    
        SL_EstadosQuery_JSON result = getOVDocNum(Integer.valueOf(cot.DocEntry__c), login_c);
    
        if (result != null && !result.value.isEmpty()) {
            SL_EstadosQuery_JSON.Value sl = result.value.get(0);
            System.debug(sl);
    
            // Procesamiento inicial
            status = getOnlyStatusQuote(sl.OVDocEntry, sl.CANCELED, sl.DocStatus, sl.WddStatus);
            if (!cot.Estado_en_SAP__c.equals(status)) {

                // Actualizar la cotización en Salesforce
                cot.Estado_en_SAP__c  = status;
                cot.OVDocEntry__c     = sl.OVDocEntry;
                cot.OVDocNum__c       = sl.OVDocNum;

                if (status.equals('Documento Autorizado') && !cot.CodigoUN__c.equals('GE')) {
                    Boolean ejecucion = postDraftToDocument(Integer.valueOf(cot.DocEntry__c), login_c);
                    if (ejecucion) {
                        // Segunda llamada a getOVDocNum para obtener estado actualizado
                        SL_EstadosQuery_JSON rOrdenVenta = getOVDocNum(Integer.valueOf(cot.DocEntry__c), login_c);
                        if (rOrdenVenta != null && !rOrdenVenta.value.isEmpty()) {
                            SL_EstadosQuery_JSON.Value vOV = rOrdenVenta.value.get(0);
                            status                  = 'Orden de Venta Creada';
                            cot.Estado_en_SAP__c    = 'Orden de Venta Creada';
                            cot.OVDocEntry__c       = vOV.OVDocEntry;
                            cot.OVDocNum__c         = vOV.OVDocNum;
                            System.debug('CASOMAP: ' + cot.DocEntry__c + ': OV CREADA ' + cot.OVDocNum__c);
                        } else {
                            System.debug('ERROR DRAFT: ' + cot.DocEntry__c + ': NO PUDO SER CREADA OV');
                        }
                    }
                }
                update(cot);
            }
        } else {
            System.debug('ERROR: No se recibió respuesta de SAP o ocurrió un error');
        }
        return status;
    }

    public static SL_EstadosQuery_JSON getListStatus(SL_Login_JSON login_c){
        SL_EstadosQuery_JSON result;
        if (login_c != null) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            request.setTimeout(120000);
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION=' + login_c.sessionId + '; ROUTEID=.node1');
            request.setHeader('Prefer', 'odata.maxpagesize=0'); // Para que no se limite a 20 registros
            request.setEndpoint(ENDPOINT+'(\'GetStatusDraft_ListDocEntry\')/List');
            response = http.send(request);

            if (response != null && response.getStatusCode() == 200) {
                result = SL_EstadosQuery_JSON.parse(response.getBody());
            } else if (response != null) {
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON) JSON.deserialize(response.getBody(), SL_Client_Err_JSON.class);
                System.debug('ERROR desde SAP: ' + failresp);
            }
        }
        return result;
    }

    public static SL_EstadosQuery_JSON getOVDocNum(Integer iDocEntry, SL_Login_JSON login_c) {
        SL_EstadosQuery_JSON result;
        if (login_c != null && iDocEntry != null) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            request.setTimeout(120000);
            request.setMethod('GET');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION=' + login_c.sessionId + '; ROUTEID=.node1');
            request.setEndpoint(ENDPOINT+'(\'GetStatusDraft_DocEntry\')/List?DocEntry='+iDocEntry);
            response = http.send(request);

            if (response != null && response.getStatusCode() == 200) {
                result = SL_EstadosQuery_JSON.parse(response.getBody());
            } else if (response != null) {
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON) JSON.deserialize(response.getBody(), SL_Client_Err_JSON.class);
                System.debug('ERROR desde SAP: ' + failresp);
            }
        }
        return result;
    }

    public static Boolean postDraftToDocument(Integer iDocEntry, SL_Login_JSON login_c) {
        Boolean result = false;
        System.debug('iDocEntry: '+iDocEntry+' - LOGIN: '+login_c);
        if (login_c != null && iDocEntry != null) {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            HttpResponse response;
            request.setTimeout(120000);
            request.setMethod('POST');
            request.setHeader('Accept', '*/*');
            request.setHeader('Cookie', 'B1SESSION=' + login_c.sessionId + '; ROUTEID=.node1');
            request.setEndpoint(DRAFT_TO_DOC);
            String requestBody = '{"Document":{"DocEntry":"' + iDocEntry + '"}}';
            request.setBody(requestBody);                            
            response = http.send(request);              
            if (response != null && (response.getStatusCode() == 200 || response.getStatusCode() == 204))
            {             
                result = true;              
            } else {
                System.debug('ERROR desde SAP: ' + response.getBody());                
            }
        }
        return result;
    }
    
    public static String getOnlyStatusQuote(Integer ovDocEntry, String canceled, String docStatus, String wddStatus) {
        String status = 'Documento Pendiente';
        if (ovDocEntry != null) {
            if (canceled == 'Y') {
                status = 'Orden de Venta Cancelada';
            } else {
                status = 'Orden de Venta Creada';
            }
        } else if (docStatus == 'O') {
            if (wddStatus == 'N') {
                status = 'Documento Rechazado';
            } else if (wddStatus == 'C') {
                status = 'Documento Cancelado';
            } else if (wddStatus == 'Y') {
                status = 'Documento Autorizado';
            }
        }
        return status;
    }
}