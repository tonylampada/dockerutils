#!/bin/bash
app=$1
version=$2
environ=$3

if [ -f ~/.dockerutils/env.sh ]; then
    source ~/.dockerutils/env.sh
fi
if [ "$MIGRATION_HOST" ]; then
    echo "[MIGRATION] host pra rodar migration: $MIGRATION_HOST"
    install_dockerutils_remote.sh $MIGRATION_HOST
    ssh -o StrictHostKeyChecking=no $MIGRATION_HOST dockerutils/remotebin/migratedb.sh $app $version $environ
    echo "[MIGRATION] Executou migration no host: $MIGRATION_HOST"
else
    echo "[MIGRATION] Skipando migration pq a envvar MIGRATION_HOST nao esta definida"
fi
