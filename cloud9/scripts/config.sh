
#!/bin/bash
test -d $HOME/environment/info || mkdir $HOME/environment/info

# Identificando o endereco pub da instancia:
wget -qO- http://ipecho.net/plain | xargs echo > $HOME/environment/info/PUBLIC_IP.txt

# Resizing para o disco local do ambiente:
sh ./resize.sh 20 > /dev/null

# Instalando o docker + docker-compose
printf "\n Instalando o docker-compose \n"
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Download e instalação do kubectl
printf "\n Instalando o cliente do Kubernetes \n"
sudo curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl