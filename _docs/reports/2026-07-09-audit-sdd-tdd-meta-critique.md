# Méta-critique de l'audit SDD/TDD du 2026-07-09

**Date** : 2026-07-09
**Objet** : audit du rapport `2026-07-09-audit-sdd-tdd.md` (21 findings), sur le contenu et sur la méthode.
**Méthode de cette méta-critique** : lecture intégrale du rapport, puis contre-vérification par sondage de 8 findings (les 6 P0 + #7 + #12) par des moyens déterministes (`ls`, `git ls-tree`, `git log`, `grep`, exécution pytest) — délibérément distincts des outils de recherche utilisés par l'audit initial.

---

## Verdict

**Le rapport n'est pas actionnable en l'état pour les P0.** Son finding n°1 — celui que le résumé exécutif désigne comme « le cas le plus grave » et que le séquencement place en tête — est factuellement faux : `orchestrator.py` existe sur le disque (10 959 octets, `.claude/skills/speckit-orchestrator/orchestrator.py`), est commité dans HEAD (commit `3512406`), s'importe correctement, et 27 de ses 30 tests unitaires passent. Le rapport a construit sa hiérarchie de priorités sur une hallucination d'absence — précisément la classe d'erreur qu'il prétendait détecter chez les autres.

Le bilan du sondage est cependant contrasté, et c'est ce contraste qui rend le diagnostic utile :

| Classe de claim | Résultat du sondage |
|---|---|
| Claims de **présence** (code cité fichier:ligne) | 5/5 vérifiés exacts (#2, #3, #4, #6, #12) |
| Claims d'**absence** (« X n'existe pas », « aucun test ne... ») | 2/2 faux (#1 entièrement, #7 partiellement) |
| Arithmétique du résumé exécutif | incohérente (25 labels de sévérité pour 21 findings) |

Le rapport est donc fiable là où il cite du code, et défaillant là où il affirme une absence ou synthétise. Les findings #2, #4 et #6 peuvent être traités immédiatement (avec une correction de séquencement sur #2, voir §5). Le #1 doit être réécrit de fond en comble. Le reste demande le tri détaillé ci-dessous.

---

## 1. Le finding #1 est faux — anatomie de l'erreur

### 1.1 Les faits

| Claim du rapport | Réalité vérifiée |
|---|---|
| « `orchestrator.py` n'existe pas » | Existe : `ls` montre `orchestrator.py` (10 959 o, daté 1er mars) aux côtés de README.md et SKILL.md |
| « le dossier contient seulement `SKILL.md` » | Faux : 3 fichiers présents |
| « Vérifié par Glob récursif : aucun `.py` dans ce dossier » | Le tool Glob retourne effectivement « No files found » sur ce dossier — **alors que les fichiers existent**. Faux négatif reproductible de l'outil, pas un fait sur le disque |
| (implicite) le code n'a jamais été écrit | Commit `3512406` « feat(orchestrator): Implement skillchain sequential orchestration » : 309 lignes de `orchestrator.py` + 525 lignes de tests, toujours dans HEAD |
| (implicite) les tests de l'orchestrateur testent un fantôme | `pytest tests/unit/` : 27 passed, 3 failed — le module s'importe et fonctionne majoritairement |

Le fichier n'est ignoré par aucune règle (`git check-ignore` : exit 1, pas de `.claudeignore`). Le mécanisme exact du faux négatif de Glob sur `.claude/skills/` n'est pas établi (probablement un masquage du répertoire de configuration actif par le harness lui-même — la copie dans `.claude/skills_backup_20260322/`, nommée différemment, est visible, elle). Ce qui est établi : l'agent d'audit a pris un zéro-résultat d'outil pour une preuve d'inexistence, sans second canal de vérification.

### 1.2 L'ironie structurelle

Le finding #1 justifie son rang par ce scénario : « un agent futur lira CLAUDE.md, croira que le gate fail-fast existe [et agira sur cette croyance] ». C'est le miroir exact de ce qui s'est produit : l'agent d'audit a lu un résultat d'outil, cru que le fichier n'existait pas, et le rapport entier a été priorisé sur cette croyance. Le mode de défaillance dénoncé et le mode de défaillance commis sont le même — confiance dans une source unique non contre-vérifiée.

### 1.3 Les dégâts en cascade dans le rapport

- **Résumé exécutif, famille de risque n°1** (« hallucination structurelle ») : s'effondre. CLAUDE.md ne décrit pas un fantôme ; il décrit du code réel et commité, avec un drift mineur (309 lignes réelles vs « 200-250 » documentées).
- **Recommandation de séquencement** (« traiter #1 et #2 en premier — les deux causes racines ») : à moitié invalide. #1 n'est cause de rien.
- **Action recommandée du #1** (« écrire `orchestrator.py` pour de vrai — c'est un cahier des charges prêt à l'emploi ») : aurait conduit à réécrire 309 lignes de code existant et testé. Pour un développeur dont le principe est ZERO-NEW/ultra-lean, le rapport recommandait la pire option possible, présentée comme la plus vertueuse.

### 1.4 Ce qui survit du #1

Trois résidus réels, tous mineurs par rapport au finding d'origine :
1. **3 tests rouges** dans `test_orchestrator.py` (classe `TestPipelineExecution`, erreur `[TDD GATE] tasks.md not found`) — pour un système TDD strict, une suite rouge est un vrai finding, absent du rapport (voir §4.2).
2. **Copie backup non trackée** `.claude/skills_backup_20260322/` — pollution qui a d'ailleurs contribué à brouiller ma propre première recherche.
3. **Drift documentaire mineur** dans CLAUDE.md (compte de lignes obsolète). P2 au mieux.

---

## 2. Le finding #7 contient un claim faux et une contradiction interne non détectée

### 2.1 Le claim absolu est faux

« Aucune des 3 suites de tests existantes ne référence `specify_cli` » : faux. `tests/unit/test_trivy_workflow.py:8` contient `from specify_cli import generate_trivy_workflow`, et cette fonction existe (`__init__.py:901`). La couverture de `specify_cli` est quasi nulle, pas nulle — le fond du finding (fonctions I/O critiques non testées : download, extraction, merge) survit intégralement, mais c'est la deuxième affirmation d'absence du rapport qui tombe au sondage. Deux sur deux.

### 2.2 La contradiction #1↔#7 que le rapport ne voit pas

Le rapport affirme simultanément :
- #1 : `orchestrator.py` n'existe pas ;
- #7 : les « 3 suites de tests existantes » incluent `test_orchestrator*.py`.

Si #1 était vrai, ces suites importeraient un module inexistant et ne pourraient même pas être collectées — les « suites existantes » du #7 seraient des cadavres. Aucun des deux findings ne référence l'autre. C'est le symptôme le plus net de l'absence de passe de cohérence inter-findings : deux agents ont chacun décrit leur périmètre, et la rédaction finale a juxtaposé sans confronter. Une confrontation aurait immédiatement soulevé la question « mais alors, ces tests tournent-ils ? » — dont la réponse (oui, 27/30) invalidait #1.

---

## 3. Le résumé exécutif ne compte pas juste et la sévérité n'est pas traçable

- Annonce : « 10 CRITICAL, 7 HIGH, 6 MEDIUM, 2 LOW » = **25 labels**.
- Corps du rapport : findings #1-#21 = **21 findings**, répartis P0=6, P1=7, P2=6, P3=2.
- Les colonnes HIGH/MEDIUM/LOW s'alignent exactement sur P1/P2/P3 (7/6/2), mais « 10 CRITICAL » ≠ 6 P0. Quatre findings CRITICAL ont disparu entre l'évaluation et la rédaction, ou le chiffre est inventé.

Plus structurel : **aucun finding individuel ne porte de label de sévérité**. Seuls les buckets P0-P3 existent. Le référentiel du workspace (`severity-tiers.md`) distingue explicitement sévérité (CRITICAL/HIGH/...) et niveau d'obligation (P0-P3) ; le rapport les conflate, et la conflation rend l'incohérence 25≠21 invérifiable depuis le corps du texte. Conséquence pratique : le chiffre « 10 CRITICAL » cité en synthèse (et repris tel quel dans les échanges depuis) ne correspond à rien d'auditable.

Défaut de discipline corollaire : les findings P0/P1 ont tous un champ « Action » ; les P2/P3 (#14 à #19) n'en ont pour la plupart aucun. Le format se délite à mesure que la sévérité baisse — signe d'une rédaction en une passe sans réconciliation finale.

---

## 4. Priorisation : partiellement causale, avec trois défauts nets

Le rapport fait un effort causal réel (le séquencement final désigne des causes racines, #12 référence #1) — ce n'est pas une simple liste d'ordre de découverte déguisée. Mais trois défauts :

### 4.1 Le P0 est hétérogène

Le #5 (une ligne de `docs/README.md` référençant un workflow déplacé) est cosmétique : impact nul sur le code, la sécurité ou le workflow TDD, correction en 30 secondes. Il siège en P0 aux côtés de #4 (releases cassées) et #6 (perte silencieuse de fichiers utilisateur). Un P0 qui mélange « bloquant avant toute feature » et « une ligne de doc périmée » perd sa fonction de tri.

### 4.2 Asymétries et dépendances non argumentées

- **#6 (P0) vs #8 (P1)** : les deux sont des écrasements silencieux de fichiers utilisateur. Mais #6 détruit un `settings.json` VS Code (reconstructible), #8 écrase un `spec.md` (`Copy-Item -Force`) — **le produit central d'un système SDD**. L'asymétrie de priorité est défendable ou non, mais elle n'est jamais argumentée ; à l'aune de l'objectif déclaré de l'audit (protéger le workflow SDD/TDD), elle est probablement inversée.
- **#10 dépend de #4** : l'action du #10 est « publier un `checksums.txt` signé dans chaque release » — impossible tant que le pipeline de release ne tourne pas (#4). La dépendance n'est pas déclarée ; traiter #10 avant #4 est un non-sens opérationnel.
- **Findings manquants de rang P0** (voir aussi §6) : la suite de tests est rouge (3 fails) et ne se lance même pas sans contorsion (`uv run pytest` depuis la racine spec-kit échoue : pytest remonte sur `C:\dev\pyproject.toml`, exige `--cov` avec un pytest-cov absent de l'env). Pour un système dont la règle d'or est « test-first, jamais modifier les tests », **une infrastructure de test qui ne s'exécute pas nativement est le finding le plus prioritaire qui soit** — il conditionne la vérifiabilité de tous les autres fixes. Aucun des trois agents ne l'a vu, car aucun n'a exécuté quoi que ce soit.

### 4.3 Le piège de l'action du #2

Le #2 est vérifié et réel (308 vs 267 lignes, constitutions 69 vs 60, pointeurs divergents confirmés : `.claude/commands/speckit.constitution.md` → `.specify/memory/`, `templates/commands/constitution.md` → `/memory/`). Mais son action est un piège en deux temps :

1. **« Choisir `.specify/` comme source de vérité [...] Supprimer ou symlink l'autre »** — or le rapport établit lui-même que les gates TDD/sécurité vivent dans `templates/` (le fichier riche) et sont **absents** de `.specify/`. Exécutée littéralement (« supprimer l'autre »), l'action canonise l'arbre sans gates et détruit l'arbre qui les contient. L'étape indispensable — porter les gates de `templates/` vers `.specify/` **avant** toute suppression — n'est pas écrite. Pour un rapport dont la raison d'être est de protéger ces gates, c'est l'ambiguïté la plus dangereuse du document.
2. **`.specify/` n'est pas tracké par git.** Le git status montre `?? .specify/memory/`, `?? .specify/scripts/powershell/*`, `?? .specify/templates/*`, et la moitié des `.claude/commands/speckit.*.md` également non trackés. Le rapport recommande de faire d'un arbre hors contrôle de version la source de vérité, sans mentionner ce fait. Un `git clean -fd` (ou un clone frais) détruirait la « source de vérité » recommandée. Aucun agent n'a regardé l'état git — voir §6.

---

## 5. Les familles de risque du résumé exécutif sont mal découpées

Le résumé nomme trois familles : hallucination documentaire, divergence de templates, corruption silencieuse. La première est fausse (§1). Mais surtout, le rapport contient tous les symptômes d'une cause commune qu'il ne nomme jamais : **les migrations inachevées qui laissent des artefacts dupliqués ou déplacés sans nettoyage**.

Les indices, tous présents dans le rapport ou dans le repo :
- `.claude/skills_backup_20260322/` (copie backup non nettoyée — a piégé l'audit lui-même) ;
- `.github/workflows/OLD_20251209/` (ancien pipeline déplacé, non supprimé — cause du #5) ;
- `templates/` vs `.specify/templates/` (deux arbres divergents — #2) ;
- `templates/commands/` avec frontmatter `{SCRIPT}` vs `.claude/commands/` en dur PowerShell (#3) ;
- `release.yml` remplacé par un pipeline d'un autre projet, scripts `.sh` orphelins (#4) ;
- moitié de l'arbre actif non commité (§4.3).

Cinq des six P0 sont des symptômes de ce pattern unique. Le geste correctif n'est alors pas « six fixes indépendants » mais un seul chantier : inventorier les restes de migration, décider une fois l'arbre canonique, appliquer partout, commiter. Le rapport, faute de passe de synthèse causale, livre les symptômes en ordre dispersé et laisse le lecteur refaire la causalité — ce qui est précisément le travail qu'on attend d'un audit.

---

## 6. Angles morts de périmètre

Quatre dimensions n'appartenaient au périmètre d'aucun des trois agents, et chacune a coûté :

1. **L'historique et l'état git.** Aucun `git log`, aucun `git status` interprété. Coût : cause racine du #1 ratée, non-tracking de `.specify/` raté, pattern « migrations inachevées » non nommé.
2. **L'exécution.** Trois agents lecteurs (Explore, read-only), zéro commande lancée. Coût : suite rouge non vue, fuite de config pytest vers `C:\dev` non vue, et surtout #1 non réfuté alors qu'un simple `ls` suffisait.
3. **La relation fork/upstream.** Le repo est un fork de github/spec-kit lourdement modifié localement. Aucun finding n'adresse le risque de résurrection des divergences lors d'un merge upstream — pertinent puisque le #2 propose justement de supprimer un des deux arbres.
4. **L'échantillonnage du reste de CLAUDE.md.** Le rapport traite le #1 comme un défaut localisé d'une section. Si une section de CLAUDE.md pouvait halluciner (hypothèse du rapport), la conclusion logique était d'échantillonner les autres sections pour la même classe d'erreur — jamais fait. (Le fait que #1 soit faux ne retire rien au défaut de méthode : l'audit croyait avoir trouvé une hallucination documentaire et n'a pas cherché à en estimer la prévalence.)

Point positif à conserver : la section « Ce qui n'a pas été trouvé » est une bonne pratique anti-extrapolation. Un bémol : le claim sur `zipfile.extractall` (« protège nativement contre `..` ») y est affirmé sans version Python épinglée ni source — une affirmation négative de plus, non vérifiée, dans un rapport dont les deux affirmations négatives sondées se sont révélées fausses.

---

## 7. Méthode : le process était structurellement incapable de produire ce qu'il annonce

### 7.1 Le défaut n'est pas la parallélisation, c'est l'absence de l'étage suivant

Trois agents parallèles à périmètres disjoints (CLI Python / templates-commands / PowerShell-CI) sont un bon étage de **collecte**. Le rapport revendique pourtant en synthèse des causes racines **systémiques** — or une cause systémique, par définition, traverse les frontières des périmètres. Sans passe de synthèse dédiée, les « familles » du résumé exécutif ne peuvent être que du pattern-matching rédactionnel produit au moment du write-up. La démonstration est faite : la famille n°1 est fausse, et la vraie famille commune (migrations inachevées) n'est pas nommée alors que tous ses symptômes sont dans le corps du rapport.

### 7.2 Les claims d'absence exigeaient un second canal — règle déjà écrite, non appliquée

La méthode déclarée (« findings vérifiés par citation de code fichier:ligne ») vérifie structurellement des **présences**. Elle ne peut rien pour les **absences** — et les deux claims porteurs du rapport (#1, #7) étaient des absences. Le workspace encode déjà la parade (`learnings.md`, corollaire claim-gate, point e) : « tout verdict fondé sur "script/fichier absent" → re-vérifier par check déterministe avant d'accepter le verdict ». Appliquée, cette règle tuait #1 en une commande. L'audit a de surcroît utilisé pour vérifier l'absence l'outil même qui portait l'angle mort (Glob sur `.claude/skills/`) — un faux négatif d'outil promu au rang de fait.

### 7.3 Ce qu'un harness différent aurait attrapé, concrètement

| Étage ajouté | Coût approximatif | Aurait attrapé |
|---|---|---|
| Check déterministe des claims d'absence (`ls`, `git ls-tree`, `Test-Path`) — script, pas agent | ~0 | #1 (faux), #7 (claim absolu faux) |
| Smoke run d'exécution (`pytest --collect-only`, `pytest -q`) | 2 min | Suite rouge, fuite config pytest, réfutation #1 par l'import |
| Passe adversariale bornée aux P0 (1 agent réfuteur par finding, brief « essaie de démolir ce finding ») | ~1/3 du run initial | #1, le piège de l'action #2, la dépendance #10→#4 |
| Agent de synthèse causale avec brief explicite « pour chaque paire de findings : dépendance, contradiction, ou indépendance » | 1 agent | Contradiction #1↔#7, famille « migrations inachevées », asymétrie #6/#8 |
| Réconciliation déterministe finale (compter les findings, vérifier sévérité+priorité+action par finding) — checklist, pas agent | ~0 | 25≠21, sévérités non tracées, actions manquantes en P2/P3 |

Deux remarques d'économie : (a) les deux étages les plus rentables (check d'absence, réconciliation) sont déterministes et quasi gratuits — le harness a échoué d'abord sur ce qui ne coûtait rien ; (b) le pattern canonique du Workflow tool du workspace est justement find → **adversarially verify** → synthesize. L'audit a exécuté la moitié gauche du pattern et livré comme si la moitié droite avait tourné.

### 7.4 Ce que le process a bien fait

Pour calibrer le jugement, pas pour adoucir : la discipline de citation fichier:ligne a produit 5/5 claims de présence exacts au sondage, la partition en trois périmètres a donné une couverture honnête de chaque zone, et la section « non trouvé » borne l'extrapolation. La défaillance est concentrée — claims d'absence, synthèse causale, réconciliation — exactement les trois étages absents du harness. Le problème est de structure de process, pas de qualité d'agents : le corriger est un changement de template d'orchestration, pas un « faire plus attention ».

---

## 8. Plan d'action corrigé

### P0 réels (ordre causal)

| # | Finding | Origine | Correction vs rapport |
|---|---|---|---|
| P0.1 | **Commiter l'arbre actif** : `.specify/**` et les `.claude/commands/speckit.*.md` non trackés | nouveau | Préalable à tout : on ne désigne pas une source de vérité hors contrôle de version |
| P0.2 | **Résoudre la divergence des arbres** (ex-#2), action re-séquencée : (1) porter les gates TDD/sécurité de `templates/` vers `.specify/`, (2) vérifier par diff que rien n'est perdu, (3) alors seulement supprimer/symlinker `templates/` | ex-#2 | L'ordre « porter → vérifier → supprimer » remplace « choisir → supprimer » |
| P0.3 | **Réparer l'infrastructure de test** : 3 tests orchestrateur rouges, pytest inutilisable depuis la racine (config `C:\dev\pyproject.toml` héritée, pytest-cov absent) | nouveau | Conditionne la vérifiabilité de tous les autres fixes (TDD strict) |
| P0.4 | **Réécrire `release.yml` en pipeline Python** (ex-#4) | ex-#4 vérifié | Inchangé |
| P0.5 | **Fix `merge_json_files`/`handle_vscode_settings`** (ex-#6) : warning non conditionné à verbose + backup `.bak` | ex-#6 vérifié | Inchangé — et premier candidat TDD (test rouge d'abord, cf. P0.3) |

### Reclassements

- **ex-#1** → P2 : nettoyer `.claude/skills_backup_20260322/`, corriger les 3 tests rouges (couvert par P0.3), rafraîchir les comptes de lignes de CLAUDE.md. L'action « écrire orchestrator.py » est annulée.
- **ex-#5** → P3 : une ligne de doc.
- **ex-#8** → discuter une promotion P0/P1 haut de liste : écrasement silencieux de `spec.md`, l'artefact central du système.
- **ex-#10** → explicitement bloqué par P0.4 (pas de checksums sans pipeline de release fonctionnel).
- **ex-#7** → reformuler : « couverture de `specify_cli` quasi nulle (1 fonction testée : `generate_trivy_workflow`) » — le claim « aucune » est faux.

### Pour les prochains audits (changement de harness)

Ajouter au template d'audit multi-agents, dans cet ordre : (1) tout claim d'absence passe par un check déterministe avant inscription ; (2) un smoke run d'exécution (tests, imports) fait partie du périmètre d'office ; (3) une passe adversariale sur les seuls P0 avant rédaction ; (4) un agent de synthèse causale avec brief de confrontation par paires ; (5) une checklist de réconciliation finale (comptes, sévérité par finding, action par finding). Les étapes 1 et 5 sont gratuites ; c'est par elles que ce rapport a failli.

---

## Annexe — journal des contre-vérifications

| Claim du rapport | Vérification effectuée | Verdict |
|---|---|---|
| #1 `orchestrator.py` absent | `ls`, `git ls-tree HEAD`, `git show 3512406 --stat`, `pytest` (import OK) | **FAUX** — existe, commité, importable |
| #1 (méthode) « Glob récursif » | Glob rejoué sur le dossier : « No files found » malgré 3 fichiers présents | Faux négatif d'outil reproduit |
| #2 divergence 308L/267L + constitutions 69L/60L | `wc -l` sur les 4 fichiers | Confirmé |
| #2 pointeurs constitution divergents | `grep` sur les deux fichiers de commande | Confirmé (`.specify/memory/` vs `/memory/`) |
| #3 chemins PowerShell en dur, pas de `{SCRIPT}`, pas de `scripts/bash/` | `sed`/`ls` sur `speckit.specify.md` et `.specify/scripts/` | Confirmé |
| #4 `npm ci`/codecov/docker dans release.yml | `grep` (lignes 27, 36, 72, 114) | Confirmé |
| #6 code `merge_json_files` lignes 611-616 | Read du code | Confirmé (retour silencieux sur JSONDecodeError) |
| #7 « aucune suite ne référence specify_cli » | `grep -rl specify_cli tests/` | **FAUX** — `test_trivy_workflow.py:8` importe `generate_trivy_workflow` (existante, `__init__.py:901`) |
| #12 `speckit.verify` référencé nulle part | `grep -rln` sur `.claude/commands/`, tail de `speckit.implement.md` | Confirmé |
| Résumé « 10 CRITICAL, 7 HIGH, 6 MEDIUM, 2 LOW » | Comptage des findings : 21 (P0=6, P1=7, P2=6, P3=2) | **Incohérent** — 25 labels pour 21 findings ; sévérité jamais tracée par finding |
| (hors rapport) exécution des tests | `uv run pytest tests/unit/ -o addopts="" -c pyproject.toml` | 27 passed, 3 failed ; échec de lancement sans override (config héritée de `C:\dev`) |
