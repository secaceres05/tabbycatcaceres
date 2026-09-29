# CLAUDE.md

Contexto para sesiones de Claude Code en este repo.

## Qué es

Fork de [Tabbycat](https://github.com/TabbycatDebate/tabbycat) para el **XIV Torneo Nacional de Debate** (Cali, Pontificia Universidad Javeriana, 9 al 15 de diciembre de 2026).

- Repo: `secaceres05/tabbycatcaceres`
- Rama de trabajo: `front-nacional`
- Upstream: `TabbycatDebate/tabbycat` (remote `upstream`, rama `develop`)

## Regla principal

**Solo se modifican templates, SCSS y componentes Vue.** Nunca vistas, modelos, migraciones ni lógica en Python.

Única excepción existente, anterior a esta regla: `tabbycat/settings/docker.py` activa `USE_WEBPACK_SERVER` cuando `DEBUG` (commit `9f04e72ff`). No agregar más.

## Entorno

- El repo vive en WSL2 (Ubuntu): `~/proyectos/tabbycatcaceres`.
- **Claude Code debe correr dentro de WSL**, no desde Windows. Desde Windows (ruta `\\wsl.localhost\...`) git rechaza el repo por *dubious ownership*, cmd.exe no acepta rutas UNC y `npx`/`python` resuelven a los binarios de Windows.
- Se levanta con `docker compose up`. Sass y Vite corren dentro del contenedor `web` con hot-reload (`bin/docker-dev.sh`).
  - Sitio: http://localhost:8000
  - Vite: http://localhost:8888
- El CSS compilado (`tabbycat/static/css/`) está en `.gitignore`. Para confirmar que Sass compiló: `docker logs --since 2m tabbycatcaceres-web-1 | grep -i scss`.
- Chrome cachea `style.css`: tras un cambio de SCSS, recargar con Ctrl+F5.

### docker-compose.override.yml

Es local y está en `.gitignore`. Contenido actual, para recrearlo en otra máquina:

```yaml
services:
  web:
    volumes:
      - .:/tcd
    command: ["./bin/docker-wait.sh", "--timeout=0", "db:5432", "--", "./bin/docker-dev.sh"]
    ports:
      - "8888:8888"
```

## jsi18n

- **Nunca commitear cambios en `tabbycat/locale/jsi18n/`.** Si aparecen en `git status`, descartarlos con `git checkout -- tabbycat/locale/jsi18n/`.
- No se corre `compilejsi18n` en desarrollo.
- No agregar esa carpeta a `.gitignore`: producción usa los archivos versionados.

## Logo

- El template que se usa es `tabbycat/templates/nav/logo.html`. `logo_local.html` solo aplica con `ON_LOCAL=True`, que no está activo.
- `logo.html` carga `static/images/tnd-logo-icon.png` (solo montañas y perfiles, 312×160, limpio de halo). Recibe `height` y calcula el ancho solo: 40px en `nav/top_nav_base.html`, 32px en `nav/admin_nav.html`.
- `static/images/tnd-logo.png` es el original (1355×1160, 766 KB, con halo semitransparente del recorte de fondo). No usarlo directo en la interfaz.

## Identidad visual

Definida en `tabbycat/templates/scss/components/custom.scss` (variables de Bootstrap 4.6).

| Rol | Color | Variable |
|---|---|---|
| Primario (teal) | `#2FE6C6` | `$purple` → `primary` |
| Info (magenta) | `#F72585` | `$blue` → `info` |
| Warning (amarillo) | `#FFB627` | `$orange` → `warning` |
| Success | `#1fcf9e` | `$green` → `success` |
| Danger | `#d1185e` | `$red` → `danger` |
| Fondo | `#0B2B2E` | `$body-bg` |
| Superficie (cards, inputs, list-groups) | `#10353a` | `$card-bg`, `$input-bg`, `$list-group-bg` |
| Superficie oscura (navbar, sidebar, thead) | `#071a1c` | `dark`, `$navbar-dark-bg`, `$sidebar-bg`, `$table-head-bg` |
| Texto | `#f1f5f4` | `$body-color` |

Los nombres `$purple`/`$blue` son históricos de Tabbycat; lo que cuenta es el rol en `$theme-colors`.

Tipografía (Google Fonts, cargadas en `base.html`):

- **Anton**: títulos (`$headings-font-family`), peso 400 (no tiene otro; 700 genera negrita falsa).
- **DM Sans**: cuerpo (`$font-family-sans-serif`).
- **Archivo Black**: botones (`$btn-font-family`) y `.navbar-brand`. Los `.btn-link` van en DM Sans porque se ven como links.
- **Caveat**: acento (`.accent-script`).

Contraste: `$yiq-text-dark: #071a1c` y `$yiq-contrasted-threshold: 140`, para que teal, success y amarillo lleven texto oscuro.

## Archivos del núcleo modificados

Posibles conflictos al traer cambios de upstream (`git diff --name-status $(git merge-base HEAD upstream/develop) HEAD`):

Configuración y entorno:
- `.gitignore`: agrega `docker-compose.override.yml`
- `render.yaml`: `startCommand` y `PYTHON_VERSION` (ver Pendientes)
- `tabbycat/settings/docker.py`: `USE_WEBPACK_SERVER` en dev
- `bin/docker-dev.sh`: nuevo

Templates:
- `tabbycat/templates/base.html`
- `tabbycat/templates/footer.html`
- `tabbycat/templates/nav/logo.html`
- `tabbycat/templates/nav/top_nav_base.html`
- `tabbycat/templates/nav/admin_nav.html`
- `tabbycat/templates/components/item-action.html`
- `tabbycat/templates/components/item-submit.html`
- `tabbycat/templates/admin/style_guide.html`
- `tabbycat/templates/tables/TablesContainer.vue`

SCSS:
- `tabbycat/templates/scss/components/custom.scss`
- `tabbycat/templates/scss/components/variables.scss`
- `tabbycat/templates/scss/modules/footer.scss`
- `tabbycat/templates/scss/modules/forms.scss`
- `tabbycat/templates/scss/modules/nav.scss`
- `tabbycat/templates/scss/modules/tables.scss`
- `tabbycat/templates/scss/modules/typography.scss`

Mantener esta lista al día cuando se toque otro archivo del núcleo.

## Pendientes

- **Modo oscuro del editor de asignaciones** (Allocate adjudicators, Edit Sides/Matchups). No usa `<table>` sino `.draw-row` y componentes Vue, y sigue en blanco: `scss/components/allocations.scss`, `scss/modules/drag-and-drop.scss`, `allocations/DragAndDropDebate.vue` y relacionados (`DragAndDropActions.vue` y `DragAndDropUnallocatedItems.vue` usan `navbar-light`).
- `components/item-submit.html` todavía tiene `bg-white` en su variante normal.
- Fases 2 a 4 del rediseño.
- **Render**: el worker está apagado. `render.yaml` usa `npm run render-server` (solo el servidor) en vez de `npm run render-serve` (servidor + worker) por falta de RAM en el plan free. **Antes del torneo:** subir de plan y volver a `render-serve`.

## Forma de trabajo

- Mostrar el diff antes de aplicar cambios grandes.
- No hacer commit ni push sin confirmación.
- Revisar `git status` antes de cada commit (y descartar `tabbycat/locale/jsi18n/`).
- Mensajes de commit en español.
- El repo es público: nunca poner en este archivo ni en ningún commit contraseñas, tokens, variables de entorno de Render ni datos de participantes.
