#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/../.."

workers="${DARONE_GLOBAL_WORKERS:-${JULIA_NUM_THREADS:-4}}"
workers="${workers%%,*}"
[[ "$workers" == auto ]] && workers=$(nproc)
[[ "$workers" =~ ^[1-9][0-9]*$ ]] || { echo "Invalid worker count: $workers" >&2; exit 2; }
(( workers > 16 )) && workers=16

output="${1:-$HOME/darone-fig4c}"
mkdir -p "$output/logs"
export DARONE_PAPER_OUTPUT_DIR="$(cd "$output" && pwd)"
export DARONE_EXAMPLE_ITERATIONS="${DARONE_EXAMPLE_ITERATIONS:-28800}"
export JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1

echo "Running 16 DAR1 tiles using $workers concurrent processes"
seq 1 16 | xargs -P "$workers" -n 1 bash -c '
  set -euo pipefail
  tile="$1"
  x=$(( (tile - 1) / 4 + 1 ))
  y=$(( (tile - 1) % 4 + 1 ))
  export DARONE_GLOBAL_X_TILE="$x" DARONE_GLOBAL_Y_TILE="$y"
  log="$DARONE_PAPER_OUTPUT_DIR/logs/tile-x${x}-y${y}.log"
  if julia --startup-file=no --project=. case_studies/global_steadystate_run.jl > "$log" 2>&1; then
    echo "Finished tile x=$x y=$y"
  else
    echo "Failed tile x=$x y=$y; last 80 log lines:" >&2
    tail -n 80 "$log" >&2
    exit 1
  fi
' _
