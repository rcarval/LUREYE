global class LUREYE_Drafts_SAP {   

    public String idQuote;    
    public Boolean mostrarBtnVolver {get;set;}    
    public Boolean testDraftCreado;

    public LUREYE_Drafts_SAP(ApexPages.StandardController controller){
        idQuote = controller.getId();        
        mostrarBtnVolver = false;
        system.debug('GETID = '+idQuote);
    }

    public PageReference CrearDraftsPage() {
        String rspServices = CrearDrafts(idQuote);
        system.debug('GETID = ' + idQuote);
    
        if (rspServices == null) {
            Quote qryQuote = [SELECT Id, DocEntry__c FROM Quote WHERE Id = :idQuote];  
    
            mostrarBtnVolver = true;
            system.debug('GETID = ' + idQuote);
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO, '¡Se ha creado el Draft ' + qryQuote.DocEntry__c + ' exitosamente en SAP!');
            ApexPages.addMessage(msg);
        } else {
            system.debug('GETID = ' + idQuote);
            mostrarBtnVolver = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Atención: ¡' + rspServices + '!');
            ApexPages.addMessage(msg);
        }
        return null;
    }    

    public PageReference ConsultaDraftsPage(){
        String rspServices;
        String sDraftEntry;
        String sQuoteID;
        String message;
        ApexPages.Severity severity;

        Quote qryQuote = new Quote();
        qryQuote = [SELECT  Id, DocEntry__c
                    FROM Quote
                    WHERE Id =: idQuote];
                    
        sDraftEntry = String.valueOf(qryQuote.DocEntry__c);
        sQuoteID    = String.valueOf(qryQuote.Id);

        try{        
            CS_EventNotify obj = new CS_EventNotify();
            rspServices = obj.getStatusQuote(sQuoteID);
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
            rspServices = 'Error al consultar la cotización';
            mostrarBtnVolver = true;
            severity = ApexPages.Severity.ERROR;
            ApexPages.Message msg = new ApexPages.Message(severity, rspServices);
            ApexPages.addMessage(msg);
            return null;              
        }        

        if (rspServices == 'Documento Pendiente') {
            message = 'El estado del Draft ' + sDraftEntry + ' es: ' + rspServices;
            severity = ApexPages.Severity.INFO;
        } else if (rspServices == 'Documento Autorizado') {
            message = 'El estado del Draft ' + sDraftEntry + ' es: ' + rspServices;
            severity = ApexPages.Severity.WARNING;
        } else if (rspServices == 'Orden de Venta Creada') {
            message = 'El estado del Draft ' + sDraftEntry + ' es: ' + rspServices;
            severity = ApexPages.Severity.CONFIRM;
        } else if (rspServices == 'Orden de Venta Cancelada' || rspServices == 'Documento Rechazado' || rspServices == 'Documento Cancelado') {
            message = 'El estado del Draft ' + sDraftEntry + ' es: ' + rspServices;
            severity = ApexPages.Severity.ERROR;
        }else {
            message = 'El draft no ha sido encontrado';
            severity = ApexPages.Severity.ERROR;
        }
        
        mostrarBtnVolver = true;
        ApexPages.Message msg = new ApexPages.Message(severity, message);
        ApexPages.addMessage(msg);
        return null;                  
    }

    public PageReference volver(){
        PageReference back = new PageReference('/'+idQuote);
        back.setRedirect(true);
        return back;   
    }  

    public String CrearDrafts(String idQuote){
        String bodyDraft        = null;
        String IdCuenta         = null;
        String bodyQuoteLI      = '';
        String dirFact          = '';
        String dirDesp          = '';

        String addressExtension = '';
        String slpCode          = '';
        String propiedades      = '';
        String propHES          = '';
        String bodega           = null;
        String codUN            = null;

        String docDueDate       = null;
        String glosa            = null;
        String ordenCompra      = null;
        String costingcode      = null;
        String sucursal         = null;

        String moneda           = '';
        Decimal branch          = null;
        Decimal lineaN          = null;
        Decimal condicionPago   = null;
    
        Quote qryQuote          = new Quote();
        Direccion__c shipAddr   = new Direccion__c();
        Direccion__c billAddr   = new Direccion__c();
        User userqry            = new User();
    
        List<QuoteLineItem> qryQuoteLineItem = new List<QuoteLineItem>();
        List<Account> qryAccount    = new List<Account>();
        List<Product2> lstprd       = new List<Product2>();
        Map<Id, String> prdMap      = new Map<Id, String>();

        try{
            //Cotización
            qryQuote = [SELECT  Id, ClienteId__c, CreatedById, DirFacturacion__c, DirDespacho__c, FechaEntrega__c, 
                                DocEntry__c, OVDocNum__c, Estado_en_SAP__c, Glosa__c, URL_Anexo__c, NOrdenCompra__c,
                                CondicionPago__c, IndicacionesLogisticas__c, Propiedades__c, RequiereHES__c, CurrencyIsoCode
                        FROM Quote
                        WHERE Id =: idQuote];

            userqry = [SELECT RUT_SD__c,RUT_DV__c, CodigoUN__c, Branch__c, Codigo_SAP__c,Sucursal__c,
                        Linea_Negocio__c,Centro_Costo__c
                    FROM User
                    WHERE Id =: qryQuote.CreatedById];

            //Valido que el Branch está cargado en el empleado
            if(userqry.Branch__c != null){
                branch = userqry.Branch__c;
            }else{
                return 'El campo "Branch" en el usuario está vacío, es un campo requerido en SAP';
            }

            //Valido que la Glosa está cargada
            if(qryQuote.Glosa__c != null){
                glosa = qryQuote.Glosa__c;
            }else{
                return 'El campo "Glosa" está vacío, es un campo requerido en SAP';
            }

            //Valido que la OC está cargada
            if(qryQuote.NOrdenCompra__c != null){
                ordenCompra = qryQuote.NOrdenCompra__c;
            }else{
                return 'El campo "N° Orden de Compra" está vacío, es un campo requerido en SAP';
            }            

            //Valido que el rut esté lleno en el empleado
            if(userqry.Codigo_SAP__c != null){
                slpCode = String.valueOf(userqry.Codigo_SAP__c);
            }else{
                slpCode = '-1';
            }

            //Valido que el Código Unidad esté lleno en el empleado
            if(userqry.CodigoUN__c != null){
                codUN = userqry.CodigoUN__c;
            }else{
                codUN = '1';
            }
            
            //Valido que HES está cargado            
            if (qryQuote.Propiedades__c != null){
                propiedades = qryQuote.Propiedades__c;
                propHES     = qryQuote.RequiereHES__c;

                if(propHES == 'HES' || propHES == '802')
                {
                    bodega = 'VTADFL10';
                }        
            }
            
            costingcode = String.ValueOf(userqry.Centro_Costo__c);
            sucursal    = String.ValueOf(userqry.Sucursal__c);
            lineaN      = userqry.Linea_Negocio__c;

        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
            return 'Error al consultar cotización';
        }

        if (qryQuote!=null){
            //Items de la Cotización
            try{
                qryQuoteLineItem = [SELECT  Quantity, QuoteId,QLBI__c, ListPrice, UnitPrice, TotalPrice, Product2Id
                                    FROM QuoteLineItem
                                    WHERE QuoteId =: idQuote];
                
                lstprd = [SELECT  Id, Name
                            FROM Product2
                            WHERE Id in (SELECT Product2Id
                                         FROM QuoteLineItem
                                         WHERE QuoteId =: idQuote)];
                
                for (QuoteLineItem qLI:qryQuoteLineItem){
                    if (qLI.QLBI__c == null){
                        return 'Se debe completar el campo QLBI en todos los ítems de la cotización';
                    }
                }

                for (Product2 prd:lstprd){
                    prdMap.put(prd.Id,prd.Name);
                    System.debug('Product Id: '+prd.Id+' , '+'Product Name: '+prd.Name);
                }           

                bodyQuoteLI = LUREYE_Items_SAP.createQuoteLI(prdMap, qryQuoteLineItem, null, costingcode, sucursal, lineaN, glosa, bodega);

            }catch(Exception e){
                system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+
                                e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
                return 'Error al consultar cotización';
            }

            if (!qryQuoteLineItem.isEmpty()){
                IdCuenta = qryQuote.ClienteId__c;
                if(IdCuenta!=null){
                    //Cliente
                    try{
                        qryAccount =[SELECT Id, Name, RUT_SD__c, RUT_DV__c, EstadoSAP__c
                                    FROM Account
                                    WHERE Id =: IdCuenta];
                    }catch(Exception e){
                        system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+
                                        e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
                        return 'Error al consultar cuenta';
                    }

                    if(qryQuote.DirFacturacion__c!=null){
                        try{
                            billAddr = [SELECT  Id,Tipo__c,LicTradNum__c,Region__c,Pais__c,StreetNo__c,
                                                Name,TaxCode__c,GlblLocNum__c,CurrencyIsoCode,ZipCode__c,
                                                Comuna__c,Ciudad__c,Street__c,AccountId__c                
                                        FROM    Direccion__c
                                        WHERE   Id =: qryQuote.DirFacturacion__c];
                            
                            dirFact = '"BillToStreet": "'+billAddr.Street__c.toUpperCase()+'",'+
                                      '"BillToStreetNo": "'+billAddr.StreetNo__c+'",'+
                                      '"BillToCity": "'+billAddr.Ciudad__c.toUpperCase()+'",'+
                                      '"BillToZipCode": "'+billAddr.ZipCode__c+'",'+
                                      '"BillToCounty": "'+billAddr.Comuna__c.toUpperCase()+'",'+
                                      '"BillToState": "'+billAddr.Region__c+'",'+
                                      '"BillToCountry": "CL",'+
                                      '"BillToGlobalLocationNumber": "'+billAddr.GlblLocNum__c+'"';
                        }catch(Exception e){
                            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
                            return 'Error al consultar la dirección de Facturación';
                        }
                    }

                    if(qryQuote.DirDespacho__c!=null){
                        try{
                            shipAddr = [ SELECT  Id,Tipo__c,LicTradNum__c,Region__c,Pais__c,StreetNo__c,
                                                Name,TaxCode__c,GlblLocNum__c,CurrencyIsoCode,ZipCode__c,
                                                Comuna__c,Ciudad__c,Street__c,AccountId__c               
                                        FROM    Direccion__c
                                        WHERE   Id =: qryQuote.DirDespacho__c];
                            dirDesp = '"ShipToStreet": "'+shipAddr.Street__c.toUpperCase()+'",'+
                                      '"ShipToStreetNo": "'+shipAddr.StreetNo__c+'",'+
                                      '"ShipToCity": "'+shipAddr.Ciudad__c.toUpperCase()+'",'+
                                      '"ShipToZipCode": "'+shipAddr.ZipCode__c+'",'+
                                      '"ShipToCounty": "'+shipAddr.Comuna__c.toUpperCase()+'",'+
                                      '"ShipToState": "'+shipAddr.Region__c+'",'+
                                      '"ShipToCountry": "CL",'+
                                      '"ShipToGlobalLocationNumber": "'+shipAddr.GlblLocNum__c+'"';
                        
                        }catch(Exception e){
                            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
                            return 'Error al consultar la dirección de Despacho';
                        }
                    }

                    //Contrucción del body AddressExtension
                    if(dirDesp != '' && dirFact != ''){
                        addressExtension = dirDesp + ',' + dirFact;
                    }else if(dirDesp != '' && dirFact == '') {
                        addressExtension = dirDesp;
                    }else if(dirDesp == '' && dirFact != '') {
                        addressExtension = dirFact;
                    }

                    if (qryQuote.FechaEntrega__c != null){
                        docDueDate = String.valueOf(qryQuote.FechaEntrega__c).substring(0, 10);
                    }
                    
                    if (qryQuote.CurrencyIsoCode != '') {
                        if (qryQuote.CurrencyIsoCode == 'CLP') {
                            moneda = '$';
                        } else if (qryQuote.CurrencyIsoCode == 'CLF') {
                            moneda = 'UF';
                        } else {
                            moneda = qryQuote.CurrencyIsoCode;
                        }
                    }
                    System.debug('MONEDA DRAFT--> '+ moneda);

                    if (qryQuote.IndicacionesLogisticas__c != null) {
                        glosa = glosa + ' - ' + qryQuote.IndicacionesLogisticas__c;
                    }
                    
                    condicionPago = LUREYE_SAP_Controller.switchStrCondition(qryQuote.CondicionPago__c);
                    
                    // Verifico si hay archivos adjuntos antes de continuar
                    CS_UploadFiles uploadFiles = new CS_UploadFiles();                        
                    if (!uploadFiles.hasAttachments(idQuote)) {
                        return 'Debe adjuntar al menos un archivo para crear el draft en SAP';
                    }
                    
                    //CSalas: Reviso si hay adjuntos para crear y agregar                              
                    Map<String, Object> resultMap = uploadFiles.uploadFilesToDrive(idQuote);
                    String bodyAttachment = (String)resultMap.get('bodyJSON');
                    List<String> fileIdList = (List<String>)resultMap.get('fileIdList');                        

                    bodyDraft = '{'+
                            '"CardCode": "C'+qryAccount[0].RUT_SD__c+'",'+
                            '"BPL_IDAssignedToInvoice": '+branch+','+
                            '"Series": "13",'+
                            '"DocDueDate": "'+docDueDate+'",'+
                            '"DocCurrency": "'+moneda+'",'+
                            '"NumAtCard": "'+ordenCompra+'",'+
                            '"PaymentGroupCode": "'+condicionPago+'",'+
                            '"DocObjectCode": "17",'+
                            '"SalesPersonCode":"'+slpCode+'",'+
                            '"Comments": "'+glosa+'",'+
                            '"U_IDCajaHisto": "SF:'+qryQuote.Id+'",'+
                            '"U_EXX_FE_TDBSII": "'+propHES+'",'+
                            '"Name": "'+qryAccount[0].Name+'",'+
                            '"U_URL_ANEXO": "'+qryQuote.URL_Anexo__c+'",'+
                            '"DocumentLines": ['+bodyQuoteLI+'],'+
                            '"AddressExtension": { '+addressExtension+' }'+
                            '}';

                    bodyDraft = bodyDraft.replaceAll('\"', '\\\"');
                    bodyDraft = bodyDraft.replaceAll('\\r', '\\\\r');
                    bodyDraft = bodyDraft.replaceAll('\\n', '\\\\n');
                    bodyDraft = bodyDraft.replaceAll('\\t', '\\\\t');
                    bodyDraft = bodyDraft.replaceAll('\"null\"', 'null');
                    bodyDraft = bodyDraft.replaceAll('\"NULL\"', 'null');                                                             
                                        
                    //SL_Drafts_JSON response = LUREYE_Servicios_SAP.CreaDrafts(body);  
                    //CSalas: Ejecuto la función del Batch Draft en vez de Crear Drafts 
                    integer response;
                    if (!Test.isRunningTest()) {
                        response = CS_BatchDraft.createSequential(bodyAttachment, bodyDraft);
                    } else {
                        // Simular un comportamiento exitoso o fallido basado en los datos de prueba
                        response = (testDraftCreado) ? 1 : 0;
                    }
                   
                    //Hago consulta al draft para poder obtener el DocEntry Creado
                    if(response == 1){
                        SL_Drafts_JSON consDrft = null;
                        if(!Test.isRunningTest()){
                            consDrft = ConsultaDrafts(qryQuote.Id);
                        }else{
                            consDrft = (SL_Drafts_JSON)JSON.deserialize('{"odata.metadata": "https://lureye.com:50000/b1s/v1/$metadata#Orders","value": [{"DocEntry": 154}]}',SL_Drafts_JSON.class);
                        }

                        try{
                            if(consDrft!=null){
                                if(!consDrft.value.isEmpty()){
                                    qryQuote.DocEntry__c = consDrft.value[0].docentry;
                                    qryQuote.Estado_en_SAP__c = 'Documento Pendiente';
                                    update(qryQuote);

                                    System.debug('DRAFT CREADO EXITOSAMENTE --> '+ consDrft.value[0].docentry);
                                    return null;
                                }
                            }

                        }catch(Exception e){
                            if (bodyAttachment != null) {
                                CS_GoogleDrive drive = new CS_GoogleDrive();
                                drive.login();
                                drive.deleteFiles(fileIdList);
                                drive.logout();
                            }
                            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
                            return 'Ocurrió un error en la creación del draft';
                        }
                    } else {
                        if (bodyAttachment != null) {
                            CS_GoogleDrive drive = new CS_GoogleDrive();
                            drive.login();
                            drive.deleteFiles(fileIdList);
                            drive.logout();
                        }
                    }
                
                } else {
                    return 'No se encontró la cuenta para esta cotización';
                }
            } else {
                return 'No se encuentra seleccionado ninguna cuenta para esta cotización';
            }
        } else {
            return 'No se encuentra seleccionado ningún Item para esta cotización';
        }

        return 'Error al crear el Draft en SAP';
    }

    public static SL_Drafts_JSON ConsultaDrafts(String idQuote){ 
        try{
            if (idQuote != null){
                SL_Drafts_JSON response = LUREYE_Servicios_SAP.GetDocEntryDrafts(idQuote);
                system.debug('response '+response);
                if (response !=null){
                    if(!response.value.isEmpty()){ 
                        return response;
                    }
                }
            }
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
            return null;
        }
        return null;
    }     
}