global class CS_EventNotifyBatch implements Database.Batchable<Quote>, Database.AllowsCallouts {
    private Integer branchId;
    public SL_Login_JSON login_c;

    public CS_EventNotifyBatch(Integer branchId) {
        this.branchId = branchId;
    }    

    public Iterable<Quote> start(Database.BatchableContext context) {
        return [
            SELECT Id, DocEntry__c, OVDocEntry__c, OVDocNum__c, Estado_en_SAP__c, CreatedBy.Branch__c, CodigoUN__c
            FROM Quote
            WHERE Opportunity.StageName IN ('Cotización', 'Propuesta', 'Negociación')
            AND Status  = 'Approved'
            AND Estado_en_SAP__c NOT IN ('No Ingresado')
            AND Owner.IsActive = true
            AND CreatedDate >= 2024-01-01T00:00:00Z
            AND CreatedBy.Branch__c =: branchId
        ];
    }

    public void execute(Database.BatchableContext context, List<Quote> quotes) {
        if (!Test.isRunningTest()) {
            login_c = LUREYE_Servicios_SAP.callLogin(branchId);
        } else {
            login_c = (SL_Login_JSON) JSON.deserialize(
                '{"odata.metadata": "https://sap10.com:50001/b1s/v1/$metadata#B1Sessions/@Element","SessionId": "e413fb8e-61","Version": "1000190","SessionTimeout": 30}',
                SL_Login_JSON.class
            );
        }
        
        if (login_c == null){
            System.debug('ERROR desde SSL: no fue posible realizar login');
            return;
        }

        if (!quotes.isEmpty()) {
            SL_EstadosQuery_JSON result = CS_EventNotify.getListStatus(login_c);
            
            if (result != null) {
                List<Quote> quotesToUpdate = new List<Quote>();
                for (Quote cot : quotes) {
                    Integer qDocEntry   = (Integer)cot.DocEntry__c;
                    String qStatus      = cot.Estado_en_SAP__c;
    
                    // Encuentra la correspondencia en el resultado de SAP
                    for (SL_EstadosQuery_JSON.Value sl : result.value) {
                        if (sl.DocEntry == qDocEntry) {
                            String status = CS_EventNotify.getOnlyStatusQuote(sl.OVDocEntry, sl.CANCELED, sl.DocStatus, sl.WddStatus);
    
                            if (!qStatus.equals(status)) {
                                // Actualizar la cotización en Salesforce
                                cot.Estado_en_SAP__c  = status;
                                cot.OVDocEntry__c     = sl.OVDocEntry;
                                cot.OVDocNum__c       = sl.OVDocNum;

                                if (status.equals('Documento Autorizado') && !cot.CodigoUN__c.equals('GE')) {
                                    Boolean ejecucion = CS_EventNotify.postDraftToDocument(Integer.valueOf(cot.DocEntry__c), login_c);
                                    if (ejecucion) {
                                        // Segunda llamada a getOVDocNum para obtener estado actualizado
                                        SL_EstadosQuery_JSON rOrdenVenta = CS_EventNotify.getOVDocNum(Integer.valueOf(cot.DocEntry__c), login_c);
                                        if (rOrdenVenta != null && !rOrdenVenta.value.isEmpty()) {
                                            SL_EstadosQuery_JSON.Value vOV = rOrdenVenta.value.get(0);
                                            cot.Estado_en_SAP__c    = 'Orden de Venta Creada';
                                            cot.OVDocEntry__c       = vOV.OVDocEntry;
                                            cot.OVDocNum__c         = vOV.OVDocNum;
                                            System.debug('CASOMAP: ' + cot.DocEntry__c + ': OV CREADA ' + cot.OVDocNum__c);
                                        } else {
                                            System.debug('ERROR DRAFT: ' + cot.DocEntry__c + ': NO PUDO SER CREADA OV');
                                        }
                                    }
                                }
                                quotesToUpdate.add(cot);
                            }
                            break;
                        }
                    }
                }
    
                if (!quotesToUpdate.isEmpty()) {
                    System.enqueueJob(new QuoteUpdateQueueable(quotesToUpdate));
                    System.debug('ESTADOS ACTUALIZADOS');
                }
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        System.debug('FINALIZO LA ACTUALIZACIÓN DE ESTADOS');    
    }
}