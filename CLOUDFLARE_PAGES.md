# Piloto de migración a Cloudflare Pages (EDITH NEXT / Red Epidemiológica)

**ESTADO: Preparado en GitHub, todavía NO desplegado en Cloudflare.**

Objetivo: validar Cloudflare Pages Free como alojamiento de interfaz pública, usando EDITH NEXT como primera prueba sin ningún expediente clínico. Esta carpeta es un *output estático* aislado y deliberadamente no incluye la aplicación clínica original `edith-unica-piloto`.

## Conectar Cloudflare Pages

1. Abrir https://dash.cloudflare.com/ y entrar en **Workers & Pages**.
2. Seleccionar **Create application > Pages > Connect to Git**, autorizando GitHub si lo solicita.
3. Elegir el repositorio **doctopanda/MAPA-SIFILIS**.
4. Completar la configuración:
   - Project name: `edith-next-piloto` (si está disponible; será la dirección `edith-next-piloto.pages.dev`, verificable solamente al desplegar).
   - Production branch: `main`.
   - Framework preset: **None**.
   - Root directory: **/** (raíz del repositorio).
   - Build command: `exit 0` (o vacío si la UI lo permite).
   - Build output directory: `cloudflare-pages` (relativa a la raíz; NO usar `.` para evitar publicar todo el repositorio).
   - Environment variables: ninguna.
5. Ejecutar **Save and Deploy**. Abrir la URL `*.pages.dev` que entregue Cloudflare y verificar el portal.
6. Después de probar el despliegue, evaluar redireccionamiento/retirada de Vercel; NO hacerlo antes.

La carpeta `cloudflare-pages/` incluye únicamente `index.html` y `_headers`, sin claves ni registros sanitarios. Por ahora conserva un vínculo al mapa original (GitHub Pages) para no modificar otros despliegues.

## Fuera de alcance / advertencias
- Este piloto **no** migra `edith-unica-piloto` desde Vercel, ni su backend, ni los datos de pacientes, ni añade Realtime. Es una primera prueba segura de publicación.
- EDITH SC clínica y EDITH SA deben validarse antes de desplegar: **nunca subir HTML con snapshots nominales incrustados**, ni service_role, ni tokens. Para aplicaciones con datos sensibles, coordinar protección de datos, autorización institucional, autenticación y RLS.
- Mantener Vercel intacto hasta pasar pruebas de funcionalidad y seguridad en Cloudflare.
- La migración a Cloudflare **no cambia la base Supabase** ni resuelve por sí sola condiciones contractuales de operación institucional o tratamiento de datos sensibles.
- El nombre `edith-next-piloto` es propuesto y no está reservado; no asumir la URL final.

Docs: https://developers.cloudflare.com/pages/get-started/git-integration/
