public class SL_Login_JSON {
    public String metadata;
    public String sessionId;
    public String version;
    public String sessionTimeout;
 
    public static SL_Login_JSON parse(String json) {
        return (SL_Login_JSON) System.JSON.deserialize(json, SL_Login_JSON.class);
    }
}