
# NovaBank Core — PostgreSQL 18

Projet de base de données bancaire développé avec PostgreSQL 18, SQL et PL/pgSQL, dans le cadre d'un parcours de bases de données avancées et de cybersécurité.

L'objectif est de concevoir, déployer, administrer et sécuriser une base de données bancaire sur un serveur Ubuntu.

---

## 1. Présentation du projet

NovaBank Core simule le fonctionnement d'un système bancaire.

### Fonctionnalités

- Gestion des clients et des comptes bancaires
- Gestion des virements et des transactions
- Vérification de l'âge des clients
- Contrôle des soldes et prévention des découverts
- Détection de certaines opérations suspectes
- Journalisation des modifications
- Gestion des rôles et des permissions
- Protection des données sensibles
- Vues classiques, modifiables et matérialisées
- Optimisation des requêtes avec des index
- Fonctions bancaires en PL/pgSQL
- Tests d'intégrité et sauvegarde de la base

### Technologies utilisées

| Technologie | Utilisation |
|---|---|
| Ubuntu Linux | Système d'exploitation du serveur |
| VMware | Virtualisation |
| PostgreSQL 18 | Système de gestion de base de données |
| SQL | Création et interrogation des données |
| PL/pgSQL | Fonctions et triggers |
| OpenSSL / TLS | Chiffrement des connexions |
| pgcrypto | Chiffrement des données |
| UFW | Pare-feu |
| Bash | Automatisation du déploiement |
| Git / GitHub | Versionnement et rendu du projet |

---

## 2. Architecture de la base

La base de données s'appelle `bankdb`.

Elle utilise deux schémas :

- `core` : données et opérations bancaires
- `audit` : journalisation des modifications

### Tables principales

| Table | Description |
|---|---|
| `core.customers` | Informations des clients |
| `core.accounts` | Comptes bancaires |
| `core.transfers` | Virements |
| `core.transactions` | Historique des opérations |
| `core.fraud_alerts` | Alertes de fraude |
| `audit.audit_log` | Journal des modifications |

### Volumes de données de démonstration

| Élément | Volume initial |
|---|---:|
| Clients | 1 000 |
| Comptes | 2 000 |
| Virements | 500 000 |
| Écritures bancaires | 1 000 000 |

Ces données sont fictives et utilisées uniquement dans le cadre du projet.

---

## 3. Organisation du dépôt

```text
NovaBank/
├── README.md
├── .gitignore
│
├── scripts/
│   ├── install_server.sh
│   └── deploy.sh
│
├── sql/
│   ├── 02_tables.sql
│   ├── 03_accounts.sql
│   ├── 04_transfers.sql
│   ├── 05_transactions.sql
│   ├── 06_fraud_alerts.sql
│   ├── 07_audit_log.sql
│   ├── 08_customer_age.sql
│   ├── 09_seed_data.sql
│   ├── 10_seed_accounts.sql
│   ├── 11_seed_transfers.sql
│   ├── 12_roles.sql
│   ├── 13_views.sql
│   ├── 14_updatable_view.sql
│   ├── 15_materialized_view.sql
│   ├── 16_indexes.sql
│   ├── 17_immutable_transactions.sql
│   ├── 18_balance_trigger.sql
│   ├── 19_fraud_trigger.sql
│   ├── 20_audit_trigger.sql
│   ├── 21_secure_transfer.sql
│   ├── 22_open_account.sql
│   ├── 23_account_statement.sql
│   ├── 24_integrity_tests.sql
│   └── 25_sql_injection.sql
│
└── screenshots/
```

Le dossier `sql/` contient les scripts de création, de configuration et de test.

Le dossier `scripts/` contient les scripts Bash d'installation et de déploiement.

Le dossier `screenshots/` contient les preuves visuelles des différentes étapes du projet.

---

# 4. Installation sur une nouvelle machine

## 4.1. Prérequis

Utiliser une machine Ubuntu disposant :

- D'un accès Internet
- D'un utilisateur avec les droits `sudo`
- De Git
- De PostgreSQL 18
- Du client PostgreSQL
- D'OpenSSL

