# Gouvernance projet — modele 3 streams [PROJET]

**Derniere mise a jour** : YYYY-MM-DD
**Principe** : S1+S2 = "on fait bien les choses". S3 = "on fait les bonnes choses".

---

## Vue d'ensemble

```
  S1 Production (70%)        S2 Spec/Architecture (20%)     S3 Vision produit (10%)
  ─────────────────          ──────────────────────          ──────────────────────
  Implementer les specs      Preparer la phase suivante      Valider qu'on fait
  actives                    (clarify, plan, ADR)            les bonnes choses
```

### Allocation temps

| Stream | Part | Activites | Frequence |
|--------|------|-----------|-----------|
| S1 — Production | 70% | Implementation, TDD, debug, review, deploy | Continue |
| S2 — Architecture | 20% | Spec next phase, clarify, plan, ADR, gates | 1x/semaine |
| S3 — Vision produit | 10% | Roadmap, backlog, arbitrages, pivot | 1x/2 semaines |

Ajuster les pourcentages selon le contexte : un projet en phase exploratoire peut inverser S1 et S3.

---

## Stream 1 — Production

**Question** : "est-ce qu'on construit bien ?"

- Entree : spec clarifiee + plan valide (sortie GATE-S)
- Activites : TDD, debug, review, deploy
- Sortie : code merge, tests passent, changelog mis a jour

---

## Stream 2 — Architecture / Spec

**Question** : "est-ce qu'on prepare bien la suite ?"

- Entree : Epic qualifie dans backlog (sortie GATE-V)
- Activites : specify, clarify, plan, ADR, gates
- Sortie : spec + plan valides, ADR ecrit si decision structurante

---

## Stream 3 — Vision produit

**Question** : "est-ce qu'on fait les bonnes choses ?"

### Format session ritualisee (45 min)

```
1. REVIEW (10 min)
   - Ouvrir roadmap-valeur.md : ou en est-on ?
   - Ouvrir backlog-epics.md : quoi de neuf ?

2. INTERROGATION (15 min)
   - "Les 3 prochains mois, que doit pouvoir faire un utilisateur ?"
   - "Quel Epic apporte le plus de valeur maintenant ?"
   - "Y a-t-il un pivot necessaire ?"

3. ARBITRAGES (10 min)
   - Reprioriser backlog
   - Abandonner/reporter (archiver, pas supprimer)
   - Valider prochain jalon cible

4. LIVRABLES (10 min)
   - Mettre a jour roadmap-valeur.md + backlog-epics.md
   - Documenter dans _docs/product/sessions/session-YYYY-MM-DD.md
```

### Declencheurs

- Calendaire : 1x/2 semaines
- Evenementiel : jalon SHIPPED, feedback utilisateur, changement marche

---

## Gates

| Gate | Transition | Criteres cles |
|------|-----------|---------------|
| GATE-V | S3 → S2 | Valeur articulee, effort estime, pas de conflit |
| GATE-S | S2 → S1 | Spec >= 0.8, plan existe, gates passes, jalon rattache |
| GATE-R | S1 → SHIPPED | Tests OK, review OK, changelog, roadmap mis a jour |

---

## Synchronisation

```
S3 (Vision)          S2 (Spec)           S1 (Production)
    │                    │                    │
    ├── GATE-V ─────────►│                    │
    │                    ├── GATE-S ─────────►│
    │                    │                    ├── GATE-R ──► SHIPPED
    │◄───────────────────┼────────────────────┤
    │           (feedback / remontees)        │
```

### Remontees exceptionnelles

| Signal | Action |
|--------|--------|
| Feedback utilisateur inattendu | Session S3 extraordinaire |
| Decouverte technique majeure | Session S3 extraordinaire |
| Velocity tres differente de l'estimation | Ajustement roadmap en S3 |

---

## Comptes-rendus sessions S3

Stockes dans `_docs/product/sessions/session-YYYY-MM-DD.md`.

Format : Participants → Review → Decisions → Arbitrages backlog → Actions → Prochaine session.

---

## Regles de gestion

- Les pourcentages S1/S2/S3 sont indicatifs — l'important est que S3 existe et soit ritualise
- Un projet en phase exploratoire peut commencer a 30/20/50 (S1/S2/S3)
- Un projet en phase de livraison urgente peut temporairement passer a 90/10/0 — noter explicitement la dette S3
- Ce fichier est mis a jour lors de chaque session S3

---

*Template spec-kit — gouvernance 3 streams*
*Source : Unrest ADR-011 + analyse strategique PM 2026*
