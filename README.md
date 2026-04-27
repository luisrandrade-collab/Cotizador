# Gourmet Bites v7.0 — Handoff Fase 0 → Fase 1

Fecha: 26 de abril de 2026
Owner: Luis Andrade (La Calera / Bogotá, Colombia)

## Contenido de este paquete

```
gourmet-bites-v7-fase0-completa/
├── README.md                                    ← este archivo
├── Plan_de_accion_v7_0_fase0_completada.json    ← JSON maestro (LEER PRIMERO)
├── wireframes/
│   ├── 00-sistema.html                          ← Bloque 1 — sistema de diseño
│   ├── 01-navegacion-desktop.html               ← Bloque 2 — sidebar desktop
│   ├── 01b-navegacion-movil.html                ← Bloque 2 — drawer móvil + FAB
│   ├── 01c-mapa-modulos.html                    ← Bloque 2 — mapa de 6 módulos × 22 submódulos
│   ├── 02-inicio-dashboard.html                 ← Bloque 3 — Dashboard rediseñado
│   └── gb-tokens.css                            ← tokens compartidos (paleta, tipo, espaciado)
└── brand/
    ├── cuchillo-negro.png                       ← cuchillo aislado, fondo transparente
    ├── cuchillo-blanco.png                      ← versión blanca para fondos oscuros
    ├── wordmark-negro.png                       ← wordmark completo (Gourmet Bites + Andrade Matuk)
    └── wordmark-blanco.png                      ← wordmark blanco para fondos oscuros
```

## Cómo usar este paquete para arrancar Fase 1

### Paso 1 — leer el JSON

`Plan_de_accion_v7_0_fase0_completada.json` tiene 19 secciones. Las más importantes para arrancar:

- `_meta.como_usar_en_nuevo_chat` → instrucciones literales del primer mensaje a enviar
- `roadmap_aprobado.secuencia_v70_aprobada` → las 4 sub-entregas (α, β, γ, δ) con alcance y esfuerzo
- `fixes_operativos_absorbidos_v70` → los 10 fixes que entran en v7.0 (4 críticos en α, 5 a β, 1 transversal)
- `pendiente_arreglo_dato_manual_2026_04_26` → contexto del bug operativo de hoy y plan de remediación post-v7.0-α
- `decisiones_aprobadas_no_discutir` → 56 decisiones cerradas que NO se vuelven a abrir

### Paso 2 — abrir los wireframes en el navegador

Abrir cualquier `.html` en Chrome/Edge. Los del Bloque 2 y 3 son interactivos:

- `01-navegacion-desktop.html`: prueba el toggle Compacta/Cómoda, click en módulos, abrir/cerrar Crear, colapsar sidebar
- `01b-navegacion-movil.html`: hamburguesa, drawer accordion, FAB con bottom sheet
- `02-inicio-dashboard.html`: dashboard real con datos hipotéticos pero realistas

### Paso 3 — arrancar nuevo chat para Fase 1

Subir al nuevo chat:

1. Los 7 archivos JS + index.html de la versión v6.4.0 ya en producción
2. `scripts/check.sh`
3. Backup actual `gourmet-bites-backup-2026-04-26-ANTES-DE-FIX.json`
4. Este JSON `Plan_de_accion_v7_0_fase0_completada.json`
5. ZIP completo de wireframes
6. Brand kit (4 PNG)

Primer mensaje sugerido:

> Arranca Fase 1 v7.0. Lee el JSON `Plan_de_accion_v7_0_fase0_completada.json`, revisa los wireframes de Fase 0, y entrégame el plan de implementación detallado para v7.0-α (incluyendo los 4 fixes operativos críticos: FIX-01 Q9, FIX-02 gate entregar-sin-producir, FIX-03 botón revertir entrega, FIX-04 confirmación multi-pedido). NO toques código todavía hasta que aprobemos el plan de implementación. Esfuerzo estimado v7.0-α: 30-40h.

## Pendientes pre-Fase 1 (no bloqueantes)

Las 4 preguntas que pueden esperar al inicio del próximo chat:

- Q17: ¿Pendientes de cobro en Operaciones o Ventas? (default: Operaciones)
- Q18: ¿Renombrar Inicio a Hoy? (default: Inicio)
- Q19: ¿Eliminar Perdidas en Clientes? (recomendación: sí, redundante)
- Q20: ¿Hacer Bloques 4-6 de Fase 0 antes de Fase 1?

## Estado del bug operativo del 26 abril 2026

Pedidos GB-2026-0123 (10 mayo, $796.000) y GB-2026-0122 (hoy, $687.500) están cruzados en la app. Decisión: NO se arreglan manualmente en Firestore. Se arreglan desde la UI usando el botón "Revertir entrega" que es uno de los fixes absorbidos a v7.0-α (FIX-03). Mientras tanto Luis lleva nota mental + advertencia a Kathy y JP de que GB-2026-0123 no está entregado a pesar de lo que dice la app.

Detalle completo en sección `pendiente_arreglo_dato_manual_2026_04_26` del JSON.