Les commandes suivantes sont à exécuter dans un terminal Ubuntu, directement ou via SSH.

## 4.2. Installer Git

```bash
sudo apt update
sudo apt install -y git
```

## 4.3. Télécharger NovaBank

```bash
git clone <URL_DU_DEPOT_GITHUB>
cd NovaBank
```

Remplacer `<URL_DU_DEPOT_GITHUB>` par l'URL réelle du dépôt.

## 4.4. Installer le serveur PostgreSQL

```bash
chmod +x scripts/install_server.sh
sudo ./scripts/install_server.sh
```

Ce script installe PostgreSQL, son client et UFW, puis démarre le service PostgreSQL.

**Attention :** le script installe la version PostgreSQL disponible dans les dépôts APT configurés. Il faut vérifier que PostgreSQL 18 est effectivement installé.

Vérification :

```bash
psql --version
pg_lsclusters
```

Vérifier le service :

```bash
sudo systemctl status postgresql
```

---

# 5. Déploiement automatisé

## Préparation des permissions Linux

Lors du déploiement, PostgreSQL doit pouvoir accéder aux fichiers SQL du projet NovaBank.

### 1. Installer les outils nécessaires

```bash
sudo apt update
sudo apt install acl -y
```

### 2. Configurer les permissions

Depuis le dossier `~/NovaBank`, exécuter :

```bash
sudo setfacl -m u:postgres:x "$HOME"
sudo setfacl -m u:postgres:x "$HOME/NovaBank"
sudo setfacl -R -m u:postgres:rX "$HOME/NovaBank/sql"
```

Ces commandes permettent à l'utilisateur `postgres` de lire les fichiers SQL sans modifier les permissions des autres utilisateurs.

### 3. Vérifier les permissions

```bash
sudo -u postgres test -r "$HOME/NovaBank/sql/02_tables.sql" && echo "OK"
```

Si `OK` apparaît, les permissions sont correctement configurées.

## Déploiement de NovaBank

Depuis le dossier du projet :

```bash
cd ~/NovaBank
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

Le script initialise la base PostgreSQL `bankdb` et exécute les fichiers SQL du projet.

## Dépannage

### Erreur : Permission denied

**Cause :** l'utilisateur `postgres` ne peut pas accéder aux fichiers SQL.

**Solution :** appliquer les commandes ACL indiquées dans la section « Préparation des permissions Linux ».

### Erreur : database "bankdb" already exists

**Cause :** une précédente tentative de déploiement a déjà créé la base de données.

**Solution :** si la machine est uniquement utilisée pour les tests et qu'aucune donnée ne doit être conservée :

```bash
sudo -u postgres dropdb bankdb
```

Relancer ensuite le déploiement :

```bash
./scripts/deploy.sh
```

**Attention :** la suppression de `bankdb` entraîne la perte définitive de toutes ses données. Ne jamais utiliser cette commande sur une base contenant des données importantes.

### Vérifier le déploiement

Afficher les tables du schéma `core` :

```bash
sudo -u postgres psql -d bankdb -c '\dt core.*'
```

Afficher les tables du schéma `audit` :

```bash
sudo -u postgres psql -d bankdb -c '\dt audit.*'
```

Si les tables attendues sont présentes et que le script s'est terminé sans erreur, le déploiement a réussi.

Le projet contient un script de déploiement :

`scripts/deploy.sh`

Son objectif est d'automatiser la création de la base et l'exécution des scripts SQL dans le bon ordre.

## 5.1. Préparer l'authentification

Sur une nouvelle machine, PostgreSQL doit autoriser `bank_owner` à se connecter localement avec un mot de passe.

Le fichier de configuration peut être localisé avec :

```bash
sudo -u postgres psql -Atc "SHOW hba_file;"
```

Pour PostgreSQL 18 sur Ubuntu, il se trouve généralement dans :

```text
/etc/postgresql/18/main/pg_hba.conf
```

La configuration doit prévoir une règle adaptée à `bank_owner` :

```conf
hostssl bankdb bank_owner 127.0.0.1/32 scram-sha-256
```

Le serveur doit avoir TLS activé pour accepter une règle `hostssl`.

Après modification :

```bash
sudo pg_ctlcluster 18 main reload
```

## 5.2. Lancer le déploiement

```bash
cd NovaBank

