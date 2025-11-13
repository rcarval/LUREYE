public class LUREYE_SAP_Controller {
    public String idCuenta;
    public Boolean mostrarBtnVolver {get;set;}
    
    public LUREYE_SAP_Controller(ApexPages.StandardController controller){
        idCuenta = controller.getId();
        mostrarBtnVolver = false;
    }

    public PageReference SincronizarSap(){
        String rspServices = null;
        rspServices = clienteNewSFSAP(idCuenta);
        if (rspServices == null){
            mostrarBtnVolver = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO , '¡El cliente fue sincronizado con SAP!');
            ApexPages.addMessage(msg);
            return null;

        } else {
            mostrarBtnVolver = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Atención: ¡'+ rspServices +'!');
            ApexPages.addMessage(msg);
        }
        return null;
    }

    public PageReference SincronizarInventarioSap(){
        String rspServices = null;
        rspServices = inventario(idCuenta);
        if (rspServices == null){
            mostrarBtnVolver = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.INFO , '¡El Inventario fue sincronizado con SAP!');
            ApexPages.addMessage(msg);
            return null;

        } else {
            mostrarBtnVolver = true;
            ApexPages.Message msg = new ApexPages.Message(ApexPages.severity.ERROR, 'Atención: ¡'+ rspServices +'!');
            ApexPages.addMessage(msg);
        }
        return null;
    }

    //Flujo de creación de clientes en la unidad de crédito
    //Salesforce --> SAP
    public static String clienteNewSFSAP(String idCuenta) {
        List<Direccion__c> direcciones = new List<Direccion__c>();
        List<Contact> contactos = new List<Contact>();
        List<String> lstChkCtc = new List<String>();
        List <String> lstctc = new List <String>();
        String contact = null, contacts='',address = '', cType = null,RutCode = null,blkMark = null;
        Direccion__c dir = new Direccion__c();
        Integer payCondition=null;
        Account act = new Account();
        Giro__c giro = new Giro__c();
        //Almaceno datos de la cuenta
        act = queryAccount(idCuenta);

        if( act != null){
            RutCode = String.valueof(act.RUT_SD__c);
            
                //Llama al servicio de CrearCliente de Salesforce
                SL_Client_JSON responseCons = LUREYE_Servicios_SAP.ConsultaClienteSAP(RutCode);
                //system.debug('responseCons '+responseCons);
                if(responseCons==null){
                    //Obtener valor de giro
                    if(act.Giro__c != null){
                        giro = chkGiro(act.Giro__c,act.CurrencyIsoCode,null);
                    }else{
                        giro = null;
                    }
                    //Validacion de campos minimos necesarios
                    if(act.RUT_DV__c !=null && act.Email__c != null && act.Phone != null && giro !=null && act.Phone.length() == 9){
                        
                        //Validaciones Contacto
                        contactos = queryContact(act.Id);
                        if(contactos.size()>0){
                            for (Contact contc : contactos){
                                if(lstChkCtc.size()>0){
                                    for(String chkCtc:lstChkCtc){
                                        if(chkCtc == contc.Name){
                                            system.debug('Nombre de contacto repetido');
                                            return 'Error al sincronizar contactos con SAP, el Nombre Completo del contacto no se puede repetir dentro de la misma cuenta';
                                        }
                                    }
                                }
                                contact='{'+
                                            '"CardCode": "C'+RutCode+'",'+
                                            '"Name": "'+contc.Name+'",'+
                                            '"Position": "'+contc.Title+'",'+
                                            '"Phone1": "'+contc.MobilePhone+'",'+
                                            '"Phone2": "'+contc.HomePhone+'",'+
                                            '"Fax": "'+contc.Fax+'",'+
                                            '"E_Mail": "'+contc.Email+'",'+
                                            '"FirstName": "'+contc.FirstName+'",'+
                                            '"MiddleName": "'+contc.MiddleName+'",'+
                                            '"LastName": "'+contc.LastName+'"'+
                                            '}';
                                lstctc.add(contact);
                                lstChkCtc.add(contc.Name);
                                
                            }
                            //Body de Contactos
                            if (lstctc.size()> 0){
                                for (String ctc : lstctc){
                                    contacts= contacts+ctc+',';
                                }
                                //Elimino la ultima coma
                                contacts = contacts.substring(0, contacts.length()-1).replace('"null"', 'null');
                                system.debug('Contacts: '+contacts);
                            }
                        }

                        //Validaciones y Creacion de Direcciones
                        direcciones = queryDirecciones(act);
                        
                        //system.debug('direcciones '+direcciones);
                        if(direcciones.size()>0){
                            address = creaDireccion(RutCode, direcciones);
                            //system.debug('address '+address);
                            if (address!='ERROR 1' && address!='ERROR 2'){
                                address = creaDireccion(RutCode, direcciones);
                            }else if(address=='ERROR 1'){
                                return 'Verifique que exista una dirección con nombre y tipo "Facturación" y una dirección con nombre y tipo "Despacho"';
                            }else if(address=='ERROR 2'){
                                return 'Error al sincronizar con SAP, El nombre de las direcciones deben ser únicos por tipo (Facturación/Despacho)'; 
                            }
                        }else{
                            return 'Se debe agregar al menos una dirección';
                        }

                        //Calculo para CardType
                        if(act.CardType__c == 'C'){
                            cType = 'cCustomer';
                        }else{
                            cType = 'cSupplier';
                        }
                        
                        payCondition = switchStrCondition(act.CondicionPago__c);
                        if(act.BlockComm__c == false){
                            blkMark = 'tNO';
                        }else{
                            blkMark = 'tYES';
                        } 

                        if(blkMark == 'tYES'){
                            return 'El campo "Bloquear envío de marketing" no puede estar activado'; 
                        }

                        String Body = '{"CardCode": "C'+RutCode+'",'+
                                '"CardName": "'+act.Name+'",'+
                                '"CardForeignName": "'+act.NombreFantasia__c+'",'+
                                '"CardType": "'+cType+'",'+
                                '"Phone1": "'+act.Phone+'",'+
                                '"Cellular": "'+act.Phone+'",'+ 
                                '"Notes": "'+giro.Name+'",'+
                                '"FederalTaxID": "'+RutCode+'-'+act.RUT_DV__c+'",'+
                                '"Country": "'+act.Country__c+'",'+
                                '"EmailAddress": "'+act.Email__c+'",'+
                                '"Website": "'+act.Website+'",'+
                                '"BlockSendingMarketingContent": "'+blkMark+'",'+
                                '"PayTermsGrpCode": "'+payCondition+'",'+
                                '"DefaultCurrency": "##",'+
                                '"BilltoDefault": "Facturación",'+
                                '"BPAddresses": ['+address+'],'+
                                '"ContactEmployees": ['+contacts+'],'+
                                '"SalesPersonCode": -1,'+
                                '"Properties1": "'+act.Ownership+'",'+
                                '"CreditLimit": "'+act.CreditLine__c+'",'+
                                '"MaxCommitment": "'+act.DebtLine__c+'",'+
                                '"BPCurrenciesCollection": ['+
                                    '{'+
                                        '"CurrencyCode": "CLP",'+
                                        '"Include": "tYES"'+
                                    '},'+
                                    '{'+
                                        '"CurrencyCode": "EUR",'+
                                        '"Include": "tYES"'+
                                    '},'+
                                    '{'+
                                        '"CurrencyCode": "UF",'+
                                        '"Include": "tYES"'+
                                    '},'+
                                    '{'+
                                        '"CurrencyCode": "USD",'+
                                        '"Include": "tYES"'+
                                    '}'+
                                ']'+
                            '}';

                        //Corrige body para valores null
                        Body = Body.replace('"null"', 'null');
                        system.debug('body: '+ body);
                        SL_Client_JSON response = LUREYE_Servicios_SAP.CrearClienteSFSAP(Body);
                    
                        if(response != null){
                            act.EstadoSAP__c = 'Validado por SAP';
                            update(act);
                            system.debug('ESTADO CUENTA ACTUALIZADO A Validado por SAP');
                            return null;
                        }else{
                            return 'Se produjo un error en la sincronización del cliente';
                        }
                        
                        
                    //Fin If validacion de campo
                    }else{
                        if(act.RUT_DV__c ==null){
                            return 'Debe completar el campo Rut antes de sincronizar con SAP';
                        }
                        if(act.Email__c == null){
                            return 'Debe completar el campo Email antes de sincronizar con SAP';
                        } 
                        if(giro == null){
                            return 'Se debe asignar el Giro antes de sincronizar con SAP';
                        } 
                        if(act.Phone==null || act.Phone.length() != 9){
                            return 'Debe completar el campo Teléfono (con 9 dígitos) antes de sincronizar con SAP';
                        }
                    }
                }else{
                    String rspClientNew = clienteNewSAPSF(RutCode,responseCons,act);
                    
                    if (rspClientNew == null){
                        return null;
                    }else{
                        return rspClientNew;
                    }
                }

        }//Fin If Account
        return 'No se puede sincronizar el cliente con SAP, valide el Rut del cliente. En caso de poseer Rut nulo, se requiere Cliente Principal';
    }

    //Flujo de creación de clientes en la unidad de crédito
    //SAP--> Salesforce
    public static String clienteNewSAPSF(String RutCode,SL_Client_JSON response,Account act) {
            
        //Validaciones y Creacion de Direcciones y Contacto
        List<Direccion__c> direcciones = new List<Direccion__c>();
        List<Direccion__c> updDir = new List<Direccion__c>();
        List<Direccion__c> insDir = new List<Direccion__c>();
        Direccion__c dir = new Direccion__c();
        List<Contact> contactos = new List<Contact>();
        List<Contact> updCtc = new List<Contact>();
        List<Contact> insCtc = new List<Contact>();
        List <String> lstctc = new List <String>();
        Contact cntacs = new Contact();
        Boolean newDir =false, newCtc=false, updcontc=false,chkUpdCtc=false,upd=false;
        String shipaddr = null, billaddr = null;
        List <String> lstshipaddr = new List <String>();
        List <String> lstbilladdr = new List <String>();
        List <String> lstNameaddr = new List <String>();
        List <String> lstChkCtc = new List <String>();
        List <String> lstChk2Ctc = new List <String>();
        String address = '',contact='',contacts='',patchBody='',idContac=null,addrType='';
        //Valida si el cliente esta activo en SAP
        if(response.valid=='tYES'){

            //Validación Contacto
            try{
                contactos = queryContact(act.Id);
                if(response.ContactEmployees.size()>0){
                    for(SL_Client_JSON.ContactEmployees ctc:response.ContactEmployees){
                        system.debug('ctc.firstname '+ctc.firstname);
                        cntacs = new Contact();
                        chkUpdCtc = false;
                        updcontc = false;
                        cntacs.Title = ctc.position;
                        cntacs.MobilePhone = ctc.phone1;
                        cntacs.HomePhone = ctc.phone2;
                        cntacs.Fax = ctc.fax;
                        cntacs.Email = ctc.e_mail;
                        cntacs.FirstName = ctc.firstname;
                        cntacs.MiddleName = ctc.middlename;
                        cntacs.LastName = ctc.lastname;

                        //system.debug('contactos.size() '+contactos.size());
                        //Validación de Contacto existente
                        if(contactos.size() > 0){
                            for (Contact clientCtc : contactos){
                                chkUpdCtc = lstChkCtc.contains(clientCtc.Name);
                                if (!chkUpdCtc){
                                    updcontc = true;
                                    cntacs.Id=clientCtc.Id;
                                    updCtc.add(cntacs);
                                    lstChkCtc.add(clientCtc.Name);
                                    system.debug('SE ACTUALIZARÁ EL CONTACTO '+clientCtc.Name);
                                    break;
                                }
                            }
                        }
                        
                        if (updcontc == false /*&& cntacs.Name != null*/){
                            cntacs.AccountId=act.Id;
                            insCtc.add(cntacs);
                            system.debug('SE INSERTARÁ EL CONTACTO '+cntacs.Name);
                        }
                    }
                }

                lstChkCtc.clear();
                //Validacion de nuevos contactos en Salesforce
                if(contactos.size() > 0){
                    for (Contact clientCtc : contactos){
                        newCtc = false;
                        
                        //Validacion contacto duplicado
                        if(!lstChk2Ctc.contains(clientCtc.Name)){
                            lstChk2Ctc.add(clientCtc.Name);
                        }else{
                                return 'Error al sincronizar contactos con SAP, el Nombre Completo del contacto no se puede repetir dentro de la misma cuenta';
                        }
                        
                        for(SL_Client_JSON.ContactEmployees ctc:response.ContactEmployees){
                            lstChkCtc.add(ctc.Name);
                            chkUpdCtc = lstChkCtc.contains(clientCtc.Name);
                            if(chkUpdCtc){
                                break;
                            }
                        }

                        if(!chkUpdCtc){
                            lstChk2Ctc.add(clientCtc.Name);
                            system.debug('NUEVO CONTACTO EN SF:' +clientCtc.Name);
                            if (clientCtc.Name!=null){
                                contact='{'+
                                                '"CardCode": "C'+RutCode+'",'+
                                                '"Name": "'+clientCtc.Name+'",'+
                                                '"Position": "'+clientCtc.Title+'",'+
                                                '"Phone1": "'+clientCtc.MobilePhone+'",'+
                                                '"Phone2": "'+clientCtc.HomePhone+'",'+
                                                '"Fax": "'+clientCtc.Fax+'",'+
                                                '"E_Mail": "'+clientCtc.Email+'",'+
                                                '"FirstName": "'+clientCtc.FirstName+'",'+
                                                '"MiddleName": "'+clientCtc.MiddleName+'",'+
                                                '"LastName": "'+clientCtc.LastName+'"'+
                                                '}';
                                lstctc.add(contact);
                            }else{
                                return 'Error al sincronizar contactos con SAP, el Nombre Completo del contacto no puede ser nulo';
                            }
                        }                      
                    }
                }
                //Body de Contactos
                if (lstctc.size()> 0){
                    for (String ctc : lstctc){
                        contacts= contacts+ctc+',';
                    }
                    //Elimino la ultima coma
                    contacts = contacts.substring(0, contacts.length()-1).replace('"null"', 'null');
                } 

            //catch Contacto
            }catch(Exception e){
                system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
                return 'No se pudo sincronizar los contactos desde SAP';
            }

            try{
                direcciones = queryDirecciones(act);
                //Cargo los nombres de la dirección para luego validar que no existan repetidos

                if(response.BPAddresses.size()>0){
                    for(SL_Client_JSON.BPAddresses adr:response.BPAddresses){
                        dir = new Direccion__c();
                        if(!lstNameaddr.contains(adr.addressname+adr.AddressType)){
                            lstNameaddr.add(adr.addressname+adr.AddressType);

                            if (adr.AddressType == 'bo_ShipTo'){
                                dir.Tipo__c = 'Despacho';
                            }else{
                                dir.Tipo__c = 'Facturación';
                            }

                            dir.Street__c = adr.street;
                            //Descomento adr.block para usarla en vez de County
                            dir.Comuna__c = adr.block;
                            dir.ZipCode__c = adr.zipcode;
                            dir.Ciudad__c = adr.city;
                            //if(adr.block=='null'){dir.Comuna__c =null;}else{dir.Comuna__c = adr.block;}
                            dir.Name = adr.addressname;
                            dir.Nombre__c = adr.addressname;
                            //dir.Pais__c = 'CL';
                            dir.Pais__c = adr.country;
                            dir.Region__c = adr.state;
                            dir.TaxCode__c = adr.taxcode;
                            dir.StreetNo__c = adr.streetno;
                            dir.LicTradNum__c = adr.bpcode;
                            dir.GlblLocNum__c = adr.globallocationnumber;
                            dir.AccountId__c = act.Id;
                            // Se crea datos de Block                            
                            dir.Block__c = adr.BuildingFloorRoom;

                            //Validación de dirección existente
                            if(direcciones.size() > 0){
                                upd = false; 
                                for (Direccion__c clientDir : direcciones){
                                    if (clientDir.Name == adr.addressname && clientDir.Tipo__c == dir.Tipo__c){
                                        dir.Id = clientDir.Id;
                                        updDir.add(dir);
                                        upd = true;
                                        break;
                                    }     
                                }
                                if (upd == false){
                                    insDir.add(dir);
                                }
                            }else{
                                insDir.add(dir);
                            }
                        }else{
                            return 'Error al sincronizar con SAP, Direcciones duplicadas desde SAP, consulte a su Administrador SAP';
                        }   
                    }
                }
                
                //Validacion de nuevas direcciones en Salesforce
                if(direcciones.size() > 0){
                    
                    for (Direccion__c clientDir : direcciones){
                        newDir = false;
                        for(SL_Client_JSON.BPAddresses adr:response.BPAddresses){
                            if (adr.AddressType == 'bo_ShipTo'){
                                addrType = 'Despacho';
                            }else{
                                addrType = 'Facturación';
                            }
                            if (clientDir.Name == adr.addressname && clientDir.Tipo__c == addrType){
                                newDir = true;
                            }
                        }
                        if (!newDir){
                            system.debug('NUEVA DIRECCIÓN EN SF:' +clientDir.Name);
                            
                            if(clientDir.Tipo__c == 'Despacho'){
                                shipaddr='{'+
                                            '"AddressName": "'+clientDir.Name+'",'+
                                            '"Street": "'+clientDir.Street__c+'",'+
                                            '"Block": "'+clientDir.Comuna__c+'",'+
                                            '"ZipCode": "'+clientDir.ZipCode__c+'",'+
                                            '"City": "'+clientDir.Ciudad__c+'",'+
                                            //'"County": "'+clientDir.Comuna__c+'",'+
                                            '"Country": "'+clientDir.Pais__c+'",'+
                                            //'"Country": "CL",'+
                                            '"State": "'+clientDir.Region__c+'",'+
                                            '"TaxCode": "'+clientDir.TaxCode__c+'",'+
                                            '"AddressType": "bo_ShipTo",'+
                                            '"StreetNo": "'+clientDir.StreetNo__c+'",'+
                                            '"BPCode": "C'+RutCode+'",'+
                                            '"GlobalLocationNumber": "'+clientDir.GlblLocNum__c+'",'+
                                            '"BuildingFloorRoom": "'+clientDir.Block__c+'"'+ 
                                            '}';
                                lstshipaddr.add(shipaddr);
                            }else{
                                billaddr='{'+
                                            '"AddressName": "'+clientDir.Name+'",'+
                                            '"Street": "'+clientDir.Street__c+'",'+
                                            '"Block": "'+clientDir.Comuna__c+'",'+
                                            '"ZipCode": "'+clientDir.ZipCode__c+'",'+
                                            '"City": "'+clientDir.Ciudad__c+'",'+
                                            //'"County": "'+clientDir.Comuna__c+'",'+
                                            //'"Country": "'+clientDir.Pais__c+'",'+
                                            '"Country": "CL",'+
                                            '"State": "'+clientDir.Region__c+'",'+
                                            '"TaxCode": "'+clientDir.TaxCode__c+'",'+
                                            '"AddressType": "bo_BillTo",'+
                                            '"StreetNo": "'+clientDir.StreetNo__c+'",'+
                                            '"BPCode": "C'+RutCode+'",'+
                                            '"GlobalLocationNumber": "'+clientDir.GlblLocNum__c+'",'+                                            
                                            '"BuildingFloorRoom": "'+clientDir.Block__c+'"'+ 
                                            '}';
                                lstbilladdr.add(billaddr);
                            }       
                        }
                    }
                }
                
                //Body de Direcciones
                address= bodyDir(lstshipaddr,lstbilladdr);
                
                if(address!='' || contacts!=''){
                    if(address!='' && contacts!=''){
                        patchBody = '{"BPAddresses": ['+address+'],"ContactEmployees": ['+contacts+']}';
                    }else if(address!='' && contacts==''){
                        patchBody = '{"BPAddresses": ['+address+']}';
                    }else if(address=='' && contacts!=''){
                        patchBody = '{"ContactEmployees": ['+contacts+']}';
                    }
                    patchBody = patchBody.replace('"null"', 'null');

                    //Llama al servicio de Update de Sap
                    String responseCons = LUREYE_Servicios_SAP.ClienteExistente(patchBody,RutCode);
                    system.debug('responseCons '+responseCons);
                    if (responseCons!=null){
                        system.debug('SE AGREGARON LAS NUEVAS DIRECCIONES/CONTACTOS');
                        //return null;
                    }else{
                        return 'Error al Sincronizar con SAP, no se pudo agregar las nuevas direcciones/contactos en SAP';
                    }   
                }

            //catch Direcciones
            }catch(Exception e){
                system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());               
                return 'No se pudo sincronizar las direcciones desde SAP';
            }
        
            //Asignaciones
            if (response !=null && act.id != null){

                act.CondicionPago__c = switchIntCondition(response.paytermsgrpcode);
                act.Description = response.cardname;
                act.NumberOfEmployees = response.salespersoncode;
                act.Fax = response.fax;
                act.NombreFantasia__c = response.cardforeignname;

                //system.debug('Currency '+response.currencys);
                //Validación de existencia de Giro
                Giro__c giro = new Giro__c();
                giro = chkGiro(act.Giro__c, response.currencys,response.notes);
                if(giro!=null){
                    act.Giro__c = giro.Id;
                }

                if(response.emailaddress=='null'){act.Email__c =null;}else{act.Email__c = response.emailaddress;}
                
                act.Name = response.cardname;
                act.Ownership = response.properties1;
                act.Website = response.website;
                act.Phone = response.cellular;
                
                //Calculo para CardType
                if(response.cardtype == 'cCustomer'){
                    act.CardType__c = 'C';
                }else{
                    act.CardType__c = 'P';
                }
                
                act.GroupCode__c = response.groupcode;
                act.CreditLine__c = response.creditlimit;
                act.DebtLine__c = response.maxcommitment;
                act.SlpCode__c = response.salespersoncode;
                
                switch on response.currencys {            
                    when 'UF' { act.CurrencyIsoCode = 'CLF'; }
                    when 'USD' { act.CurrencyIsoCode = 'USD'; }
                    when 'EUR' { act.CurrencyIsoCode = 'EUR'; }
                    when else { act.CurrencyIsoCode = 'CLP'; }
                }
                
                act.Country__c = response.country;
                act.EstadoSAP__c = 'Validado por SAP';
                
                if(response.AliasName!=null){
                    act.NombreFantasia__c = response.AliasName;
                }else{
                    act.NombreFantasia__c = response.cardname;
                }

                if(response.blockSendingmarketingcontent == 'tNO'){
                    act.BlockComm__c = false;
                }else{
                    act.BlockComm__c = true;
                } 
         
                try{
                    //Update Cuenta
                    update(act);
                    system.debug('CUENTA ACTUALIZADA EN SF');
                    //Insert / Update Contact
                    if (insCtc.size() > 0){
                        insert(insCtc);
                        system.debug('INSERT CONTACT');
                    }
                    if (updCtc.size() > 0){
                        update(updCtc);
                        system.debug('UPDATE CONTACT');
                    }
                    
                    //Insert / Update Direcciones
                    if (insDir.size() > 0){
                        insert(insDir);
                        system.debug('INSERT DIR');
                    }
                    if (updDir.size() > 0){
                        update(updDir);
                        system.debug('UPDATE DIR');
                    }
                    
                //catch upd
                }catch(Exception e){
                    system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
                    return 'No se puede sincronizar el cliente con SAP';
                }
                return null;
            }
            return null;
        }else{
            try{
                act.EstadoSAP__c='Cliente Inactivo en SAP';
                update(act);
            }catch(Exception e){
                system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            }
            return 'No se puede sincronizar con SAP, el cliente no se encuentra activo en SAP, contacte a su administrador de SAP';
        }
    }

    //Stock disponible para la venta, desde SAP incluye el on hand + en transito
    public static String inventario(String prodId) {
        String invId = null;
        Product2 prd = new Product2();
        Inventario__c inv = new Inventario__c();
        Map<String,String> invMap = new Map<String,String>();
        List<Inventario__c> invsf = new List<Inventario__c>();
        List<Inventario__c> lstInvIns = new List<Inventario__c>();
        List<Inventario__c> lstInvUpd = new List<Inventario__c>();

        Schema.DescribeFieldResult objFieldDescribe = Inventario__c.Bodega__c.getDescribe();
        List<Schema.PicklistEntry> lstPickListValues = objFieldDescribe.getPickListValues();
        List<String> lstPickListValuesStr = new List<String>();

        //Obtengo los valores de las bodegas para luego filtrar
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            lstPickListValuesStr.add(objPickList.getValue());
        }

        try{
            prd = [ SELECT  Id,Name,StockKeepingUnit,Family,cod_proveedor__c,Ultima_Actualizaci_n_Inventario__c
                    FROM Product2
                    WHERE Id =: prodId ];

            invsf = [ SELECT  Id,Name,Bodega__c
                      FROM Inventario__c
                      WHERE Producto__c =: prodId ];

        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
        }
        SL_Inventory_JSON response = LUREYE_Servicios_SAP.InventarioDisponible(prd.Name);
        if(response!=null){
            if(response.value.size()>0){

                for (Inventario__c inventario:invsf){
                    invMap.put(inventario.Bodega__c,inventario.Id);
                }

                //system.debug('response.value '+response.value);
                for(SL_Inventory_JSON.val values : response.value){
                    SYSTEM.DEBUG('values '+values);
                    inv = new Inventario__c();
                    //filtro por bodegas en salesforce
                    if(lstPickListValuesStr.contains(values.itemsitemwarehouseinfocollection.warehousecode)){
                        inv.Bodega__c=values.itemsitemwarehouseinfocollection.warehousecode;
                        inv.OnHand__c=values.itemsitemwarehouseinfocollection.instock;
                        inv.Comprometido__c=values.itemsitemwarehouseinfocollection.committed;
                        inv.OnOrder__c=values.itemsitemwarehouseinfocollection.ordered;
                        inv.Producto__c=prodId;
                        invId = invMap.get(String.valueOf(values.itemsitemwarehouseinfocollection.warehousecode));
                        if(invId != null){
                            inv.Id=invId;
                            lstInvUpd.add(inv);
                            system.debug('ACTUALIZA INVENTARIO'+inv);
                        }else{
                            lstInvIns.add(inv);
                            system.debug('INSERTA INVENTARIO'+inv);
                        }
                    }
                }

                try{
                    if (lstInvUpd.size()>0){
                        update(lstInvUpd);
                    }
                    if (lstInvIns.size()>0){
                        insert(lstInvIns);
                    }
                }catch(Exception e){
                    system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
                    system.debug('No se pudo sincronizar inventario');
                }

                DateTime dt = DateTime.now();
                prd.Ultima_Actualizaci_n_Inventario__c = dt.format('dd/MM/yyyy hh:mm:ss');
                update(prd);
                return null;
            }//end if items null
        }else{
            system.debug('No se encontró el producto en el inventario');
            return ('No se encontró el producto en el inventario');
        
        }//end if response null
        return null;
    }

    public static Account queryAccount(String idAccount){
        Account act = new Account();
        Account parAcct = new Account();
        //Almaceno datos de la cuenta
        try{
            act = [ SELECT  Id, CondicionPago__c, ParentId, Description, ShippingAddress,
                            BillingAddress, NumberOfEmployees, Fax, Giro__c, Industry,Name,
                            Ownership,RUT_SD__c, Website, Phone, Type, CardType__c, GroupCode__c,
                            CreditLine__c, DebtLine__c, SlpCode__c, CurrencyIsoCode, Country__c, NombreFantasia__c,
                            BlockComm__c, RUT_DV__c, Email__c,EstadoSAP__c
                    FROM    Account
                    WHERE   Id =: idAccount ];

            if (act.RUT_SD__c==null){
                if(act.ParentId != null){
                    parAcct = [ SELECT Id, CondicionPago__c, ParentId, Description, ShippingAddress,
                            BillingAddress, NumberOfEmployees, Fax, Giro__c, Industry,Name,
                            Ownership,RUT_SD__c, Website, Phone, Type, CardType__c, GroupCode__c,
                            CreditLine__c, DebtLine__c, SlpCode__c, CurrencyIsoCode, Country__c, NombreFantasia__c,
                            BlockComm__c, RUT_DV__c, Email__c,EstadoSAP__c
                    FROM    Account
                    WHERE   Id =: act.ParentId ];
                    return parAcct;
                }else{
                    return null;
                }

            }
            return act;
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            return null;
        }
    }
    
    //Valida si existen direcciones para el cliente
    public static List<Direccion__c> queryDirecciones(Account act){

        try{
            List<Direccion__c> direcciones = [ SELECT  Id,Tipo__c,LicTradNum__c,Region__c,Pais__c,StreetNo__c,
                                                        Name,TaxCode__c,GlblLocNum__c,CurrencyIsoCode,ZipCode__c,
                                                        Comuna__c,Ciudad__c,Street__c,Block__c
                                                FROM    Direccion__c
                                                WHERE   AccountId__c =: act.Id];
            
            return direcciones;
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            return null;
        }
    }

    public static String creaDireccion(String RutCode, List<Direccion__c> direcciones){
        
        String shipaddr = null, billaddr = null;
        Integer ship = 0, bill = 0;
        List <String> lstshipaddr = new List <String>();
        List <String> lstbilladdr = new List <String>();
        List <String> lstshipValidaddr = new List <String>();
        List <String> lstbillValidaddr = new List <String>();
        String address = '';
        boolean dirRep = false;
        for (Direccion__c clientDir : direcciones){
            
            if(clientDir.Tipo__c=='Despacho'){
                //Se valida que exista una sola dirección con nombre Despacho
                if(clientDir.Name == 'Despacho'){
                    ship=ship+1;
                }
                //Se valida si existen mas direcciones de tipo Despacho con el mismo nombre
                if(!lstshipValidaddr.contains(clientDir.Name)){
                    lstshipValidaddr.add(clientDir.Name);
                    shipaddr='{'+
                                '"AddressName": "'+clientDir.Name+'",'+
                                '"Street": "'+clientDir.Street__c+' '+clientDir.StreetNo__c+'",'+
                                '"Block": "'+clientDir.Comuna__c+'",'+
                                '"ZipCode": "'+clientDir.ZipCode__c+'",'+
                                '"City": "'+clientDir.Ciudad__c+'",'+
                                //'"County": "'+clientDir.Comuna__c+'",'+
                                '"Country": "'+clientDir.Pais__c+'",'+
                                //'"Country": "CL",'+
                                '"State": "'+clientDir.Region__c+'",'+
                                '"TaxCode": "'+clientDir.TaxCode__c+'",'+
                                '"AddressType": "bo_ShipTo",'+
                                '"StreetNo": "'+clientDir.StreetNo__c+'",'+
                                '"BPCode": "C'+RutCode+'",'+
                                '"GlobalLocationNumber": "'+clientDir.GlblLocNum__c+'",'+
                                '"BuildingFloorRoom": "'+clientDir.Block__c+'"'+ 
                                '}';
                    lstshipaddr.add(shipaddr);
                }else{
                    dirRep=true;
                }
            }else{
                //Se valida que exista una sola dirección con nombre Facturación
                
                if(clientDir.Name == 'Facturación'){
                    bill=bill+1;
                }
                if(!lstbillValidaddr.contains(clientDir.Name)){
                    lstbillValidaddr.add(clientDir.Name);
                    billaddr='{'+
                                '"AddressName": "'+clientDir.Name+'",'+
                                '"Street": "'+clientDir.Street__c+' '+clientDir.StreetNo__c+'",'+
                                '"Block": "'+clientDir.Comuna__c+'",'+
                                '"ZipCode": "'+clientDir.ZipCode__c+'",'+
                                '"City": "'+clientDir.Ciudad__c+'",'+
                                //'"County": "'+clientDir.Comuna__c+'",'+
                                '"Country": "'+clientDir.Pais__c+'",'+
                                //'"Country": "CL",'+
                                '"State": "'+clientDir.Region__c+'",'+
                                '"TaxCode": "'+clientDir.TaxCode__c+'",'+
                                '"AddressType": "bo_BillTo",'+
                                '"StreetNo": "'+clientDir.StreetNo__c+'",'+
                                '"BPCode": "C'+RutCode+'",'+
                                '"GlobalLocationNumber": "'+clientDir.GlblLocNum__c+'",'+
                                '"BuildingFloorRoom": "'+clientDir.Block__c+'"'+ 
                                '}';
                    lstbilladdr.add(billaddr);
                }else{
                    dirRep=true;
                }
            }     
        }
        
        if(ship != 1 || bill != 1){
            //Retorno un mensaje para poder mostrar el error
            return 'ERROR 1';
        }else if(dirRep){
            //Retorno un mensaje para poder mostrar el error
            return 'ERROR 2';
        }else{
            //Body de Direcciones
            address= bodyDir(lstshipaddr,lstbilladdr);
            return address;
        }
    }

    //Construye el body para direcciones
    public static String bodyDir(List <String> lstshipaddr,List <String> lstbilladdr){
        String address = '';
        if (lstshipaddr.size()> 0 && lstbilladdr.size()> 0 ){
            for (String shp : lstshipaddr){
                address= address+shp+',';
            }
            for (String bll : lstbilladdr){
                address= address+bll+',';
            }
        } else if (lstshipaddr.size()> 0 && lstbilladdr.size()== 0){
            for (String shp : lstshipaddr){
                address= address+shp+',';
            }
        } else if(lstshipaddr.size()== 0 && lstbilladdr.size() > 0){
            for (String bll : lstbilladdr){
                address= address+bll+',';
            }
        }
        
        if(address.length()>0){
            //Elimino la ultima coma
            address = address.substring(0, address.length()-1).replace('"null"', 'null');
        }
        return address;
    }

    //Valida si existe el giro, sino lo crea
    public static Giro__c chkGiro(String idGiro, String currencyCode, String rspgiro){

        Giro__c giro = new Giro__c();
        switch on currencyCode {            
            when 'UF'{currencyCode = 'CLF';}
            when 'USD'{currencyCode = 'USD';}
            when 'EUR'{currencyCode = 'EUR';}
            when else {currencyCode = 'CLP';}
        }
        
        if(idGiro == null && rspgiro!=null){
            system.debug('NO EXISTE GIRO ASOCIADO A LA CUENTA');
            try{
                giro = [ SELECT  Id, Codigo__c, CurrencyIsoCode,Name                      
                         FROM    Giro__c
                         WHERE   Codigo__c =: rspgiro LIMIT 1];
                
                if (giro.Codigo__c != rspgiro || giro.CurrencyIsoCode != currencyCode){
                    giro.Name = rspgiro;
                    giro.Codigo__c = rspgiro;
                    giro.CurrencyIsoCode = currencyCode;
                    update giro;
                    system.debug('GIRO ACTUALIZADO EN SF');
                }
                return giro;
            }catch(Exception e){
                system.debug('NO EXISTE GIRO EN SF');
            }
            giro.Codigo__c = rspgiro;
            giro.Name = rspgiro;
            giro.CurrencyIsoCode = currencyCode;
            try{
                insert giro;
            }catch(Exception e){
                system.debug('ERROR EN INSERTAR GIRO EN SF');
                return null;
            }
            system.debug('GIRO INSERTADO EN SF');
            return giro;

        }else if (idGiro != null && rspgiro!=null){
            try{
                giro = [ SELECT  Id, Codigo__c, CurrencyIsoCode,Name                       
                         FROM    Giro__c
                         WHERE   Id =: idGiro ];
                if (giro.Codigo__c != rspgiro || giro.CurrencyIsoCode != currencyCode){
                    giro.Name = rspgiro;
                    giro.Codigo__c = rspgiro;
                    giro.CurrencyIsoCode = currencyCode;
                    
                    system.debug('EXISTE GIRO CON DIFERENTE NOMBRE O DIFERENTE DIVISA');
                    system.debug('UPDT GIRO CON SAP');
                    update(giro);
                    return giro;
                    
                }else{
                    system.debug('GIRO ACTUALIZADO');
                    return giro;
                }
            }catch(Exception e){
                system.debug('ERROR EN CONSULTA O UPDATE DEL GIRO');
                return null;
            }
        }else if (idGiro != null && rspgiro==null){
            try{
                giro = [ SELECT  Id, Name, CurrencyIsoCode,Codigo__c                     
                         FROM    Giro__c
                         WHERE   Id =: idGiro ];
                return giro;      
            }catch(Exception e){
                system.debug('ERROR EN CONSULTA DE GIRO');
                return null;
            }
        }
        return null;
    }

    public static List<Contact> queryContact(String idAccount){

        //Almaceno datos del contacto
        try{
            List<Contact> ctc = [ SELECT  Id,Title,MobilePhone,HomePhone,Email,Name,Phone,FirstName,
                                          MiddleName,LastName,Fax
                                  FROM    Contact
                                  WHERE   AccountId =: idAccount ];
            return ctc;
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            return null;
        }
    }

    public static Integer switchStrCondition(String condition) {
        Integer condicionPago = null;
    
        switch on condition {
            //Condicion Salesforce-->Sap

            when 'Contado' { condicionPago = -1; }
            when '30 días Precio Contado' { condicionPago = 1; }
            when '60 Días sin Intereses' { condicionPago = 2; }
            when '90 Días sin Intereses' { condicionPago = 3; }
            when 'Cuotas 30, 60, 90 s/Intereses' { condicionPago = 4; }
            when 'Crédito 30 días' { condicionPago = 5; }
            when 'Anticipo, Cheques 30 y 60 días' { condicionPago = 6; }
            when 'Anticipo, Cheques 30, 60 y 90 días' { condicionPago = 7; }
            when 'Crédito 7 días' { condicionPago = 8; }
            when 'Crédito 15 días' { condicionPago = 9; }

            when 'Crédito 45 días' { condicionPago = 10; }
            when 'Crédito 75 días' { condicionPago = 11; }
            when 'Anticipo 20% saldo 30 días' { condicionPago = 12; }
            when 'Anticipo 30% saldo 30 días' { condicionPago = 13; }
            when 'Anticipo 40% saldo 30 días' { condicionPago = 14; }
            when 'Anticipo 50% saldo 30 días' { condicionPago = 15; }
            when 'Crédito 60 días' { condicionPago = 16; }
            when 'Anticipo, saldo 30 días' { condicionPago = 17; }
            when 'Anticipo 20% saldo 60 días' { condicionPago = 18; }
            when 'Anticipo 30% saldo 60 días' { condicionPago = 19; }

            when 'Anticipo 40% saldo 60 días' { condicionPago = 20; }
            when 'Anticipo 50% saldo 60 días' { condicionPago = 21; }
            when 'Cheque adjunto 30 días' { condicionPago = 22; }
            when 'Anticipo 40% saldo 30 y 60 días' { condicionPago = 23; }
            when 'Anticipo 40% saldo 30, 60 y 90 días' { condicionPago = 24; }
            when 'Anticipo 20% saldo 30 y 60 días' { condicionPago = 25; }
            when 'Crédito 90 días' { condicionPago = 26; }
            when 'Anticipo 20% saldo 30, 60 y 90 días' { condicionPago = 27; }
            when 'Anticipo 40%, Cheques 30, 60 y 90 días' { condicionPago = 28; }
            when 'Anticipo 40%, Cheques 30 y 60 días' { condicionPago = 29; }

            when 'Cheque adjunto 30 y 60 días' { condicionPago = 30; }
            when 'Cheque adjunto 30, 60 y 90 días' { condicionPago = 31; }
            when 'Cheque adjunto 45 días' { condicionPago = 32; }
            when 'Cheque adjunto 60 días' { condicionPago = 33; }
            when 'Anticipo,Cheques 30 y 45 días' { condicionPago = 34; }
            when 'Anticipo 50% saldo contra entrega' { condicionPago = 35; }
            when 'Leasing' { condicionPago = 36; }
            when 'Anticipo 60% saldo 30, 60 y 90 días' { condicionPago = 37; }
            when 'Anticipo 40% saldo contra entrega' { condicionPago = 38; }
            when 'Anticipo 50%, Cheques 30, 60 y 90 días' { condicionPago = 39; }         

            when 'Anticipo 70%, Cheques 30 días' { condicionPago = 40; } 
            when 'Anticipo 70%, Cheques 30 y 60 días' { condicionPago = 41; } 
            when 'Anticipo 70%, Cheques 30, 60 y 90 días' { condicionPago = 42; } 
            when 'Anticipo, Cheques 30 días' { condicionPago = 43; }            

            when else { condicionPago = -1; } // default block, optional
        }
        return condicionPago;
    }

    public static String switchIntCondition(Integer condition){
        String condicionPago=null;

        switch on condition {
            //Condicion Sap-->Salesforce
            when -1 {condicionPago = 'Contado';}    
            when 1  {condicionPago ='30 días Precio Contado';}
            when 2  {condicionPago ='60 Días sin Intereses';}
            when 3  {condicionPago ='90 Días sin Intereses';}
            when 4  {condicionPago ='Cuotas 30, 60, 90 s/Intereses';}
            when 5  {condicionPago ='Crédito 30 días';}
            when 6  {condicionPago ='Anticipo, Cheques 30 y 60 días';}
            when 7  {condicionPago ='Anticipo, Cheques 30, 60 y 90 días';}
            when 8  {condicionPago ='Crédito 7 días';}
            when 9  {condicionPago ='Crédito 15 días';}

            when 10 {condicionPago ='Crédito 45 días';}
            when 11 {condicionPago ='Crédito 75 días';}
            when 12 {condicionPago ='Anticipo 20% saldo 30 días';}
            when 13 {condicionPago ='Anticipo 30% saldo 30 días';}
            when 14 {condicionPago ='Anticipo 40% saldo 30 días';}
            when 15 {condicionPago ='Anticipo 50% saldo 30 días';}
            when 16 {condicionPago ='Crédito 60 días';}
            when 17 {condicionPago ='Anticipo, saldo 30 días';}
            when 18 {condicionPago ='Anticipo 20% saldo 60 días';}
            when 19 {condicionPago ='Anticipo 30% saldo 60 días';}

            when 20 {condicionPago ='Anticipo 40% saldo 60 días';}
            when 21 {condicionPago ='Anticipo 50% saldo 60 días';}
            when 22 {condicionPago ='Cheque adjunto 30 días';}
            when 23 {condicionPago ='Anticipo 40% saldo 30 y 60 días';}
            when 24 {condicionPago ='Anticipo 40% saldo 30, 60 y 90 días';}
            when 25 {condicionPago ='Anticipo 20% saldo 30 y 60 días';}
            when 26 {condicionPago ='Crédito 90 días';}
            when 27 {condicionPago ='Anticipo 20% saldo 30, 60 y 90 días';}
            when 28 {condicionPago ='Anticipo 40%, Cheques 30, 60 y 90 días';}
            when 29 {condicionPago ='Anticipo 40%, Cheques 30 y 60 días';}

            when 30 {condicionPago ='Cheque adjunto 30 y 60 días';}
            when 31 {condicionPago ='Cheque adjunto 30, 60 y 90 días';}
            when 32 {condicionPago ='Cheque adjunto 45 días';}
            when 33 {condicionPago ='Cheque adjunto 60 días';}
            when 34 {condicionPago ='Anticipo,Cheques 30 y 45 días';}
            when 35 {condicionPago ='Anticipo 50% saldo contra entrega';}
            when 36 {condicionPago ='Leasing';}
            when 37 {condicionPago ='Anticipo 60% saldo 30, 60 y 90 días';}
            when 38 {condicionPago ='Anticipo 40% saldo contra entrega';}
            when 39 {condicionPago ='Anticipo 50%, Cheques 30, 60 y 90 días';}

            when 40 {condicionPago ='Anticipo 70%, Cheques 30 días';}
            when 41 {condicionPago ='Anticipo 70%, Cheques 30 y 60 días';}
            when 42 {condicionPago ='Anticipo 70%, Cheques 30, 60 y 90 días';}
            when 43 {condicionPago ='Anticipo, Cheques 30 días';}

            when else {condicionPago = 'Contado';}
        }
        return condicionPago;
    }

    public PageReference volver(){
        PageReference back = new PageReference('/'+idCuenta);
        back.setRedirect(true);
        return back;   
    }
}