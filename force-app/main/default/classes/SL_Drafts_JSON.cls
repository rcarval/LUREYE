public class SL_Drafts_JSON {
    public Integer docentry;
    public Integer docnum;
    public String documentstatus;
    public String authorizationstatus;
    public List<val> value;

    public class val{
        public Integer docentry;
        public Integer docnum;
        public String documentstatus;
        public String authorizationstatus;
    }

    public static SL_Drafts_JSON parse(String json) {
        return (SL_Drafts_JSON) System.JSON.deserialize(json, SL_Drafts_JSON.class);
    }
}