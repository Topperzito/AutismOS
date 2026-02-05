#!/usr/bin/env bash
set -euo pipefail

### ============================
### Globals
### ============================

DIALOG=dialog
PKG_MANAGER=""
SYSTEMD_AVAILABLE=0
PKG_MANAGER_SELECTED=0

### ============================
### Helpers
### ============================

die() {
  echo "ERROR: $1" >&2
  exit 1
}

msg() {
  $DIALOG --title "MariaDB Installer" --msgbox "$1" 10 70
}

input() {
  $DIALOG --stdout --inputbox "$1" 10 70
}

password() {
  $DIALOG --stdout --passwordbox "$1" 10 70
}

menu() {
  $DIALOG --stdout --menu "$1" 15 70 8 "${@:2}"
}

checklist() {
  $DIALOG --stdout --checklist "$1" 20 70 12 "${@:2}"
}

require_root() {
  [[ $EUID -eq 0 ]] || die "Run as root"
}

### ============================
### System detection
### ============================

detect_systemd() {
  if command -v systemctl >/dev/null && [[ -d /run/systemd/system ]]; then
    SYSTEMD_AVAILABLE=1
  fi
}

detect_pkg_managers() {
  local options=()

  [[ $PKG_MANAGER_SELECTED -eq 1 ]] && return

  if command -v pacman >/dev/null; then
    PKG_MANAGER="$(select_arch_helper)"
    PKG_MANAGER_SELECTED=1
    return
  fi

  command -v apt && options+=(apt "Debian/Ubuntu")
  command -v dnf && options+=(dnf "Fedora")
  command -v zypper && options+=(zypper "openSUSE")
  command -v apk && options+=(apk "Alpine")
  command -v nixos-rebuild && options+=(nixos "NixOS")
  command -v nix && options+=(nix "Nix (user environment)")

  [[ ${#options[@]} -gt 0 ]] || die "No supported package manager detected"

  PKG_MANAGER=$(menu "Select package manager" "${options[@]}")
}

select_arch_helper() {
  local choice

  choice=$(menu "Arch Linux detected. Select package manager:" \
    pacman "Official repos only" \
    paru   "AUR helper (recommended)" \
    yay    "AUR helper")

  case "$choice" in
    pacman)
      echo pacman
      ;;
    paru|yay)
      ensure_aur_helper "$choice"
      echo "$choice"
      ;;
    *)
      die "Invalid Arch package manager selection"
      ;;
  esac
}

ensure_aur_helper() {
  local helper="$1"
  local builddir user home

  if command -v "$helper" >/dev/null; then
    return
  fi

  user="${SUDO_USER:?AUR helpers must be built as a normal user}"
  home="$(getent passwd "$user" | cut -d: -f6)"

  msg "$helper not found. Installing..."

  pacman -Sy --needed --noconfirm base-devel git

  sudo -v

  sudo -u "$user" bash <<EOF
set -e

builddir="\$(mktemp -d "\$HOME/.cache/${helper}.XXXXXX")"
cd "\$builddir"

git clone https://aur.archlinux.org/${helper}.git
cd ${helper}

makepkg -si --noconfirm
EOF
}



### ============================
### Package installation
### ============================

install_packages() {
  case "$PKG_MANAGER" in
    pacman)
      pacman -Sy --noconfirm mariadb dialog
      ;;
    paru)
      paru -Sy --noconfirm mariadb dialog
      ;;
    yay)
      yay -Sy --noconfirm mariadb dialog
      ;;
    apt)
      apt update
      apt install -y mariadb-server dialog
      ;;
    dnf)
      dnf install -y mariadb-server dialog
      ;;
    zypper)
      zypper install -y mariadb dialog
      ;;
    apk)
      apk add mariadb mariadb-client dialog
      ;;
    nixos)
      generate_nixos_config
      ;;
    nix)
      install_nix_dev_env
      ;;
    *)
      die "Unsupported package manager: $PKG_MANAGER"
      ;;
  esac
}

### ============================
### Nix handlers
### ============================

generate_nixos_config() {
  cat <<'EOF'

NixOS detected.
You cannot imperatively install MariaDB.

Add the following to your configuration.nix:

-------------------------------------
services.mysql = {
  enable = true;
  package = pkgs.mariadb;
};

environment.systemPackages = with pkgs; [
  mariadb
];
-------------------------------------

Then run:
sudo nixos-rebuild switch

EOF

  exit 0
}

