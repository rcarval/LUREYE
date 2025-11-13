global class LUREYE_PriceListItems_SAP_Batch implements Database.Batchable<PricebookEntry>{
    List<PricebookEntry> lstpriceItems;

    //Constructor
    global LUREYE_PriceListItems_SAP_Batch(List<PricebookEntry> lst) {
        this.lstpriceItems = lst;
    }

    global List<PricebookEntry> start(Database.BatchableContext info){ 
        system.debug('start');
        system.debug('lstpriceItems '+this.lstpriceItems);
        return this.lstpriceItems; 
    }     

    //Ejecuta por lotes
    global void execute(Database.BatchableContext info, List<PricebookEntry> lstpbEntry){
        
        try{
            List<PricebookEntry> lstpriceItemsNew = new List<PricebookEntry>();
            List<PricebookEntry> lstpriceItemsUpd = new List<PricebookEntry>();
            List<PricebookEntry> lststdpriceItemsNew = new List<PricebookEntry>();
            List<Pricebook2> stdPriceLst = new List<Pricebook2>();
            List<PricebookEntry> stdPrice = new List<PricebookEntry>();
            PricebookEntry priceEntry = new PricebookEntry();
            PricebookEntry priceEntryClone = new PricebookEntry();
            List<PricebookEntry> qrypriceEntry = new List<PricebookEntry>();
            Product2 prdNew = new Product2();
            List<String> lstprdNames = new List<String>();
            Map<String,String> prdIds = new Map<String,String>();
            String prdName = null, prdId = null;

            //Valido la lista recibida
            if(lstpbEntry.size()>0){
                //Obtengo el Id de la lista de precios Standard
                stdPriceLst = [SELECT Id FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];

                //Obtengo los productos del lote procesado
                for (PricebookEntry prdNames:lstpbEntry){
                    //system.debug('Nombre de producto: '+prdNames.ItemCode__c);
                    lstprdNames.add(prdNames.ItemCode__c);
                }

                //Obtengo los Id de los productos
                List<Product2> prds = [SELECT Name, Id 
                                        FROM Product2 
                                        WHERE Name IN :lstprdNames];

                //Cargo en Map para manipular la data                        
                for (Product2 prd:prds){
                    prdIds.put(prd.Name,prd.Id);
                }

                //Recorro la Entrada de Listas de Precios
                for (PricebookEntry addEntry:lstpbEntry){
                    //Busco el Id del producto
                    prdId = prdIds.get(String.valueOf(addEntry.ItemCode__c));
                    if(prdId!=null){
                        if(stdPriceLst.size()==1){
                            //Valido si tiene precio en la Standard Price List
                            stdPrice = [SELECT Id 
                                        FROM PricebookEntry 
                                        WHERE Pricebook2Id =: stdPriceLst[0].Id AND 
                                                Product2Id =: prdIds.get(String.valueOf(addEntry.ItemCode__c))
                                                AND CurrencyIsoCode =: addEntry.CurrencyIsoCode
                                                LIMIT 1];
                            if(stdPrice.size()==0){
                                system.debug('No posee precio en la Standard Price para producto existente');
                                priceEntry = new PricebookEntry(); 
                                priceEntryClone = new PricebookEntry();
                                priceEntry.Product2Id=prdIds.get(String.valueOf(addEntry.ItemCode__c));
                                priceEntry.IsActive = true;
                                priceEntry.CurrencyIsoCode = addEntry.CurrencyIsoCode;
                                
                                priceEntry.UnitPrice = addEntry.UnitPrice;
                                priceEntry.UseStandardPrice = false;
                                //Clono la lista hasta este momento para poder hacer el insert de la lista de precios
                                priceEntryClone = priceEntry.clone();
                                priceEntry.Pricebook2Id = stdPriceLst[0].Id;
                                //Añado a la lista de precios Standard
                                lststdpriceItemsNew.add(priceEntry);
                                system.debug('Se inserta un precio para la Lista Standard '+ priceEntry);
                                
                                //Se carga el id de la lista de precios a insertar
                                priceEntryClone.Pricebook2Id = addEntry.Pricebook2Id;
                                lstpriceItemsNew.add(priceEntryClone);
                                system.debug('Se inserta un precio para la Lista de precios '+ priceEntryClone);
                            
                            }else{
                                priceEntry = new PricebookEntry(); 
                                priceEntry.Product2Id=prdId;
                                priceEntry.IsActive = true;
                                priceEntry.CurrencyIsoCode = addEntry.CurrencyIsoCode;
                                priceEntry.Pricebook2Id = addEntry.Pricebook2Id;
                                priceEntry.UnitPrice = addEntry.UnitPrice;
                                priceEntry.UseStandardPrice = false;

                                //Valido si ya existe la entrada de lista de precio
                                qrypriceEntry = new List<PricebookEntry>([  SELECT Id 
                                                                            FROM   PricebookEntry
                                                                            WHERE  Pricebook2Id =: addEntry.Pricebook2Id 
                                                                            AND    Product2Id =: prdId LIMIT 1]); 
                                
                                if(qrypriceEntry.size() == 1){
                                    priceEntry.id = qrypriceEntry[0].Id;
                                    lstpriceItemsUpd.add(priceEntry);
                                    system.debug('Se añade a la lista para actualizar '+ qrypriceEntry[0].Id);
                                }else{
                                    lstpriceItemsNew.add(priceEntry);
                                    system.debug('Se añade a la lista para insertar '+ priceEntry.Product2Id);
                                }
                                /*upsert(priceEntry);
                                system.debug('Se inserta/actualiza un precio para la Lista de precios '+ addEntry.Pricebook2Id);*/
                            }
                        }

                    }else{
                        //Se debe crear el producto
                        prdNew.Name=addEntry.ItemCode__c;
                        prdNew.ProductCode=addEntry.ItemCode__c;
                        prdNew.IsActive=true;
                        prdNew.CurrencyIsoCode=addEntry.CurrencyIsoCode;
                        insert(prdNew);
                        system.debug('Se crea el producto '+ prdNew.Name);
                         
                        if(stdPriceLst.size()==1){
                            system.debug('Se crea precio en la Standard Price para producto nuevo');
                            //Se debe insertar la entrada en el Standard Price Book
                            priceEntry = new PricebookEntry(); 
                            priceEntryClone = new PricebookEntry();
                            priceEntry.Product2Id=prdNew.Id;
                            priceEntry.IsActive = true;
                            priceEntry.CurrencyIsoCode = addEntry.CurrencyIsoCode;
                            priceEntry.UnitPrice = addEntry.UnitPrice;
                            priceEntry.UseStandardPrice = false;
                            //Clono la lista hasta este momento para poder hacer el insert de la lista de precios
                            priceEntryClone = priceEntry.clone();
                            priceEntry.Pricebook2Id = stdPriceLst[0].Id;
                            //Añado a la lista de precios Standard
                            lststdpriceItemsNew.add(priceEntry);
                            system.debug('Se inserta un precio para la Lista Standard '+ priceEntry);
                            
                            //Se carga el id de la lista de precios a insertar
                            priceEntryClone.Pricebook2Id = addEntry.Pricebook2Id;
                            lstpriceItemsNew.add(priceEntryClone);
                            system.debug('Se inserta un precio para la Lista de precios '+ priceEntryClone);
                        
                        }else{
                            system.debug('NO SE ENCONTRO LISTA DE PRECIOS STANDARD');
                            //return null;
                        }
                    }
                
                }
                if(lststdpriceItemsNew.size()>0){
                    //Inserto todos los registros que se necesitan en la lista Standard 
                    system.debug('lststdpriceItemsNew '+lststdpriceItemsNew);                               
                    insert(lststdpriceItemsNew);
                }

                if(lstpriceItemsNew.size()>0){
                    //Inserto todos los registros que se necesitan en la listas correspondientes  
                    system.debug('lstpriceItemsNew '+lstpriceItemsNew);                              
                    insert(lstpriceItemsNew);
                }

                if(lstpriceItemsUpd.size()>0){
                    //Actualizo todos los registros que se necesitan en la listas correspondientes                                
                    update(lstpriceItemsUpd);
                }
                
            }
            
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext info){     
    
    }

}