public class SL_Price_List_Items_JSON {
    public String odatametadata;
    public String sqltest;
    public List<val> value;

    public class val{
        public String currencys;
        public String factor;
        public String itemcode;
        public String listnum;
        public Double Price;
    }

    public class items{
        public Integer pricelist;
        public Double price;
        public String currencys;
        public Double additionalprice1;
        public String additionalcurrency1;
        public Double additionalprice2;
        public String additionalCurrency2;
        public Integer basepricelist;
        public Double factor;
        public List<uomp> uomprices;
    }

    public class uomp{}

    public static SL_Price_List_Items_JSON parse(String json) {
        return (SL_Price_List_Items_JSON) System.JSON.deserialize(json, SL_Price_List_Items_JSON.class);
    }
}