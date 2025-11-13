public class CS_UploadFiles {
    private CS_GoogleDrive googleDrive;
    List<String> fileIdList = new List<String>();

    public CS_GoogleDrive getGoogleDrive() {
        return googleDrive;
    }

    public CS_UploadFiles() {
        this.googleDrive = new CS_GoogleDrive();
    }

    @TestVisible
    private CS_UploadFiles(CS_GoogleDrive googleDrive) {
        this.googleDrive = googleDrive;
    }

    public Boolean hasAttachments(String quoteId) {
        // Obtener la lista de ContentDocumentLink que están relacionados con la cotización
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :quoteId LIMIT 1];
        
        // Si existe al menos un archivo relacionado, retornar verdadero
        return !documentLinks.isEmpty();
    }

    public static List<ContentVersion> getFiles(String quoteId) {
        // Obtener la lista de ContentDocumentLink que están relacionados con la cotización
        List<ContentDocumentLink> documentLinks = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :quoteId];
    
        // Construir una lista de ContentDocumentId a partir de los ContentDocumentLink que tengan una versión de contenido asociada
        List<Id> documentIds = new List<Id>();
        for (ContentDocumentLink documentLink : documentLinks) {
            List<ContentVersion> contentVersions = [SELECT Id FROM ContentVersion WHERE ContentDocumentId = :documentLink.ContentDocumentId LIMIT 1];
            if (contentVersions.size() > 0) {
                documentIds.add(documentLink.ContentDocumentId);
            }
        }
    
        // Obtener la lista de ContentVersion para los documentos asociados con la cotización
        List<ContentVersion> contentVersions = [SELECT Title, FileExtension, VersionData FROM ContentVersion WHERE ContentDocumentId IN :documentIds];
        System.debug('Se encontraron ' + contentVersions.size() + ' archivos relacionados con la cotización ' + quoteId + ':');       
        return contentVersions;
    }

    public Map<String, Object> uploadFilesToDrive(String quoteId) {
        List<ContentVersion> files = getFiles(quoteId);        

        if (files.isEmpty()) {
            // Si no hay ContentVersion, retornar un mapa con una lista vacía en lugar de nula
            Map<String, Object> resultMap = new Map<String, Object>();
            resultMap.put('bodyJSON', null);
            resultMap.put('fileIdList', new List<String>());
            return resultMap;
        }

        String rutaSAP = '\\\\10.41.2.3\\ArchivosSAP';
        String fileId;

        // Obtener los valores de los campos personalizados de la cotización
        Quote quote = [SELECT QuoteNumber, CodigoUN__c, Carpeta__c FROM Quote WHERE Id = :quoteId LIMIT 1];
        String unidadNegocio        = quote.CodigoUN__c;
        String cotizacionNumero     = quote.QuoteNumber;    

        CS_GoogleDrive drive        = new CS_GoogleDrive();
        drive.login();

        for (ContentVersion file : files) {
            String filename             = unidadNegocio + cotizacionNumero + '_' + file.Title + '.' + file.FileExtension;
            String decodedFileContent   = EncodingUtil.base64Encode(file.VersionData);
            Blob decodedBlob            = EncodingUtil.base64Decode(decodedFileContent); 

            try {
                System.debug('filename: ' + filename);
                System.debug('FileExtension: ' + file.FileExtension);
                System.debug('decodedBlob: ' + decodedBlob);

                // Agregar el ID del archivo a la lista fileIdList
                fileId = drive.uploadFileToDrive(filename, decodedBlob);
                if (fileId != null) {
                    // Agregar el ID del archivo a la lista fileIdList
                    fileIdList.add(fileId);
                } else {
                    System.debug('Error: El archivo no se subió correctamente a Google Drive.');
                }                
            } catch (Exception e) {
                System.debug('Error al subir el archivo a Google Drive: ' + e.getMessage());
            }
        }
        drive.logout();
               
        // Crear el Body y la estructura para registrar en Attachment2 de SAP Service Layer
        String bodyJSON = getBodyAttachment(files, rutaSAP, unidadNegocio, cotizacionNumero);

        // Retornar un mapa con ambos valores
        Map<String, Object> resultMap = new Map<String, Object>();
        resultMap.put('bodyJSON', bodyJSON);
        resultMap.put('fileIdList', fileIdList);
        return resultMap;
    }

    public static String getBodyAttachment(List<ContentVersion> files, String folderSAP, String unidadNegocio, String cotizacionNumero) {
        List<Map<String, Object>> attachments = new List<Map<String, Object>>();
        for (ContentVersion file : files) {

            String filename = unidadNegocio + cotizacionNumero + '_' + file.Title;

            Map<String, Object> attachment = new Map<String, Object>();
            
            attachment.put('FileName', filename);
            attachment.put('FileExtension', file.FileExtension);
            attachment.put('SourcePath', folderSAP);
            attachment.put('Override', 'tYES');
            attachment.put('CopyToTargetDoc', 'tYES');
            attachment.put('CopyToProductionOrder', 'tYES');
            attachments.add(attachment);

            System.debug('FileName: ' + filename);
            System.debug('FileExtension: ' + file.FileExtension);
            System.debug('SourcePath: ' + folderSAP);
        }
        Map<String, List<Map<String, Object>>> body = new Map<String, List<Map<String, Object>>>();
        body.put('Attachments2_Lines', attachments);
        String bodyAttachment = JSON.serialize(body);
        System.debug('Attachments2_Lines: ');
        System.debug(attachments);
        return bodyAttachment;
    }
}