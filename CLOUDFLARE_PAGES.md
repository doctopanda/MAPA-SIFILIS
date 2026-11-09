# EDITH NEXT · Cloudflare Workers Static Assets

**Estado de la migración (9 de noviembre de 2026)**

- Cloudflare creó un Worker llamado `edith` y entregó la URL `https://edith.ibrahimharos.workers.dev`. El primer despliegue terminó con éxito, pero **su salida era `.`**, es decir, la raíz del repositorio, y publicó más archivos de los previstos.
- Se añadió **`/wrangler.jsonc` en la rama `main`** para restringir los archivos servidos al directorio `./cloudflare-pages`. Este archivo es la configuración canónica para `npx wrangler deploy`.
- El nuevo despliegue aún debe confirmarse en el panel Cloudflare. **No interpretar un commit GitHub como confirmación del nuevo despliegue**.

## Configuración canónica

```json
{
  "name": "edith",
  "compatibility_date": "2026-11-09",
  "assets": {
    "directory": "./cloudflare-pages"
  }
}
```

La carpeta incluye únicamente el piloto público `index.html` y el archivo `_headers`. **No deben añadirse bases, snapshots, registros nominales ni claves privadas allí**.

## Validación obligatoria del despliegue

1. En el panel Cloudflare seleccionar **Cómputo → Workers y Pages → edith → Implementaciones**.
2. Abrir la ejecución más reciente, posterior al commit de configuración. Si no aparece, revisar en **Configuración → Compilaciones** que la integración de GitHub despliegue la rama `main`. **No usar «Reintentar compilación» en una ejecución antigua**, ya que podría repetir el commit anterior.
3. Revisar los logs: `Assets directory`, `Output directory` o el archivo de configuración deben indicar `./cloudflare-pages`, no `.`.
4. Abrir `https://edith.ibrahimharos.workers.dev/`; debe mostrar el portal **EDITH NEXT**, no el mapa raíz.
5. Probar `https://edith.ibrahimharos.workers.dev/data/snapshot/rows-01.json`; **no debe mostrar el archivo** (debería responder 404). Verificar que `/README.md` tampoco se publique.
6. Registrar capturas y aprobar el piloto solo tras estas pruebas.

## Datos sensibles

Este piloto **no sustituye** la aplicación clínica EDITH SC alojada en Vercel (`edith-unica-piloto`) y no contiene conexión privada a Supabase. La clínica requiere revisión de HTML incrustado, autenticación RLS, y autorización institucional antes de migrar.

No comprar dominio ni borrar el proyecto en Vercel mientras se verifica el piloto.

Referencia: https://developers.cloudflare.com/workers/static-assets/migration-guides/vercel-to-workers/static-site/
