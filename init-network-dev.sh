#!/bin/bash
wget https://hyperledger.jfrog.io/artifactory/besu-binaries/besu/23.10.1/besu-23.10.1.tar.gz 
tar -xvf besu-23.10.1.tar.gz && rm besu-23.10.1.tar.gz && export PATH=/home/besu-23.10.1/bin:$PATH 
cd /home/besu-23.10.1/Permisssioned-Network/Node-$NODE_NUMBER/ 

besu --data-path=data --genesis-file=../genesis.json --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,QBFT --host-allowlist="*" --rpc-http-cors-origins="*" --p2p-port=$BESU_P2P_PORT --rpc-http-port=$BESU_PORT --p2p-host=$HOST2 --metrics-enabled