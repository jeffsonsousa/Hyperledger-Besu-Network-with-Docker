#!/bin/bash
# Baixando dependencias da Besu

wget https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/23.10.1/besu-23.10.1.tar.gz 
tar -xvf besu-23.10.1.tar.gz 
rm besu-23.10.1.tar.gz 
export PATH=/home/besu-23.10.1/bin:$PATH

# Geração de chaves criptograficas e bloco genesis da rede

cd besu-23.10.1/Permisssioned-Network/ 
besu operator generate-blockchain-config --config-file=qbftConfigFile.json --to=networkFiles --private-key-file-name=key 
cp networkFiles/genesis.json . 

# Exportação de chaves criptograficas e bloco genesis da rede para validators 

cd networkFiles/keys/
ls | grep 0x > .env
# Define o arquivo .env e o diretório de destino
env_file=".env"
permissions_config="/home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/permissions_config.toml"
i=0
argsaccounts=""
# Lê cada linha do arquivo .env e copia o conteúdo correspondente
while IFS= read -r identificador
do
    if [ $i -ne 0 ]; then
        argsaccounts+=", "
    fi
    argsaccounts+="\"$identificador\""
    i=$((i+1))
    if [ $i -eq 2 ]; then
        break
    fi
done < "$env_file"

env_file=".env"
node=1
i=0
argsnodes=""

# Lê cada linha do arquivo .env e copia o conteúdo correspondente
while IFS= read -r identificador
do
    if [ $i -ne 0 ]; then
        argsnodes+=", "
    fi
    cd $identificador/
    pub_file="key.pub"
    while IFS= read -r line || [[ -n "$line" ]]; do
        line="${line#0x}"
        case $i in
            0) host=$HOST1 ;;
            1) host=$HOST2 ;;
            2) host=$HOST3 ;;
            3) host=$HOST4 ;;
            *) echo "Número de arquivos .env excede o número de hosts definidos"; continue 1 ;;
        esac
        argsnodes+="\"enode://$line@$host:30303\""
    done < "$pub_file"
    cd ..
    i=$((i+1))
done < "$env_file"
echo $argsnodes

# Verifica se o arquivo permissions_config.toml já existe
if [ ! -f "$permissions_config" ]; then
cat << EOF > "permissions_config.toml"
nodes-allowlist=[$argsnodes]
accounts-allowlist=[$argsaccounts]
EOF
fi

env_file=".env"
node=1
i=0
while IFS= read -r identificador
do
    cp /home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/$identificador/* /home/besu-23.10.1/Permisssioned-Network/Node-$node/data/
    i=$((i+1))
    node=$((node+1))
done < "$env_file"

cp /home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/permissions_config.toml /home/besu-23.10.1/Permisssioned-Network/Node-1/data/
cp /home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/permissions_config.toml /home/besu-23.10.1/Permisssioned-Network/Node-2/data/
cp /home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/permissions_config.toml /home/besu-23.10.1/Permisssioned-Network/Node-3/data/
cp /home/besu-23.10.1/Permisssioned-Network/networkFiles/keys/permissions_config.toml /home/besu-23.10.1/Permisssioned-Network/Node-4/data/

echo "Exportação de chaves concluída."

# Subir Start-Node da rede Besu

cd /home/besu-23.10.1/Permisssioned-Network/Node-1/

besu --data-path=data --genesis-file=../genesis.json --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="*" --metrics-enabled --p2p-port=30303 --rpc-http-port=8545 --p2p-host=$HOST1