chmod +x scripts/deploy.sh

./scripts/deploy.sh
```

Le script prévoit les opérations suivantes :

1. Vérification du client PostgreSQL
2. Création du rôle `bank_owner` si nécessaire
3. Création de la base `bankdb`
4. Création des schémas `core` et `audit`
5. Exécution des scripts SQL `02` à `11`
6. Configuration des rôles avec le script `12`
7. Installation des vues, index, triggers et fonctions `13` à `23`
8. Exécution des tests d'intégrité `24`

**État :** ce déploiement automatisé doit encore être validé sur une installation PostgreSQL vierge. Certains scripts, notamment la création des rôles, peuvent nécessiter des ajustements de privilèges.

Ne pas lancer le déploiement sur une base contenant des données à conserver.

---

# 6. Déploiement manuel

Si le déploiement automatique échoue ou si l'on souhaite comprendre chaque étape, il est possible d'exécuter les scripts manuellement.

## 6.1. Créer le rôle propriétaire

```bash
sudo -u postgres createuser --login --pwprompt bank_owner
```

Cette commande demande de définir un mot de passe pour le rôle.

## 6.2. Créer la base

```bash
sudo -u postgres createdb -O bank_owner bankdb
```

## 6.3. Créer les schémas

```bash
psql -h 127.0.0.1 -U bank_owner -d bankdb \
-c "CREATE SCHEMA IF NOT EXISTS core AUTHORIZATION bank_owner;"
```

```bash
psql -h 127.0.0.1 -U bank_owner -d bankdb \
-c "CREATE SCHEMA IF NOT EXISTS audit AUTHORIZATION bank_owner;"
```

## 6.4. Ordre des scripts SQL

L'ordre suivant respecte l'organisation du projet.

| Ordre | Script | Fonction |
|---|---|---|
| 1 | `02_tables.sql` | Tables initiales |
| 2 | `03_accounts.sql` | Comptes bancaires |
| 3 | `04_transfers.sql` | Virements |
| 4 | `05_transactions.sql` | Transactions |
| 5 | `06_fraud_alerts.sql` | Alertes |
| 6 | `07_audit_log.sql` | Audit |
| 7 | `08_customer_age.sql` | Contrôle de l'âge |
| 8 | `09_seed_data.sql` | Clients fictifs |
| 9 | `10_seed_accounts.sql` | Comptes fictifs |
| 10 | `11_seed_transfers.sql` | Virements fictifs |
| 11 | `12_roles.sql` | Rôles et permissions |
| 12 | `13_views.sql` | Vues sécurisées |
| 13 | `14_updatable_view.sql` | Vue modifiable |
| 14 | `15_materialized_view.sql` | Vue matérialisée |
| 15 | `16_indexes.sql` | Index |
| 16 | `17_immutable_transactions.sql` | Immutabilité |
| 17 | `18_balance_trigger.sql` | Contrôle des soldes |
| 18 | `19_fraud_trigger.sql` | Détection de fraude |
| 19 | `20_audit_trigger.sql` | Audit automatique |
| 20 | `21_secure_transfer.sql` | Virement sécurisé |
| 21 | `22_open_account.sql` | Ouverture de compte |
| 22 | `23_account_statement.sql` | Relevé bancaire |
| 23 | `24_integrity_tests.sql` | Tests d'intégrité |
| Bonus | `25_sql_injection.sql` | Démonstration SQL injection |

## 6.5. Exécuter les scripts de création

Depuis la racine du projet :

```bash
for n in $(seq -w 2 11); do
    file=$(find sql -maxdepth 1 -name "${n}_*.sql" -print -quit)

    if [ -z "$file" ]; then
        echo "Script manquant : $n"
        exit 1
    fi

    psql -h 127.0.0.1 \
         -U bank_owner \
         -d bankdb \
         -v ON_ERROR_STOP=1 \
         -f "$file" || exit 1
