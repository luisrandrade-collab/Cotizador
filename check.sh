#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════
# Gourmet Bites — Pre-deploy check (v6.3.0 E3-2)
# ═══════════════════════════════════════════════════════════════════════════
# Valida que el proyecto esté listo para deploy ANTES de subir a GitHub Pages.
# Correr desde la raíz del proyecto:  bash scripts/check.sh
#
# Checks:
#   1. node -c en los 7 archivos JS (sintaxis)
#   2. BUILD_VERSION en app-core.js coincide con comentario VERSION en index.html
#   3. Los 7 <script src=...?v=X.Y.Z> en index.html apuntan a la misma versión
#   4. Existencia de los 9 archivos del proyecto + scripts/check.sh (10 total)
#   5. Modales críticos presentes en HTML (#confirm-modal, #edit-warning-modal)
#
# Sale con código 0 si TODO está OK. Cualquier fallo → exit 1.
# Uso típico:
#   bash scripts/check.sh && zip -r gourmet-bites-vX_Y_Z.zip *.js *.html *.json scripts/
# ═══════════════════════════════════════════════════════════════════════════

set -u  # no -e: queremos recolectar todos los errores, no parar al primero

# ─── Colores ───────────────────────────────────────────────────────────────
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m' # no color
else
  GREEN=''; RED=''; YELLOW=''; BLUE=''; BOLD=''; NC=''
fi

OK="${GREEN}✅${NC}"
FAIL="${RED}❌${NC}"
WARN="${YELLOW}⚠️${NC}"
INFO="${BLUE}ℹ️${NC}"

ERRORS=0
WARNINGS=0

print_header() {
  echo ""
  echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD} $1${NC}"
  echo -e "${BOLD}═══════════════════════════════════════════════════════════${NC}"
}

pass()  { echo -e "  ${OK} $1"; }
fail()  { echo -e "  ${FAIL} $1"; ERRORS=$((ERRORS+1)); }
warn()  { echo -e "  ${WARN} $1"; WARNINGS=$((WARNINGS+1)); }
info()  { echo -e "  ${INFO} $1"; }

# ─── Localizar raíz del proyecto ───────────────────────────────────────────
# El script puede ejecutarse desde la raíz o desde scripts/
if [ -f "./index.html" ] && [ -f "./app-core.js" ]; then
  ROOT="."
elif [ -f "../index.html" ] && [ -f "../app-core.js" ]; then
  ROOT=".."
else
  echo -e "${FAIL} No encuentro index.html + app-core.js. Ejecuta desde la raíz del proyecto."
  exit 1
fi

cd "$ROOT" || exit 1
PROJECT_ROOT=$(pwd)

print_header "🍽️  GOURMET BITES — PRE-DEPLOY CHECK"
echo -e "${INFO} Proyecto: $PROJECT_ROOT"
echo -e "${INFO} Fecha:    $(date '+%Y-%m-%d %H:%M:%S')"

# ─── Check 1: node disponible ──────────────────────────────────────────────
print_header "1. Node.js disponible"
if ! command -v node >/dev/null 2>&1; then
  fail "node no está instalado. Instala Node.js para validar sintaxis JS."
  echo ""
  echo -e "${RED}${BOLD}ABORT:${NC} Sin node no se pueden validar los JS. Instala desde https://nodejs.org"
  exit 1
fi
NODE_VERSION=$(node --version)
pass "node $NODE_VERSION disponible"

# ─── Check 2: sintaxis de los 7 archivos JS ────────────────────────────────
print_header "2. Sintaxis JavaScript (node -c en 7 archivos)"
JS_FILES=(app-assets.js app-core.js app-cotizar.js app-propuesta.js app-historial.js app-seguimiento.js app-dashboard.js)
for f in "${JS_FILES[@]}"; do
  if [ ! -f "$f" ]; then
    fail "$f no existe"
    continue
  fi
  ERR_OUT=$(node -c "$f" 2>&1)
  if [ $? -eq 0 ]; then
    LINES=$(wc -l < "$f" | tr -d ' ')
    pass "$f ($LINES líneas)"
  else
    fail "$f — SYNTAX ERROR"
    echo "$ERR_OUT" | sed 's/^/        /'
  fi
done

# ─── Check 3: extraer BUILD_VERSION de app-core.js ─────────────────────────
print_header "3. Consistencia de BUILD_VERSION"

if [ ! -f "app-core.js" ]; then
  fail "app-core.js no existe — no se puede extraer BUILD_VERSION"
