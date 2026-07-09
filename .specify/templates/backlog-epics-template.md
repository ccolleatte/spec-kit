# Backlog epics — [PROJET]

**Derniere mise a jour** : YYYY-MM-DD
**Convention** : liste priorisee des Epics identifies. Pas un engagement — un reservoir d'idees qualifiees.

---

## Epics actifs (spec existante dans .specify/)

| # | Epic | Jalon | Statut | Spec |
|---|------|-------|--------|------|
| 001 | [Nom] | v0.1 | [SHIPPED/EN COURS] | `001-nom` |

---

## Epics planifies (pas de spec, perimetre identifie)

| # | Epic | Jalon | Valeur utilisateur | Effort | Priorite |
|---|------|-------|--------------------|--------|----------|
| NNN | [Nom] | vX.Y | [Ce que l'utilisateur pourra faire] | [FAIBLE/MOYEN/ELEVE] | [HAUTE/MOYENNE/BASSE] |

---

## Epics en backlog (idees qualifiees, pas encore planifiees)

| Idee | Jalon cible | Source | Valeur | Effort estime | Priorite |
|------|-------------|--------|--------|---------------|----------|
| [Nom] | vX.Y | [README, constitution, ADR, analyse...] | [Description courte] | [FAIBLE/MOYEN/ELEVE] | [HAUTE/MOYENNE/BASSE/A EVALUER] |

---

## Criteres de priorisation

| Critere | Poids |
|---------|-------|
| Valeur utilisateur directe | 40% |
| Prerequis pour la suite (chemin critique) | 30% |
| Effort relatif (fail-fast, low-hanging fruit d'abord) | 20% |
| Risque technique (inconnu a derisquer tot) | 10% |

---

## Regles de gestion

- Un Epic passe de "backlog" a "planifie" quand on decide de le faire dans le trimestre courant
- Un Epic passe de "planifie" a "actif" quand sa spec.md est creee dans `.specify/specs/`
- Ce fichier est mis a jour lors de chaque `/pm roadmap` ou en fin de jalon SHIPPED
- Les Epics abandonnes sont deplaces dans une section "Archive" (pas supprimes)