done
```

## 6.6. Configurer les rôles

```bash
sudo -u postgres psql -d bankdb \
-v ON_ERROR_STOP=1 \
-f sql/12_roles.sql
```

Ce script nécessite des droits administratifs pour la création des rôles.

Il faut vérifier que les permissions et propriétaires définis par le script sont compatibles avec les objets créés précédemment.

## 6.7. Installer les fonctionnalités

```bash
for n in $(seq 13 23); do
    file=$(find sql -maxdepth 1 -name "${n}_*.sql" -print -quit)

    if [ -z "$file" ]; then
        echo "Script manquant : $n"
        exit 1
    fi

    psql -h 127.0.0.1 \
         -U bank_owner \
         -d bankdb \
         -v ON_ERROR_STOP=1 \
         -f "$file" || exit 1
done
```

---

# 7. Vérification de l'installation

## 7.1. Se connecter à la base

```bash
psql -h 127.0.0.1 -U bank_owner -d bankdb
```

## 7.2. Afficher les tables

```sql
\dt core.*
\dt audit.*
```

## 7.3. Vérifier les données

```sql
SELECT COUNT(*) FROM core.customers;
SELECT COUNT(*) FROM core.accounts;
SELECT COUNT(*) FROM core.transfers;
SELECT COUNT(*) FROM core.transactions;
```

## 7.4. Vérifier les fonctions

```sql
\df core.*
```

## 7.5. Vérifier les rôles

```sql
\du
```

## 7.6. Exécuter les tests d'intégrité

Depuis le terminal :

```bash
psql -h 127.0.0.1 \
-U bank_owner \
-d bankdb \
-v ON_ERROR_STOP=1 \
-f sql/24_integrity_tests.sql
```

Les contrôles portent notamment sur :

- Les soldes négatifs
- Les virements incomplets
- La cohérence des débits et crédits
- Les transactions orphelines

---

# 8. Fonctions bancaires

## 8.1. Virement sécurisé

Fonction :

```sql
core.make_transfer()
```

Exemple avec deux comptes de démonstration existants :

```sql
BEGIN;

SELECT core.make_transfer(
    1,
    2,
    50.00,
    'Test de virement'
);

ROLLBACK;
```

Le `ROLLBACK` annule les modifications du test.

## 8.2. Ouverture de compte

Fonction :

```sql
core.open_account()
```

Exemple avec un client existant dont le KYC est vérifié :

```sql
BEGIN;

SELECT core.open_account(
    2,
    'FR7611111111111111111111111',
    'CURRENT'
);

