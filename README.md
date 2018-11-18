# Instruções

 1. Faça um fork deste repositório em sua conta pessoal do Github;
 2. Responda ao [teste teórico](https://github.com/hotmilhas/devops-test/blob/master/teorico.md) nos espaços reservados;
 3. Desenvolva o [teste prático](https://github.com/hotmilhas/devops-test/blob/master/pratical.md);
 4. Ao finalizar os testes teórico e prático, crie um pull request para este repositório.

## Observações

 - Questões que você não sabe a resposta podem ser deixadas em branco
 - Pode ser utilizado ferramentas open-source desde que sejam explicado o seu funcionamento
 - Todas as configurações realizadas na AWS deverão utilizar sempre as menores instâncias.

## Diferenciais

 - Kubernetes
 - Serverless

### Criação da infraestrutura na AWS

A infraestrutura na AWS foi criada utilizando uma ferramenta chamada Terraform. O script que desenvolvi com todas as instruções está em main.tf.
A qualquer momento é possível executar o comando (terraform destroy) para apagar todas as configurações que foram criadas na AWS.

O Terraform é uma ferramenta para construir, alterar e configurar uma infraestrutura de rede de forma segura e eficiente. Com ele é possível gerenciar serviços de nuvem bem conhecidos, bem como soluções internas personalizadas. Veja a lista completa de serviços de infraestrutura de nuvem suportados em: https://www.terraform.io/docs/providers/index.html.

Os arquivos de configuração do Terraform descrevem os componentes necessários para executar um único aplicativo ou todo o seu datacenter. Ele pode gerar um plano de execução descrevendo o que ele fará para atingir o estado desejado e, em seguida, ele pode executar as instruções para construir a infraestrutura descrita. Conforme a configuração muda, o Terraform é capaz de determinar o que mudou e criar planos de execução incrementais que podem ser aplicados.

O Terraform trata a infraestrutura como código e dessa forma você pode versioná-lo usando o Git, por exemplo, e ter um backup, fazer rollback em caso de problemas e fazer auditoria à medida que o tempo passa e as alterações vão sendo realizadas no seu ambiente.

O Terraform é desenvolvido e mantido pela empresa Hashicorp. Ele é gratuito com código fonte aberto e assim pode receber contribuições da comunidade no GitHub (https://github.com/hashicorp/terraform). Ele está disponível para download na página: https://www.terraform.io/downloads.html

1. Instalação Terraform
- wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip
- unzip terraform_0.11.10_linux_amd64.zip
- cp terraform /usr/local/bin

2. Rodando Terraform para criar a infraestrutura na AWS
- Acessar o projeto devops-test
- Executar o comando: terraform init
- Setar variáveis de ambiente com region, access-key, secret-key da aws e github_token:

- export AWS_ACCESS_KEY_ID=""
- export AWS_SECRET_ACCESS_KEY=""
- export AWS_DEFAULT_REGION="us-east-1"
- export GITHUB_TOKEN="" (https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

- Adicionar valores nas variáveis do arquivo variables.tf
- Executar comando: terraform apply

### Containers

Os arquivos Dockerfile foram criados dentro dos projetos node e php. 

1. Construir e usar os containers localmente
- OBS: (O arquivo Dockerfile está dentro de cada projeto, é necessário clonar os dois projetos para executar o build)
- Executar os comandos:
    - docker build -t hotmilhas/devops-node-test .
    - docker build -t hotmilhas/devops-php-test .
    - docker network create devops-test (Criando rede local para os containers se comunicarem)
    - docker run --name devops-php-test --net devops-test -p 4444:4444 -d hotmilhas/devops-php-test
    - docker run --name devops-node-test --net devops-test -p 8080:8080 -d hotmilhas/devops-node-test
- OBS: apontar variável de ambiente PHP_HOSTNAME para http://devops-php-test, assim o container node consegue se comunicar com o container php pela rede devops-test criada anteriomente.

## AWS ECS

Para executar os containers fiz a criação (via Terraform) de um cluster AWS ECS (serviço da AWS para executar containers).
Os containers estão sendo executados com um Load Balance na frente. Atualmente o DNS para acessar os mesmos é: 
- http://devops-php-test-alb-openjobs-1190652842.us-east-1.elb.amazonaws.com:4444/
- http://devops-node-test-alb-openjobs-1418573030.us-east-1.elb.amazonaws.com:8080/all

## AWS Code Pipeline

Para fazer deploy dos containers utilizei a ferramenta da CodePipeline da AWS. 
Fiz a criação (via Terraform) de um processo de pipeline, com hook do github, build e deploy.
As instruções para build dos containers e execução dos testes unitários estão dentro da pasta codepipeline-buildspec.
OBS: Ao fazer um commit no github é iniciado o processo de deploy, os containers são construidos e executados, são executados os testes unitários e caso tudo passe o deploy é feito no ECS.

## Observações
O processo de deploy está apontando para o fork dos projetos devops-php-test e devops-node-test na minha conta. Caso queira apontar para a conta da hotmilhas para testar a Integração Continua:
- Aceitar Pull Request
- Colocar nome da conta na variável GITHUB_USER no arquivo variables.tf
- OBS: Não esquecer de setar a variável de ambiente GITHUB_TOKEN sitada anteriomente.
- Rodar comando (terraform apply) para modificar o processo de Pipeline.

## Observação Final
Após revisar tudo, rodar comando (terraform destroy) para apagar todas as configurações que fiz na conta da AWS.