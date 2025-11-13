# 🔘 Validación: Botón "Crear Draft en SAP"

**Ticket:** 00024376  
**Componente:** Quick Action `Crear_Draft_en_SAP`  
**Tiempo:** 5 minutos

---

## ✅ CHECKLIST DE VALIDACIÓN

### 1. Verificar que el Quick Action existe

**Ruta:** Setup > Quick Actions

**Buscar:** `Crear Draft en SAP`

**Validar:**
- ✅ Quick Action Name: `Crear_Draft_en_SAP`
- ✅ Object: Quote
- ✅ Type: Visualforce Page
- ✅ Visualforce Page: `LUREYE_Crea_Drafts_SAP`
- ✅ Height: 280
- ✅ Width: -100 (full width)

**Estado:** ⬜ Validado

---

### 2. Verificar que está en el Page Layout

**Ruta:** Setup > Object Manager > Quote > Page Layouts

**Seleccionar:** El Page Layout que uses (ej: "Quote Layout" o "GE Quote Layout")

**Validar:**
1. Click en **Salesforce Mobile and Lightning Experience Actions**
2. Verificar que en la sección superior aparece: `Crear_Draft_en_SAP`

**Si NO aparece:**
1. Click en **Override the predefined actions**
2. Desde la paleta izquierda, arrastrar `Crear_Draft_en_SAP`
3. Posicionarlo donde quieras que aparezca
4. Save

**Estado:** ⬜ Validado

---

### 3. Verificar la Visualforce Page

**Ruta:** Setup > Visualforce Pages

**Buscar:** `LUREYE_Crea_Drafts_SAP`

**Validar:**
- ✅ Page Name: `LUREYE_Crea_Drafts_SAP`
- ✅ Controller: `Quote` (standard)
- ✅ Extension: `LUREYE_Drafts_SAP`
- ✅ Available for Lightning Experience: Yes

**Estado:** ⬜ Validado

---

### 4. Validar visibilidad en Quote Record

**Pasos:**
1. Abrir **cualquier Quote** en Salesforce
2. Ir arriba a la derecha (donde están los botones)
3. **Debe aparecer:** Botón con icono ⚡ y texto "Crear Draft en SAP"

**Ubicación del botón:**
```
[Edit] [Delete] [Submit for Approval] [Crear Draft en SAP] [▼ Show more]
```

**Si NO aparece:**
- Verificar que estás usando el Page Layout correcto
- Verificar que tienes permisos en el perfil
- Verificar que la Quote no esté en estado bloqueado

**Estado:** ⬜ Validado

---

### 5. Probar funcionalidad del botón (Sin crear Draft)

**Pasos:**
1. Crear una Quote **SIN** llenar campos obligatorios (sin Glosa, sin OC)
2. Click en `Crear Draft en SAP`
3. **Debe aparecer:** Modal con errores en rojo:
   ```
   Campos Obligatorios para SAP
   • El campo "Glosa" no ha sido ingresado.
   • El campo "N° Orden de Compra" no ha sido ingresado.
   ```
4. **Validar:** Aparece botón "Volver a la cotización"

**Estado:** ⬜ Validado

---

## 🎨 ASPECTO VISUAL DEL BOTÓN

### En Lightning Experience

El botón debe verse así:

```
┌─────────────────────────┐
│  ⚡ Crear Draft en SAP  │
└─────────────────────────┘
```

**Características:**
- Icono de rayo (⚡) o icono default de Visualforce
- Texto: "Crear Draft en SAP"
- Color: Azul (color standard de acción)
- Posición: Junto a otros action buttons

---

### Modal al hacer click (con campos vacíos)

```
┌──────────────────────────────────────────────┐
│                                              │
│  ⏳ Cargando...                              │
│                                              │
│  ─────────────────────────────────────────   │
│                                              │
│  Campos Obligatorios para SAP                │
│                                              │
│  • El campo "Glosa" no ha sido ingresado.    │
│  • El campo "N° Orden de Compra" no ha...    │
│                                              │
│  [Volver a la cotización]                    │
│                                              │
└──────────────────────────────────────────────┘
```

---

### Modal al hacer click (exitoso)

```
┌──────────────────────────────────────────────┐
│                                              │
│  ✅ ¡Se ha creado el Draft 12345             │
│     exitosamente en SAP!                     │
│                                              │
│  [Volver a la cotización]                    │
│                                              │
└──────────────────────────────────────────────┘
```

---

## 🔧 TROUBLESHOOTING

### Problema: "This page has an error..."

**Causa:** Error en Visualforce Page o extensión Apex

**Solución:**
1. Ver el error completo en el modal
2. Ir a Setup > Debug Logs
3. Ver el error exacto
4. Verificar que `LUREYE_Drafts_SAP` está deployado correctamente

---

### Problema: Botón existe pero no hace nada

**Causa:** JavaScript no se ejecuta

**Solución:**
1. Abrir Developer Tools en el navegador (F12)
2. Ver la consola de JavaScript
3. Buscar errores en rojo
4. Verificar que la página `LUREYE_Crea_Drafts_SAP` carga correctamente

---

### Problema: Aparece "Unauthorized endpoint"

**Causa:** Named Credential no está autorizado

**Solución:**
1. Setup > Named Credentials
2. Buscar la credential de SAP
3. Verificar que está autorizada
4. Re-autorizar si es necesario

---

## 📋 CONFIGURACIÓN DEL QUICK ACTION

Si necesitas recrear o modificar el Quick Action:

**Setup > Quick Actions > New Action**

```
Action Type:     Visualforce
Target Object:   Quote
Height:          280
Label:           Crear Draft en SAP
Name:            Crear_Draft_en_SAP
Visualforce:     LUREYE_Crea_Drafts_SAP
Icon:            (default)
Description:     Crea un borrador de Orden de Venta en SAP Business One
```

---

## ✅ RESUMEN

Para validar completamente el botón:

1. ✅ Quick Action existe
2. ✅ Está en el Page Layout
3. ✅ Aparece en Quote Record
4. ✅ Abre modal al hacer click
5. ✅ Valida campos obligatorios
6. ✅ Llama a `LUREYE_Drafts_SAP.CrearDraftsPage()`
7. ✅ Muestra mensaje de éxito/error

**Si todos estos puntos pasan, el botón está correctamente configurado.** ✅

---

**Última actualización:** 13 Noviembre 2025

