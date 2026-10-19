#!/bin/bash
set -euo pipefail

#verif droit d'admin
if [ "$EUID" -ne 0 ]; then
    echo "Erreur: Executer le scripte avec les droits sudo"
    exit 1
fi

echo "=== Mise à jour des paquets ==="
apt update

echo "=== Installation de PostgreSQL et UFW ==="
DEBIAN_FRONTEND=noninteractive apt install -y \
    postgresql \
    postgresql-client \
    ufw

echo "=== Activation de PostgreSQL ==="
systemctl enable --now postgresql

echo "=== Verfification des clusters ==="
pg_lsclusters

echo "=== Installation terminé ==="
