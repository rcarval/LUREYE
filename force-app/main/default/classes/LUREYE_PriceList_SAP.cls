public class LUREYE_PriceList_SAP {

    @InvocableMethod(label='Ejecutar SincronizarLPSap' description='')
    public static void SincronizarLPSap(){
        priceLists();
    }

    //Lista de precios base
    @future (callout=true)
    public static void priceLists() {
        Boolean pLnew=false;
        List<Pricebook2> priceLists = new List<Pricebook2>();
        Pricebook2 nullPriceList = new Pricebook2();
        List<Pricebook2> newPriceLists = new List<Pricebook2>();
        List<Pricebook2> updPriceLists = new List<Pricebook2>();
        try{
            priceLists = [ SELECT  Name,Cuenta__c,IsActive,IsStandard,Company__c
                           FROM Pricebook2 
                           LIMIT 5000];
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
        }

        SL_Price_List_JSON response = LUREYE_Servicios_SAP.ListaPrecios();
        if(response!=null){
            if(response.value.size()>0){
                for (SL_Price_List_JSON.val val:response.value){
                    pLnew=false;
                    //system.debug('val '+val.pricelistname);
                    for (Pricebook2 pList:priceLists){
                        if (pList.Name == val.pricelistname){
                            pLNew=true;
                            if(val.active=='tYES'){pList.IsActive=true;}else{pList.IsActive=false;}
                            //pList.IsStandard=true;
                            pList.Company__c = String.valueOf(val.pricelistno);
                            updPriceLists.add(pList);
                        }
                    }
                    if (!pLNew){
                        nullPriceList = new Pricebook2();
                        nullPriceList.Name = val.pricelistname;
                        nullPriceList.Company__c = String.valueOf(val.pricelistno);
                        if(val.active=='tYES'){nullPriceList.IsActive=true;}else{nullPriceList.IsActive=false;}
                        //nullPriceList.IsStandard=true;
                        newPriceLists.add(nullPriceList);
                    }
                }
            } //End List value null
        } //End if response null
        try{
            if (updPriceLists.size()>0){
                update(updPriceLists);
            }
            if (newPriceLists.size()>0){
                insert(newPriceLists);
            }
        }catch(Exception e){
            system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            system.debug('No se pudo sincronizar la lista de precios con SAP');
        }
        
        system.debug('response: '+response);
    }

}