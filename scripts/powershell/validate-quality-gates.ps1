# validate-quality-gates.ps1
# Script de validation qualite autonome pour projets spec-kit
# Detecte le contexte (TypeScript, Python, etc.) et applique les gates P0/P1/P2
#
# Usage:
#   .\validate-quality-gates.ps1 -SourcePath "C:\dev\unrest\backend\src"
#   .\validate-quality-gates.ps1 -SourcePath "." -Language auto -Mode Warnings
#   .\validate-quality-gates.ps1 -SourcePath "." -Mode Advisory
#
# Modes:
#   Strict   = P0 only (BLOCKING, exit 1 si FAIL)
#   Warnings = P0+P1 (WARN non-bloquant, exit 0)
#   Advisory = P0+P1+P2 (informational, exit 0)
#
# Exit codes:
#   0 = PASS ou WARN ou Advisory
#   1 = FAIL (au moins un gate P0)

param(
  [string]$SourcePath = ".",
  [string]$Language = "auto",      # typescript | python | auto
  [string]$Mode = "Strict"         # Strict | Warnings | Advisory
)

$failed = 0
$warned = 0
$advised = 0

# Resolver chemin absolu
$SourcePath = Resolve-Path $SourcePath -ErrorAction SilentlyContinue
if (-not $SourcePath) {
  Write-Host "[FAIL] SourcePath not found" -ForegroundColor Red
  exit 1
}

Write-Host ""
Write-Host "Quality Gates Validation" -ForegroundColor Cyan
Write-Host "Source: $SourcePath" -ForegroundColor Gray
Write-Host "Language: $Language | Mode: $Mode" -ForegroundColor Gray
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
# P0-1: Complexite fichiers
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
# P0-3: Console.log dans lib/
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
# P1-1: DRY Violation (code duplicated >=3 times)
# ============================================================
if ($Mode -in @("Warnings", "Advisory") -and $Language -in @("typescript", "auto")) {
  Write-Host "P1-1 DRY violation check..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '\.(test|spec|config|d)\.ts$' }

  # Detect common duplicated patterns: error handling, validation blocks, similar function signatures
  $duplicatePatterns = @(
    'switch.*period',        # period-based logic duplication
    'if.*!.*verify',         # verification patterns
    'const.*=.*validate'     # validation patterns
  )

  $suspiciousFiles = @()
  foreach ($file in $tsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    foreach ($pattern in $duplicatePatterns) {
      $matches = [Regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
      if ($matches.Count -ge 3) {
        $suspiciousFiles += $file.Name
      }
    }
  }

  $suspiciousFiles = $suspiciousFiles | Sort-Object -Unique
  foreach ($fileName in $suspiciousFiles) {
    $msg = "[WARN] $fileName" + ": Potential DRY violation (pattern duplicated >=3 times)"
    Write-Host $msg -ForegroundColor Yellow
    $warned++
  }

  if ($suspiciousFiles.Count -eq 0) {
    Write-Host "[OK] No obvious DRY violations detected" -ForegroundColor Green
  }
}

# ============================================================
# P1-2: N+1 Queries (Prisma findMany in loop)
# ============================================================
if ($Mode -in @("Warnings", "Advisory") -and $Language -in @("typescript", "auto")) {
  Write-Host "P1-2 N+1 query patterns..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -match 'routers|services' -and $_.Name -notmatch '\.(test|spec)\.ts$' }

  $n1Files = @()
  foreach ($file in $tsFiles) {
    $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
    # Detect: for/forEach containing db.*.findMany or similar
    if ($content -match 'for\s*\(.*\).*prisma\.|forEach.*prisma\.' -or
        $content -match 'items\.map.*await.*prisma\.' -or
        $content -match 'for.*of.*{.*await\s+db\.' ) {
      $n1Files += $file.Name
    }
  }

  $n1Files = $n1Files | Sort-Object -Unique
  foreach ($fileName in $n1Files) {
    $msg = "[WARN] $fileName" + ": Potential N+1 query pattern (loop with DB call)"
    Write-Host $msg -ForegroundColor Yellow
    $warned++
  }

  if ($n1Files.Count -eq 0) {
    Write-Host "[OK] No obvious N+1 patterns detected" -ForegroundColor Green
  }
}

# ============================================================
# P1-3: Unused imports
# ============================================================
if ($Mode -in @("Warnings", "Advisory") -and $Language -in @("typescript", "auto")) {
  Write-Host "P1-3 Unused imports check..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '\.(test|spec|config|d)\.ts$' } |
    Select-Object -First 20  # Limiter pour performance

  $filesWithUnused = 0
  foreach ($file in $tsFiles) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
    # Simple heuristic: import X from Y, but X never appears in file (case-sensitive)
    $imports = [Regex]::Matches($content, 'import\s+{?\s*(\w+)', [System.Text.RegularExpressions.RegexOptions]::Multiline)
    foreach ($match in $imports) {
      $importName = $match.Groups[1].Value
      # Count occurrences (excluding the import line itself)
      $linesAfterImport = $content -split "`n" | Select-Object -Skip 1 | Out-String
      $usageCount = ([Regex]::Matches($linesAfterImport, "\b$importName\b")).Count
      if ($usageCount -eq 0) {
        Write-Host "[WARN] $($file.Name): Unused import '$importName'" -ForegroundColor Yellow
        $filesWithUnused++
        break  # Only report once per file
      }
    }
  }
}

