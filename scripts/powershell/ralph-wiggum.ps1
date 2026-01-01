#!/usr/bin/env pwsh

<#
.SYNOPSIS
Ralph Wiggum - Iterative spec refinement via test scenario analysis

.DESCRIPTION
Orchestrates the Ralph Wiggum loop:
1. Generate test scenarios from spec.md
2. Detect ambiguities via scenario analysis
3. Ask focused clarification questions
4. Update spec.md with answers
5. Check convergence (< 2 ambiguities → done)
6. Repeat until converged or max iterations reached

.PARAMETER Iteration
Current iteration number (1-3)

.PARAMETER QuestionsFile
Path to questions file for this iteration

.PARAMETER ScenariosFile
Path to scenarios file for this iteration

.PARAMETER AmbiguitiesFile
Path to ambiguities file for this iteration

.PARAMETER Json
Output in JSON format for scripting

.EXAMPLE
.\ralph-wiggum.ps1 -Iteration 1 -QuestionsFile "questions-1.md" -ScenariosFile "scenarios-1.md" -AmbiguitiesFile "ambiguities-1.md"
#>

[CmdletBinding()]
param(
    [int]$Iteration,
    [string]$QuestionsFile,
    [string]$ScenariosFile,
    [string]$AmbiguitiesFile,
    [string]$FeatureDir,
    [switch]$Json
)

$ErrorActionPreference = 'Stop'

# Source common functions
. "$PSScriptRoot/common.ps1"

# ========== FUNCTIONS ==========

function Parse-QuestionsMarkdown {
    [CmdletBinding()]
    param([string]$QuestionsContent)

    $questions = @()
    $currentQuestion = $null
    $currentOptions = @()

    $lines = $QuestionsContent -split "`n"

    foreach ($line in $lines) {
        if ($line -match '^### Q(\d+):') {
            # Save previous question
            if ($currentQuestion) {
                $currentQuestion.options = $currentOptions
                $questions += $currentQuestion
            }

            # Start new question
            $currentQuestion = [PSCustomObject]@{
                number  = [int]$matches[1]
                text    = $line -replace '^### Q\d+:\s*', ''
                options = @()
                type    = if ($line -match '\[Category\]') { 'multi' } else { 'short' }
            }
            $currentOptions = @()
        } elseif ($line -match '^\| ([A-Z])\s*\|\s*(.+)\s*\|') {
            $currentOptions += [PSCustomObject]@{
                letter = $matches[1]
                text   = $matches[2]
            }
        }
    }

    # Save last question
    if ($currentQuestion) {
        $currentQuestion.options = $currentOptions
        $questions += $currentQuestion
    }

    return $questions
}

function Initialize-RalphSession {
    [CmdletBinding()]
    param(
        [string]$FeatureDir,
        [int]$MaxIterations = 3,
        [int]$ConvergenceThreshold = 2
    )

    $sessionFile = Join-Path $FeatureDir '.ralph-session.json'

    if (Test-Path $sessionFile) {
        try {
            return Get-Content $sessionFile -Raw | ConvertFrom-Json
        } catch {
            Write-Warning "Failed to parse session file, re-initializing"
        }
    }

    # Create new session
    return [PSCustomObject]@{
        current_iteration      = 0
        max_iterations         = $MaxIterations
        convergence_threshold  = $ConvergenceThreshold
        iterations             = @()
        started_at             = Get-Date -Format "o"
    }
}

function Update-RalphSession {
    [CmdletBinding()]
    param(
        [PSCustomObject]$Session,
        [string]$FeatureDir,
        [int]$ScenariosCount,
        [int]$AmbiguitiesCount,
        [int]$QuestionsAsked
    )

    $Session.current_iteration++

    $iterationRecord = [PSCustomObject]@{
        iteration         = $Session.current_iteration
        scenarios_count   = $ScenariosCount
        ambiguities_found = $AmbiguitiesCount
        questions_asked   = $QuestionsAsked
        timestamp         = Get-Date -Format "o"
    }

    $Session.iterations += $iterationRecord

    $sessionFile = Join-Path $FeatureDir '.ralph-session.json'
    $sessionFile | ForEach-Object {
        # Atomic write: write to temp, then rename
        $tempFile = "$_`.tmp"
        $Session | ConvertTo-Json -Depth 10 | Set-Content $tempFile -Encoding UTF8
        Move-Item $tempFile $_ -Force
    }

    return $Session
}

