#!/usr/bin/env bash
# Generate all game assets via Blender headless scripts
# Run from: game/tools/

set -e

BLENDER="$HOME/Documents/funracing/blender-5.0.1-linux-x64/blender"
SCRIPTS_DIR="$(dirname "$0")/blender_scripts"

if [ ! -f "$BLENDER" ]; then
    echo "ERROR: Blender not found at $BLENDER"
    exit 1
fi

echo "=== FunRacing Asset Generator ==="
echo "Blender: $BLENDER"
echo ""

run_script() {
    local script="$1"
    echo "--- Running: $(basename "$script") ---"
    "$BLENDER" --background --python "$script" 2>&1 | grep -E '^\[|ERROR|WARNING|Exported'
    echo ""
}

run_script "$SCRIPTS_DIR/gen_f1_car.py"
run_script "$SCRIPTS_DIR/gen_track_azur.py"
run_script "$SCRIPTS_DIR/gen_track_harrowstone.py"
run_script "$SCRIPTS_DIR/gen_track_veloce.py"

echo "=== Asset generation complete! ==="
echo "GLB files are in:"
echo "  game/cars/player_car/meshes/"
echo "  game/tracks/track_01_street/meshes/"
echo "  game/tracks/track_02_mixed/meshes/"
echo "  game/tracks/track_03_highspeed/meshes/"
