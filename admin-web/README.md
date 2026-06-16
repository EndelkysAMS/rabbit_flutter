# Rabbit Admin Web

Panel web de administración para el rol **ADMIN_LINEA** de mototaxi Rabbit.

## Stack

- React 18 + TypeScript + Vite
- React Router 7
- TanStack Query
- Axios
- React Leaflet (mapa en vivo)
- React Hot Toast

## Requisitos

- Node.js 18+
- Backend Django corriendo con CORS habilitado para `http://localhost:5173`

## Instalación

```bash
cd admin-web
npm install
```

## Variables de entorno

Copia `.env.example` a `.env.development`:

```env
VITE_API_BASE_URL=http://192.168.10.11:3000
```

## Desarrollo

```bash
npm run dev
```

Abre [http://localhost:5173](http://localhost:5173)

**Credenciales de prueba:** `lineasanbenito@gmail.com` / `123456`

## Build producción

```bash
npm run build
npm run preview
```

## Rutas

| Ruta | Descripción |
|------|-------------|
| `/login` | Inicio de sesión |
| `/dashboard` | KPIs de la línea |
| `/drivers` | Conductores activos |
| `/drivers/inactive` | Conductores inactivos |
| `/drivers/new` | Crear conductor |
| `/drivers/:id` | Editar conductor |
| `/map` | Mapa GPS en vivo |
| `/trips` | Listado de viajes + export CSV |
| `/trips/:id` | Detalle de viaje |
| `/clients` | Clientes (solo lectura) |
| `/fares` | Tarifas km/min |
| `/profile` | Perfil del admin |

## Auth

- Login: `POST /auth/login`
- Token guardado en `localStorage` como `rabbit_admin_token`
- Header: `Authorization: <token>` (incluye prefijo `Bearer` tal cual viene del backend)
- 401 → logout automático

## Componentes reutilizables

- `DataTable` — tablas con loading skeleton
- `StatusBadge` — estados de viaje
- `ConfirmDialog` — confirmaciones
- `PageHeader` — título + acciones
- `StatCard` — KPIs del dashboard

## Notas

- No modifica el backend; consume `/admin-linea/*` existente.
- Si algún endpoint no existe aún en tu backend, la pantalla mostrará el error del API.
- Arrays de conductores vienen como JSON array directo (no paginado).