function Show-Questions {
    [CmdletBinding()]
    param(
        [string]$QuestionsFile
    )

    if (-not (Test-Path $QuestionsFile)) {
        Write-Error "Questions file not found: $QuestionsFile"
        return @()
    }

    $content = Get-Content $QuestionsFile -Raw

    Write-Output ""
    Write-Output "======================================================================"
    Write-Output "           Ralph Wiggum Clarification Questions"
    Write-Output "======================================================================"
    Write-Output ""
    Write-Output $content
    Write-Output ""

    return $content
}

function Capture-Answers {
    [CmdletBinding()]
    param(
        [PSCustomObject[]]$Questions
    )

    $answers = @()

    foreach ($q in $Questions) {
        Write-Output ""
        Write-Output "----------------------------------------------------------------------"
        Write-Output "Question $($q.number): $($q.text)"
        Write-Output "----------------------------------------------------------------------"

        if ($q.options.Count -gt 0) {
            # Multiple choice question
            Write-Output "Options:"
            foreach ($opt in $q.options) {
                Write-Output "  [$($opt.letter)] $($opt.text)"
            }
            Write-Output ""

            $answer = ""
            do {
                $answer = Read-Host "Your choice ($($q.options[0].letter)-$($q.options[-1].letter))"
                $answer = $answer.ToUpper().Trim()

                if ($answer -eq "YES" -or $answer -eq "RECOMMENDED") {
                    # Use first option as default
                    $answer = $q.options[0].letter
                    break
                }

                $validOptions = $q.options.letter -join ','
                if ($answer -notin $q.options.letter) {
                    Write-Output "Invalid choice. Please enter $validOptions"
                } else {
                    break
                }
            } while ($true)

            $selectedOption = $q.options | Where-Object { $_.letter -eq $answer } | Select-Object -First 1
            $answers += [PSCustomObject]@{
                question = $q.number
                text     = $q.text
                answer   = $answer
                answerText = $selectedOption.text
            }
        } else {
            # Short answer question
            $answer = ""
            do {
                $answer = Read-Host "Your answer (<=5 words)"
                $wordCount = ($answer -split '\s+' | Where-Object { $_ } | Measure-Object).Count

                if ($wordCount -gt 5) {
                    Write-Output "Answer too long ($wordCount words). Please limit to 5 words."
                } else {
                    break
                }
            } while ($true)

            $answers += [PSCustomObject]@{
                question   = $q.number
                text       = $q.text
                answer     = $answer
                answerText = $answer
            }
        }
    }

    return $answers
}

function Count-Ambiguities {
    [CmdletBinding()]
    param(
        [string]$SpecContent
    )

    $count = 0

    # Count [NEEDS CLARIFICATION] markers
    $clarificationMatches = @([regex]::Matches($SpecContent, '\[NEEDS CLARIFICATION'))
    $count += $clarificationMatches.Count

    # Count TODO/TBD markers
    $todoMatches = @([regex]::Matches($SpecContent, '\b(TODO|TBD)\b', [System.Text.RegularExpressions.RegexOptions]::IgnoreCase))
    $count += $todoMatches.Count

    return $count
}

function Check-Convergence {
    [CmdletBinding()]
    param(
        [int]$CurrentIteration,
        [int]$MaxIterations,
        [int]$AmbiguityCount,
        [int]$ConvergenceThreshold
    )

    if ($AmbiguityCount -lt $ConvergenceThreshold) {
        return "CONVERGED"
    }

    if ($CurrentIteration -ge $MaxIterations) {
        return "MAX_ITERATIONS"
    }

    return "CONTINUE"
}

function Save-Answers {
    [CmdletBinding()]
    param(
        [PSCustomObject[]]$Answers,
        [string]$OutputPath
    )

    $markdown = @"
# Ralph Wiggum - Iteration Answers

Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

    foreach ($answer in $Answers) {
        $markdown += @"
## Q$($answer.question): $($answer.text)

**Answer**: $($answer.answer)

> $($answer.answerText)

---

"@
    }

    $markdown | Set-Content $OutputPath -Encoding UTF8
}

