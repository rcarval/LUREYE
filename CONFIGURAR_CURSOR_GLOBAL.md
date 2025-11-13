# 🎯 Configurar Cursor Rules GLOBALMENTE - Guía Paso a Paso

## Método 1: Interfaz de Cursor (Más fácil)

### Paso 1: Abrir Settings
1. Presiona: `Cmd + ,` (coma)
2. Se abrirá la ventana de Settings

### Paso 2: Buscar la configuración de Rules
En la barra de búsqueda arriba (donde dice "Search settings"), escribe:
```
rules
```

### Paso 3: Encontrar "Cursor > General > Rules"
Deberías ver una opción que dice algo como:
- **"Cursor: General Rules"** o
- **"Rules for AI"** o  
- **"Cursor > General > Rules"**

### Paso 4: Hacer click en "Edit in settings.json"
Verás un link que dice "Edit in settings.json" o un ícono de archivo.
Haz click ahí.

### Paso 5: Pegar las reglas
Se abrirá un archivo JSON. Añade esta sección:

```json
{
  "cursor.general.rules": "# Salesforce Development Rules\n\n## Lenguaje\n- Responde siempre en español\n- Usa terminología técnica en inglés cuando sea apropiado\n\n## Apex Code Standards\n\n### Nomenclatura\n- Clases: PascalCase con prefijo del proyecto\n- Métodos: camelCase\n- Variables: camelCase\n- Constantes: UPPER_SNAKE_CASE\n\n### Best Practices\n- Siempre usar bulkification (evitar DML/SOQL en loops)\n- Limitar SOQL queries: máximo 100 por transacción\n- Limitar DML statements: máximo 150 por transacción\n- Usar try-catch con logs detallados\n- Tests: incluir Test.startTest() y Test.stopTest()\n\n### Testing\n- Cobertura mínima: 75%\n- Usar @isTest en vez de testMethod\n- Mockear callouts HTTP\n- Nombres descriptivos: test_WhenCondition_ThenExpectedResult\n\n### SOQL/DML\n- Usar SOQL For Loops para grandes volúmenes\n- Verificar permisos con WITH SECURITY_ENFORCED\n- Database.insert/update con allOrNone=false cuando sea necesario\n\n### Security\n- Usar 'with sharing' o 'without sharing' explícitamente\n- Validar inputs de usuarios\n- Escapar strings en consultas dinámicas\n- @AuraEnabled(cacheable=true) para métodos de lectura\n\n## LWC Standards\n- const/let, nunca var\n- Async/await para operaciones asíncronas\n- Try-catch para manejo de errores\n- Accesibilidad: labels, aria-*, roles\n\n## Integration Patterns\n- Named Credentials cuando sea posible\n- Retry logic en callouts\n- Timeout apropiados (120s default)\n- Logs completos: getMessage(), getStackTraceString(), getCause(), getLineNumber()\n\n## Code Generation\n- Incluir comentarios explicativos\n- Manejo de errores robusto\n- Considerar límites del governor\n- Sugerir tests unitarios"
}
```

### Paso 6: Guardar
- `Cmd + S` para guardar
- Cierra Cursor completamente
- Vuelve a abrir Cursor

---

## Método 2: Editar archivo directamente (Si no funciona el método 1)

### Paso 1: Abrir Command Palette
Presiona: `Cmd + Shift + P`

### Paso 2: Buscar settings.json
Escribe: `Preferences: Open User Settings (JSON)`

Presiona Enter.

### Paso 3: Se abrirá un archivo JSON
Pega este contenido (si ya tiene contenido, añade la línea nueva sin borrar lo existente):

```json
{
  "cursor.general.rules": "# Salesforce Development Rules\n\n## Lenguaje\n- Responde siempre en español\n- Usa terminología técnica en inglés cuando sea apropiado\n\n## Apex Code Standards\n\n### Nomenclatura\n- Clases: PascalCase con prefijo del proyecto\n- Métodos: camelCase\n- Variables: camelCase\n- Constantes: UPPER_SNAKE_CASE\n\n### Best Practices\n- Siempre usar bulkification (evitar DML/SOQL en loops)\n- Limitar SOQL queries: máximo 100 por transacción\n- Limitar DML statements: máximo 150 por transacción\n- Usar try-catch con logs detallados\n- Tests: incluir Test.startTest() y Test.stopTest()\n\n### Testing\n- Cobertura mínima: 75%\n- Usar @isTest en vez de testMethod\n- Mockear callouts HTTP\n- Nombres descriptivos: test_WhenCondition_ThenExpectedResult\n\n### SOQL/DML\n- Usar SOQL For Loops para grandes volúmenes\n- Verificar permisos con WITH SECURITY_ENFORCED\n- Database.insert/update con allOrNone=false cuando sea necesario\n\n### Security\n- Usar 'with sharing' o 'without sharing' explícitamente\n- Validar inputs de usuarios\n- Escapar strings en consultas dinámicas\n- @AuraEnabled(cacheable=true) para métodos de lectura\n\n## LWC Standards\n- const/let, nunca var\n- Async/await para operaciones asíncronas\n- Try-catch para manejo de errores\n- Accesibilidad: labels, aria-*, roles\n\n## Integration Patterns\n- Named Credentials cuando sea posible\n- Retry logic en callouts\n- Timeout apropiados (120s default)\n- Logs completos: getMessage(), getStackTraceString(), getCause(), getLineNumber()\n\n## Code Generation\n- Incluir comentarios explicativos\n- Manejo de errores robusto\n- Considerar límites del governor\n- Sugerir tests unitarios"
}
```

### Paso 4: Guardar
- `Cmd + S`
- Reinicia Cursor

---

## Método 3: Script automático (Terminal)

Si los métodos anteriores no funcionan, ejecuta este script:

```bash
# Abrir el archivo de configuración directamente
open ~/Library/Application\ Support/Cursor/User/settings.json
```

Luego pega manualmente el JSON del Método 2.

---

## 🧪 Verificar que funcionó

1. Cierra Cursor completamente
2. Abre cualquier proyecto (Salesforce o no)
3. Abre el chat de Cursor
4. Escribe: "Crea un método Apex de ejemplo"
5. Debería responder en español y seguir las convenciones (camelCase, try-catch, etc.)

---

## ❓ Si nada funciona

Comparte screenshot de:
1. Cursor Settings (`Cmd + ,`)
2. La barra de búsqueda con "rules"

Y te ayudo a encontrar exactamente dónde está en tu versión de Cursor.

---

## 📌 IMPORTANTE

Una vez configurado globalmente:
- ✅ Aplicará a TODOS tus proyectos
- ✅ No necesitas el archivo `.cursorrules` en cada proyecto
- ✅ Proyectos Node.js NO se verán afectados (Cursor detecta el contexto)



