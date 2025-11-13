# Ticket 00024376 - Checklist de Pendientes

## 🔴 CRÍTICO - Bloquean la implementación

### 1. Valores exactos del campo `User.Sucursal__c` en Producción

**Problema:** No sabemos los valores reales que usan en producción.

**Query a ejecutar en PRODUCCIÓN:**
```apex
SELECT Id, Name, Sucursal__c, Linea_Negocio__c, CodigoUN__c, Branch__c
FROM User 
WHERE Sucursal__c != null AND IsActive = true 
ORDER BY Sucursal__c
```

**Necesito confirmar:**
- ¿Es "SANTIAGO" o "SANT" o "13" o "STGO"?
- ¿Es "ANTOFAGASTA" o "ANTO" o "2" o "ANF"?
- ¿Es "PUERTO MONTT" o "PMON" o "10"?
- ¿Es "TALCAHUANO" o "TALC" o "8" o "CONC"?

**Sin esto no puedo:**
- Crear las reglas en Custom Metadata correctamente
- Hacer el match en el código
- Garantizar que funcione

---

### 2. Confirmación de códigos de bodegas en SAP

**Query a ejecutar en SAP (via Postman o Developer Console):**
```bash
# Con sesión SAP activa:
GET /Warehouses?$select=WarehouseCode,WarehouseName
```

**O ejecutar en Developer Console:**
```apex
// Consultar bodegas disponibles en SAP
LUREYE_Servicios_SAP.setLoginByDeveloperName('LoginGE');
// Hacer llamada a endpoint Warehouses para listar todas
```

**Necesito validar que existen estos códigos:**
- ✅ VTLE
- ✅ ST10
- ✅ STA10
- ✅ STSP10
- ✅ STC10
- ✅ VTADFL10

**¿Estos códigos están escritos exactamente así en SAP?**
- ¿Son case-sensitive? (VTLE vs vtle vs Vtle)
- ¿Tienen espacios? ("ST10" vs "ST 10")

---

### 3. Bodega por defecto (Fallback)

**Pregunta:** Si no hay match en ninguna regla, ¿qué hacemos?

**Opciones:**

**a) Retornar error y NO crear Draft**
```apex
if (bodega == null) {
    return 'No se pudo determinar la bodega SAP. Verifique la configuración del usuario (Línea de Negocio y Sucursal).';
}
```
- ✅ Garantiza que siempre se envía bodega correcta
- ❌ Puede bloquear ventas si falta configuración

**b) Usar bodega por defecto**
```apex
if (bodega == null) {
    bodega = 'BODEGA_DEFAULT'; // ¿Cuál?
    System.debug('⚠️ Usando bodega por defecto');
}
```
- ✅ No bloquea el proceso
- ❌ Puede enviar a bodega incorrecta

**c) Crear sin WarehouseCode (comportamiento actual)**
```apex
if (bodega == null) {
    // No enviar campo WarehouseCode
    // SAP usará su bodega por defecto
}
```
- ✅ Mantiene compatibilidad con flujo actual
- ❌ No cumple el objetivo del ticket

**DECISIÓN REQUERIDA:** ¿Cuál opción prefieren? (Recomiendo la **a**)

---

### 4. Mapeo Línea de Negocio: ¿User o Opportunity?

**Encontré que:**
- Campo existe en **`User.Linea_Negocio__c`** (Number) ← Se usa actualmente
- Campo existe en **`Opportunity.LineaDeNegocio__c`** (Picklist)

**Pregunta:** ¿Cuál debemos usar para determinar la bodega?

**Opción A: User.Linea_Negocio__c** (actual)
- Pro: Ya se consulta en la integración actual
- Con: Es fijo por usuario, no por transacción

**Opción B: Opportunity.LineaDeNegocio__c**
- Pro: Más flexible, puede variar por oportunidad
- Con: Requiere consultar la Oportunidad desde la Quote
  
**Opción C: Ambos (prioridad Opportunity, fallback User)**
```apex
Decimal lineaNegocio;
if (qryQuote.Opportunity.LineaDeNegocio__c != null) {
    lineaNegocio = obtenerCodigoDePicklist(qryQuote.Opportunity.LineaDeNegocio__c);
} else {
    lineaNegocio = userqry.Linea_Negocio__c;
}
```

**DECISIÓN REQUERIDA:** ¿Cuál enfoque prefieren?

---

### 5. Formato del campo Linea_Negocio__c en User

**Query a ejecutar:**
```apex
SELECT Id, Name, Linea_Negocio__c 
FROM User 
WHERE Linea_Negocio__c != null AND IsActive = true 
LIMIT 20
```

