public class CS_BatchDraft {

    private static final String ENDPOINT = 'https://lureye.exxiscloud.com:50000/b1s/v1';
    
    //Enviare 1 si esta OK y 0 si no funciono
    public static integer createSequential(String attachmentJsonBody, String draftJsonBody) {
        SL_Login_JSON login_c = new SL_Login_JSON();
        if (!Test.isRunningTest()) {
            login_c = LUREYE_Servicios_SAP.callLogin();            
        } else {
            login_c = (SL_Login_JSON) JSON.deserialize('{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}', SL_Login_JSON.class);
        }
    
        if (login_c != null) {
            // Crear la primera llamada HTTP solo si hay attachmentJsonBody
            Integer absoluteEntry = null;
            if (attachmentJsonBody != null) {
                String attachmentEndpoint = ENDPOINT + '/Attachments2';
                HttpRequest attachmentRequest = buildHttpRequest(attachmentEndpoint, attachmentJsonBody, login_c.sessionId);
                HttpResponse attachmentResponse = sendHttpRequest(attachmentRequest);
    
                // Tomar la respuesta de la primera llamada HTTP y usarla para construir la segunda llamada HTTP, que actualiza un Draft con el 'AbsoluteEntry' del archivo adjunto
                absoluteEntry = parseAttachmentAbsoluteEntry(attachmentResponse.getBody());
                System.debug('ADJUNTOS ENVIADOS: ' + attachmentResponse.getBody());
            }
    
            // Actualizar el JSON del Draft con el 'AbsoluteEntry' del archivo adjunto si existe
            String updatedDraftJsonBody = draftJsonBody;
            if (absoluteEntry != null) {
                updatedDraftJsonBody = updateDraftWithAttachment(draftJsonBody, absoluteEntry);
            }
    
            // Crear la segunda llamada HTTP para actualizar el Draft con el 'AbsoluteEntry' del archivo adjunto o sin él
            //String draftEndpoint = ENDPOINT + '/Quotations';
            String draftEndpoint = ENDPOINT + '/Orders';
            HttpRequest draftRequest = buildHttpRequest(draftEndpoint, updatedDraftJsonBody, login_c.sessionId);
            HttpResponse draftResponse = sendHttpRequest(draftRequest);
            System.debug('Draft Endpoint: ' + draftEndpoint);
            System.debug('Draft JsonBody: ' + updatedDraftJsonBody);
            System.debug('Draft Request: ' + draftRequest);
            System.debug('Draft Status: ' + draftResponse.getStatusCode());
            if (draftResponse.getStatusCode() == 201 || draftResponse.getStatusCode() == 404) {
                System.debug('body Resp->'+draftResponse.getBody());
                System.debug('DRAFT CREADO ');                
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return 1;
            } else {
                SL_Client_Err_JSON failresp = (SL_Client_Err_JSON)JSON.deserialize(draftResponse.getBody(),SL_Client_Err_JSON.class);
                system.debug('FALLO LA CREACIÓN DEL DRAFT');
                system.debug('Mensaje desde SAP: ' + failresp.error);
                LUREYE_Servicios_SAP.callLogout(login_c.sessionId);
                return 0;
            }
        }
        return 0;
    }

    private static Integer parseAttachmentAbsoluteEntry(String responseBody) {
        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
        return (Integer)responseMap.get('AbsoluteEntry');
    }
    
    private static String updateDraftWithAttachment(String draftJsonBody, Integer absoluteEntry) {
        Map<String, Object> draftMap = (Map<String, Object>)JSON.deserializeUntyped(draftJsonBody);
        draftMap.put('AttachmentEntry', absoluteEntry);
        String updatedBusinessObjectJsonBody = JSON.serialize(draftMap);
        return updatedBusinessObjectJsonBody;
    }

    private static HttpRequest buildHttpRequest(String endpoint, String requestBody, String sessionId) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Accept', '*/*');
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Content-Length', String.valueOf(requestBody.length()));
        request.setHeader('Cookie', 'B1SESSION=' + sessionId + '; ROUTEID=.node1');
        request.setBody(requestBody);
        return request;
    }

    private static HttpResponse sendHttpRequest(HttpRequest request) {
        Http http = new Http();
        HttpResponse response = http.send(request);
        return response;
    }           
}