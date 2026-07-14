# Sistema de Gestão Hospitalar - Dra. Yuska Maritan Brito

## Integrantes da equipe:
- Kevin Gabriel Morais Mangueira
- Antônio Francelino de Pontes Neto
- Luiz Henrique Santos da Graça
- Victor Gabriel Da Silva Menezes

## Pré-requisitos:
Antes de tudo, é necessário instalar:
- PostgreSQL (o SGBD em si) — https://www.postgresql.org/download/
    - Durante a instalação, será solicitado definir uma senha para o usuário postgres. Guarde essa senha.
    - A instalação já inclui o psql, o cliente de linha de comando do Postgres.
- DBeaver (cliente visual, opcional mas recomendado) — https://dbeaver.io/download/
    - Facilita visualizar tabelas, rodar scripts e ver resultados sem depender do terminal.
- Git — https://git-scm.com/downloads
    - Necessário para clonar o repositório do GitHub.

## Criando o banco de dados:
Com o PostgreSQL instalado e rodando, criar um banco vazio para o projeto:
- Acesse o cliente psql como o usuário postgres:
    - psql -U postgres
- Dentro do psql, cria o banco de dados:
    - CREATE DATABASE hospital_db;
- Saia do psql:
    - \q

## Executando os Scripts SQL:
Os scripts devem ser executados na ordem correta, pois o DML depende das tabelas já existirem, e as tabelas têm dependências entre si (ex: PACIENTE depende de PESSOA já existir).

### Via linha de comando (psql):
1. Crie as tabelas(estrutura):
    - psql -U postgres -d hospital_db -f sql/ddl/01_create_tables.sql
2. Insira os dados de teste:
    - psql -U postgres -d hospital_db -f sql/dml/01_dados_teste.sql
3. (Opcional) Executa uma consulta específica para testar:
    - psql -U postgres -d hospital_db -f sql/analytics/01_ranking_residentes_por_atendimentos.sql

### Via DBeaver (interface visual):
1. Criar uma nova conexão apontando para o banco hospital_db;
2. Abrir o arquivo .sql desejado (File → Open File);
3. Conectar o arquivo sql com o hospital_db;
4. Executar o script inteiro com Alt+X (ou o botão "Execute SQL Script").

## Para verificar se tudo deu certo:
Após rodar os scripts, é possível conferir se os dados foram inseridos corretamente:
- psql -U postgres -d hospital_db
- Dentro do psql:
    - \dt
    - SELECT * FROM pessoa;
    - SELECT * FROM atendimento;