install_nix_dev_env() {
  msg "Installing MariaDB in user environment (dev-only)"

  nix profile install nixpkgs#mariadb nixpkgs#dialog

  msg "NOTE:
MariaDB installed in user environment.
You must start it manually and data will be user-scoped."
}

### ============================
### MariaDB setup
### ============================

validate_db_scope() {
  local scope="$1"

  if [[ -z "$scope" ]]; then
    echo "*.*"
    return
  fi

  if [[ "$scope" != *.* ]]; then
    msg "Invalid database scope.

Use:
  *.*
  mydb.*
  mydb.table"
    return 1
  fi

  if [[ "$scope" == "." || "$scope" == *"." || "$scope" == ".*" ]]; then
    msg "Invalid database scope: '$scope'"
    return 1
  fi

  echo "$scope"
}

user_exists() {
  local user="$1"
  local host="$2"

  mariadb -N -B <<SQL | grep -q 1
SELECT 1 FROM mysql.user WHERE User='${user}' AND Host='${host}';
SQL
}



init_mariadb() {
  msg "Initializing MariaDB data directory..."

  case "$PKG_MANAGER" in
    pacman|apt|dnf|zypper|apk)
      mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
      ;;
    nix)
      msg "Skipping system init for Nix dev env"
      return
      ;;
  esac
}

start_mariadb() {
  [[ $SYSTEMD_AVAILABLE -eq 1 ]] || return

  systemctl enable mariadb
  systemctl start mariadb
}

secure_baseline() {
  mariadb <<'SQL'
DELETE FROM mysql.user WHERE User='';
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db LIKE 'test_%';
FLUSH PRIVILEGES;
SQL
}

### ============================
### User creation
### ============================

create_user_tui() {
  local username host pw privs priv_sql raw_scope db_scope action

  username=$(input "Enter username")
  host=$(menu "Select host" \
    localhost "Local socket/localhost" \
    127.0.0.1 "Local TCP (GUI-friendly)" \
    % "Any host (NOT recommended)")

  pw=$(password "Enter password for $username")

  privs=$(checklist "Select privileges" \
    SELECT "Read data" off \
    INSERT "Insert data" off \
    UPDATE "Update data" off \
    DELETE "Delete data" off \
    CREATE "Create objects" off \
    DROP "Drop objects" off \
    ALTER "Alter schema" off \
    INDEX "Index management" off \
    ALL "ALL PRIVILEGES" off)

  if [[ "$privs" == *ALL* ]]; then
    priv_sql="ALL PRIVILEGES"
  else
    priv_sql=$(echo "$privs" | tr ' ' ',' | tr -d '"')
  fi

  while true; do
    raw_scope=$(input "Database scope (example: mydb.* or *.*)")
    db_scope=$(validate_db_scope "$raw_scope") && break
  done

  if user_exists "$username" "$host"; then
    action=$($DIALOG --stdout --menu \
      "User ${username}@${host} already exists. Choose action:" 12 70 3 \
      abort "Abort" \
      alter "Alter password & privileges" \
      recreate "Drop and recreate")

    case "$action" in
      abort)
        msg "User creation aborted."
        return
        ;;
      alter)
        mariadb <<SQL
ALTER USER '${username}'@'${host}' IDENTIFIED BY '${pw}';
GRANT ${priv_sql} ON ${db_scope} TO '${username}'@'${host}';
FLUSH PRIVILEGES;
SQL
        msg "User ${username}@${host} updated."
        return
        ;;
      recreate)
        mariadb <<SQL
DROP USER '${username}'@'${host}';
CREATE USER '${username}'@'${host}' IDENTIFIED BY '${pw}';
GRANT ${priv_sql} ON ${db_scope} TO '${username}'@'${host}';
FLUSH PRIVILEGES;
SQL
        msg "User ${username}@${host} recreated."
        return
        ;;
    esac
  else
    mariadb <<SQL
CREATE USER '${username}'@'${host}' IDENTIFIED BY '${pw}';
GRANT ${priv_sql} ON ${db_scope} TO '${username}'@'${host}';
FLUSH PRIVILEGES;
SQL
    msg "User ${username}@${host} created."
  fi
}


### ============================
### Main
### ============================

require_root
detect_systemd
detect_pkg_managers
install_packages

if [[ "$PKG_MANAGER" != "nixos" ]]; then
  init_mariadb
  start_mariadb
  secure_baseline

  $DIALOG --yesno "Create a database user now?" 8 50 && create_user_tui
fi

msg "MariaDB setup complete."
