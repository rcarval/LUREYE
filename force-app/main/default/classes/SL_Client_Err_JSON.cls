public class SL_Client_Err_JSON {
    
    public err error;

    public class err{
        public String code;
        public msg message;
    }

    public class msg{
        public String lang;
        public String value;
    }
    public static SL_Client_Err_JSON parse(String json) {
        return (SL_Client_Err_JSON) System.JSON.deserialize(json, SL_Client_Err_JSON.class);
    }
}