public with sharing class CS_GoogleDrive {
    public String access_token;
    private String client_id;
    private String client_secret;
    public String refresh_token;
    private String scope;
    public DateTime access_token_expiration;
    public String grant_type;

    public void setAccessToken(String token) {
        access_token = token;
    }    
    
    public CS_GoogleDrive() {
        
        // Inicializar los datos de autenticación
        Credenciales_Google__mdt metadato = Credenciales_Google__mdt.getInstance('Google_Drive');

        access_token  = null;
        client_id     = metadato.client_id__c;//'641965646308-asrpfqhgglr215f38hasv2aimp76croo.apps.googleusercontent.com';
        client_secret = metadato.client_secret__c;//'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';
        refresh_token = metadato.refresh_token__c;//'1//04_K-EeDTHajeCgYIARAAGAQSNwF-L9IrgGYvp26MCDpUUsJr-MGFR4p0aHV4CIU_4QTPfypK_R8QurXpI_rjGQvWcUs3IlO4nYA';
        scope         = metadato.scope__c;//'https://www.googleapis.com/auth/drive';
        grant_type    = metadato.grant_type__c;
        access_token_expiration = null;
    }

    @TestVisible
    private CS_GoogleDrive(String testAccessToken) {
        this.access_Token = testAccessToken;
    }    

    public void login() {
        System.debug('LOGIN GDrive');
        refreshToken();
    }
    
    public void logout() {
        System.debug('LOGOUT GDrive');
        access_token = null;
        access_token_expiration = null;        
    }

    public void refreshToken() {
        System.debug('access_token->'+access_token);
        System.debug('access_token_expiration->'+access_token_expiration);
        if (access_token != null && access_token_expiration != null && access_token_expiration > DateTime.now()) {
            // Utiliza el accessToken proporcionado
            return;
        }
    
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://oauth2.googleapis.com/token');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        String requestBody = 'client_id=' + EncodingUtil.urlEncode(client_id, 'UTF-8');
        requestBody += '&client_secret='  + EncodingUtil.urlEncode(client_secret, 'UTF-8');
        requestBody += '&refresh_token='  + EncodingUtil.urlEncode(refresh_token, 'UTF-8');
        requestBody += '&grant_type='     + EncodingUtil.urlEncode(grant_type, 'UTF-8');
        
        request.setBody(requestBody);
        
        System.debug('body->'+requestBody);
        Http http = new Http();
        HttpResponse response = http.send(request);
        System.debug(response.getBody());
        if (response.getStatusCode() == 200) {
            Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            access_token = (String) responseData.get('access_token');
            Integer expires_in = (Integer) responseData.get('expires_in');
            access_token_expiration = DateTime.now().addSeconds(expires_in);
            
        } else {
            System.debug('Error refreshing access token: ' + response.getStatus() + ' - ' + response.getBody());
        }
    }    

    public String getFileIdByName(String fileName) {
        String fileId = null;
        String formatFileName = EncodingUtil.urlEncode(fileName, 'UTF-8');
        String strEndpoint = 'https://www.googleapis.com/drive/v3/files?q=mimeType!=\'application/vnd.google-apps.folder\'%20and%20trashed=false%20and%20name=\''+ formatFileName +'\'';
        System.debug('ENDPOINT: ' + strEndpoint);
        try {
            // Hacer la petición HTTP GET para obtener la lista de archivos y carpetas
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(strEndpoint);
            request.setHeader('Authorization', 'Bearer ' + access_token);
            request.setMethod('GET');
            HttpResponse response = http.send(request);
    
            if (response.getStatusCode() == 200) {
                // Conexión exitosa -> Extraer el ID del archivo
                fileId = extractFileIdFromResponse(response.getBody(), fileName);
            } 
            else {
                // Error de conexión
                System.debug('Error al conectar con Google Drive: ' + response.getStatus() + ' - ' + response.getBody());
            }            
        } catch (Exception e) {
            System.debug('Error al obtener el ID del archivo: ' + e.getMessage());
        }
        System.debug('Archivo encontrado, el ID es: '+fileId);
        return fileId;
    }
    
    public static String extractFileIdFromResponse(String responseBody, String fileName) {
        String fileId = null;
        Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        List<Object> items = (List<Object>) jsonResponse.get('files');
        if (items != null && !items.isEmpty()) {
            Map<String, Object> file = (Map<String, Object>) items.get(0);
            fileId = (String) file.get('id');
        }
        else {
            System.debug('No se encontraron archivos con el nombre "' + fileName + '".');
        }
        return fileId;
    }    

    public void deleteFiles(List<String> fileIds) {
        try {
            login();
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('https://www.googleapis.com/batch/drive/v3');
            request.setHeader('Authorization', 'Bearer ' + access_token);
            request.setHeader('Content-Type', 'multipart/mixed; boundary=batch_request');
            request.setMethod('POST');
            
            String batchRequest = '';
            for (String fileId : fileIds) {
                batchRequest += '--batch_request\r\n'
                        + 'Content-Type: application/http\r\n'
                        + 'Content-ID: ' + fileId + '\r\n\r\n'
                        + 'DELETE /drive/v3/files/' + fileId + '?supportsAllDrives=true HTTP/1.1\r\n'
                        + 'Host: www.googleapis.com\r\n'
                        + 'Content-Length: 0\r\n\r\n';
            }
            batchRequest += '--batch_request--\r\n';
    
            request.setBodyAsBlob(Blob.valueOf(batchRequest));
            HttpResponse response = http.send(request);
    
            if (response.getStatusCode() == 200 || response.getStatusCode() == 202) {
                System.debug('Archivos eliminados exitosamente');
            } else {
                System.debug('Error al eliminar archivos en Google Drive: ' + response.getStatus() + ' - ' + response.getBody());
            }
            logout();
        } catch (Exception e) {
            System.debug('Error al eliminar archivos en Google Drive: ' + e.getMessage());
        }
    }    

    public String uploadFileToDrive(String filename, Blob fileContent) {
        System.debug('filename :' + filename);
        System.debug('fileContent :' + fileContent);
        String requestBody = createRequestBody(filename);
        String fileId;

        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', 'Bearer ' + access_token);
        request.setEndpoint('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'multipart/related; boundary=---BOUNDARY');
    
        // Codificar el contenido del archivo en Base64
        String fileContentBase64 = EncodingUtil.base64Encode(fileContent);

        // Concatenar el cuerpo de la solicitud en formato Base64 con el contenido del archivo en Base64
        String body = requestBody + '\r\n' + fileContentBase64 + '\r\n--' + '---BOUNDARY--';
        System.debug('body :'+body);
        Blob bodyBlob = Blob.valueOf(body);
        System.debug('bodyBlob :'+bodyBlob);

        // Asignamos el Blob final como cuerpo de la solicitud
        request.setBodyAsBlob(bodyBlob);
        
        try {
            Http http = new Http();
            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200) {
                // Archivo subido exitosamente
                System.debug('Archivo subido exitosamente a Google Drive');

                // Extraer el ID del archivo de la respuesta HTTP
                Map<String, Object> jsonResponse = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                fileId = (String) jsonResponse.get('id');
                System.debug('ID del archivo subido: ' + fileId);         
                              
            } else {
                // Error al subir el archivo
                System.debug('Error (1) al subir archivo a Google Drive: ' + response.getStatus() + ' - ' + response.getBody());
            }
        } catch (Exception e) {
            System.debug('Error (2) al subir el archivo a Google Drive: ' + e.getMessage());
        }
        return fileId;
    }

    public String createRequestBody(String filename) {
        String boundary = '---BOUNDARY';
        String delimiter = '\r\n--' + boundary + '\r\n';
        String closeDelimiter = '\r\n--' + boundary + '--';
        String body = '';
        body += delimiter;
        body += 'Content-Type: application/json; charset=UTF-8\r\n\r\n';
        body += '{"name":"' + filename + '", "parents":[]}';
        body += delimiter;
        body += 'Content-Type: ' + getMimeType(filename) + '\r\n';
        body += 'Content-Transfer-Encoding: base64\r\n\r\n';
        return body;
    }

    public String getMimeType(String fileName) {
        String mimeType = '';
        Map<String, String> m = new Map<String, String>{
            '.ai'   => 'application/postscript',
            '.avi'  => 'video/x-msvideo',
            '.bmp'  => 'image/bmp',
            '.css'  => 'text/css',
            '.csv'  => 'text/csv',
            '.doc'  => 'application/msword',
            '.docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
            '.eps'  => 'application/postscript',
            '.gif'  => 'image/gif',
            '.html' => 'text/html',
            '.jpeg' => 'image/jpeg',
            '.jpg'  => 'image/jpeg',
            '.js'   => 'text/javascript',
            '.json' => 'application/json',
            '.mp3'  => 'audio/mpeg',
            '.mpeg' => 'video/mpeg',
            '.odp'  => 'application/vnd.oasis.opendocument.presentation',
            '.ods'  => 'application/vnd.oasis.opendocument.spreadsheet',
            '.odt'  => 'application/vnd.oasis.opendocument.text',
            '.pdf'  => 'application/pdf',
            '.png'  => 'image/png',
            '.ppt'  => 'application/vnd.ms-powerpoint',
            '.pptx' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
            '.psd'  => 'image/vnd.adobe.photoshop',
            '.svg'  => 'image/svg+xml',
            '.txt'  => 'text/plain',
            '.wav'  => 'audio/wav',
            '.xls'  => 'application/vnd.ms-excel',
            '.xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
            '.xml'  => 'application/xml',
            '.zip'  => 'application/zip'
        };
        String ext = fileName.substring(fileName.lastIndexOf('.')).toLowerCase();
        if (m.containsKey(ext)) {
            mimeType = m.get(ext);
        }
        return mimeType;
    }    
}