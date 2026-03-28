param(
    [switch]$Json,
    [switch]$Scaffold
)

# Load common functions
. "$PSScriptRoot\common.ps1"

# Get repository root
$repoRoot = Get-RepoRoot

# --- Scaffold mode: copy e2e-scaffold template into project ---
if ($Scaffold) {
    $templateDir = Join-Path $PSScriptRoot ".." "templates" "e2e-scaffold"
    if (-not (Test-Path $templateDir)) {
        Write-Error "e2e-scaffold template not found at $templateDir"
        exit 1
    }

    # Detect tests directory based on project structure
    $testsDir = if (Test-Path (Join-Path $repoRoot "frontend")) {
        Join-Path $repoRoot "frontend" "tests"
    } elseif (Test-Path (Join-Path $repoRoot "src")) {
        Join-Path $repoRoot "tests"
    } else {
        Join-Path $repoRoot "tests"
    }

    # Copy scaffold files (do not overwrite existing)
    $items = @(
        @{ Src = "playwright.config.ts"; Dst = (Join-Path $repoRoot "playwright.config.ts") }
        @{ Src = "pages";                Dst = (Join-Path $testsDir "pages") }
        @{ Src = "helpers";              Dst = (Join-Path $testsDir "helpers") }
        @{ Src = "visual-regression";    Dst = (Join-Path $testsDir "visual-regression") }
        @{ Src = "e2e";                  Dst = (Join-Path $testsDir "e2e") }
    )

    $copied = 0
    foreach ($item in $items) {
        $srcPath = Join-Path $templateDir $item.Src
        $dstPath = $item.Dst

        if (Test-Path $dstPath) {
            Write-Host "[SKIP] $dstPath already exists" -ForegroundColor Yellow
            continue
        }

        if (Test-Path $srcPath -PathType Container) {
            Copy-Item -Path $srcPath -Destination $dstPath -Recurse
        } else {
            $parentDir = Split-Path $dstPath -Parent
            if (-not (Test-Path $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -Path $srcPath -Destination $dstPath
        }
        Write-Host "[OK] $dstPath" -ForegroundColor Green
        $copied++
    }

    Write-Host ""
    Write-Host "Scaffold E2E copie: $copied element(s)." -ForegroundColor Cyan
    Write-Host "Prochaines etapes:"
    Write-Host "  1. npm install -D @playwright/test @axe-core/playwright"
    Write-Host "  2. npx playwright install chromium"
    Write-Host "  3. Remplacer les placeholders [FRONTEND_PORT], [PAGE_NAME], etc."
    Write-Host "  4. Adapter auth-helpers.ts a votre systeme d'auth"
    exit 0
}

# Detect feature directory from git branch
$branch = Get-CurrentBranch
$featureMatch = $branch -match '(\d{3})-(.+)'

if (-not $featureMatch) {
    Write-Error "Not on a feature branch (expected format: 001-feature-name)"
    exit 1
}

$featureNum = $matches[1]
$featureName = $matches[2]
$specsDir = Join-Path $repoRoot "specs" "$featureNum-$featureName"

# Check required files exist
$specPath = Join-Path $specsDir "spec.md"
$planPath = Join-Path $specsDir "plan.md"

if (-not (Test-Path $specPath)) {
    Write-Error "spec.md not found. Run /speckit.specify first."
    exit 1
}

if (-not (Test-Path $planPath)) {
    Write-Error "plan.md not found. Run /speckit.plan first."
    exit 1
}

# Optional files
$dataModelPath = Join-Path $specsDir "data-model.md"
$constitutionPath = Join-Path $repoRoot ".specify" "memory" "constitution.md"

# Determine E2E directory based on project structure
$e2eDir = if (Test-Path (Join-Path $repoRoot "frontend")) {
    # Monorepo with frontend/backend
    Join-Path $repoRoot "frontend" "e2e"
} elseif (Test-Path (Join-Path $repoRoot "08-tests")) {
    # Numbered directory structure (like 202512_curation)
    Join-Path $repoRoot "08-tests" "e2e"
} elseif (Test-Path (Join-Path $repoRoot "backend")) {
    # Monorepo backend-only
    Join-Path $repoRoot "backend" "tests" "e2e"
} else {
    # Single project
    Join-Path $repoRoot "tests" "e2e"
}

# Output JSON for Claude Code
if ($Json) {
    $result = @{
        FEATURE_SPEC = $specPath
        IMPL_PLAN = $planPath
        DATA_MODEL = if (Test-Path $dataModelPath) { $dataModelPath } else { $null }
        CONSTITUTION_PATH = if (Test-Path $constitutionPath) { $constitutionPath } else { $null }
        SPECS_DIR = $specsDir
        E2E_DIR = $e2eDir
        BRANCH = $branch
        FEATURE_NAME = $featureName
        REPO_ROOT = $repoRoot
    }

    $result | ConvertTo-Json -Compress
}
