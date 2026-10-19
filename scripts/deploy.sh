
cd ~/NovaBank

cat > scripts/deploy.sh <<'BASH'
#!/usr/bin/env bash
set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SQL_DIR="$ROOT/sql"
DB="bankdb"
OWNER="bank_owner"

trap 'echo "ERREUR ligne $LINENO : deploiement interrompu." >&2' ERR

echo "======================================="
echo "      NOVABANK - DEPLOIEMENT"
echo "======================================="

for cmd in sudo psql createuser createdb find; do
    command -v "$cmd" >/dev/null || {
        echo "Commande manquante : $cmd"
        exit 1
    }
done

sudo -v

VERSION=$(sudo -u postgres psql -Atqc "SHOW server_version_num;")

if (( VERSION < 180000 || VERSION >= 190000 )); then
    echo "PostgreSQL 18 requis. Version actuelle : $VERSION"
    exit 1
fi

declare -a FILES

for n in $(seq 2 24); do
    printf -v prefix '%02d' "$n"

    mapfile -t matches < <(
        find "$SQL_DIR" -maxdepth 1 -type f \
        -name "${prefix}_*.sql" | sort
    )

    if (( ${#matches[@]} != 1 )); then
        echo "ERREUR : un seul fichier ${prefix}_*.sql est attendu."
        exit 1
    fi

    FILES[$n]="${matches[0]}"
done

echo "23 scripts SQL detectes."

if sudo -u postgres psql -Atqc \
    "SELECT 1 FROM pg_database WHERE datname = '$DB'" \
    | grep -qx 1; then
    echo "ERREUR : la base $DB existe deja."
    echo "Aucune donnee existante n'a ete modifiee."
    exit 1
fi

if ! sudo -u postgres psql -Atqc \
    "SELECT 1 FROM pg_roles WHERE rolname = '$OWNER'" \
    | grep -qx 1; then
    echo "Creation de $OWNER..."
    sudo -u postgres createuser --login "$OWNER"
fi

echo "Creation de $DB..."
sudo -u postgres createdb -O "$OWNER" "$DB"

sudo -u postgres psql -d "$DB" \
    -v ON_ERROR_STOP=1 <<SQL
CREATE SCHEMA core AUTHORIZATION $OWNER;
CREATE SCHEMA audit AUTHORIZATION $OWNER;
SQL

run_owner() {
    local n="$1"
    local file="${FILES[$n]}"

    echo
    echo ">>> [bank_owner] $(basename "$file")"

    {
        printf 'SET ROLE %s;\n' "$OWNER"
        printf '\\i %s\n' "$file"
    } | sudo -u postgres psql \
        -X \
        -d "$DB" \
        -v ON_ERROR_STOP=1
}

run_admin() {
    local n="$1"

    echo
    echo ">>> [postgres] $(basename "${FILES[$n]}")"

    sudo -u postgres psql \
        -d "$DB" \
        -v ON_ERROR_STOP=1 \
        -f "${FILES[$n]}"
}

echo
echo "=== TABLES ET DONNEES ==="

for n in $(seq 2 11); do
    run_owner "$n"
done

echo
echo "=== ROLES ET PERMISSIONS ==="
run_admin 12

echo
echo "=== VUES, INDEX, TRIGGERS, FONCTIONS ==="

for n in $(seq 13 23); do
    run_owner "$n"
done

echo
echo "=== TESTS D'INTEGRITE ==="
run_owner 24

echo
echo "======================================="
echo "     DEPLOIEMENT TERMINE"
echo "======================================="

sudo -u postgres psql -d "$DB" -c \
"SELECT 'customers' AS table_name, COUNT(*) FROM core.customers
 UNION ALL
 SELECT 'accounts', COUNT(*) FROM core.accounts
 UNION ALL
 SELECT 'transfers', COUNT(*) FROM core.transfers
 UNION ALL
 SELECT 'transactions', COUNT(*) FROM core.transactions;"

echo
echo "Bonus CYBER non executes automatiquement."
BASH

chmod +x scripts/deploy.sh
bash -n scripts/deploy.sh