**Necesito confirmar:**
- ¿El campo `User.Linea_Negocio__c` contiene solo el número (21000) o el texto completo ("21000 RELACIONAL")?
- El campo es tipo **Number(5,0)**, así que debería ser solo número
- Pero necesito confirmar para hacer el match correcto

**Si es solo número:**
```apex
lineaNegocio = 21000; // Comparar directamente
```

**Si incluye texto (lo cual sería raro para un campo Number):**
```apex
String lineaNegocioStr = String.valueOf(lineaNegocio).split(' ')[0]; // Extraer "21000"
```

---

### 6. Otras Líneas de Negocio no mencionadas

**El requerimiento solo menciona:**
- 21000 RELACIONAL
- 15000 PROYECTOS  
- 10000 TRANSACCIONAL
- 22000 SERVICIO

**Pero existen también:**
- 14000 EQUIPOS USADOS
- 16000 CANAL TELEFONICO
- 17000 CANAL KAM
- 18000 ARRIENDOS AMOBLADOS
- 19000 ARRIENDOS SIN AMOBLAR
- 20000 FEE
- 99000 NUEVOS NEGOCIOS

**Preguntas:**
1. ¿Estas líneas de negocio usan alguna bodega específica?
2. ¿O se dejan sin configurar (comportamiento actual = sin bodega)?
3. ¿Debería retornar error si alguien intenta crear OV con estas líneas?

**DECISIÓN REQUERIDA:** ¿Configuramos bodegas para estas líneas o las ignoramos?

---

### 7. Validación: ¿El campo WarehouseCode es obligatorio en SAP?

**Necesito confirmar con equipo SAP/WMS:**

Si envío JSON **SIN** WarehouseCode:
```json
{
    "DocumentLines": [
        {
            "ItemCode": "200000367",
            "Quantity": "1.00"
            // SIN WarehouseCode
        }
    ]
}
```

**¿SAP:**
- a) Lo acepta y usa bodega por defecto?
- b) Retorna error 400/500?
- c) Crea la OV pero en estado pendiente?

**Esto afecta la decisión del punto #3 (bodega por defecto)**

---

### 8. Prioridad de reglas: ¿Sucursal específica vs TODAS?

**Escenario:**

Tengo 2 reglas:
1. Línea=22000, Sucursal=TODAS, Bodega=X
2. Línea=22000, Sucursal=SANTIAGO, Bodega=ST10

Si un usuario es Línea=22000 y Sucursal=SANTIAGO, ¿cuál regla gana?

