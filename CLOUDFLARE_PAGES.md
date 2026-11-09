# EDITH ÚNICA · Migración de Vercel a Cloudflare Workers

**Estado al 9 de noviembre de 2026: aplicación v1.9.4.1 integrada a GitHub; publicación definitiva pendiente de confirmar en Cloudflare y validar con usuario autorizado.**

- Respaldo aportado: `EDITH_UNICA_v1.9.4.1_HOTFIX_PPTX.html`.
- Destino Cloudflare Worker: `https://edith.ibrahimharos.workers.dev/`.
- Código de la aplicación: `cloudflare-pages/index.html` (v1.9.4.1).
- Prototipo previo preservado: `cloudflare-pages/edith-next-boceto.html`.
- `wrangler.jsonc`: `assets.directory="./cloudflare-pages"`.
- Exportación PPTX: bundle PptxGenJS 4.0.1 desde CDN fijado; XLSX 0.18.5 desde CDN preexistente.
- Cliente Supabase Auth / REST, Roles y RLS: código original conservado; no se migran tablas ni usuarios.

**Pendiente antes de considerarlo una operación institucional validada:**
1. En Cloudflare → Workers & Pages → `edith` → Implementaciones, comprobar que la última compilación incluya el commit `6a9f33e` (o uno posterior) y muestre éxito.
2. Abrir `https://edith.ibrahimharos.workers.dev/` en ventana privada. Debe mostrar «EDITH ÚNICA» y el acceso institucional; no «EDITH NEXT».
3. Verificar `https://edith.ibrahimharos.workers.dev/data/snapshot/rows-01.json` y `/README.md`: deben ser 404 y no exponer archivos de raíz del repositorio.
4. Entrar con una cuenta autorizada y comprobar conteos (2026: 178 activos en el corte mostrado por el usuario), curvas, filtros y registros visibles según rol. No asumir que los conteos siguen iguales en fechas posteriores.
5. Validar exportación PPTX (requiere conexión a CDN), análisis por SE, permisos distritales, importación y auditoría. Revisar consola y CORS si falla login.
6. Mantener Vercel intacto como recuperación. No apagar Vercel hasta completar pruebas.

**Seguridad:** se revisó el archivo respaldado y no se encontraron expedientes nominales embebidos ni claves privilegiadas. La clave publicable Supabase es propia del cliente, pero su uso solo es seguro cuando RLS y funciones RPC están adecuadamente restringidas. Antes de uso institucional, auditar permisos y protección de datos sensibles.

**No comprar dominio:** la URL `workers.dev` sirve para validar el nuevo despliegue.
