# Roadmap [PROJET] — par valeur utilisateur

**Derniere mise a jour** : YYYY-MM-DD
**Convention** : chaque jalon repond a "qu'est-ce qu'un utilisateur peut faire apres cette etape ?"

---

## Vue d'ensemble

```
  v0.1            v0.5           v1.0           v2.0
   |               |              |              |
   [capacite 1]    [capacite 2]   [capacite 3]   [capacite 4]
   ───●═════════════●══════════════○──────────────○───
       SHIPPED         SHIPPED       EN COURS       VISION
```

---

## v0.1 — [Nom du jalon] [STATUT]

**Valeur utilisateur** : [phrase unique — ce que l'utilisateur peut faire qu'il ne pouvait pas avant]

| Capacite | Detail |
|----------|--------|
| [Capacite 1] | [Description courte] |
| [Capacite 2] | [Description courte] |

**Specs rattachees** :
- `NNN-nom-spec` ([Phase technique])

**Phases techniques** : [Phase 0, B1.1, etc.]

---

<!-- Repeter le bloc ci-dessus pour chaque jalon -->

## Matrice recapitulative

| Jalon | Statut | Specs | Phases tech | LOC | Effort |
|-------|--------|-------|-------------|-----|--------|
| v0.1 | [STATUT] | [NNN] | [Phase X] | ~Xk | Xj |
| **Total shipped** | | **N specs** | **N phases** | **X** | **Xj** |

---

## Comment lire cette roadmap

- **Jalon** = ce que l'utilisateur peut faire (pas une phase technique)
- **Spec** = un Epic agile — perimetre fonctionnel d'une capacite majeure
- **Phase technique** = lot d'implementation au sein d'un ou plusieurs Epics
- **SHIPPED** = deploye et fonctionnel en production
- **EN COURS** = spec existante, implementation demarree ou prete
- **PLANIFIE** = perimetre identifie, spec pas encore ecrite
- **VISION** = intention strategique, pas encore decoupee en specs

Les specs sont dans `.specify/specs/NNN-nom/` et suivent le workflow spec-kit.
