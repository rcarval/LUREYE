public class SL_Price_List_JSON {
    public String odatametadata;
    public List<val> value;

    public class val{
        public String roundingmethod;
        public String groupnum;
        public Integer basepricelist;
        public Double factor;
        public Integer pricelistno;
        public String pricelistname;
        public String isgrossprice;
        public String active;
        public String validfrom;
        public String validto;
        public String defaultprimecurrency;
        public String defaultadditionalcurrency1;
        public String defaultadditionalcurrency2;
        public String roundingrule;
        public Double fixedamount;
    }

    public static SL_Price_List_JSON parse(String json) {
        return (SL_Price_List_JSON) System.JSON.deserialize(json, SL_Price_List_JSON.class);
    }
}