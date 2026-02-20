# validate-quality-gates.ps1
# Script de validation qualite autonome pour projets spec-kit
# Detecte le contexte (TypeScript, Python, etc.) et applique les gates P0
#
# Usage:
#   .\validate-quality-gates.ps1 -SourcePath "C:\dev\unrest\backend\src"
#   .\validate-quality-gates.ps1 -SourcePath "." -Language auto
#
# Exit codes:
#   0 = PASS (ou WARN uniquement)
#   1 = FAIL (au moins un gate P0 echoue)
#
# Resultats attendus sur Unrest (2026-02-20):
#   FAIL admin.ts (1205 LOC), WARN assessment.ts (520 LOC)

param(
  [string]$SourcePath = ".",
  [string]$Language = "auto"  # typescript | python | auto
)

$failed = 0
$warned = 0
$checks = @()

# Resolver chemin absolu
$SourcePath = Resolve-Path $SourcePath -ErrorAction SilentlyContinue
if (-not $SourcePath) {
  Write-Host "[FAIL] SourcePath not found" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Quality Gates Validation" -ForegroundColor Cyan
Write-Host "Source: $SourcePath" -ForegroundColor Gray
Write-Host "Language: $Language" -ForegroundColor Gray
Write-Host ""

# Detection langage
if ($Language -eq "auto") {
  $hasTsFiles = (Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0
  $hasPyFiles = (Get-ChildItem -Path $SourcePath -Recurse -Filter "*.py" -ErrorAction SilentlyContinue | Measure-Object).Count -gt 0
  if ($hasTsFiles) { $Language = "typescript" }
  elseif ($hasPyFiles) { $Language = "python" }
  else { $Language = "unknown" }
}

# ============================================================
# P0-1: Complexite fichiers (tous projets TypeScript)
# ============================================================
if ($Language -in @("typescript", "auto")) {
  Write-Host "P0-1 File complexity check..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object {
      $_.Name -notmatch '\.(test|spec|config|d)\.ts$' -and
      $_.Name -ne 'index.ts'
    }

  foreach ($file in $tsFiles) {
    $loc = (Get-Content $file.FullName -ErrorAction SilentlyContinue | Measure-Object -Line).Lines
    if ($loc -gt 800) {
      Write-Host "[FAIL] $($file.Name): $loc LOC (hard limit 800)" -ForegroundColor Red
      $failed++
    } elseif ($loc -gt 500) {
      Write-Host "[WARN] $($file.Name): $loc LOC (soft limit 500)" -ForegroundColor Yellow
      $warned++
    }
  }
}

# ============================================================
# P0-2: Pattern d'erreur (routers TypeScript)
# ============================================================
if ($Language -in @("typescript", "auto")) {
  Write-Host "P0-2 Error pattern check (routers)..." -ForegroundColor Gray

  $routerFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match '[\\/]routers?[\\/]' }

  foreach ($file in $routerFiles) {
    $bareErrors = Select-String -Path $file.FullName -Pattern 'throw new Error\(' -Quiet
    if ($bareErrors) {
      $count = (Select-String -Path $file.FullName -Pattern 'throw new Error\(').Count
      Write-Host "[FAIL] $($file.Name): $count bare 'throw new Error()' (use createError())" -ForegroundColor Red
      $failed++
    }
  }
}

# ============================================================
# P0-3: Console.log dans lib/ (TypeScript)
# ============================================================
if ($Language -in @("typescript", "auto")) {
  Write-Host "P0-3 Console.log check in lib/..." -ForegroundColor Gray

  $libFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object {
      $_.FullName -match '[\\/]lib[\\/]' -and
      $_.Name -notmatch '\.(test|spec)\.ts$' -and
      $_.Name -ne 'logger.ts'
    }

  foreach ($file in $libFiles) {
    $consoleLogs = Select-String -Path $file.FullName -Pattern 'console\.(log|warn|error|info)\(' -Quiet
    if ($consoleLogs) {
      $count = (Select-String -Path $file.FullName -Pattern 'console\.(log|warn|error|info)\(').Count
      Write-Host "[WARN] $($file.Name): $count console.* calls (use logger)" -ForegroundColor Yellow
      $warned++
    }
  }
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
$statusColor = if ($failed -gt 0) { "Red" } elseif ($warned -gt 0) { "Yellow" } else { "Green" }
$statusLabel = if ($failed -gt 0) { "FAIL" } elseif ($warned -gt 0) { "WARN" } else { "PASS" }

Write-Host "Quality Gates: [$statusLabel] $failed FAIL, $warned WARN" -ForegroundColor $statusColor

if ($failed -gt 0) {
  Write-Host "Fix P0 violations before merging." -ForegroundColor Red
}

exit $(if ($failed -gt 0) { 1 } else { 0 })