function Show-ConvergenceReport {
    [CmdletBinding()]
    param(
        [PSCustomObject]$Session,
        [string]$Status,
        [int]$FinalAmbiguityCount
    )

    Write-Output ""
    Write-Output "======================================================================"
    Write-Output "         Ralph Wiggum Refinement Report"
    Write-Output "======================================================================"
    Write-Output ""

    Write-Output "Status: $Status"
    Write-Output "Iteration: $($Session.current_iteration) / $($Session.max_iterations)"
    Write-Output "Final Ambiguity Count: $FinalAmbiguityCount"
    Write-Output ""

    Write-Output "Iteration Summary:"
    $Session.iterations | ForEach-Object {
        Write-Output "  [$($_.iteration)] Scenarios=$($_.scenarios_count), Ambiguities=$($_.ambiguities_found), Questions=$($_.questions_asked)"
    }

    Write-Output ""

    if ($Status -eq "CONVERGED") {
        Write-Output "✓ Spec has converged! All critical ambiguities resolved."
        Write-Output "  Ready for: /speckit.plan"
    } elseif ($Status -eq "MAX_ITERATIONS") {
        Write-Output "⚠ Max iterations reached with $FinalAmbiguityCount remaining ambiguities."
        Write-Output "  Recommendation: Review remaining gaps, proceed if acceptable, or run /speckit.ralph again"
    } else {
        Write-Output "➜ Iteration complete. Run /speckit.ralph again to continue refinement."
    }

    Write-Output ""
}

# ========== MAIN EXECUTION ==========

try {
    # If FeatureDir not provided, get from environment
    if (-not $FeatureDir) {
        $paths = Get-FeaturePathsEnv
        $FeatureDir = $paths.FEATURE_DIR
    }

    # Ensure .ralph directory exists
    $ralphDir = Join-Path $FeatureDir ".ralph"
    if (-not (Test-Path $ralphDir)) {
        New-Item -Path $ralphDir -ItemType Directory -Force | Out-Null
    }

    # Initialize or load session
    $session = Initialize-RalphSession -FeatureDir $FeatureDir

    Write-Verbose "Feature Dir: $FeatureDir"
    Write-Verbose "Iteration: $Iteration / $($session.max_iterations)"
    Write-Verbose "Questions File: $QuestionsFile"

    # Validate input files
    if (-not (Test-Path $QuestionsFile)) {
        Write-Error "Questions file not found: $QuestionsFile"
        exit 1
    }

    # Read spec to count ambiguities
    $specFile = Join-Path $FeatureDir "spec.md"
    if (-not (Test-Path $specFile)) {
        Write-Error "Spec file not found: $specFile"
        exit 1
    }

    $specContent = Get-Content $specFile -Raw
    $initialAmbiguityCount = Count-Ambiguities -SpecContent $specContent

    # Show questions and capture answers
    $questionsContent = Get-Content $QuestionsFile -Raw
    $questions = Parse-QuestionsMarkdown -QuestionsContent $questionsContent

    if ($questions.Count -eq 0) {
        Write-Output "No questions to ask. Spec may already be clear."
        exit 0
    }

    $answers = Show-Questions -QuestionsFile $QuestionsFile | Out-Null
    $answers = Capture-Answers -Questions $questions

    # Save answers
    $answersFile = Join-Path $ralphDir "answers-$Iteration.md"
    Save-Answers -Answers $answers -OutputPath $answersFile
    Write-Verbose "Answers saved to: $answersFile"

    # Count scenarios and ambiguities from input files
    $scenariosContent = Get-Content $ScenariosFile -Raw -ErrorAction SilentlyContinue
    $scenariosCount = ([regex]::Matches($scenariosContent, '^Given\s', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count

    $ambiguitiesContent = Get-Content $AmbiguitiesFile -Raw -ErrorAction SilentlyContinue
    $ambiguitiesCount = ([regex]::Matches($ambiguitiesContent, '^\s*-\s*\[', [System.Text.RegularExpressions.RegexOptions]::Multiline)).Count

    # Update session
    $session = Update-RalphSession -Session $session `
        -FeatureDir $FeatureDir `
        -ScenariosCount $scenariosCount `
        -AmbiguitiesCount $ambiguitiesCount `
        -QuestionsAsked $answers.Count

    # Re-read spec (will be updated by Claude in speckit.ralph.md Step 3e)
    $specContent = Get-Content $specFile -Raw
    $finalAmbiguityCount = Count-Ambiguities -SpecContent $specContent

    # Check convergence
    $status = Check-Convergence -CurrentIteration $session.current_iteration `
        -MaxIterations $session.max_iterations `
        -AmbiguityCount $finalAmbiguityCount `
        -ConvergenceThreshold $session.convergence_threshold

    # Display report
    Show-ConvergenceReport -Session $session -Status $status -FinalAmbiguityCount $finalAmbiguityCount

    # Determine exit code
    if ($status -eq "CONVERGED") {
        exit 0
    } elseif ($status -eq "MAX_ITERATIONS") {
        exit 2
    } else {
        exit 1
    }
} catch {
    Write-Error "Ralph Wiggum error: $_"
    Write-Error $_.ScriptStackTrace
    exit 1
}
