# EDITH CORE v2 · Sprint 01

## Checkpoint and isolation
- Production baseline: v1.9.7, commit 994836d47a19f0d3a40e7e20921a342aa7db5edd.
- Checkpoint: checkpoint/edith-v1.9.7-2026-11-25. Do not merge or modify.
- Development: feature/edith-core-v2.
- Production deployment and data must remain unchanged during development.
- STAGING exclusively uses synthetic fixtures. Never copy real patients into STAGING or GitHub.

## Implemented
- Private SQL classification normalizer `edith_core.classify_v1(text)`.
- STAGING migration 20261125181846, name edith_core_classification_v1.
- 12 synthetic cases and three privilege checks in core/tests/classification_v1.sql.
- This is a descriptive compatibility rule, not an official case definition. Preserve raw classification and distinguish ZONA GRIS from SIN CLASIFICAR.
- Before promotion, reconcile all categories to the annual active-record total. Do not silently change classifications or impute weeks/dates.

## Next acceptance gates
1. Reusable read-only audit: compare canonical vs analytical record counts, uniqueness of case UID, missing weeks, classification closure and quality. Return aggregated counts only.
2. Expand synthetic staging fixtures for 2024–2026, dates, duplicate detection, zone gray, all six districts and consultant role. No real patient data.
3. Add automated RLS negative tests for pending, district, state, master and consultant; session revocation and MFA where required. Do not relax existing grants.
4. Review official study form and date definitions before opportunity calculation.
5. Build atomic, audited institutional aggregate refresh in STAGING. No release to public maps of institutional-only counts.
6. Confirm dashboard and exports share the same versioned classification contract; test browser downloads and maps before promotion.
7. Resolve production master 403 with non-mutating diagnostics first. No blanket grants.

## Rollback
No production changes in this sprint. STAGING migration introduces a private schema and a pure function, not an API endpoint; any removal requires a reviewed rollback and dependency check.
