# Primeiro Buildar a imagem local para subir o primeiro nó da rede
```
docker build --no-cache -f Dockerfile -t start-node-besu:1.0 .
```
# Segundo Subir o container para o primeiro nó
```
docker network create besu-network
cd start-network/
docker-compose up -d start-node
```
# Copiar chaves para os proximos nós 
```
bash copy-keys.sh
```

# Na nova maquina, suba o novo nó (Repetir passos para os 3 nós)
## Copiar os arquivos de networkFiles para os nós restantes (NÃO ESQUEÇA DE ALTERAR O IP DE CADA HOST NOS ARQUIVOS .env, .bashrc e Dockerfile-dev[line 27-28])

# Primeiro Buildar a imagem local para subir os nós restantes da rede
```
docker build --no-cache -f Dockerfile-dev -t validator-node-besu:1.0 .
```
# Segundo Subir o container para os nós restantes

```
docker network create besu-network
cd start-network/
docker-compose up -d validator-node

```
# Copie o enode do Start Node (Na maquina do nó 1)
```
docker exec -it start-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq  
```

# Cole no comando cURL e Adicione nós como peers (Na maquina do nó 2)

```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode2>"],"id":1}' http://127.0.0.1:8545 | jq 

```

# Cole no comando cURL e Adicione nós como peers (Na maquina do nó 3)

```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode3>"],"id":1}' http://127.0.0.1:8545 | jq 

```

# Cole no comando cURL e Adicione nós como peers (Na maquina do nó 4)
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["<EnodeNode4>"],"id":1}' http://127.0.0.1:8545 | jq 

```
# Verificar a contagem de peers
```
docker exec -it validator-node curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' localhost:8545 | jq 

```

# Limpar a rede (start-node)
docker container stop start-node
docker container stop validator-node
docker system prune --all --force --volumes

# Limpar a rede (validator-node)
docker container stop start-boot
docker container stop validator-node
docker system prune --all --force --volumes

# Testar a rede 

curl http://localhost:9545/metrics 


curl -X POST --data '{"jsonrpc":"2.0","method":"debug_metrics","params":[],"id":1}' http://127.0.0.1:8545 | jq

curl -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://127.0.0.1:8545 | jq

curl -X POST --data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":53}' http://127.0.0.1:8545 | jq

curl -X POST --data '{"jsonrpc":"2.0","method":"net_enode","params":[],"id":1}' http://127.0.0.1:8545 | jq

curl -X POST --data '{"jsonrpc":"2.0","method":"net_services","params":[],"id":1}' http://127.0.0.1:8545 | jq

curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' http://127.0.0.1:8545 | jq

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