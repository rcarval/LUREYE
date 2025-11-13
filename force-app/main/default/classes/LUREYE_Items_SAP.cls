public class LUREYE_Items_SAP {

    public static String createQuoteLI(Map<Id, String> prdMap, List<QuoteLineItem> qryQuoteLineItem, Decimal order,
    String costingcode, String sucursal, Decimal lineaN, String glosa, String bodega){
     
        String bodyQuoteLI = null, body = '', productName='', sBodega='';
        List <String> lstQuoteLI = new List <String>();
        Product2 prd = new Product2();
        integer it = 0, cuartaDimension = 4001;

        // Construir la cadena de WarehouseCode si bodega no es null
        if (bodega != null) {
            sBodega = ',"WarehouseCode": "'+bodega+'"';
        }

        for (QuoteLineItem QuoteLineItem : qryQuoteLineItem){
            productName = '';
            try{
                productName=prdMap.get(QuoteLineItem.Product2Id);
                if(order == null){
                    bodyQuoteLI='{'+
                                '"ItemCode": "'+productName+'",'+
                                '"Quantity": "'+QuoteLineItem.Quantity+'",'+
                                '"TaxCode": "IVA",'+
                                '"CostingCode": "'+costingcode+'",'+
                                '"CostingCode2": "'+lineaN+'",'+
                                '"CostingCode3": "'+sucursal+'",'+
                                '"CostingCode4": "'+cuartaDimension+'",'+
                                '"COGSCostingCode": "'+costingcode+'",'+
                                '"COGSCostingCode2": "'+lineaN+'",'+
                                '"COGSCostingCode3": "'+sucursal+'",'+
                                '"COGSCostingCode4": "'+cuartaDimension+'",'+
                                '"U_EXX_FE_QBLI": "'+QuoteLineItem.QLBI__c+'",'+
                                '"FreeText": "'+glosa+'",'+
                                '"UnitPrice": "'+QuoteLineItem.UnitPrice+'"'+
                                sBodega + // Agregar WarehouseCode si no es null
                                '}';
                }else{
                    bodyQuoteLI='{'+
                                '"ItemCode": "'+productName+'",'+
                                '"Quantity": "'+QuoteLineItem.Quantity+'",'+
                                '"TaxCode": "IVA",'+
                                '"CostingCode": "'+costingcode+'",'+
                                '"CostingCode2": "'+lineaN+'",'+
                                '"CostingCode3": "'+sucursal+'",'+
                                '"CostingCode4": "'+cuartaDimension+'",'+
                                '"COGSCostingCode2": "'+lineaN+'",'+
                                '"COGSCostingCode3": "'+sucursal+'",'+
                                '"COGSCostingCode4": "'+cuartaDimension+'",'+
                                '"U_EXX_FE_QBLI": "'+QuoteLineItem.QLBI__c+'",'+
                                '"FreeText": "'+glosa+'",'+
                                '"UnitPrice": "'+QuoteLineItem.UnitPrice+'",'+
                                '"BaseType": 23,'+
                                '"BaseLine": '+it+','+
                                '"BaseEntry": "'+order+'"'+
                                sBodega + // Agregar WarehouseCode si no es null
                                '}';
                }
                it=it+1;
                lstQuoteLI.add(bodyQuoteLI);

            }catch(Exception e){
                system.debug('Error Message: '+ e.getMessage()+'. Cause: '+e.getCause()+'. Line Number: '+e.getLineNumber()+'. Stack Trace: '+e.getStackTraceString());
            }
        }

        for (String QuoteLI : lstQuoteLI){
            //Construye el body para los Items
            body= body+QuoteLI+',';
        }
       
        if(body.length()>0){
            //Elimino la ultima coma
            body = body.substring(0, body.length()-1).replace('"null"', 'null');
        }
        return body;
    }    

    public static String direcciones(List <String> lstshipaddr,List <String> lstbilladdr){
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
}