public class SL_Inventory_JSON {
    public String odatametadata;
    public List<val> value;

    public class val{
        public item items;
        public wharehouse itemsitemwarehouseinfocollection;
    }

    public class item{
        public String itemcode;
        public String itemname;
        public String valid;
        public Double avgstdprice;
    }

    public class wharehouse{
        public String warehousecode;
        public Double instock;
        public Double committed;
        public Double ordered;
    }

    public static SL_Inventory_JSON parse(String json) {
        return (SL_Inventory_JSON) System.JSON.deserialize(json, SL_Inventory_JSON.class);
    }

}