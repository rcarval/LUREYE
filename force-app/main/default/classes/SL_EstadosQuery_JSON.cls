public class SL_EstadosQuery_JSON {
    public String odatametadata;
    public String SqlText;
    public List<Value> value;

    public class Value {
        public String CANCELED;
        public String Comments;
        public Integer DocEntry;
        public Integer DocNum;
        public String DocStatus;
        public Integer OVDocEntry;
        public Integer OVDocNum;
        public String OVDocStatus;
        public String OVWddStatus;
        public String U_IDCajaHisto;
        public String WddStatus;
    }

    public static SL_EstadosQuery_JSON parse(String json) {
        return (SL_EstadosQuery_JSON) System.JSON.deserialize(json, SL_EstadosQuery_JSON.class);
    }
}