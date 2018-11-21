# Teste teórico

1- **Como funciona a integração continua? Cite os seus benefícios.**
 
  [RESPOSTA]

“Integração Contínua é uma pratica de desenvolvimento de software onde os membros de um time integram seu trabalho frequentemente, geralmente cada pessoa integra pelo menos diariamente – podendo haver multiplas integrações por dia. Cada integração é verificada por um build automatizado (incluindo testes) para detectar erros de integração o mais rápido possível. Muitos times acham que essa abordagem leva a uma significante redução nos problemas de integração e permite que um time desenvolva software coeso mais rapidamente.” Martin Fowler

A vantagem da integração contínua e poder identificar de forma rápida os problemas no código executando testes automatizados que podem identificar as falhas durante cada commit. A dideia é a cada commit no repositório, o build é feito automaticamente com todos os testes sendo executados e as falhas sendo detectadas. O benefício é pode identificar os problemas e corrigir o mais rápido possível sem quebrar o código que já está em produção. Integração contínua é mais uma forma de trazer segurança em relação a mudanças: você pode fazer modificações sem medo, pois será avisado caso algo saia do esperado.

2- **Você tem um aplicativo distribuído que processa periodicamente grandes volumes de dados em várias instâncias do Amazon EC2. O aplicativo foi projetado para . Você é obrigado a realizar essa tarefa da maneira mais econômica possível.
Qual das seguintes opções atenderá aos seus requisitos?**

  a) Spot Instances (X)
  
  b) Reserved Instances
  
  c) Dedicated Instances
  
  d) On-Demand Instances
  

3- **Quais configurações se faz necessário para que todos os objetos enviados para Amazon S3 sejam definidos como leitura pública?**

  a) Definir permissões de leitura pública durante o upload do arquivo

  b) Configure a política para definir todos os arquivos para leitura pública (X)

  c) Use as funções AWS Identity e Access Management para definir a política de leitura pública

  d) Amazon S3 por padrão é configurado para leitura pública, nenhuma ação se faz necessária

4- **Se você deseja iniciar as instâncias do Amazon Elastic Compute Cloud (EC2) e atribuir a cada instância um endereço IP privado predeterminado, deve:**
 
  a) Inicie a instância de uma Amazon Machine Image (AMI) privada

  b) Atribuir um grupo de Elastic IP sequencias às instâncias

  c) Inicie as instâncias com Amazon Virtual Private Cloud (VPC) (X)

  d) Inicie as intâncias em um Placement Group


5-  **Sobre sub-redes, qual a alternativa correta?**

   a) Você pode anexar várias tabelas de rota a uma sub-rede

   b) Você pode anexar várias sub-redes a uma tabela de rotas (X)

   c) Ambos, A e B

   d) Nenhuma das alternativas
 
 
6- **Por que se deve criar sub-redes?**
 
  a) Porque há escassez de redes

  b) Para utilizar eficientemente redes que possuem um grande número de hosts (X)

  c) Porque há escassez de hosts

  d) Para utilizar eficientemente redes que possuem um pequeno número de hosts


7- Qual a diferença entre Amazon RDS, DynamoDB e Redshift?

  [RESPOSTA]
 
  RDS é um serviço de bancos de dados relacionais (Exemplo: MYSQL, Postgres, MariaDB).
  DynnamoDB é um serviço de banco de dados não relacional (NoSQL) da Amazon.
  Redshift é um serviço de banco de dados também, porém para processamento de um grande volume de dados em seus warehouses.

  A diferança entre eles é que cada um possui o seu proposito, são banco de dados muito diferentes e devem ser escolhidos de acordo com a demanda.

8- **Se um instância de banco de dados como Multi-AZ, é possível utilizar uma instância de banco de dados em espera para operações de leitura e escrita com o banco de dados principal? Justifique.**
 
  a) Sim

  b) Não (X)

  c) Apenas instâncias MySQL RDS

  d) Apenas instâncias Oracle RDS

  Em bancos de dados Multi-AZ somente a instância primária está ativa. A segunda instância será utilizada em casos de failover.
 
9- **Uma instância Amazon EC2 está se aproximando de 100% da utilização da CPU. Qual opção irá reduzir a carga nesta instância Amazon EC2?**
 
  a) Criar um load balancer para a instância Amazon EC2 (X)

  b) Configurar o CloudFront e definindo a instância Amazon EC2 como origem

  c) Criar um Auto Scaling Group a partir da instância utilizando a ação CreateAutoScalingGroup (X)

  d) Criar um Launch Configuration a partir da instância utilizando a ação CreateLaunchConfigurationAction (X)

Essas questões são bem complicadas de responder, pois depende muito.
Caso seja uma aplicação web vamos precisar do Auto Scaling Group com um Launch Configuration para escalar as máquinas caso necessite de mais recursos.
Mas também vamos precisar de um load balance para divir a carga entre essas máquinas.
Na minha opção as 3 questões podem estar certas dependendo da situação.
