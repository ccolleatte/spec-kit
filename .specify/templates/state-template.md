# Etat projet — [PROJET]

## Position actuelle

- **Jalon** : [vX.Y — nom du jalon]
- **Phase** : [N sur 5]
- **Nom phase** : [Init/Specify/Clarify/Plan/Tasks/Implement]
- **Spec active** : [NNN-nom-spec]
- **Status** : [Draft/Ready/In Progress/Done]

## Progression par jalon

| Jalon | Statut | Specs | LOC |
|-------|--------|-------|-----|
| [vX.Y Nom] | [SHIPPED/EN COURS/PLANIFIE] | [NNN, NNN] | [~Xk] |

**Total shipped** : [X LOC] | [N tests passed] | [Nj actifs]

## Progression taches (spec active)

| Phase | Taches | Status |
|-------|--------|--------|
| [Phase N — Nom] | [TX-TY] | [done/in_progress/pending] |

**Total** : [X / Y completees (Z%)]

## Streams (modele 3 streams)

| Stream | Etat | Detail |
|--------|------|--------|
| S1 Production | [Actif/Pause] | [Spec en implementation ou "aucune"] |
| S2 Architecture | [Actif/Pause/A lancer] | [Spec en preparation ou ADR en cours] |
| S3 Vision | [Date derniere session] | [Prochaine session prevue] |

**Gouvernance** : `_docs/product/gouvernance-3-streams.md`

## Decisions accumulees

| Decision | Contexte | Date |
|----------|----------|------|
| [Decision] | [Pourquoi] | [YYYY-MM-DD] |

## ADRs

| ADR | Status |
|-----|--------|
| [ADR-NNN Titre] | [PROPOSED/ACCEPTED/DEPRECATED] |

## Blockers actifs

- [ ] [Description du blocker]

*Aucun.* ← (si pas de blocker)

## Historique sessions

| Session | Date | Activite |
|---------|------|----------|
| [Nom session] | [YYYY-MM-DD] | [Description courte] |

## Reprise session

- **Derniere activite** : [YYYY-MM-DD]
- **Prochaine action** : [Description]
- **Stream recommande** : [S1/S2/S3 — justification courte]

---

*Template spec-kit — etat projet persistant (STATE.md)*
*Cree automatiquement par `/pm status` si `.specify/` existe*
