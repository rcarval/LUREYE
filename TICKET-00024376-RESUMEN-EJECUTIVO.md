# Ticket 00024376 - Bodegas Dinámicas SAP WMS
## Resumen Ejecutivo para Cliente

---

### 📌 PROBLEMA

Actualmente las Órdenes de Venta (OV) creadas desde Salesforce a SAP **no especifican bodega**, causando que SAP use una bodega por defecto. Esto genera problemas en WMS: inventario mal ubicado, picking desde bodegas incorrectas y movimientos manuales adicionales.

**Único caso que funciona hoy:** Ventas con condición HES-802 van a bodega VTADFL10.

---

### ✅ SOLUCIÓN

Implementar lógica que asigne automáticamente la bodega correcta según:
1. **Línea de Negocio** del usuario (GE, EM, SE)
2. **Región de despacho** de la cotización (Santiago, Antofagasta, etc.)
3. **Condición de pago** (HES-802 override)

**Resultado:** Cada OV llega a la bodega WMS correcta automáticamente.

---

### 🎯 REGLAS DE NEGOCIO

| Línea de Negocio | Región Despacho | Condición | → Bodega SAP |
|------------------|-----------------|-----------|--------------|
| **Cualquiera** | **Cualquiera** | **HES/802** | **VTADFL10** (prioridad máxima) |
| RELACIONAL/PROYECTO/TRANSACCIONAL | Todas | Normal | VTLE |
| SERVICIO | Santiago (RM) | Normal | ST10 |
| SERVICIO | Antofagasta | Normal | STA10 |
| SERVICIO | Puerto Montt | Normal | STSP10 |
| SERVICIO | Concepción | Normal | STC10 |
| Otras | Cualquiera | Normal | Sin bodega (SAP default) |

---

### 🛠️ COMPONENTES A DESARROLLAR

#### 1. Custom Metadata Type: `Bodega_SAP__mdt`
**Justificación:** Configuración sin código, administradores pueden editar bodegas sin deploy.

**Campos:**
- Línea de Negocio (texto)
- Región Despacho (texto)
- Requiere HES (texto)
- Código Bodega SAP (texto) ← **El valor que se envía**
- Nombre Bodega (texto descriptivo)
- Activo (checkbox)
- Prioridad (número)

#### 2. Registros de Configuración (6 reglas)
**Justificación:** Define matriz de bodegas. Editables por admins.

1. HES_802_Override → VTADFL10
2. GE_Ventas_VTLE → VTLE
3. Servicio_Santiago_ST10 → ST10
4. Servicio_Antofagasta_STA10 → STA10
5. Servicio_PuertoMontt_STSP10 → STSP10
6. Servicio_Concepcion_STC10 → STC10

#### 3. Clase Apex: `LUREYE_Bodega_SAP_Service`
**Justificación:** Lógica centralizada y reutilizable para determinar bodega.

**Métodos:**
- `determinarBodega(lineaNegocio, region, requiereHES)` → Retorna código bodega
- Validaciones internas por prioridad

**Líneas:** ~150

#### 4. Test: `LUREYE_Bodega_SAP_Service_Test`
**Justificación:** Cobertura >75% requerida. Valida los 6 casos + casos edge.

**Test cases:** 11 métodos de prueba

#### 5. Modificación: `LUREYE_Drafts_SAP.cls`
**Justificación:** Integrar nueva lógica en proceso existente.

**Cambio:** ~20 líneas (obtener región de despacho + llamar a servicio de bodega)

**Ubicación:** Líneas 173-217

---

### ⏱️ TIMELINE

- **Desarrollo:** 3 días hábiles
- **Testing Sandbox:** 1 día
- **Deploy Producción:** 0.5 día
- **Monitoreo:** 5 días
- **TOTAL:** 5 días desarrollo + 5 días validación

---

### ✨ BENEFICIOS

✅ Inventario en bodega correcta desde el inicio  
✅ Procesos WMS optimizados  
✅ Sin movimientos manuales  
✅ Reportería precisa por bodega  
✅ Configurable sin programación  
✅ Escalable a nuevas bodegas/regiones  

---

### 📋 PRÓXIMOS PASOS

1. ✅ Aprobar diseño técnico (este documento)
2. Desarrollar componentes (3 días)
3. Testing en sandbox (1 día)
4. Deploy a producción
5. Validar con equipo WMS

---

**Desarrollador:** Rodrigo Carvallo  
**Solicitante:** Marcelo Pinto  
**Fecha:** 13 Nov 2025  
**Prioridad:** URGENTE

