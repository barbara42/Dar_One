#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../.."

# One serial Julia/Fortran process per tile; JULIA_NUM_THREADS controls concurrency.
workers="${DARONE_GLOBAL_WORKERS:-${JULIA_NUM_THREADS:-4}}"
workers="${workers%%,*}"
if [[ "$workers" == auto ]]; then workers=$(nproc); fi
if [[ ! "$workers" =~ ^[0-9]+$ ]] || (( 10#$workers < 1 )); then
  echo "Worker count must be a positive integer: $workers" >&2
  exit 2
fi
workers=$((10#$workers))
if (( workers > 16 )); then workers=16; fi

export DARONE_BRAY_TILE_DIR="${DARONE_BRAY_TILE_DIR:-$PWD/bray-curtis-tiles}"
mkdir -p "$DARONE_BRAY_TILE_DIR"
export DARONE_BRAY_TILE_DIR="$(cd "$DARONE_BRAY_TILE_DIR" && pwd)"
export DARONE_EXAMPLE_LOG_DIR="${DARONE_EXAMPLE_LOG_DIR:-$DARONE_BRAY_TILE_DIR/logs}"
mkdir -p "$DARONE_EXAMPLE_LOG_DIR"
export DARONE_EXAMPLE_ITERATIONS="${DARONE_EXAMPLE_ITERATIONS:-28800}"
export JULIA_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1 OMP_NUM_THREADS=1

# Clear outputs from earlier runs so all 16 tiles must finish this run.
rm -f "$DARONE_BRAY_TILE_DIR"/bray-x*-y*.nc

echo "Running 16 DAR1 tiles using $workers concurrent processes"
seq 1 16 | xargs -P "$workers" -n 1 bash -c '
  set -euo pipefail
  tile="$1"
  x_tile=$(( (tile - 1) / 4 + 1 ))
  y_tile=$(( (tile - 1) % 4 + 1 ))
  export DARONE_GLOBAL_X_TILE="$x_tile" DARONE_GLOBAL_Y_TILE="$y_tile"
  log="$DARONE_EXAMPLE_LOG_DIR/darone-global-x${x_tile}-y${y_tile}.log"
  if julia --startup-file=no --project=. case_studies/global_steadystate_run.jl > "$log" 2>&1 &&
     julia --startup-file=no --project=. test/resources/export_bray_curtis_tiles.jl "$x_tile" "$y_tile" >> "$log" 2>&1; then
    echo "Finished tile x=$x_tile y=$y_tile"
  else
    echo "Failed tile x=$x_tile y=$y_tile; last 80 log lines:" >&2
    tail -n 80 "$log" >&2
    exit 1
  fi
' _

count=$(find "$DARONE_BRAY_TILE_DIR" -maxdepth 1 -type f -name 'bray-x*-y*.nc' | wc -l)
[[ "$count" -eq 16 ]] || { echo "Expected 16 tile outputs, found $count" >&2; exit 1; }
