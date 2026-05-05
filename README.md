# Projeto 2 — Pipeline de Dados com Delta Lake

Pipeline de engenharia de dados que extrai dados de um banco PostgreSQL, armazena em um data lake MinIO e converte para o formato Delta Lake usando Apache Spark.

## Arquitetura

```
PostgreSQL → (01) → MinIO landing-zone (CSV) → (02) → MinIO bronze (Delta Lake) → (03) → DML / Time Travel
```

| Camada | Tecnologia | Descrição |
|--------|------------|-----------|
| Fonte | PostgreSQL 17 | Banco relacional com dados de streaming de música |
| Landing | MinIO (S3) | Arquivos CSV extraídos do banco |
| Bronze | MinIO (S3) + Delta Lake | Dados em formato Delta, com histórico de versões |

## Modelo de Dados

5 tabelas no domínio de streaming musical:

- **artistas** — nome, país, gênero
- **albuns** — título, ano de lançamento, total de faixas
- **musicas** — título, duração, número da faixa
- **usuarios** — nome, email, plano (basico/premium)
- **reproducoes** — histórico de plays por usuário

## Pré-requisitos

- Python 3.11
- [uv](https://docs.astral.sh/uv/)
- Docker e Docker Compose

## Setup

**1. Suba os serviços:**

```bash
docker compose up -d
```

**2. Configure as variáveis de ambiente:**

```bash
cp .env.example .env
```

Edite o `.env` com suas credenciais:

```env
# PostgreSQL
DB_SERVER=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres
DB_DATABASE=apashe-spark

# MinIO
MINIO_ENDPOINT=http://localhost:9020
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_LANDING_BUCKET=landing-zone
MINIO_BRONZE_BUCKET=bronze
```

**3. Instale as dependências:**

```bash
uv sync
```

**4. Inicie o JupyterLab:**

```bash
uv run jupyter lab
```

## Notebooks

| # | Notebook | Descrição |
|---|---|---|
| 01 | `01_postgres_to_minio_csv.ipynb` | Extrai todas as tabelas do PostgreSQL e salva como CSV na landing zone |
| 02 | `02_csv_to_delta.ipynb` | Lê os CSVs com Spark e converte para Delta Lake na camada bronze |
| 03 | `03_dml_delta.ipynb` | Demonstra operações DML (INSERT, UPDATE, DELETE, MERGE) e Time Travel no Delta Lake |

Execute os notebooks em ordem.

## Serviços

| Serviço | URL | Credenciais |
|---|---|---|
| MinIO Console | http://localhost:9021 | minioadmin / minioadmin |
| MinIO API (S3) | http://localhost:9020 | — |
| PostgreSQL | localhost:5432 | postgres / postgres |

## Dependências principais

| Pacote | Versão |
|---|---|
| pyspark | 3.5.3 |
| delta-spark | 3.2.0 |
| boto3 | ≥ 1.43 |
| psycopg2-binary | ≥ 2.9.10 |
| pandas | ≥ 3.0 |
