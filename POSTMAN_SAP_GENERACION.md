# Curl para consultar productos de Generación en SAP

## 📋 Información necesaria (reemplazar en el curl)

Basándome en el código de `LUREYE_Product_Synch_from_SAP.cls` y `LUREYE_Servicios_SAP.cls`, necesitas obtener estos valores de tu org:

### 1. Obtener valores de SAP__mdt (LoginGE)
Ejecuta en Developer Console o VS Code:
```apex
SAP__mdt loginGE = [SELECT CompanyDB__c, Content_Type__c, Endpoint__c, Method__c, Username__c, Password__c 
                    FROM SAP__mdt WHERE DeveloperName = 'LoginGE' LIMIT 1];
System.debug('Endpoint: ' + loginGE.Endpoint__c);
System.debug('Username: ' + loginGE.Username__c);
System.debug('Password: ' + loginGE.Password__c);
System.debug('CompanyDB: ' + loginGE.CompanyDB__c);
```

### 2. Obtener valor del Custom Label SAP_Campos_SAP_GE
Ejecuta en Developer Console:
```apex
String camposGE = System.Label.SAP_Campos_SAP_GE;
System.debug('Campos GE: ' + camposGE);
```

---

## 🔐 Paso 1: Login a SAP

```bash
curl --location 'https://lureye.exxiscloud.com:50000/b1s/v1/Login' \
--header 'Content-Type: application/json' \
--header 'Accept: */*' \
--data '{
    "CompanyDB": "SBO_GENERACION",
    "UserName": "InterfazSF",
    "Password": "Xxi-9-22!"
}'
```

**Respuesta esperada:**
```json
{
    "odata.metadata": "https://...",
    "SessionId": "abc123-session-id",
    "Version": "1000190",
    "SessionTimeout": 30
}
```

**Guarda el `SessionId` para el siguiente paso.**

---

## 📦 Paso 2: Consultar productos de Generación

### Opción A: Productos actualizados HOY (diasMenos = 0)

```bash
curl --location 'https://[TU_ENDPOINT_SAP]:50001/b1s/v1/Items?$select=[CAMPOS_GE]&$filter=UpdateDate%20ge%20%272025-11-11%27' \
--header 'Accept: */*' \
--header 'Cookie: B1SESSION=[SESSION_ID_DEL_PASO_1]; ROUTEID=.node1'
```

### Opción B: Productos desde AYER (diasMenos = -1) - RECOMENDADO

```bash
curl --location 'https://[TU_ENDPOINT_SAP]:50001/b1s/v1/Items?$select=[CAMPOS_GE]&$filter=UpdateDate%20ge%20%272025-11-10%27' \
--header 'Accept: */*' \
--header 'Cookie: B1SESSION=[SESSION_ID_DEL_PASO_1]; ROUTEID=.node1'
```

### Opción C: Consultar un producto específico por ItemCode

```bash
curl --location 'https://[TU_ENDPOINT_SAP]:50001/b1s/v1/Items('\''300004173'\'')' \
--header 'Accept: */*' \
--header 'Cookie: B1SESSION=[SESSION_ID_DEL_PASO_1]; ROUTEID=.node1'
```

---

## 🔓 Paso 3: Logout de SAP

```bash
curl --location --request POST 'https://[TU_ENDPOINT_SAP]:50001/b1s/v1/Logout' \
--header 'Content-Type: application/json' \
--header 'Cookie: B1SESSION=[SESSION_ID_DEL_PASO_1]; ROUTEID=.node1'
```

---

## 📝 Campos esperados para Generación (GE)

Basándome en el código, los campos para GE probablemente incluyen:

```
Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_MMotor,U_PoNo,Manufacturer,SupplierCatalogNo,ForeignName
```

**Nota:** Verifica el valor exacto ejecutando:
```apex
System.debug(System.Label.SAP_Campos_SAP_GE);
```

---

## 🎯 Ejemplo completo con valores de ejemplo

### 1. Login
```bash
curl --location 'https://sap10.lureye.com:50001/b1s/v1/Login' \
--header 'Content-Type: application/json' \
--header 'Accept: */*' \
--data '{
    "CompanyDB": "LUREYE_GE",
    "UserName": "manager",
    "Password": "tu_password"
}'
```

