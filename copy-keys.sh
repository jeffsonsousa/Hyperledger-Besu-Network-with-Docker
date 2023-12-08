#!/bin/bash

sudo mkdir -p networkFiles-staging/Node-1/data
sudo mkdir -p networkFiles-staging/Node-2/data
sudo mkdir -p networkFiles-staging/Node-3/data
sudo mkdir -p networkFiles-staging/Node-4/data
sudo chown -R $USER networkFiles-staging/
cd networkFiles/
cp genesis.json ../networkFiles-staging/
cd keys/
env_file=".env"
node=1
i=0
# Lê cada linha do arquivo .env e copia o conteúdo correspondente
while IFS= read -r identificador
do
    cp $identificador/* ../../networkFiles-staging/Node-$node/data/
    cp permissions_config.toml ../../networkFiles-staging/Node-$node/data/
    i=$((i+1))
    node=$((node+1))
done < "$env_file"

echo "Chaves dos nós copiadas!"
