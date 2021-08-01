## Object Storage

No uso de S3 ou soluções similares, existe o conceito de Object Storage, um modelo de armazenamento onde os dados são manipulados como objetos;

**Object Storage Policys**

Conforme descrito no capítulo sobre autorização e autenticação, no uso de soluções baseadas em Cloud Computing temos o conceito de Policys,  a partir de uma policy é possível liberar o acesso a uma conta para um objetivo específico, como adicionar ou visualizar objetos em um Bucket (nome dado aos diretórios criados para armazenar objetos).

Com base neste conceito a conta utilizada para este laboratório possui as seguintes as configurações:


- Neste exemplo a conta foi criada no formato "Programatic Account", uma conta usada para administração via API e sem acesso ao painel de gerenciamento, essa escolha de tipo de conta visa restringir o vetor de ataque;

- Esta conta será manipulada pelo terraform, que foi a solução de orquestração adotada no exemplo;

- O terraform foi configurado para guardar o estado dos recursos manipulados (criação de instâncias, Elastic IPs etc.) em um bucket usando como mecanismo de autenticação a nossa "Programatic Account" e como mecanismo de autorização uma Policy de acesso ao Bucket similar a policy deste exemplo;

- A autorização nas policys se baseia na identificação das contas que no caso da AWS são chamadas de  (ARNs) ou Amazon Resource Names;