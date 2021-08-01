## Security Groups

O gerenciamento dos grupos de segurança é feito a partir do terraform, o grupo de segurança vinculado a instância possui a seguinte configuração de acesso;

- Restrição de acesso à porta 22 utilizada pelo protocolo SSH para o terminal do Cloud9;
- Liberação de acesso à porta 80 usada pelo servidor de conteúdo nginx ou apache;
- Liberação de ICMP;