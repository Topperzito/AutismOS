prepare_dirs() {
  export MODULES_DIR="$ROOT/generated/.modules"
  export LOCK_FILE="$ROOT/generated/.lock"

  mkdir -p "$MODULES_DIR"
  touch "$LOCK_FILE"
}