else
  BUILD_VER=$(grep -E 'const BUILD_VERSION\s*=' app-core.js | head -1 | sed -E 's/.*"(v[^"]+)".*/\1/')
  if [ -z "$BUILD_VER" ]; then
    fail "No se pudo extraer BUILD_VERSION de app-core.js"
  else
    info "BUILD_VERSION en app-core.js: $BUILD_VER"

    # ─── Check 3a: comentario VERSION en index.html ──────────────────────
    if [ ! -f "index.html" ]; then
      fail "index.html no existe"
    else
      HTML_VER=$(grep -oE '<!-- VERSION: [^>]*-v[0-9]+\.[0-9]+\.[0-9]+' index.html | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
      if [ -z "$HTML_VER" ]; then
        warn "No se encontró comentario '<!-- VERSION: ... -v?.?.? -->' en index.html"
      elif [ "$BUILD_VER" = "$HTML_VER" ]; then
        pass "Comentario VERSION de index.html coincide: $HTML_VER"
      else
        fail "Comentario VERSION de index.html ($HTML_VER) ≠ BUILD_VERSION ($BUILD_VER)"
      fi

      # ─── Check 3b: 7 <script src=...?v=X.Y.Z> coinciden ──────────────
      VERSION_NUM=$(echo "$BUILD_VER" | sed 's/^v//')
      SCRIPT_VERSIONS=$(grep -oE 'script src="app-[^"]+\?v=[0-9]+\.[0-9]+\.[0-9]+' index.html | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | sort -u)
      SCRIPT_COUNT=$(echo "$SCRIPT_VERSIONS" | wc -l | tr -d ' ')

      if [ "$SCRIPT_COUNT" -eq 1 ] && [ "$SCRIPT_VERSIONS" = "$VERSION_NUM" ]; then
        pass "Los 7 <script ?v=$VERSION_NUM> coinciden con BUILD_VERSION"
      elif [ "$SCRIPT_COUNT" -eq 1 ]; then
        fail "<script ?v=$SCRIPT_VERSIONS> ≠ BUILD_VERSION ($VERSION_NUM)"
      else
        fail "<script ?v=...> INCONSISTENTES: $(echo $SCRIPT_VERSIONS | tr '\n' ' ')"
      fi
    fi
  fi
fi

# ─── Check 4: existencia de los 10 archivos del proyecto ───────────────────
print_header "4. Inventario de archivos (10 esperados)"
EXPECTED=(
  "app-assets.js"
  "app-core.js"
  "app-cotizar.js"
  "app-propuesta.js"
  "app-historial.js"
  "app-seguimiento.js"
  "app-dashboard.js"
  "index.html"
  "scripts/check.sh"
)

MISSING=0
for f in "${EXPECTED[@]}"; do
  if [ -f "$f" ]; then
    SIZE=$(wc -c < "$f" | tr -d ' ')
    pass "$f (${SIZE} bytes)"
  else
    fail "$f — FALTA"
    MISSING=$((MISSING+1))
  fi
done

# JSON del plan (nombre varía por versión)
JSON_PLAN=$(ls Plan_de_accion_*.json 2>/dev/null | head -1)
if [ -n "$JSON_PLAN" ]; then
  SIZE=$(wc -c < "$JSON_PLAN" | tr -d ' ')
  pass "$JSON_PLAN (${SIZE} bytes)"
else
  fail "Plan_de_accion_*.json — FALTA"
  MISSING=$((MISSING+1))
fi

# ─── Check 5: modales críticos en HTML ─────────────────────────────────────
print_header "5. Modales críticos presentes en index.html"
if [ ! -f "index.html" ]; then
  warn "index.html no existe — skipping modales"
else
  REQUIRED_MODALS=(
    "confirm-modal:v6.3.0 E3-3 confirmModal genérico"
    "edit-warning-modal:v5.5.0 edit warning"
    "doc-preview-modal:v6.1.0 modal preview"
    "edit-history-modal:v5.5.0 audit trail"
    "hoja-entregas-modal:v6.2.0 Hoja de Entregas"
  )
  for entry in "${REQUIRED_MODALS[@]}"; do
    ID="${entry%%:*}"
    DESC="${entry#*:}"
    if grep -q "id=\"$ID\"" index.html; then
      pass "#$ID ($DESC)"
    else
      fail "#$ID no encontrado ($DESC)"
    fi
  done
fi

# ─── Check 6: alerts puros (excluyendo fallbacks defensivos) ───────────────
print_header "6. Alerts puros restantes (deberían ser 0 en v6.3.0+)"
TOTAL_PURE=0
for f in "${JS_FILES[@]}"; do
  if [ ! -f "$f" ]; then continue; fi
  # Alerts que NO son parte del patrón defensivo "if(typeof toast==...)else alert(..)"
  PURE=$(grep -nE '^\s*(if\s*\()?alert\(|\)\s*alert\(|;alert\(|else alert\(' "$f" 2>/dev/null | grep -v "typeof toast" | wc -l | tr -d ' ')
  if [ "$PURE" -gt 0 ]; then
    warn "$f: $PURE alert() puro(s) — considerar migrar a toast()"
    TOTAL_PURE=$((TOTAL_PURE+PURE))
  else
    pass "$f: 0 alerts puros"
  fi
done

# ─── Resumen final ─────────────────────────────────────────────────────────
print_header "RESUMEN"

if [ "$ERRORS" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}✅ TODO OK — listo para deploy${NC}"
  if [ -n "${BUILD_VER:-}" ]; then
    echo -e "${INFO} Versión: $BUILD_VER"
    VNO_UNDER=$(echo "$BUILD_VER" | sed 's/^v//;s/\./_/g')
    echo ""
    echo -e "${BOLD}Siguiente paso sugerido:${NC}"
    echo "  zip -r gourmet-bites-${VNO_UNDER}.zip app-*.js index.html Plan_de_accion_*.json scripts/"
  fi
  exit 0
elif [ "$ERRORS" -eq 0 ]; then
  echo -e "${YELLOW}${BOLD}⚠️  $WARNINGS advertencia(s) — revisa antes de deploy${NC}"
  echo -e "${INFO} No hay errores bloqueantes. Puedes deployar si las advertencias son aceptables."
  exit 0
else
  echo -e "${RED}${BOLD}❌ $ERRORS error(es) · $WARNINGS advertencia(s)${NC}"
  echo -e "${RED}${BOLD}NO deployar hasta corregir los errores.${NC}"
  exit 1
fi