ROLLBACK;
```

## 8.3. Relevé bancaire

Fonction :

```sql
core.get_account_statement()
```

Exemple :

```sql
SELECT *
FROM core.get_account_statement(
    1,
    '2026-01-01',
    '2027-01-01'
)
LIMIT 10;
```

Les identifiants et dates doivent être adaptés aux données présentes.

---

# 9. Sécurité PostgreSQL

## 9.1. Gestion des rôles

Le projet utilise plusieurs profils :

| Rôle | Utilisation |
|---|---|
| `bank_owner` | Propriétaire des objets |
| `bank_app` | Exécution des fonctions bancaires autorisées |
| `bank_analyst` | Analyse des données |
| `bank_support` | Consultation des informations autorisées |
| `bank_auditor` | Consultation des journaux d'audit |

Les permissions sont conçues selon le principe du moindre privilège.

## 9.2. Protection des transactions

Les transactions bancaires sont protégées contre les modifications et suppressions directes grâce à un trigger d'immutabilité.

## 9.3. Contrôle des soldes

Un trigger met à jour le solde des comptes et empêche les opérations entraînant un solde négatif.

## 9.4. Détection de fraude

Des règles permettent de détecter notamment :

- Les retraits importants
- Les virements fréquents

## 9.5. Audit

Les modifications de certaines tables sont enregistrées dans `audit.audit_log`.

---

# 10. Parcours CYBER

Quatre bonus de cybersécurité ont été réalisés.

## C1 — Chiffrement TLS

### Objectif

Chiffrer les connexions entre PostgreSQL et les clients.

### Technologies

- TLS 1.3 (déjà installé sur ubuntu)
- OpenSSL
- `hostssl`
- `pg_hba.conf`

### Vérification

```bash
psql "host=127.0.0.1 dbname=bankdb user=bank_owner sslmode=require"
```

Dans PostgreSQL :

```sql
\conninfo
```

Le test a confirmé l'utilisation de TLS 1.3 et du chiffrement `TLS_AES_256_GCM_SHA384`.

### Refuser une connexion non chiffrée

```bash
psql "host=127.0.0.1 dbname=bankdb user=bank_owner sslmode=disable" \
-c "SELECT current_user;"
```

Résultat attendu :

```text
FATAL: pg_hba.conf rejects connection ... no encryption
```

**Remarque :** `sslmode=require` vérifie le chiffrement, mais ne garantit pas à lui seul l'identité du serveur. Pour cela, il faut utiliser un certificat de confiance et `sslmode=verify-full`.

---

## C2 — Détection des connexions échouées

### Objectif

Simuler cinq mauvais mots de passe et retrouver les erreurs dans les journaux PostgreSQL.

### Vérifier la journalisation

```bash
sudo -u postgres psql -c "SHOW log_destination;"
sudo -u postgres psql -c "SHOW log_connections;"
```

### Activer la journalisation des connexions

```bash
sudo -u postgres psql \
-c "ALTER SYSTEM SET log_connections = 'all';"
```

```bash
sudo -u postgres psql \
-c "SELECT pg_reload_conf();"
```

### Simuler cinq tentatives incorrectes

```bash
for i in {1..5}; do
    PGPASSWORD='MauvaisMotDePasse_C2' \
    psql "host=127.0.0.1 dbname=bankdb user=bank_owner sslmode=require" \
    -c "SELECT 1;"
done
```

### Rechercher les erreurs

```bash
sudo grep 'password authentication failed for user "bank_owner"' \
/var/log/postgresql/postgresql-18-main.log | tail -5
```

Le test réalisé a permis d'identifier cinq échecs consécutifs dans les journaux PostgreSQL.

---

## C3 — Chiffrement des numéros de téléphone

### Objectif

Stocker un numéro de téléphone sous une forme illisible et le déchiffrer uniquement avec une clé.

### Activer pgcrypto

```bash
sudo -u postgres psql -d bankdb \
-c "CREATE EXTENSION IF NOT EXISTS pgcrypto;"
```

### Ajouter une colonne chiffrée

```sql
ALTER TABLE core.customers
ADD COLUMN phone_encrypted bytea;
```

Cette commande ne doit être exécutée qu'une seule fois si la colonne n'existe pas.

### Démonstration

```sql
BEGIN;

UPDATE core.customers
SET phone_encrypted = public.pgp_sym_encrypt(
    '+33612345678',
    'CleDemoC3_NovaBank_2026'
)
WHERE customer_id = 2;
```

### Afficher la donnée chiffrée

```sql
SELECT customer_id,
       encode(phone_encrypted, 'hex')
FROM core.customers
WHERE customer_id = 2;
```

### Déchiffrer

```sql
SELECT customer_id,
       public.pgp_sym_decrypt(
           phone_encrypted,
           'CleDemoC3_NovaBank_2026'
       ) AS decrypted_phone
