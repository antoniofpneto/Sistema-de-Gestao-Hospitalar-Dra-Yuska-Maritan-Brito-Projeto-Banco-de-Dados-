# Sistema de Gestão Hospitalar - Dra. Yuska Maritan Brito

## Integrantes da equipe:
- Kevin Gabriel Morais Mangueira
- Antônio Francelino de Pontes Neto
- Luiz Henrique Santos da Graça
- Victor Gabriel Da Silva Menezes

---

## 🛠️ Pré-requisitos Gerais
Antes de tudo, é necessário ter instalado em sua máquina:
- **PostgreSQL** (SGBD) — [Download](https://www.postgresql.org/download/)
    - Durante a instalação, será solicitado definir uma senha para o usuário `postgres`. Guarde essa senha.
    - A instalação já inclui o `psql`, o cliente de linha de comando do Postgres.
- **DBeaver** (Cliente visual, opcional mas recomendado) — [Download](https://dbeaver.io/download/)
    - Facilita visualizar tabelas, rodar scripts e ver resultados sem depender do terminal.
- **Git** — [Download](https://git-scm.com/downloads)
    - Necessário para clonar o repositório.
- **Python 3.x** — [Download](https://www.python.org/downloads/)
    - Necessário para rodar o backend e a interface web da Etapa 2.

---

## 💾 Etapa 1: Criando e Povoando o Banco de Dados

### 1. Criando o banco vazio
Com o PostgreSQL instalado e rodando, crie o banco para o projeto:
1. Acesse o cliente `psql` no terminal: `psql -U postgres`
2. Crie o banco de dados: `CREATE DATABASE gestao_hospitalar;` *(Nota: ajuste o nome conforme sua preferência)*
3. Saia do psql: `\q`

### 2. Executando os Scripts SQL
Os scripts devem ser executados na ordem correta (DDL primeiro, depois DML), pois há dependências relacionais estruturais.

**Via linha de comando (psql):**
1. Crie as tabelas (estrutura):
    `psql -U postgres -d gestao_hospitalar -f sql/ddl/01_create_tables.sql`
2. Insira os dados de teste:
    `psql -U postgres -d gestao_hospitalar -f sql/dml/01_dados_teste.sql`
3. (Opcional) Execute uma consulta analítica:
    `psql -U postgres -d gestao_hospitalar -f sql/analytics/01_ranking_residentes_por_atendimentos.sql`

**Via DBeaver (Interface visual):**
1. Crie uma nova conexão apontando para o banco `gestao_hospitalar`.
2. Abra os arquivos `.sql` desejados em File → Open File.
3. Conecte o arquivo ao banco e execute tudo com `Alt+X`.

Para verificar se tudo deu certo via terminal, acesse o banco (`psql -U postgres -d gestao_hospitalar`), digite `\dt` para listar as tabelas ou faça um `SELECT * FROM pessoa;`.

---

## 💻 Etapa 2: Executando a Aplicação Web (Flask + SQLAlchemy)

A Etapa 2 traz uma interface web interativa para o sistema, substituindo os scripts manuais por um mapeamento objeto-relacional (ORM).

### 1. Configurando o Ambiente Virtual
Para evitar conflitos com outras bibliotecas do seu computador, criamos uma "sala limpa" (ambiente virtual). No terminal, dentro da pasta do projeto, execute:

**No Windows:**
```powershell
python -m venv venv
venv\Scripts\Activate
```

**No Linux/Mac:**
```
python3 -m venv venv
source venv/bin/activate
```

### 2. Instalando as Dependências

Com o ambiente ativado, instale as bibliotecas necessárias para o motor do servidor rodar:

Bash

```
pip install -r requirements.txt
```

### 3. Configurando o Cofre de Senhas (.env)

A aplicação precisa saber como acessar o seu banco de dados, mas não deixamos senhas expostas no código.

1. Crie um arquivo chamado `.env` na raiz do projeto (use o arquivo `.env.example` como base).
2. Preencha com as suas credenciais reais do PostgreSQL:

Fragmento do código
```
DB_USER=seu_usuario
DB_PASSWORD=sua_senha
DB_HOST=localhost
DB_PORT=5432
DB_NAME=gestao_hospitalar
```

### 4. Iniciando os arquivos SQL, caso não tenham sido ativados:
1. `psql -U postgres -d gestao_hospitalar -f sql/ddl/01_create_tables.sql`
2. `psql -U postgres -d gestao_hospitalar -f sql/ddl/02_stored_procedures.sql`
3. `psql -U postgres -d gestao_hospitalar -f sql/ddl/03_triggers.sql`
4. `psql -U postgres -d gestao_hospitalar -f sql/dml/01_dados_teste.sql`

### 5. Iniciando o Servidor
Com tudo configurado, basta ligar o servidor web:
1. Navegue até a pasta da aplicação: `cd app`
2. Execute o sistema: `python app.py`

Pronto! A recepcão do hospital já está operante. Abra o seu navegador e acesse: **`http://localhost:5000`**