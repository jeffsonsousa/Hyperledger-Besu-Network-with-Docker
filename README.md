# Requirements
- Docker
- Docker-Compose
- cURL

## Install Docker
``` 
sudo apt-get install curl
```
Baixe e execute o script de instalação.

```
curl -fsSL https://get.docker.com | sudo bash
```
Para executar o Docker sem utilizar o sudo, criaremos um grupo de usuário docker e adicionaremos o usuário atual nele:
```
sudo groupadd docker
sudo usermod -aG docker $USER
```
Atualize as mudanças realizadas no grupo:
```
newgrp docker
```
Para verificar a versão instalada:
```
docker version
```
Com os comandos realizados acima, ainda há possibilidade de não ter atribuído permissão sudo ao docker. Caso seja o caso, realize o comando abaixo:
```
sudo chmod 666 /var/run/docker.sock
```

## Install Docker-compose
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
Para verificar a versão instalada:
```
docker-compose version
```
> [!NOTE]
> <sup>Este tutorial foi baseado na doc oficial da Besu [Documentação Hyperledger Besu](https://besu.hyperledger.org/private-networks/tutorials/permissioning)</sup>

# Build Start-Node
## 1. Subir imagem local para primeiro nó da rede
```
docker build --no-cache -f Dockerfile -t start-node-besu:1.0 .
```
## 2. Subir o container para o primeiro nó
```
docker network create besu-network
cd start-network/
docker-compose up -d start-node
```
## 3. Copiar chaves para os proximos nós 
```
bash copy-keys.sh
```
# Copy init files of dir networkFiles-staging 
> [!WARNING]
> <sup>Não esqueça de alterar o ip de cada HOST nos arquivos .env, .bashrc e Dockerfile-dev[line 27-28]</sup>

> [!IMPORTANT]
> <sup>Repetir os passos a seguir para os 3 nós</sup>
# Build Validator-Node

## 1. Subir imagem local na nova maquina
```
docker build --no-cache -f Dockerfile-dev -t validator-node-besu:1.0 .
```
## 2. Subir container para os nós restantes
```
docker network create besu-network
cd start-network/
docker-compose up -d validator-node
```
## Copiar o enode do Start Node 
> [!IMPORTANT]
> <sup>Na maquina do start-node</sup>
```
docker exec -it start-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq  
```
## Add peer do Node-2 
> [!IMPORTANT]
> <sup>Na maquina do node 2</sup>
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode1>"],"id":1}' http://127.0.0.1:8545 | jq 
```
## Copiar o enode do Node-2 
> [!IMPORTANT]
> <sup>Na maquina do node 2</sup>
```
docker exec -it start-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq  
```
## Add peer do Node-3
> [!IMPORTANT]
> <sup>Na maquina do node 3</sup>
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode2>"],"id":1}' http://127.0.0.1:8545 | jq 
```
## Copiar o enode do Node-3
> [!IMPORTANT]
> <sup>Na maquina do node 3</sup>
```
docker exec -it start-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq
```
## Add peer do Node-4
> [!IMPORTANT]
> <sup>Na maquina do node 4</sup>
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode3>"],"id":1}' http://127.0.0.1:8545 | jq 
```
## Verificar a contagem de peers
## Check peer count
> [!IMPORTANT]
> <sup>Em qualquer nó</sup>
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' localhost:8545 | jq 
```
# Derrubar a rede 
## Down start-node
> [!IMPORTANT]
> <sup>Na maquina do tipo start-node</sup>
```
docker container stop start-node
```
## Down validators
> [!IMPORTANT]
> <sup>Nas maquinas do tipo validator-node</sup>
```
docker container stop start-bootnode
```
> [!CAUTION]
> <sup>O comando a seguir irá excluir todas as imagens e containers que não estiverem em uso, use com cautela</sup>
```
docker system prune --all --force --volumes
```
## Testar a rede 

> [!NOTE]
> <sup>
```
curl http://localhost:9545/metrics 
curl -X POST --data '{"jsonrpc":"2.0","method":"debug_metrics","params":[],"id":1}' http://127.0.0.1:8545 | jq
curl -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://127.0.0.1:8545 | jq
curl -X POST --data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":53}' http://127.0.0.1:8545 | jq
curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq
curl -X POST --data '{"jsonrpc":"2.0","method":"net_services","params":[],"id":1}' http://127.0.0.1:8545 | jq
curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://127.0.0.1:8545 | jq
```
</sup>