FROM core.customers
WHERE customer_id = 2;
```

### Annuler la démonstration

```sql
ROLLBACK;
```

La clé ci-dessus est uniquement une clé fictive de démonstration. Les véritables clés ne doivent jamais être publiées dans les scripts ou sur GitHub.

---

## C4 — Injection SQL et correction

### Objectif

Démontrer une injection SQL dans une fonction PL/pgSQL, puis corriger la vulnérabilité.

### Script

```text
sql/25_sql_injection.sql
```

### Fonction vulnérable

La première fonction utilise une concaténation directe de la saisie utilisateur dans une requête SQL.

Exemple de saisie piégée :

```sql
SELECT *
FROM core.search_customers_unsafe(''' OR TRUE --');
```

Cette injection peut rendre la condition de recherche toujours vraie.

### Correction

La version sécurisée utilise des paramètres :

```sql
RETURN QUERY EXECUTE
    'SELECT customer_id, first_name, last_name
     FROM core.customers
     WHERE last_name = $1'
USING p_name;
```

### Vérification

```sql
SELECT *
FROM core.search_customers_safe(''' OR TRUE --');
```

La saisie est alors traitée comme une simple valeur et ne modifie plus la structure de la requête SQL.

### Nettoyage

La fonction vulnérable est supprimée de la base après la démonstration.

Son code est conservé dans le dépôt GitHub comme preuve pédagogique.

**Ne pas exécuter ce bonus sur une base de production.**

---

# 11. Sauvegarde PostgreSQL

## 11.1. Créer une sauvegarde

```bash
mkdir -p backups
```

```bash
pg_dump -h 127.0.0.1 \
-U bank_owner \
-d bankdb \
-Fc \
-f backups/bankdb_backup.dump
```

## 11.2. Vérifier la sauvegarde

```bash
pg_restore -l backups/bankdb_backup.dump
```

## 11.3. Restaurer une sauvegarde

Sur une base de destination vide, préparée avec les rôles et extensions nécessaires :

```bash
pg_restore -h 127.0.0.1 \
-U bank_owner \
-d bankdb \
--no-owner \
--no-acl \
backups/bankdb_backup.dump
```

Cette commande restaure les objets contenus dans l'archive. La restauration des rôles et des permissions globales doit être gérée séparément.

Les sauvegardes ne sont pas publiées sur GitHub.

---

# 12. Captures d'écran

Le dossier `screenshots/` contient les preuves des principales étapes.

Captures recommandées :

| Fichier | Preuve |
|---|---|
| `01_postgresql.png` | Version PostgreSQL |
| `02_tables.png` | Tables et schémas |
| `03_permissions.png` | Rôles et permissions |
| `04_transactions.png` | Virement bancaire |
| `05_tls.png` | Connexion TLS et refus sans chiffrement |
| `06_failed_logins.png` | Cinq échecs d'authentification |
| `07_encryption.png` | Chiffrement et déchiffrement |
| `08_sql_injection.png` | Injection SQL et correction |

Les captures doivent être réalisées sur le terminal et ne doivent pas exposer de mots de passe ou de clés privées.

---

# 13. Versionnement Git

## Vérifier les modifications

```bash
git status
```

## Ajouter les fichiers

```bash
git add README.md
git add sql/
git add scripts/
git add screenshots/
git add .gitignore
```

## Vérifier le contenu du commit

```bash
git diff --cached --stat
```

## Créer un commit

```bash
git commit -m "Complete NovaBank PostgreSQL project"
```

## Publier sur GitHub

Si le dépôt distant `origin` est déjà configuré :

```bash
git push -u origin HEAD
```

Sinon, il faut d'abord créer le dépôt GitHub et configurer son URL.

---

# 14. Sécurité et limites

NovaBank Core est un projet pédagogique, et non une application bancaire prête pour la production.

Des améliorations seraient nécessaires pour :

- Authentifier les utilisateurs finaux
- Vérifier qu'un client possède les comptes auxquels il accède
- Protéger les clés de chiffrement avec un gestionnaire de secrets
- Vérifier complètement les certificats TLS
- Tester les opérations bancaires concurrentes
- Vérifier l'intégralité de l'historique comptable
- Automatiser les tests de restauration
- Renforcer la supervision et les alertes

Les données de démonstration sont fictives.

Les sauvegardes, mots de passe et clés privées sont exclus du dépôt Git.

---

# 15. Conclusion

Ce projet permet de mettre en pratique les principales compétences d'administration et de sécurisation d'une base PostgreSQL :

- Modélisation relationnelle
- SQL avancé
- PL/pgSQL
- Gestion des permissions
- Indexation
- Transactions
- Triggers
- Audit
- Sauvegardes
- Chiffrement TLS
- Journalisation des connexions
- Chiffrement des données
- Prévention des injections SQL

Le dépôt contient les scripts nécessaires à la compréhension et à la reproduction du projet, ainsi que les preuves des tests réalisés.

# projet pédagogique, non destiné à la diffusion