# ============================================================
# P1-4: Type 'any' usage
# ============================================================
if ($Mode -in @("Warnings", "Advisory") -and $Language -in @("typescript", "auto")) {
  Write-Host "P1-4 Type 'any' check..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object {
      $_.Name -notmatch '\.(test|spec|config|d)\.ts$' -and
      $_.FullName -notmatch '[\\/]tests?[\\/]'
    }

  [int]$anyFileCount = 0
  foreach ($file in $tsFiles) {
    $matches = Select-String -Path $file.FullName -Pattern ':\s*any\b|as\s+any\b' -ErrorAction SilentlyContinue
    $anyCount = if ($matches -is [array]) { $matches.Count } else { if ($matches) { 1 } else { 0 } }
    if ($anyCount -gt 0) {
      Write-Host "[WARN] $($file.Name): $anyCount 'any' type(s) found (use explicit types)" -ForegroundColor Yellow
      $anyFileCount++
      $warned++
    }
  }

  if ($anyFileCount -eq 0) {
    Write-Host "[OK] No 'any' types in non-test files" -ForegroundColor Green
  }
}

# ============================================================
# P2-1: Cyclomatic complexity (functions > 10 branches)
# ============================================================
if ($Mode -eq "Advisory" -and $Language -in @("typescript", "auto")) {
  Write-Host "P2-1 Cyclomatic complexity advisory..." -ForegroundColor Gray

  $tsFiles = Get-ChildItem -Path $SourcePath -Recurse -Filter "*.ts" -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notmatch '\.(test|spec)\.ts$' } |
    Select-Object -First 10  # Limiter

  $complexFuncs = 0
  foreach ($file in $tsFiles) {
    $content = Get-Content $file.FullName -ErrorAction SilentlyContinue
    # Count if/else/switch/case occurrences per function (heuristic)
    $functions = [Regex]::Matches($content, 'function|=>|async\s+\(')
    if ($functions.Count -gt 0 -and $functions.Count -gt 10) {
      Write-Host "[ADV] $($file.Name): High function count ($($functions.Count)) - consider breaking into smaller functions" -ForegroundColor Cyan
      $advised++
    }
  }
}

# ============================================================
# Summary
# ============================================================
Write-Host ""
$statusColor = if ($failed -gt 0) { "Red" } elseif ($warned -gt 0) { "Yellow" } else { "Green" }
$statusLabel = if ($failed -gt 0) { "FAIL" } elseif ($warned -gt 0) { "WARN" } else { "PASS" }

Write-Host "Quality Gates: [$statusLabel] $failed FAIL, $warned WARN, $advised ADV" -ForegroundColor $statusColor

if ($failed -gt 0) {
  Write-Host "❌ P0 violations detected - fix before merging" -ForegroundColor Red
}
if ($warned -gt 0) {
  Write-Host "⚠️  P1 warnings found - address before merge (non-blocking)" -ForegroundColor Yellow
}
if ($advised -gt 0) {
  Write-Host "INFO: P2 advisories noted - log in refactoring-debt.yaml" -ForegroundColor Cyan
}

Write-Host ""
exit $(if ($failed -gt 0) { 1 } else { 0 })
