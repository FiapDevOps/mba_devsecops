# Microserviços

Laboratório para execução de aplicações em Docker e Kubernetes como exemplo de mecanismo baseado em micro-serviços;

**A relação entre containers e microserviços**

Conforme a definição disponível no artigo ["O que é um container Linux?"](https://www.redhat.com/pt-br/topics/containers/whats-a-linux-container) publicado no blog da RedHat:

*Um container é um conjunto de um ou mais processos organizados isoladamente do sistema. Todos os arquivos necessários à execução de tais processos são fornecidos por uma imagem distinta, os containers são portáteis e consistentes durante toda a migração entre os ambientes de desenvolvimento, teste e produção.*

Trata-se de um arquitetura moderna baseada em sistemas operacionais linux e que se popularizou a partir de tecnologias para build e execução de imagens de aplicações como o [Docker](https://www.docker.com/) e o [ContainerD](https://containerd.io/);

O uso de Containers (em especial o Docker) surge como uma solução interessante para a construção de arquiteturas baseadas em microserviços;

Isso se deve por uma série de fatores como:

- Desacoplação;
- Isolamento de recursos;
- Escalabilidade horizontal;

## Instalação do Docker

Para execução de containers em docker é necessário o uso de duas soluções, um "motor" capaz de rodar o container como o [docker-ce](https://boxboat.com/2018/12/07/docker-ce-vs-docker-ee/) e um cliente para execução de chamadas e interação com o socket do docker como o [docker-cli](https://docs.docker.com/engine/reference/commandline/cli/);

O processo de instalação é executado de acordo com o sistema operacional conforme [documentações](https://docs.docker.com/engine/install/);

Em nosso laboratório ambas as soluções já foram instaladas, verifique a versão executando:

```sh
docker version
docker run hello-world
```

## Execução de containers:

Em essencia um container é uma versão em execução de um conjunto de layers configurados a partir de um sistema operacional encapsulado o que chamaos de imagem, ao customizar uma imagem configurando arquivos, instalando pacotes e inserindo código podemos construir uma nova imagem a partir da orinal e utilziar esta imagem para instânciar novos containers;

Neste exemplo executamos um container de forma direta via docker:

```sh
docker run -it debian:latest ls /
```

- As flags -it colocam o container em execução no modo interativo conectado a sessão atual;
- O container em execução foi o debian em sua versão mais recente identificada pela tag "latest";

Também é possível executar containers em background:

```sh
docker run -d --rm --publish 8080:80 --name webserver nginx:latest
docker ps
curl 127.0.0.1:8080
```

Destrua o container anterior:

```sh
docker kill webserver
docker ps
```

## Criando uma imagem com o Docker:

O diretório build dentro deste repositório possui um pequeno exemplo com uma aplicação python: 

```sh
cat app/build

├── buzz
│   ├── generator.py         # The buzz words generator
│   └── __init__.py
└── requirements.txt         # Requeriments files, You know... to install stuffs
```

O exemplo foi baseado no artigo ["How to build a modern CI/CD pipeline"](https://medium.com/bettercode/how-to-build-a-modern-ci-cd-pipeline-5faa01891a5b) publicado no [Medium](https://medium.com) por [Rob van der Leek](https://medium.com/@robvanderleek?source=post_header_lockup);


Este exemplo será utilizado como ponto de partida para a criação de um container linux encapsulado via docker:

Verifique o conteúdo do arquivo Dockerfile com as etapas do processo de build com base na imagem python do [DockerHub](https://hub.docker.com/_/python):

```sh
cd microservices
cat app/Dockerfile
```

Conteúdo do Dockerfile:

```sh
FROM python:3

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD [ "python", "./app.py" ]
```

Criaremos uma variavel contendo o nome da imagem para failitar os próximos passos, a composição da variável será o prefixo fiaplabs/ somado aos números do seu RM:

```sh
export DOCKER_IMAGE=fiaplabs/<SEURM>   # Por exemplo 'export DOCKER_IMAGE=fiaplabs/12345'
```

Faça um build do projeto, para execução do upload para o dockerhub:
```sh
cd app
docker build . -t ${DOCKER_IMAGE}/app-v0.0.1
```

Após o processo de build verifique a imagem criada:

```sh
docker images
```

Finalmente crie um novo container com base na imagem e bind na porta 8080:

```sh
docker run -d --name app --rm --publish 8080:5000 ${DOCKER_IMAGE}:app-v0.0.1
docker ps
curl 127.0.0.1:8080
docker kill app
```

As imagens são construidas com base na estrutura declarativa do Dockerfile, é possível customizar a imagem ou utilizar outra imagem como referência:

Substitua a primeira linha do arquivo Dockerfile alterando a imagem de referência para uma versão baseada no sistema [alpine](https://www.alpinelinux.org/);

```sh
sed -i '1c\FROM python\:3.6-alpine' Dockerfile 
cat Dockerfile
```

Em seguida faça um novo build do projeto:

```sh
docker build . -t ${DOCKER_IMAGE}/app-v0.0.2
docker images
docker ps
docker kill app
```

Troque a versão em execução:

```sh
docker run -d --name app --rm --publish 8080:5000 ${DOCKER_IMAGE}:app-v0.0.2
docker ps
curl 127.0.0.1:8080
```

Ao final do processo faça o login na conta utilizada para este laboratório:

**Para a senha utilize o token enviado pelo professor**

```sh
docker login -u fiaplabs
```

Envie a imagem criada recentemente para o repositório remoto:

```sh
docker push ${DOCKER_IMAGE}:app-v0.0.2
```

Para revisar o processo de gerencia de vulnerabilidades atualize a imagem do docker:

```sh
sed -i '1c\FROM python\:3.9-alpine' Dockerfile 
cat Dockerfile
```

Em seguida envie uma nova versão ao repositório:

```sh
 docker build . -t ${DOCKER_IMAGE}:app-v0.0.3
 docker push ${DOCKER_IMAGE}:app-v0.0.3
```

## Usando o Kubernetes:

Faça o download das credenciais de conexão ao cluster:

```sh
export BUCKET=$(aws sts get-caller-identity --query Account --output text)-tokens
aws s3 ls s3://442399433477-tokens/* .
mkdir $HOME/.kube/ && mv kubeconfig* $HOME/.kube/config
```

Teste a comunicação e funcionamento da ferramenta de lina hde comando kubectl:
```sh
kubectl config get-contexts
kubectl get po
```

Em seguida com base na imagem criada e publicada no dockerhub crie um deploy no kubernetes:
```sh
kubectl create deploy my-dep --image=${DOCKER_IMAGE}:app-v0.0.3 --replicas=2
```

Acompanhe o download e inicialização da aplicação via kubectl:

```sh
kubectl get replicaset
kubectl get po
```

> Cada versão do deployment criado possui um conjunto de replicas cuja versão é identificado como um replicaset, para cada alteração uma nova versão será criada

O deploy criado possui duas replicas do microserviço rodando dentro do kubernetes, para habilitar o acesso externo faça o expose do service via LoadBalancer:

```sh
kubectl expose deployment my-dep --type=LoadBalancer --name=my-service --port 80 --target-port 5000
kubectl get svc
```

> Acesse o endereço de LoadBalancer configurado dinamicamente na aplicação, ele será exibido em questão de segundos após o Cloud Provider alocar o recursos necessário;

## Pontos de atenção:

Do ponto de vista de Segurança o uso de microserviços cria desafios interessantes para as equipes de secdevops e para a governança e gestão de riscos relacionadas as aplicações entregues neste formato, considere os seguintes questionamentos:

1. Neste exemplo executamos um build local da imagem porém para execução em um ambiente orquestrado será necessário que a empresa possua ou contrate um registry, uma infraestrutura distribuida para armazenar as imagens criadas;

2. Essa mesma infraestrutura deverá prover mecanismos que permitam a varredura de vulnerabilidades sobre essas imagens com base em ferramentas como o [trivy da aquasecurity](https://www.aquasec.com/products/trivy/), o [Nessus](https://www.tenable.com/products/tenable-io/container-security) usando os módulos com suporte a containers, a [solução de varredura do DockerHub](https://docs.docker.com/docker-hub/vulnerability-scanning/) e outros mecanismos similares;

3. Alguns pontos de atenção relacionados ao desenvolimento e build também surgem como por exemplo a execução de containers com usuário root ou a estratégia utilziada para armazenar credenciais e certificados dentro destes containers; 

---
##### Fiap - MBA Cyber Security Forensics, Ethical Hacking & DevSecOps
profhelder.pereira@fiap.com.br

**Free Software, Hell Yeah!**
