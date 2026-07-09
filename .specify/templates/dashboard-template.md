# [PROJET] — cockpit

> Derniere mise a jour : YYYY-MM-DD | Jalon actif : [vX.Y — nom] | Phase : [N/5]

---

## Tensions

| Type | Detail | Impact |
|------|--------|--------|
| [BLOCKER / DECISION / RISQUE] | [Description courte] | [Bloque jalon vX.Y / Retarde spec NNN] |

*Aucune tension active.* <!-- retirer cette ligne si le tableau est rempli -->

---

## Sante

| Tests | Specs | Effort | Velocity | ADRs |
|-------|-------|--------|----------|------|
| [N/N pass (X%)] | [N shipped / N total] | [Xj actifs] | [~X LOC/j] | [N/N accepted] |

---

## Roadmap

```
  v0.1            v0.5           v1.0           v2.0
   |               |              |              |
   [capacite]      [capacite]     [capacite]     [capacite]
   ───●═════════════●══════════════◐──────────────○───
       SHIPPED         SHIPPED       EN COURS       VISION
```

| Jalon | Valeur utilisateur | Statut | Effort |
|-------|--------------------|--------|--------|
| [vX.Y] | [Ce que l'utilisateur peut faire] | ● SHIPPED | [Xj] |
| [vX.Y] | [...] | ◐ EN COURS | [Xj] |
| [vX.Y] | [...] | ○ PLANIFIE | [Xj] |
| **Total** | | | **[Xj]** |

### Prochain jalon

**[vX.Y — nom]** : [valeur utilisateur en 1 phrase]
- Prerequis : [specs ou decisions necessaires]
- Effort estime : [Xj]
- Date cible : [YYYY-MM-DD ou "apres decision D-XX"]

---

## Reste a faire

### Epics actifs (spec existante)

| # | Epic | Jalon | Progression | Effort restant |
|---|------|-------|-------------|----------------|
| [NNN] | [Nom] | [vX.Y] | [████░░░░░░ X%] | [~Xj] |

### Epics planifies (pas de spec)

| # | Epic | Jalon | Valeur | Effort | Priorite |
|---|------|-------|--------|--------|----------|
| [NNN] | [Nom] | [vX.Y] | [1 phrase] | [FAIBLE/MOYEN/ELEVE] | [HAUTE/MOYENNE/BASSE] |

**Backlog** : [N idees qualifiees] — detail dans `backlog-epics.md`

---

## Streams

| Stream | Etat | Prochaine action |
|--------|------|------------------|
| S1 Production | [Actif — spec NNN en cours] | [Action] |
| S2 Architecture | [Pause / Actif] | [Spec a preparer ou ADR en cours] |
| S3 Vision | [Derniere session : YYYY-MM-DD] | [Prochaine session prevue] |

**Allocation** : S1 [70]% · S2 [20]% · S3 [10]%

```
S3 Vision ──► GATE-V ──► S2 Spec ──► GATE-S ──► S1 Production ──► GATE-R ──► SHIPPED
```

---

## Decisions

### Recentes

| Date | Decision | ADR |
|------|----------|-----|
| [YYYY-MM-DD] | [Decision prise — contexte court] | [ADR-NNN ou —] |

### ADRs

| ADR | Sujet | Statut |
|-----|-------|--------|
| [ADR-NNN] | [Titre] | [● ACCEPTED / ◐ PROPOSED / ○ DEPRECATED] |

---

## Legende

- **●** SHIPPED — **◐** EN COURS — **○** PLANIFIE — **◇** VISION
- **Progression** : `████░░░░░░` = 40%
- **Jalon** = ce que l'utilisateur peut faire (pas une phase technique)
- **Epic** = perimetre fonctionnel d'une capacite majeure (~ 1 spec)
- **Effort** = jours actifs de developpement (pas calendaires)

| Fichier | Contenu |
|---------|---------|
| `STATE.md` | Position courante + taches spec active |
| `roadmap-valeur.md` | Detail roadmap par valeur utilisateur |
| `backlog-epics.md` | Backlog complet priorise |
| `gouvernance-3-streams.md` | Regles et rituels des 3 streams |

---

*Template spec-kit — cockpit projet (dashboard strategique)*
*Complementaire a `/pm view` (bandeau operationnel dev)*
*Mis a jour lors de chaque session S3 ou jalon SHIPPED*
