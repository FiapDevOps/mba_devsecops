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
docker run -it debian:latest lsb_release -a
```

- As flags -it colocam o container em execução no modo interativo conectado a sessão atual;
- O container em execução foi o debian em sua versão mais recente identificada pela tag "latest";

Também é possível executar containers em background:

```sh
docker run -d --rm --publish 80:80 --name webserver nginx:latest
```

## Criando uma imagem com o Docker:

O diretório build dentro deste repositório possui um pequeno exemplo com uma aplicação python: 

```sh
build/

├── buzz
│   ├── generator.py         # The buzz words generator
│   └── __init__.py
└── requirements.txt         # Requeriments files, You know... to install stuffs
```

O exemplo foi baseado no artigo ["How to build a modern CI/CD pipeline"](https://medium.com/bettercode/how-to-build-a-modern-ci-cd-pipeline-5faa01891a5b) publicado no [Medium](https://medium.com) por [Rob van der Leek](https://medium.com/@robvanderleek?source=post_header_lockup);


Este exemplo será utilizado como ponto de partida para a criação de um container linux encapsulado via docker:

Verifique o conteúdo do arquivo Dockerfile com as etapas do processo de build com base na imagem python do [DockerHub](https://hub.docker.com/_/python):

```sh
cat build/Dockerfile
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

Faça um novo build do projeto, para execução do upload para o docker hub será necessário uma conta na plataforma, caso não possua utilize o prefixo de conta fiaplabs:

```sh
cd build
docker build . -t fiaplabs/app:v0.0.1
```

Após o processo de build verifique a imagem criada:

```sh
docker images ls
```

Finalmente crie um novo container com base na imagem e bind na porta 8080:

```sh
docker run -d --name app --publish 8080:5000 fiaplabs/app:v0.0.1
```

---
##### Fiap - MBA Cyber Security Forensics, Ethical Hacking & DevSecOps
profhelder.pereira@fiap.com.br

**Free Software, Hell Yeah!**