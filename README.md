🚚 PIM IV - Sistema de Gestão de Transportes (TMS)

Este é um projeto acadêmico desenvolvido para o Projeto Integrado Multidisciplinar (PIM IV). O objetivo é construir a base de um Sistema de Gestão Logística (Transport Management System) robusto, focado no controle de entregas, veículos, motoristas e clientes.

O projeto foi construído utilizando boas práticas de engenharia de software, aplicando Clean Architecture (Arquitetura Limpa) para garantir um código organizado, testável e de fácil manutenção.

🛠️ Tecnologias Utilizadas

Linguagem: C# (.NET 8)

Banco de Dados: SQL Server

ORM: Entity Framework Core (Code-First)

Documentação de API: Swagger / OpenAPI

Controle de Versão: Git & GitHub

🏗️ Arquitetura do Projeto

A solução está dividida em 4 camadas principais:

Transportadora.Domain (Core): Contém as entidades de negócio puras (Cliente, Motorista, Veiculo, Entrega, OcorrenciaEntrega), Enums e Interfaces de Repositório.

Transportadora.Application: Contém as regras de aplicação, Casos de Uso (Services) e DTOs (Data Transfer Objects).

Transportadora.Infrastructure: Responsável pela comunicação externa, contendo a implementação dos Repositórios e o Contexto do Banco de Dados (TransportadoraDbContext).

Transportadora.API: A porta de entrada da aplicação, contendo os Controllers que expõem os endpoints REST (via Swagger) para o Front-end.

🚀 Como executar o projeto localmente

Pré-requisitos

.NET 8 SDK

SQL Server (Localhost)

Visual Studio 2022 (ou VS Code)

Passo a Passo

Clone o repositório:

git clone https://github.com/saularaujo04/PIM-IV.git
cd PIM-IV


Configure o Banco de Dados:
Certifique-se de que o SQL Server está rodando localmente (localhost). A string de conexão já está configurada no appsettings.json do projeto API.

Crie as tabelas no Banco de Dados (Migrations):
Abra o Console do Gerenciador de Pacotes no Visual Studio, selecione o projeto Transportadora.Infrastructure como padrão e rode:

Update-Database -StartupProject "Transportadora API"


Execute o projeto:
Defina o projeto Transportadora API como inicial e rode a aplicação (F5). O navegador será aberto automaticamente na página do Swagger, onde você poderá testar os endpoints da API.

🚧 Status do Projeto

[x] Estruturação da Arquitetura Limpa

[x] Criação das Entidades de Domínio

[x] Configuração do Banco de Dados Relacional (Foreign Keys)

[x] Criação da camada de Serviços e DTOs

[ ] Implementação dos Controllers da API

[ ] Integração com Front-end