---
description: Vérifie l'alignement entre la spec active et le code implémenté — classe chaque exigence spec en FULL_MATCH / PARTIAL_MATCH / MISMATCH / UNDOCUMENTED_CODE / AMBIGUOUS avec score de confiance 0–1 et citations obligatoires.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

---

## Règles globales (non négociables)

1. **Jamais d'inférence sans preuve** : chaque verdict DOIT citer (section spec + titre + citation courte + fichier code + numéro de ligne). Pas de citation = AMBIGUOUS automatique.
2. **Score de confiance 0–1** : estimer honnêtement l'incertitude. 1.0 = preuve directe dans le code. 0.0 = aucune trace. Décimale imposée (ex. `0.7`, pas "élevé").
3. **UNDOCUMENTED_CODE** = code qui fait quelque chose de non spécifié — le signaler, ne pas l'ignorer.
4. **Read-only** : aucune modification de fichier. Rapport uniquement.

### Rationalisations à rejeter

| Rationalisation | Pourquoi erronée |
|-----------------|-----------------|
| "La spec est claire, pas besoin de vérifier le code" | La spec décrit l'intent ; le code décrit le réel — l'écart est précisément ce qu'on cherche |
| "Le code est propre, skip l'analyse profonde" | La qualité syntaxique ne garantit pas la conformité spec |
| "C'est une lib connue, elle est sûre" | Les libs ont leur propre comportement — non spécifié ≠ conforme |
| "0 finding = code conforme" | 0 finding peut signifier analyse incomplète ou spec trop vague |
| "Skipping full verification for efficiency" | L'efficacité ne justifie pas un verdict incomplet |
| "Le comportement est évident" | Ce qui est évident pour l'auteur peut être absent de la spec |

---

## Execution steps

### Step 0 — Initialisation

Run `.specify/scripts/powershell/check-prerequisites.ps1 -Json -RequireTasks` from repo root and parse JSON for `FEATURE_DIR` and `AVAILABLE_DOCS`.

Derive absolute paths:
- `SPEC_PATH` = `FEATURE_DIR/spec.md`
- `IMPL_DIR` = répertoire d'implémentation à déterminer depuis `$ARGUMENTS` ou depuis `plan.md §Architecture` (chemin `src/`, module Python, etc.)

**Abort si** `spec.md` est absent — afficher : `[speckit.verify] spec.md introuvable dans FEATURE_DIR. Exécuter /speckit.specify d'abord.`

Si `$ARGUMENTS` contient un chemin explicite, l'utiliser comme `IMPL_DIR`. Sinon, lire `FEATURE_DIR/plan.md §Architecture` ou `§Stack` pour inférer le répertoire source.

---

### Step 1 — Découverte de la documentation

**1a. Lire les artefacts spec :**

- `FEATURE_DIR/spec.md` — sections obligatoires : Overview, Functional Requirements, Non-Functional Requirements, Edge Cases (si présente)
- `FEATURE_DIR/plan.md` (si disponible) — Architecture, contraintes techniques, choix de stack
- `FEATURE_DIR/tasks.md` (si disponible) — liste des tâches pour identifier la portée attendue

**1b. Extraire les exigences :**

Pour chaque section fonctionnelle de `spec.md`, construire une liste d'exigences vérifiables :
```
REQ-001 | [section] | [texte de l'exigence] | [type: functional|non-functional|edge-case]
```

Règle : une exigence = une affirmation vérifiable dans le code. Les phrases trop vagues (ex. "le système doit être performant") → marquer `AMBIGUOUS` d'emblée avec note "critère non mesurable".

**1c. Inventaire du code :**

```
Glob IMPL_DIR/**/*.py  (ou extension pertinente selon stack)
```

Lister les fichiers trouvés. Pour chaque fichier clé (identifié via les noms de modules dans `plan.md` ou via la fonctionnalité couverte), lire le contenu avec `offset`+`limit` si >150 lignes.

---

### Step 2 — Extraction de la représentation intermédiaire (IR)

Construire une IR structurée du code — **jamais inférée, toujours citée** :

Pour chaque fichier d'implémentation pertinent, extraire :

```
IR-[N] | fichier:ligne | comportement observé | exigence candidate (REQ-xxx ou UNDOCUMENTED)
```

**Méthode** :
1. Lire les fonctions/classes publiques — identifier leur responsabilité (nom + docstring + signature)
2. Lire les chemins de données (inputs → transformations → outputs)
3. Identifier les comportements de bord (validations, guards, raises/returns spéciaux)
4. Repérer les comportements sans correspondance dans `spec.md` → candidats `UNDOCUMENTED_CODE`

