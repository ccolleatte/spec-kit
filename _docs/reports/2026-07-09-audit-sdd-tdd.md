# Audit codebase spec-kit — bugs, risques, optimisations

**Date** : 2026-07-09
**Périmètre** : `src/specify_cli/`, `templates/`, `.specify/templates/`, `.claude/commands/speckit.*.md`, `.specify/scripts/powershell/`, `.github/workflows/`, `.claude/skills/speckit-orchestrator/`
**Méthode** : 3 agents d'exploration en parallèle (CLI Python, templates/commands SDD, scripts PowerShell/CI), findings vérifiés par citation de code (fichier:ligne).

## Résumé exécutif

10 findings CRITICAL, 7 HIGH, 6 MEDIUM, 2 LOW. Trois familles de risque dominent :

1. **Documentation qui décrit du code inexistant** (hallucination structurelle) — le cas le plus grave : `orchestrator.py` n'existe pas alors que CLAUDE.md et SKILL.md décrivent son comportement en détail.
2. **Deux jeux de templates/commandes qui divergent silencieusement** — selon le point d'entrée emprunté, le TDD gate ou le gate spec↔code peut être appliqué ou absent.
3. **Corruption silencieuse de fichiers utilisateur** — `settings.json` VS Code, `CLAUDE.md` agent, specs de features peuvent être écrasés ou laissés incohérents sans message d'erreur visible.

Zéro test ne couvre le module I/O critique (`specify_cli/__init__.py` : téléchargement, extraction zip, merge JSON).

---

## Plan d'actions priorisé

### P0 — Bloquant (à traiter avant toute nouvelle feature)

#### 1. `orchestrator.py` n'existe pas — la doc décrit un fantôme
**Fichiers** : `.claude/skills/speckit-orchestrator/` (contient seulement `SKILL.md`), `CLAUDE.md` (racine spec-kit)
**Constat** : CLAUDE.md décrit en détail un pipeline fail-fast (`spec.md` avant `plan`, `plan.md` avant `tasks`), avec exemples de commande `python .claude/skills/speckit-orchestrator/orchestrator.py`. Vérifié par Glob récursif : aucun `.py` dans ce dossier.
**Pourquoi c'est le risque n°1** : c'est exactement le risque d'hallucination documentaire que tu voulais détecter — un agent futur (toi via Claude Code, ou un collaborateur) lira CLAUDE.md, croira que le gate fail-fast existe, et soit tentera d'invoquer une commande qui échoue (`Command not found`), soit — pire — simulera manuellement le comportement décrit en pensant qu'un vrai contrôle automatisé le sécurise derrière.
**Action** : soit écrire `orchestrator.py` pour de vrai (il est déjà spécifié dans CLAUDE.md — c'est un cahier des charges prêt à l'emploi), soit supprimer la section de CLAUDE.md et documenter que l'enchaînement `specify→plan→tasks` reste manuel. Ne pas laisser cet état.

