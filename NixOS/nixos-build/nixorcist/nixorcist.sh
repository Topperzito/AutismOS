#!/usr/bin/env bash
set -euo pipefail

ROOT="/etc/nixos/nixorcist"
export ROOT

# Load directories first
source "$ROOT/lib/dirs.sh"
prepare_dirs

# Load rest
for lib in lock gen hub rebuild utils index; do
  source "$ROOT/lib/$lib.sh"
done

case "${1:-}" in
  select)
    select_packages
    ;;
  gen)
    generate_modules
    ;;
  hub)
    regenerate_hub
    ;;
  rebuild)
    run_rebuild
    ;;
  purge)
    purge_all_modules
    ;;
  import)
    shift
    import_from_file "${1:-}"
    ;;
  all)
    select_packages
    generate_modules
    regenerate_hub
    run_rebuild
    ;;
  *)
    echo "Usage: nixorcist {select|gen|hub|rebuild|all|purge|import <file>}"
    ;;
esac