**Règle 10k mental test** : si le module contient >20 fonctions, ne pas lire chaque fonction individuellement — utiliser `Grep` pour les patterns clés issus des exigences spec (ex. noms de fonctions, messages d'erreur, constantes), puis lire uniquement les fonctions matchées.

---

### Step 3 — Alignement spec ↔ code

Pour chaque exigence `REQ-xxx`, comparer avec l'IR :

**Classifications** :

| Code | Signification | Critère |
|------|--------------|---------|
| `FULL_MATCH` | Exigence implémentée conformément | Preuve directe dans l'IR, comportement identique à la spec |
| `PARTIAL_MATCH` | Implémentée partiellement ou avec écart mineur | Comportement présent mais incomplet ou légèrement déviant |
| `MISMATCH` | Implémentation contradictoire avec la spec | Comportement présent mais opposé ou incompatible |
| `UNDOCUMENTED_CODE` | Comportement dans le code sans exigence spec | IR-entry sans REQ correspondant |
| `AMBIGUOUS` | Impossible à trancher sans clarification | Spec vague OU code illisible sans contexte métier |

**Format par exigence** :

```
REQ-001 | FULL_MATCH | confiance: 0.9
  Spec  : §Functional Requirements > "La CLI accepte un argument positionnel [project-name]"
  Code  : src/specify_cli/__init__.py:892 — `def init(project_name: Optional[str] = typer.Argument(None, ...))`
  Note  : —
```

**Règle PARTIAL_MATCH** : documenter précisément ce qui est présent ET ce qui manque.

**Règle MISMATCH** : citer les deux (spec dit X, code fait Y) — ne pas qualifier l'erreur, juste constater.

**Règle AMBIGUOUS** : spécifier pourquoi la vérification est impossible (spec vague / code complexe / dépendance externe non traçable).

---

### Step 4 — Rapport

**4a. Tableau de synthèse :**

```
| REQ | Type | Verdict | Confiance | Fichier:Ligne | Note |
|-----|------|---------|-----------|---------------|------|
| REQ-001 | functional | FULL_MATCH | 0.9 | __init__.py:892 | — |
| REQ-002 | non-functional | PARTIAL_MATCH | 0.6 | __init__.py:1050 | timeout non configurable |
| REQ-003 | edge-case | MISMATCH | 0.8 | __init__.py:945 | spec dit erreur, code silencieux |
| — | — | UNDOCUMENTED_CODE | 0.85 | __init__.py:1102 | rollback auto non spécifié |
```

**4b. Résumé exécutif :**

```
Exigences analysées : N
  FULL_MATCH          : N (score moyen : X.X)
  PARTIAL_MATCH       : N
  MISMATCH            : N  ← action requise
  UNDOCUMENTED_CODE   : N  ← à documenter ou supprimer
  AMBIGUOUS           : N  ← clarification spec requise
```

**4c. Actions prioritaires :**

Lister par ordre de sévérité :

1. **MISMATCH** (priorité haute) — chaque écart avec spec + fichier:ligne
2. **UNDOCUMENTED_CODE** (priorité moyenne) — comportements sans spec : documenter dans spec OU supprimer du code
3. **PARTIAL_MATCH** (priorité basse) — compléter l'implémentation ou assouplir la spec si intent confirmé
4. **AMBIGUOUS** — questions spec à résoudre avant de pouvoir conclure

**4d. Sauvegarde du rapport (optionnel) :**

Si `$ARGUMENTS` contient `--save` ou si le nombre de findings > 5, proposer :
```
[S] Sauvegarder le rapport dans FEATURE_DIR/verify-report.md
[n] Afficher uniquement
```

Attendre confirmation avant Write. Format fichier : même contenu que le rapport, avec date en frontmatter.

---

## Périmètre et limites

**Ce que cette commande fait :**
- Vérifie l'alignement entre `spec.md` et le code source de la feature en cours
- Classifie chaque exigence avec preuve citée
- Identifie le code non documenté

**Ce que cette commande ne fait PAS :**
- Ne modifie aucun fichier
- Ne vérifie pas la qualité du code (→ `/speckit.checklist`)
- Ne vérifie pas la cohérence inter-artefacts (→ `/speckit.analyze`)
- Ne valide pas les tests (→ `uv run pytest`)
- Ne couvre pas les exigences non-fonctionnelles sans critère mesurable (→ AMBIGUOUS auto)

---

*Source : Trail of Bits `spec-to-code-compliance` plugin (CC-BY-SA-4.0) — adapté domaine SDD/Python/Markdown, 2026-06-29*
