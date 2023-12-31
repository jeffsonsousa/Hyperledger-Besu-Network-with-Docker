# Download base image ubuntu 22.04
FROM ubuntu:22.04

# LABEL about the custom image
LABEL maintainer="jcsousa@cpqd.com.br"
LABEL version="0.1"
LABEL description="This is a custom Docker Image for Besu Network."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository
RUN apt update -y && apt upgrade -y && apt install vim -y && apt install curl -y && apt install jq -y 
COPY init-network.sh /home/
COPY .bashrc /home/
COPY qbftConfigFile.json /home/qbftConfigFile.json
RUN cat < /home/.bashrc >> ~/.bashrc

# Install Besu Network Dependencies

RUN apt install wget -y && wget https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz && tar -xvf jdk-21_linux-x64_bin.tar.gz && \
mv jdk-21.0.1 /opt && rm jdk-21_linux-x64_bin.tar.gz 
RUN apt install -y libjemalloc-dev 

# Configure Nodes

RUN mkdir -p /home/besu-23.10.1/Permisssioned-Network/Node-1/data && mkdir -p /home/besu-23.10.1/Permisssioned-Network/Node-2/data && \
mkdir -p /home/besu-23.10.1/Permisssioned-Network/Node-3/data && mkdir -p /home/besu-23.10.1/Permisssioned-Network/Node-4/data && \
mv /home/qbftConfigFile.json /home/besu-23.10.1/Permisssioned-Network/ && chmod +x /home/init-network.sh

CMD ./init-network.sh

WORKDIR /home
