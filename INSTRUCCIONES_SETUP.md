# 🚀 Setup Completo de Cursor para Salesforce

## ✅ Ya configurado automáticamente en este proyecto:

1. ✅ `.vscode/settings.json` - Asociaciones de archivos Apex
2. ✅ `.vscode/apex.code-snippets` - Snippets reutilizables
3. ✅ `package.json` - Scripts npm para testing/deploy
4. ✅ `.pmd/ruleset.xml` - Análisis estático
5. ✅ `.cursorignore` - Optimización de indexación
6. ✅ `PROJECT_NOTES.md` - Documentación de convenciones

## 📋 Paso 1: Configurar Reglas Globales (5 minutos)

### Opción A: Ejecutar script automático

```bash
bash setup-cursor-global.sh
```

Este script:
- Detecta tu sistema operativo
- Crea el archivo `CURSOR_RULES.md` con las reglas
- Te da instrucciones paso a paso

### Opción B: Manual

1. Abre `CURSOR_RULES.md` (se creó al ejecutar el script)
2. Copia TODO el contenido
3. En Cursor: `Cmd + ,` (Settings)
4. Busca: "Cursor Rules" o "General Rules"
5. Pega el contenido
6. Guarda y reinicia Cursor

## 🎯 Paso 2: Verificar instalación del CLI de Salesforce

```bash
npm run verify:sf
```

Si no está instalado, el script te dará instrucciones.

## 🧪 Paso 3: Probar que todo funciona

### Snippets:
1. Abre cualquier archivo `.cls`
2. Escribe `testm` y presiona Tab
3. Debería crear un método de test completo

### Scripts:
```bash
# Ver todos los scripts disponibles
npm run

# Ejecutar tests Apex (requiere org conectada)
npm run apex:test

# Escanear código con PMD
npm run apex:scan
```

## 📦 Extensiones recomendadas de VSCode/Cursor

Instala manualmente desde el Marketplace:

1. **Salesforce Extension Pack** (salesforce.salesforcedx-vscode)
2. **Apex Language Support** (incluido en Extension Pack)
3. **Lightning Web Components** (incluido en Extension Pack)

Para instalar rápido:
```bash
code --install-extension salesforce.salesforcedx-vscode
```

## 🎨 Usar los snippets

| Trigger | Descripción |
|---------|-------------|
| `testm` | Método de test con startTest/stopTest |
| `trycatch` | Try-catch con logs detallados |
| `soql` | Query SOQL con manejo de errores |
| `debug` | Debug log con emoji |
| `invocable` | Método invocable para Flow |
| `httpcallout` | Callout HTTP básico |
| `future` | Método future |
| `batch` | Clase batch completa |

## 🔧 Scripts NPM disponibles

### Testing:
```bash
npm run apex:test              # Todos los tests con cobertura
npm run apex:test:class -- MyTestClass  # Test específico
npm run test:unit              # Tests LWC
```

### Deployment:
```bash
npm run apex:deploy            # Deploy a org
npm run apex:deploy:validate   # Validar sin deploy
npm run apex:retrieve          # Retrieve metadata
```

### Análisis:
```bash
npm run apex:scan              # PMD scanner
npm run lint                   # ESLint para JS
```

### Formateo:
```bash
npm run prettier               # Formatear todo
npm run prettier:verify        # Verificar formato
```

## 🐛 Troubleshooting

### "sf command not found"
```bash
# Instalar Salesforce CLI
npm install -g @salesforce/cli
```

### "PMD not found"
```bash
# Instalar Salesforce Code Analyzer
sf plugins install @salesforce/sfdx-scanner
```

### Snippets no funcionan
- Verifica que el archivo tenga extensión `.cls`
- Reinicia Cursor
- Verifica en Settings que Apex esté asociado a `.cls`

## 📚 Documentación de referencia

- **PROJECT_NOTES.md**: Convenciones del proyecto
- **.vscode/apex.code-snippets**: Ver todos los snippets disponibles
- **package.json**: Ver todos los scripts npm

## ✨ Próximos pasos

1. Ejecuta `bash setup-cursor-global.sh`
2. Sigue las instrucciones para copiar las reglas
3. Reinicia Cursor
4. Prueba escribir `testm` en un archivo `.cls`
5. ¡Empieza a desarrollar con superpoderes! 🚀



