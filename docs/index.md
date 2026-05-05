# Pipeline de Dados com Delta Lake

Pipeline de engenharia de dados que extrai dados de um banco PostgreSQL, armazena em um data lake no MinIO e converte para o formato **Delta Lake** usando Apache Spark.

## Visão Geral

```
PostgreSQL ──(01)──▶ MinIO landing-zone (CSV) ──(02)──▶ MinIO bronze (Delta Lake) ──(03)──▶ DML / Time Travel
```

| Etapa | Notebook | O que faz |
|-------|----------|-----------|
| 01 | `01_postgres_to_minio_csv` | Extrai todas as tabelas do PostgreSQL e grava como CSV na landing zone |
| 02 | `02_csv_to_delta` | Lê os CSVs com Spark e converte para Delta Lake na camada bronze |
| 03 | `03_dml_delta` | Executa INSERT, UPDATE, DELETE, MERGE e Time Travel no Delta Lake |

## Tecnologias

| Tecnologia | Versão | Papel |
|------------|--------|-------|
| PostgreSQL | 17 | Banco de dados fonte |
| MinIO | RELEASE.2025-02-03 | Object storage (S3-compatível) |
| Apache Spark | 3.5.3 | Engine de processamento |
| Delta Lake | 3.2.0 | Formato de tabela com ACID e Time Travel |
| Python | 3.11 | Linguagem do pipeline |
| uv | — | Gerenciamento de dependências |

## Início Rápido

```bash
# 1. Suba os serviços
docker compose up -d

# 2. Instale as dependências
uv sync

# 3. Inicie o JupyterLab
uv run jupyter lab
```

Execute os notebooks na ordem: `01` → `02` → `03`.
