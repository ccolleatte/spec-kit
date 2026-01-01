#!/usr/bin/env bash

set -e

#
# Ralph Wiggum - Iterative spec refinement via test scenario analysis
#
# Usage: ./ralph-wiggum.sh -d FEATURE_DIR -i ITERATION -q QUESTIONS_FILE -s SCENARIOS_FILE -a AMBIGUITIES_FILE
#

# Parse arguments
FEATURE_DIR=""
ITERATION=""
QUESTIONS_FILE=""
SCENARIOS_FILE=""
AMBIGUITIES_FILE=""

while getopts "d:i:q:s:a:h" opt; do
    case $opt in
        d) FEATURE_DIR="$OPTARG" ;;
        i) ITERATION="$OPTARG" ;;
        q) QUESTIONS_FILE="$OPTARG" ;;
        s) SCENARIOS_FILE="$OPTARG" ;;
        a) AMBIGUITIES_FILE="$OPTARG" ;;
        h)
            echo "Usage: $0 -d FEATURE_DIR -i ITERATION -q QUESTIONS_FILE -s SCENARIOS_FILE -a AMBIGUITIES_FILE"
            echo ""
            echo "Options:"
            echo "  -d FEATURE_DIR       Feature directory path"
            echo "  -i ITERATION         Current iteration number (1-3)"
            echo "  -q QUESTIONS_FILE    Path to questions file"
            echo "  -s SCENARIOS_FILE    Path to scenarios file"
            echo "  -a AMBIGUITIES_FILE  Path to ambiguities file"
            echo "  -h                   Show this help message"
            exit 0
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

# Validate required parameters
if [ -z "$FEATURE_DIR" ] || [ -z "$ITERATION" ] || [ -z "$QUESTIONS_FILE" ] || [ -z "$SCENARIOS_FILE" ] || [ -z "$AMBIGUITIES_FILE" ]; then
    echo "Error: Missing required parameters" >&2
    exit 1
fi

# ========== FUNCTIONS ==========

show_questions() {
    local questions_file="$1"

    if [ ! -f "$questions_file" ]; then
        echo "Error: Questions file not found: $questions_file" >&2
        return 1
    fi

    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║          Ralph Wiggum Clarification Questions                  ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    cat "$questions_file"
    echo ""
}

count_ambiguities() {
    local spec_file="$1"
    local count=0

    if [ ! -f "$spec_file" ]; then
        echo "0"
        return
    fi

    # Count [NEEDS CLARIFICATION] markers
    count=$((count + $(grep -o '\[NEEDS CLARIFICATION' "$spec_file" 2>/dev/null | wc -l)))

    # Count TODO/TBD markers
    count=$((count + $(grep -Eio '\b(TODO|TBD)\b' "$spec_file" 2>/dev/null | wc -l)))

    echo "$count"
}

check_convergence() {
    local current_iteration="$1"
    local max_iterations="$2"
    local ambiguity_count="$3"
    local convergence_threshold="${4:-2}"

    if [ "$ambiguity_count" -lt "$convergence_threshold" ]; then
        echo "CONVERGED"
    elif [ "$current_iteration" -ge "$max_iterations" ]; then
        echo "MAX_ITERATIONS"
    else
        echo "CONTINUE"
    fi
}

show_report() {
    local status="$1"
    local iteration="$2"
    local final_count="$3"

    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║        Ralph Wiggum Refinement Report                          ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Status: $status"
    echo "Iteration: $iteration / 3"
    echo "Final Ambiguity Count: $final_count"
    echo ""

    if [ "$status" = "CONVERGED" ]; then
        echo "✓ Spec has converged! Ready for: /speckit.plan"
    elif [ "$status" = "MAX_ITERATIONS" ]; then
        echo "⚠ Max iterations reached. Review remaining gaps and proceed manually."
    else
        echo "➜ More refinement needed. Run /speckit.ralph again."
    fi

    echo ""
}

# ========== MAIN EXECUTION ==========

# Ensure .ralph directory exists
RALPH_DIR="$FEATURE_DIR/.ralph"
mkdir -p "$RALPH_DIR"

# Validate input files
if [ ! -f "$QUESTIONS_FILE" ]; then
    echo "Error: Questions file not found: $QUESTIONS_FILE" >&2
    exit 1
fi

if [ ! -f "$FEATURE_DIR/spec.md" ]; then
    echo "Error: Spec file not found: $FEATURE_DIR/spec.md" >&2
    exit 1
fi

# Show questions (would be interactive in real scenario)
show_questions "$QUESTIONS_FILE"

# Count scenarios and ambiguities
SCENARIOS_COUNT=$(grep -c '^Given' "$SCENARIOS_FILE" 2>/dev/null || echo "0")
AMBIGUITIES_COUNT=$(grep -c '^\s*-\s*\[' "$AMBIGUITIES_FILE" 2>/dev/null || echo "0")

# Save placeholder answers (in real scenario, would capture user input)
ANSWERS_FILE="$RALPH_DIR/answers-$ITERATION.md"
cat > "$ANSWERS_FILE" << EOF
# Ralph Wiggum - Iteration $ITERATION Answers

Generated: $(date '+%Y-%m-%d %H:%M:%S')

(Placeholder - actual user answers would be populated here)
EOF

# Count final ambiguities
FINAL_AMBIGUITY_COUNT=$(count_ambiguities "$FEATURE_DIR/spec.md")

# Check convergence
STATUS=$(check_convergence "$ITERATION" "3" "$FINAL_AMBIGUITY_COUNT" "2")

# Show report
show_report "$STATUS" "$ITERATION" "$FINAL_AMBIGUITY_COUNT"

# Exit with appropriate code
if [ "$STATUS" = "CONVERGED" ]; then
    exit 0
elif [ "$STATUS" = "MAX_ITERATIONS" ]; then
    exit 2
else
    exit 1
fi