**Lógica propuesta:** La más específica (regla #2) usando `Prioridad__c`

**CONFIRMACIÓN REQUERIDA:** ¿Están de acuerdo con este approach?

---

### 9. Campo CodigoUN__c - ¿Se usa para bodega?

**Observo que:**
- `User.CodigoUN__c` existe (ej: "GE", "EM", "SE")
- Se consulta en la integración actual (línea 167-171)
- Pero **NO se usa** para determinar bodega actualmente

**Pregunta:** ¿Debería considerarse en la lógica de bodega?

**Ejemplo:**
- Usuario con CodigoUN = "GE" → Siempre usar bodegas de Generación
- Usuario con CodigoUN = "EM" → Siempre usar bodegas de Electromecánica

**DECISIÓN REQUERIDA:** ¿Agregamos `CodigoUN__c` como criterio?

---

### 10. Venta Normal vs null en RequiereHES__c

**El campo `Quote.RequiereHES__c` es obligatorio (`required: true`)**

Pero en el código actual dice:
```apex
if(propHES == 'HES' || propHES == '802')
```

**Preguntas:**
1. ¿Siempre tendrá valor (nunca null) por ser required?
2. ¿"Venta Normal" es el valor por defecto?
3. ¿Debo tratar "Venta Normal" igual que null?

**Lógica propuesta:**
```apex
if (requiereHES == 'HES' || requiereHES == '802') {
    // Bodega HES
} else {
    // Cualquier otro valor (incluyendo "Venta Normal") usa reglas normales
}
```

**CONFIRMACIÓN REQUERIDA:** ¿Es correcta esta interpretación?

---

### 11. ¿Todas las cotizaciones van a SAP?

**Contexto:** La integración se dispara desde botón "Crear Draft en SAP"

**Pregunta:** ¿Hay cotizaciones que NO van a SAP?
- ¿Solo ciertas unidades de negocio usan SAP?
- ¿GE, EM y SE todas usan SAP?

**Impacto:** Si hay cotizaciones que no van a SAP, la falta de configuración de bodega no es error.

---

### 12. Testing: ¿Tengo acceso a Sandbox para probar?

**Necesito:**
- Credenciales de Sandbox
- O que alguien del equipo ejecute tests
- Validar que Custom Metadata funciona correctamente

**Sin testing en sandbox:**
- Solo puedo hacer tests unitarios (mocked)
- No puedo validar integración real con SAP
- Riesgo de errores en producción

**DECISIÓN REQUERIDA:** ¿Tengo acceso a sandbox o alguien más hará el testing de integración?

---

## 📋 Resumen Ejecutivo de Pendientes

| # | Pendiente | Criticidad | Requiere Acción de |
|---|-----------|------------|-------------------|
| 1 | Valores exactos de Sucursal | 🔴 CRÍTICO | Rodrigo (query en prod) |
| 2 | Códigos de bodegas en SAP | 🔴 CRÍTICO | Equipo WMS/SAP |
| 3 | Bodega por defecto (fallback) | 🔴 CRÍTICO | Cliente/Marcelo |
| 4 | ¿User o Opportunity para LineaNegocio? | 🟡 IMPORTANTE | Cliente/Marcelo |
| 5 | Formato de Linea_Negocio__c | 🟡 IMPORTANTE | Rodrigo (query) |
| 6 | Bodegas para otras líneas | 🟢 MEDIA | Cliente/Marcelo |
| 7 | ¿WarehouseCode es obligatorio? | 🟡 IMPORTANTE | Equipo SAP |
| 8 | Prioridad: Específica vs TODAS | 🟢 MEDIA | Cliente/Marcelo |
| 9 | ¿Usar CodigoUN__c? | 🟢 BAJA | Cliente/Marcelo |
| 10 | Venta Normal vs null | 🟢 BAJA | Cliente/Marcelo |
| 11 | ¿Todas las quotes van a SAP? | 🟢 BAJA | Cliente/Marcelo |
| 12 | Acceso a Sandbox | 🟡 IMPORTANTE | Rodrigo/Marcelo |

---

## 🎯 Queries para ejecutar YA

### Query 1: Valores de Sucursal (PRODUCCIÓN)
```apex
SELECT Id, Name, Sucursal__c, COUNT(Id) 
FROM User 
WHERE Sucursal__c != null AND IsActive = true 
GROUP BY Sucursal__c 
ORDER BY Sucursal__c
```

### Query 2: Valores de Linea_Negocio (PRODUCCIÓN)
```apex
SELECT Id, Name, Linea_Negocio__c, Sucursal__c, CodigoUN__c
FROM User 
WHERE Linea_Negocio__c != null AND IsActive = true 
ORDER BY Linea_Negocio__c
LIMIT 50
```

### Query 3: Combinaciones reales en uso (PRODUCCIÓN)
```apex
SELECT Linea_Negocio__c, Sucursal__c, CodigoUN__c, COUNT(Id) NumUsuarios
FROM User 
WHERE IsActive = true AND Linea_Negocio__c != null
GROUP BY Linea_Negocio__c, Sucursal__c, CodigoUN__c
ORDER BY COUNT(Id) DESC
```

### Query 4: Cotizaciones recientes y sus usuarios (PRODUCCIÓN)
```apex
SELECT Id, QuoteNumber, CreatedBy.Name, CreatedBy.Linea_Negocio__c, 
       CreatedBy.Sucursal__c, CreatedBy.CodigoUN__c, RequiereHES__c, 
       CondicionPago__c, CreatedDate
FROM Quote 
WHERE CreatedDate = LAST_N_DAYS:30 
  AND DocEntry__c != null
ORDER BY CreatedDate DESC
LIMIT 20
```

**Objetivo:** Ver patrones reales de uso

---

## 📧 Preguntas para el Cliente (Marcelo Pinto)

### Email Template - Asunto: "Ticket 00024376 - Aclaraciones técnicas requeridas"

```
Marcelo, buen día.

Estoy trabajando en el ticket 00024376 (bodegas dinámicas para WMS) y necesito 
aclarar algunos puntos antes de comenzar el desarrollo:

1. BODEGA POR DEFECTO (CRÍTICO)
   Si un usuario no cumple ninguna regla de bodega (ej: tiene una Línea de 
   Negocio nueva o sucursal no configurada), ¿qué debería pasar?
   
   a) Mostrar error y NO crear el Draft
   b) Usar una bodega por defecto (¿cuál?)
   c) Crear sin WarehouseCode (SAP usa su default)
   
   Recomiendo: Opción (a) para garantizar datos correctos.

2. LÍNEA DE NEGOCIO - ¿De dónde tomar el valor?
   El campo existe en:
   - User.Linea_Negocio__c (se usa actualmente)
   - Opportunity.LineaDeNegocio__c
   
   ¿Cuál debemos usar? ¿O usar Opportunity si existe, sino User?

3. OTRAS LÍNEAS DE NEGOCIO
   La matriz solo menciona: RELACIONAL, PROYECTO, TRANSACCIONAL y SERVICIO.
   
   ¿Qué pasa con estas líneas de negocio?
   - 14000 EQUIPOS USADOS
   - 16000 CANAL TELEFONICO
   - 17000 CANAL KAM
   - 18000/19000 ARRIENDOS
   - 20000 FEE
   - 99000 NUEVOS NEGOCIOS
   
   ¿Usan bodega específica o quedan sin configurar?

4. VALIDACIÓN EN SAP
   ¿El equipo WMS/SAP puede confirmar que estos códigos de bodega existen 
   y están disponibles?
   - VTLE
   - ST10, STA10, STSP10, STC10
   - VTADFL10

5. TESTING
   Para validar la integración completa, ¿tengo acceso a sandbox o necesito 
   coordinar con alguien del equipo para hacer pruebas?

Quedo atento a tus respuestas para continuar.

Saludos,
Rodrigo
```

---

## 🔍 Investigación adicional que YO puedo hacer

### Acción 1: Revisar si hay Custom Settings o Custom Metadata existentes

**Query:**
```apex
// Buscar Custom Metadata existente relacionado a bodegas
List<EntityDefinition> customMetadata = [
    SELECT QualifiedApiName, Label 
    FROM EntityDefinition 
    WHERE QualifiedApiName LIKE '%Bodega%' OR QualifiedApiName LIKE '%Warehouse%'
];
```

### Acción 2: Revisar todas las llamadas actuales que envían a SAP

**Buscar en código:**
- ¿Hay otros lugares donde se cree OV/Draft?
- ¿Todos usan `LUREYE_Drafts_SAP.CrearDrafts()`?
- ¿O hay múltiples entry points?

### Acción 3: Revisar si hay validation rules en Quote

**Query:**
```apex
SELECT Id, ValidationName, ErrorDisplayField, ErrorMessage, Active
FROM ValidationRule 
WHERE EntityDefinition.QualifiedApiName = 'Quote' AND Active = true
```

**Objetivo:** Ver si hay validaciones que puedan bloquear o requerir ciertos campos

---

## ⏱️ Impacto en Timeline

| Pendiente resuelto | Puede empezar |
|-------------------|---------------|
| Pendiente #1 (Sucursales) | Desarrollo Custom Metadata |
| Pendiente #2 (Códigos SAP) | Desarrollo Custom Metadata |
| Pendiente #3 (Fallback) | Desarrollo clase helper |
| Pendiente #4 (User vs Opp) | Desarrollo clase helper |
| Todos los críticos | Modificación LUREYE_Drafts_SAP |

**Sin resolver los 🔴 CRÍTICOS: NO puedo empezar a codificar sin riesgo de rehacer todo**

---

## 📞 Próximos Pasos Propuestos

### Opción A: Resuelvo lo que puedo YO (2 horas)
1. Ejecuto queries en producción (necesito credenciales)
2. Reviso código para otros entry points
3. Creo documento actualizado con hallazgos
4. Preparo lista final de preguntas para Marcelo

### Opción B: Espero respuestas del cliente (1-2 días)
1. Envías email a Marcelo con preguntas
2. Mientras tanto, preparo estructura de Custom Metadata (borrador)
3. Preparo código de clase helper (con TODOs donde falta info)
4. Una vez tengo respuestas, completo implementación

### Opción C: Implementación con supuestos (RIESGOSO)
1. Asumo valores más probables
2. Desarrollo completo
3. Ajusto después cuando tengan respuestas
4. Riesgo: Puede requerir refactoring significativo

**¿Qué opción prefieres?** Recomiendo **Opción A** si me das credenciales de prod, o **Opción B** si prefieres esperar confirmación del cliente.

---

## 🚀 Estoy listo para:

✅ Ejecutar queries en producción (necesito acceso)
✅ Crear estructura de Custom Metadata (borrador)
✅ Desarrollar clase helper (con TODOs marcados)
✅ Preparar tests unitarios
✅ Generar email para Marcelo con preguntas

**¿Por dónde empezamos?** 🎯

