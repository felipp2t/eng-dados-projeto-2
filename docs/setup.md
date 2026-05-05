# Setup

## Pré-requisitos

- Python 3.11
- [uv](https://docs.astral.sh/uv/getting-started/installation/)
- Docker e Docker Compose

## 1. Clonar o repositório

```bash
git clone <url-do-repo>
cd projeto-2
```

## 2. Configurar variáveis de ambiente

```bash
cp .env.example .env
```

Edite o `.env`:

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

## 3. Subir os serviços

```bash
docker compose up -d
```

Verifique se os containers estão rodando:

```bash
docker ps
```

Você deve ver `postgres` e `minio` com status `Up`.

!!! note "Inicialização do banco"
    O PostgreSQL executa automaticamente o `init.sql` na primeira inicialização, criando as tabelas e inserindo os dados de exemplo.

## 4. Instalar dependências

```bash
uv sync
```

## 5. Iniciar o JupyterLab

```bash
uv run jupyter lab
```

Acesse em `http://localhost:8888`.

## Serviços disponíveis

| Serviço | URL | Usuário | Senha |
|---------|-----|---------|-------|
| JupyterLab | http://localhost:8888 | — | — |
| MinIO Console | http://localhost:9021 | minioadmin | minioadmin |
| PostgreSQL | localhost:5432 | postgres | postgres |

## Documentação (MkDocs)

Para rodar a documentação localmente:

```bash
uv run --group docs mkdocs serve
```

Acesse em `http://localhost:8000`.

Para gerar o site estático:

```bash
uv run --group docs mkdocs build
```

Os arquivos serão gerados em `site/`.