### 2. Consultar productos (reemplaza SESSION_ID)
```bash
curl --location 'https://sap10.lureye.com:50001/b1s/v1/Items?$select=Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_MMotor,U_PoNo,Manufacturer,SupplierCatalogNo,ForeignName&$filter=UpdateDate%20ge%20%272025-11-10%27' \
--header 'Accept: */*' \
--header 'Cookie: B1SESSION=abc123-tu-session-id; ROUTEID=.node1'
```

### 3. Logout
```bash
curl --location --request POST 'https://sap10.lureye.com:50001/b1s/v1/Logout' \
--header 'Content-Type: application/json' \
--header 'Cookie: B1SESSION=abc123-tu-session-id; ROUTEID=.node1'
```

---

## 📊 Respuesta esperada de Items

```json
{
    "odata.metadata": "https://...",
    "value": [
        {
            "Valid": "tYES",
            "ItemCode": "300004173",
            "U_SkuPre": "SKU123",
            "Mainsupplier": "PROV001",
            "ItemName": "MODULO LED+DIODO +A1 6-24 V DC FINDER",
            "U_Currency": "CLP",
            "U_Family": "ELECTRICOS",
            "U_MMotor": "MOTOR_X",
            "U_PoNo": "99.02.9.024.99",
            "Manufacturer": "FINDER",
            "SupplierCatalogNo": "CAT123",
            "ForeignName": "LED MODULE"
        }
    ]
}
```

---

## 🚀 Para Postman

### Collection completa:

1. **Variable de entorno `{{sap_endpoint}}`**: `https://sap10.lureye.com:50001/b1s/v1`
2. **Variable `{{session_id}}`**: Se guarda automáticamente del login

### Request 1: Login
- **Method:** POST
- **URL:** `{{sap_endpoint}}/Login`
- **Headers:** 
  - `Content-Type: application/json`
  - `Accept: */*`
- **Body (raw JSON):**
```json
{
    "CompanyDB": "LUREYE_GE",
    "UserName": "manager",
    "Password": "tu_password"
}
```
- **Tests (para guardar session):**
```javascript
var jsonData = pm.response.json();
pm.environment.set("session_id", jsonData.SessionId);
```

### Request 2: Get Products GE
- **Method:** GET
- **URL:** `{{sap_endpoint}}/Items?$select=Valid,ItemCode,U_SkuPre,Mainsupplier,ItemName,U_Currency,U_Family,U_MMotor,U_PoNo,Manufacturer,SupplierCatalogNo,ForeignName&$filter=UpdateDate ge '2025-11-10'`
- **Headers:**
  - `Accept: */*`
  - `Cookie: B1SESSION={{session_id}}; ROUTEID=.node1`

### Request 3: Logout
- **Method:** POST
- **URL:** `{{sap_endpoint}}/Logout`
- **Headers:**
  - `Content-Type: application/json`
  - `Cookie: B1SESSION={{session_id}}; ROUTEID=.node1`

---

## ⚠️ Notas importantes

1. **Timeout:** SAP tiene timeout de 30 minutos por sesión
2. **Encoding:** Los filtros deben estar URL-encoded en Postman
3. **Fecha:** Formato debe ser `YYYY-MM-DD`
4. **ROUTEID:** Es importante incluir `.node1` en la cookie
5. **HTTPS:** Verifica que tu endpoint use HTTPS y el puerto correcto (50001 es común)

---

## 🔍 Troubleshooting

### Error 401: Unauthorized
- Verifica credenciales en SAP__mdt
- Verifica que el SessionId sea válido

### Error 404: Not Found
- Verifica el endpoint
- Verifica que 'Items' esté correctamente escrito

### Sin resultados (value: [])
- Verifica la fecha del filtro
- Verifica que haya productos actualizados en ese rango
- Prueba sin filtro para ver todos: `/Items?$select=ItemCode,ItemName&$top=10`

### Error de campos
- Ejecuta `System.debug(System.Label.SAP_Campos_SAP_GE);` para ver los campos exactos
- Algunos campos custom pueden no existir en tu instancia SAP