#### 2. Divergence `templates/` vs `.specify/templates/` — gates TDD/sécurité absents selon le chemin
**Fichiers** : `templates/spec-template.md` (308L) vs `.specify/templates/spec-template.md` (267L) — 272 lignes de diff
**Constat** : le template racine contient les gates Test/Security/UX traceability, section Maybe-Later, Architecture Exploration Triggers. `.specify/templates/spec-template.md` n'a qu'un "Edge Cases" générique — **sans aucun gate TDD**. Idem pour `memory/constitution.md` vs `.specify/memory/constitution.md`.
**Pourquoi c'est bloquant** : `.claude/commands/speckit.constitution.md` pointe vers `.specify/memory/constitution.md`, tandis que `templates/commands/constitution.md` pointe vers `/memory/constitution.md`. Selon lequel des deux fichiers de commande est réellement exécuté, tu obtiens une constitution — et donc des specs — avec ou sans tes gates TDD strict. C'est directement ta demande initiale ("améliorer mon approche SDD/TDD") : actuellement, le TDD gate est une roulette russe selon le chemin de fichier emprunté.
**Action** : choisir UNE source de vérité (recommandation : `.specify/` puisque c'est le chemin réellement résolu par `.claude/commands/speckit.*.md`, qui semble être le jeu actif). Supprimer ou symlink l'autre. Ne jamais laisser deux copies diverger.

#### 3. Chemins de scripts en dur PowerShell-only dans `.claude/commands/speckit.*.md`
**Fichiers** : `.claude/commands/speckit.specify.md:59` et autres — référencent `.specify/scripts/powershell/*.ps1` en dur, sans le mécanisme `{SCRIPT}`/`{ARGS}` documenté dans AGENTS.md pour la portabilité multi-agent.
**Constat** : `.specify/scripts/bash/` n'existe pas du tout dans le repo. Le frontmatter `scripts: {sh: ..., ps: ...}` présent dans `templates/commands/*.md` a été perdu dans les fichiers `.claude/commands/`.
**Impact pour toi** : tu es en PowerShell donc ce n'est pas bloquant à l'usage aujourd'hui — mais spec-kit revendique le support de 17 agents multi-OS (README, AGENTS.md), et cette régression casse cette promesse pour tout environnement non-Windows.
**Action** : soit restaurer le mécanisme `{SCRIPT}` générique dans `.claude/commands/`, soit assumer explicitement (doc) que `.claude/commands/speckit.*.md` est une variante Windows-only distincte des templates portables.

#### 4. CI release.yml — pipeline Node.js sur un projet Python, releases cassées
**Fichier** : `.github/workflows/release.yml`
**Constat** : le pipeline a été remplacé par `npm ci`, `docker/build-push-action`, `codecov` — alors que spec-kit n'a ni `package.json` ni `Dockerfile` (seulement `pyproject.toml`). Le job `deploy-production` ne se déclenche que si `tests-complete` réussit ; `npm ci` échouera immédiatement faute de `package.json`.
**Conséquence concrète** : plus aucune release GitHub ne sera publiée sur tag `v*.*.*` — régression silencieuse (le CI échoue, mais rien n'indique clairement "ce pipeline ne correspond pas à ce projet").
**Action** : revert ou réécrire `release.yml` en pipeline Python (`uv build`, `uv publish` / release GitHub via `gh release create`), en te basant sur les scripts `.github/workflows/scripts/*.sh` toujours présents mais désormais orphelins.

#### 5. Référence orpheline à `docs.yml` supprimé
**Fichier** : `docs/README.md:35`
**Constat** : référence encore `.github/workflows/docs.yml`, déplacé dans `.github/workflows/OLD_20251209/`. Le déploiement GitHub Pages documenté ne se déclenche plus, sans erreur visible.
**Action** : mettre à jour `docs/README.md` ou restaurer le workflow si le déploiement docs est toujours voulu.

#### 6. `merge_json_files` écrase silencieusement un settings.json invalide
**Fichier** : `src/specify_cli/__init__.py:611-616`
**Constat** : si le `.vscode/settings.json` existant contient du JSON invalide, la fonction retourne le nouveau contenu sans avertir — perte silencieuse de configuration utilisateur.
**Fichier lié** : `handle_vscode_settings` (`__init__.py:590-592`) — un `except Exception` trop large déclenche un fallback `shutil.copy2` qui écrase sans merge, avec un warning conditionné à `verbose=True`. En usage par défaut (`tracker` actif), c'est totalement silencieux.
**Impact utilisateur** : `specify init` sur un projet existant avec un `.vscode/settings.json` personnalisé peut le perdre intégralement sans que rien ne le signale.
**Action** : (a) toujours logger un warning visible (pas conditionné à `verbose`) en cas de fallback écrasant, (b) sauvegarder l'original en `.bak` avant d'écraser.

### P1 — Haute priorité (prochain cycle de travail)

#### 7. Zéro test sur le module I/O critique
**Fichier** : `src/specify_cli/__init__.py` — aucune des 3 suites de tests existantes (`tests/unit/test_orchestrator*.py`, `test_trivy_workflow.py`) ne référence `specify_cli`.
**Fonctions non testées** : `download_and_extract_template`, `merge_json_files`, `handle_vscode_settings`, `ensure_executable_scripts`, `init_git_repo`, toute la commande `init`.
**Pourquoi HIGH et pas CRITICAL** : le code fonctionne empiriquement (utilisé par la communauté), mais toute régression sur ces fonctions (téléchargement, extraction, merge) passerait inaperçue jusqu'à un rapport utilisateur.
**Action** : prioriser des tests sur `merge_json_files` (finding #6) et `download_and_extract_template` (comportement rollback) — ce sont les deux fonctions à plus fort risque de corruption.

#### 8. `create-new-feature.ps1` — branche git échouée, spec créée quand même
**Fichier** : `.specify/scripts/powershell/create-new-feature.ps1:246-263`
**Constat** : `git checkout -b` est dans un try/catch qui se contente d'un `Write-Warning` et continue — si la branche existe déjà (ex. re-run avec le même `-ShortName`), le script crée/écrase `specs/<branchName>/spec.md` (`Copy-Item -Force` ligne 260) sur la branche courante, potentiellement écrasant une spec existante sans avertissement visible en mode `-Json`.
**Action** : faire échouer le script (exit non-zéro) si `git checkout -b` échoue, plutôt que continuer en état incohérent.

#### 9. `update-agent-context.ps1` — perte silencieuse si sections renommées + troncature historique non documentée
**Fichier** : `.specify/scripts/powershell/update-agent-context.ps1:300-322`
**Constat** : la mise à jour de `CLAUDE.md` cherche des marqueurs exacts (`## Active Technologies`, `## Recent Changes`) — si l'utilisateur a reformaté ces sections manuellement, les nouvelles entrées ne sont jamais insérées, mais le script rapporte "Updated" quand même. Par ailleurs, la section Recent Changes est tronquée à 2 entrées à chaque exécution (perte d'historique par conception, non documentée comme destructive).
**Action** : (a) faire échouer explicitement si les marqueurs ne matchent pas plutôt que rapporter un faux succès, (b) documenter la troncature à 2 entrées dans l'aide du script, (c) sauvegarder `CLAUDE.md` en `.bak` avant `Set-Content`.

#### 10. Aucune vérification d'intégrité sur le zip téléchargé depuis GitHub Releases
**Fichier** : `src/specify_cli/__init__.py:637-749`
**Constat** : ni checksum SHA256 ni signature — seul HTTPS protège le téléchargement. Le zip est ensuite extrait puis ses scripts `.sh` rendus exécutables automatiquement (`ensure_executable_scripts`).
**Risque réel** : faible en pratique (GitHub Releases officiel), mais aucune défense en profondeur en cas de compromission de la pipeline de build ou d'un mirror CDN.
**Action** : publier un `checksums.txt` (SHA256) signé dans chaque release, et vérifier ce hash avant extraction dans le CLI.

#### 11. Flatten de répertoire nested — fenêtre de perte de données sur interruption
**Fichier** : `src/specify_cli/__init__.py:857-865`
**Constat** : `shutil.move` → `project_path.rmdir()` → `shutil.move` à nouveau. Entre le `rmdir()` et le second `move`, le répertoire projet n'existe plus du tout sur disque. Une interruption (Ctrl+C, crash) à ce moment précis fait disparaître le projet nouvellement créé.
**Action** : utiliser un répertoire temporaire adjacent et un seul `os.replace` atomique final, plutôt que deux `move` séparés par un `rmdir`.

#### 12. `speckit.verify` existe mais n'est raccroché à aucun point d'entrée
**Fichier** : `.claude/commands/speckit.verify.md`
**Constat** : le gate spec→code existe et est cohérent (méthodologie citée, classification FULL_MATCH/PARTIAL_MATCH/MISMATCH), mais n'est référencé par aucune autre commande (`speckit.plan.md`, `speckit.implement.md` ne le mentionnent pas en sortie). Son exécution reste à la discrétion de l'utilisateur.
**Action** : ajouter une recommandation explicite "lancer `/speckit.verify` avant merge" en fin de `speckit.implement.md`, ou l'intégrer au pipeline `speckit-orchestrator` une fois le finding #1 résolu.

#### 13. Extraction zip en mode `--here` sans transaction
**Fichier** : `src/specify_cli/__init__.py:821-842`
**Constat** : les fichiers sont copiés un par un (`shutil.copy2`) dans une boucle sur un répertoire existant. Une interruption en cours de boucle laisse un mélange de fichiers écrits/non-écrits, sans rollback.
**Action** : copier vers un répertoire temporaire puis déplacer atomiquement, ou au minimum lister les fichiers déjà copiés pour permettre un rollback manuel documenté.

### P2 — Moyenne priorité (dette à traiter, pas bloquante)

#### 14. `init()` — fonction de 226 lignes, 5+ responsabilités
**Fichier** : `src/specify_cli/__init__.py:994-1292` — mélange validation d'arguments, sélection interactive, tracking UI, orchestration I/O, affichage next-steps. Dépasse le seuil de 80 lignes (God Procedure).

#### 15. Duplication du pattern `if tracker: ... elif verbose: ...`
**Fichier** : `src/specify_cli/__init__.py` — 15+ occurrences du même if/else de logging à travers le fichier. Candidat à une fonction unique `log(msg, tracker, verbose)`.

#### 16. Duplication de logique flatten entre branches `--here` et normale
**Fichier** : `download_and_extract_template` (`__init__.py:751-898`, ~148 lignes) — le même pattern de détection/flatten de répertoire nested est écrit deux fois avec variations tracker/verbose.

#### 17. `check_tool("claude", ...)` — faux positif si l'alias est cassé
**Fichier** : `__init__.py:499-503` — vérifie seulement `.is_file()` sur `CLAUDE_LOCAL_PATH`, pas que le binaire est réellement exécutable.

#### 18. `scheduled-maintenance.yml` sans bloc `permissions:` explicite
**Fichier** : `.github/workflows/scheduled-maintenance.yml` — contrairement à `lint.yml` et `pr-validation.yml`, dépend des permissions par défaut du repo pour `GITHUB_TOKEN`. Principe du moindre privilège non respecté (risque réel faible, le job ne fait que créer une issue sur échec `npm audit`).

#### 19. `version()` sans option `--github-token`
**Fichier** : `__init__.py:1379` — incohérence UX : `init` accepte `--github-token` pour l'auth GitHub, `version` non, alors qu'il fait le même type d'appel API.

### P3 — Bas — à corriger opportunistement

#### 20. Zip tronqué non nettoyé sur `KeyboardInterrupt`
**Fichier** : `__init__.py:713-740` — le nettoyage du zip partiel ne couvre que `except Exception`, pas `KeyboardInterrupt` (Ctrl+C pendant le téléchargement).

#### 21. Surface API `run_command(shell=True)` non utilisée mais exposée
**Fichier** : `__init__.py:466-482` — aucun appelant actuel ne l'utilise avec une commande non fiable, mais la surface existe pour une régression future.

---

## Ce qui n'a pas été trouvé (pour éviter toute extrapolation)

- Aucune injection de commande active détectée dans `run_command`.
- Path traversal zip : `zipfile.extractall` de la stdlib protège nativement contre `..`/chemins absolus depuis les versions Python récentes — pas de vecteur actif confirmé, seulement une absence de défense en profondeur explicite (finding #10 couvre le risque adjacent d'intégrité).
- Aucune fuite de token GitHub confirmée dans les logs `--debug` (les headers de requête ne sont pas affichés).

## Recommandation de séquencement

Vu ta préférence fail-fast et impact minimal : traiter #1 et #2 en premier — ce sont les deux causes racines qui rendent tout le reste (gates TDD, orchestration, portabilité) non fiable de façon structurelle. Les findings #3 à #13 sont des symptômes ou des risques indépendants qui peuvent être traités en parallèle une fois la source de vérité clarifiée.
