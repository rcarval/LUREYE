global class LUREYE_PriceListItems_SAP {   

    @InvocableMethod(label='Ejecutar SincronizarLPItemsSap' description='')
    global static void SincronizarLPItemsSap(){ 
        priceListsItems();
    }

    public static void priceListsItems() {

        List<PricebookEntry> lstpriceItems = new List<PricebookEntry>();
        PricebookEntry priceItems = new PricebookEntry();
        SL_Price_List_Items_JSON response = LUREYE_Servicios_SAP.ListaPreciosItems();
        Map<String, String> pricelists = new Map<String, String>();
        String priceid=null;
        //Valido que se haya obtenido respuesta del servicio
        if(response!=null){
            if(response.value.size()>0){
                system.debug('response.value '+response.value);
                
                //Almaceno los Ids de las listas de precio
                for (Pricebook2 pricelist : [SELECT Id,Company__c FROM Pricebook2 LIMIT 1000]) {
                    pricelists.put(pricelist.Company__c, pricelist.Id);
                }
                
                //Recorro la respuesta del servicio
                for (SL_Price_List_Items_JSON.val prices:response.value){
                    priceItems = new PricebookEntry();
                    //Valido campo requerido de tipo de moneda
                    if(prices.currencys!=null){
                        priceItems.CurrencyIsoCode = prices.currencys;
                    }else{
                        priceItems.CurrencyIsoCode='CLP';
                    }
                    //Valido campo requerido de precio
                    if(prices.price!=null){priceItems.UnitPrice = prices.price;}else{priceItems.UnitPrice=0;}
                    priceid = pricelists.get(String.valueOf(prices.listnum));
                    priceItems.Pricebook2Id = priceid;
                    priceItems.IsActive=true;
                    priceItems.ItemCode__c=prices.itemcode;
                    lstpriceItems.add(priceItems);
                    
                }//End for

                //Valido que tenga valores la lista de Entrada de Precios
                if(lstpriceItems.size()>0){
                    //Hago la llamada a proceso batch
                    LUREYE_PriceListItems_SAP_Batch call = new LUREYE_PriceListItems_SAP_Batch(lstpriceItems);
                    Database.executeBatch(call,50);
                    system.debug('SE ENVIA ENTRADA DE LISTAS DE PRECIOS A PROCESO BATCH');
                }

            }//End if size()
        } //End if response null
        
    }

}