# Arquitetura

## Diagrama

```
┌─────────────────┐        ┌──────────────────────────────────────────┐
│   PostgreSQL 17  │        │                  MinIO                    │
│                 │        │                                            │
│  artistas       │──(01)─▶│  landing-zone/        bronze/             │
│  albuns         │  boto3  │  ├─ artistas.csv      ├─ artistas/       │
│  musicas        │        │  ├─ albuns.csv    (02) │  ├─ _delta_log/  │
│  usuarios       │        │  ├─ musicas.csv ──────▶│  └─ *.parquet   │
│  reproducoes    │        │  ├─ usuarios.csv        ├─ albuns/        │
└─────────────────┘        │  └─ reproducoes.csv     └─ ...           │
                           └──────────────────────────────────────────┘
                                                          │
                                                         (03)
                                                          │
                                                  ┌───────────────┐
                                                  │  Delta Lake   │
                                                  │  INSERT       │
                                                  │  UPDATE       │
                                                  │  DELETE       │
                                                  │  MERGE        │
                                                  │  Time Travel  │
                                                  └───────────────┘
```

## Camadas

### Fonte — PostgreSQL

Banco relacional com o esquema do domínio de streaming musical. Inicializado automaticamente via `init.sql` pelo Docker Compose.

### Landing Zone — MinIO (CSV)

Camada de ingestão bruta. Os dados são extraídos com `psycopg2` e escritos como CSV via `boto3` (API S3-compatível do MinIO). Cada tabela vira um arquivo `<tabela>.csv` no bucket `landing-zone`.

### Bronze — MinIO (Delta Lake)

Camada de armazenamento estruturado. O Spark lê os CSVs da landing zone, infere o schema e grava no formato Delta Lake no bucket `bronze`. Cada tabela vira um diretório com arquivos Parquet e o `_delta_log/` (transaction log).

O formato Delta garante:

- **ACID transactions** — escritas atômicas e consistentes
- **Schema enforcement** — rejeita dados com schema incompatível
- **Time Travel** — acesso a versões anteriores via `versionAsOf`
- **DML completo** — UPDATE, DELETE e MERGE nativos

## Infraestrutura (Docker Compose)

| Serviço | Imagem | Porta host | Porta container |
|---------|--------|-----------|-----------------|
| postgres | `postgres:17-alpine` | `5432` | `5432` |
| minio | `minio/minio:RELEASE.2025-02-03` | `9020` (API), `9021` (console) | `9000`, `9001` |

As credenciais são lidas do arquivo `.env` via variáveis de ambiente.
