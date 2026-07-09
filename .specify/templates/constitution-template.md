# Constitution — [PROJET]

**Date de creation** : YYYY-MM-DD
**Derniere mise a jour** : YYYY-MM-DD
**Status** : ACTIVE

---

## Principes fondateurs

<!--
  Les principes sont des regles non negociables. Ils ne changent pas sans
  versioning explicite et validation PO + architecte.
  Format : P[N] — [Nom court] : [Regle en une phrase]
-->

### P1 — [Nom du principe]

[Description en 2-3 phrases. Ce que ca impose concretement.]

### P2 — [Nom du principe]

[Description]

### P3 — [Nom du principe]

[Description]

---

## Exclusions explicites

<!--
  Ce que le projet N'est PAS. Aussi important que ce qu'il est.
  Previent le scope creep et les decisions implicites.
-->

| Exclusion | Raison | Horizon de revision |
|-----------|--------|---------------------|
| [Ce qui est exclu] | [Pourquoi] | [Jamais / vX.Y / Trimestre Q] |

---

## Contraintes techniques

<!--
  Contraintes imposees par le contexte (pas des choix — des faits).
-->

| Contrainte | Impact | Source |
|------------|--------|--------|
| [e.g., "Vercel 60s timeout"] | [Limite la duree des API calls] | [Infra] |
| [e.g., "Budget zero serveur"] | [Serverless only] | [Business] |

---

## Sequencement

<!--
  Ordre de priorite quand il y a conflit entre objectifs.
-->

1. [Priorite 1 — e.g., "Securite des donnees utilisateur"]
2. [Priorite 2 — e.g., "Stabilite (pas de regression)"]
3. [Priorite 3 — e.g., "Fonctionnalite"]
4. [Priorite 4 — e.g., "Performance"]
5. [Priorite 5 — e.g., "Ergonomie"]

---

## Historique des modifications

| Version | Date | Modification | Auteur |
|---------|------|-------------|--------|
| 1.0 | YYYY-MM-DD | Creation initiale | [Auteur] |

---

*Template spec-kit — constitution projet*
