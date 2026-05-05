# 01 — Extração: PostgreSQL → CSV

**Notebook:** `notebooks/01_postgres_to_minio_csv.ipynb`

Extrai todas as tabelas do PostgreSQL e as armazena como arquivos CSV no bucket `landing-zone` do MinIO.

## O que este notebook faz

1. Carrega as variáveis de ambiente do `.env`
2. Conecta ao PostgreSQL via `psycopg2`
3. Lista todas as tabelas do schema `public`
4. Para cada tabela: lê os dados, converte para CSV e envia ao MinIO via `boto3`
5. Valida os arquivos gravados

## Resultado esperado

```
5 tabelas encontradas:
   1. albuns                (     5 registros)
   2. artistas              (     5 registros)
   3. musicas               (     5 registros)
   4. reproducoes           (     5 registros)
   5. usuarios              (     5 registros)

Extracao concluida! 5 tabelas exportadas.

Arquivos no bucket [landing-zone]:
  albuns.csv                   0.2 KB
  artistas.csv                 0.2 KB
  musicas.csv                  0.2 KB
  reproducoes.csv              0.2 KB
  usuarios.csv                 0.2 KB
```

## Dependências

| Pacote | Uso |
|--------|-----|
| `psycopg2-binary` | Conexão com PostgreSQL |
| `boto3` | Upload para MinIO (API S3) |
| `pandas` | Conversão para CSV em memória |
| `python-dotenv` | Leitura do `.env` |

## Detalhes de implementação

### Conexão PostgreSQL

```python
conn = psycopg2.connect(
    host=DB_SERVER,
    port=DB_PORT,
    user=DB_USER,
    password=DB_PASSWORD,
    dbname=DB_DATABASE
)
```

### Listagem de tabelas

```python
cursor.execute("""
    SELECT table_name FROM information_schema.tables
    WHERE table_type = 'BASE TABLE' AND table_schema = 'public'
    ORDER BY table_name
""")
```

### Upload para MinIO

Os dados são serializados para CSV em memória (sem arquivo temporário no disco) e enviados via `put_object`:

```python
csv_buffer = io.StringIO()
df.to_csv(csv_buffer, index=False)
csv_bytes = csv_buffer.getvalue().encode('utf-8')

s3_client.put_object(
    Bucket=LANDING_BUCKET,
    Key=f'{tabela}.csv',
    Body=csv_bytes,
    ContentType='text/csv'
)
```

!!! tip "Carregamento do .env em notebooks"
    O notebook usa `__vsc_ipynb_file__` (variável definida pelo VS Code) para localizar o `.env` na raiz do projeto, evitando problemas com `os.getcwd()` no WSL2.
