# 02 — Conversão: CSV → Delta Lake

**Notebook:** `notebooks/02_csv_to_delta.ipynb`

Lê os CSVs da landing zone com Apache Spark e os converte para o formato Delta Lake na camada bronze.

## O que este notebook faz

1. Inicializa uma `SparkSession` com suporte a Delta Lake e MinIO (S3A)
2. Cria o bucket `bronze` no MinIO se não existir
3. Lista os CSVs disponíveis no bucket `landing-zone`
4. Para cada CSV: lê com inferência de schema e grava como Delta Lake
5. Valida as tabelas Delta criadas
6. Exibe uma amostra de cada tabela

## Resultado esperado

```
Convertendo 5 CSVs para Delta Lake...

  albuns: 5 registros | 5 colunas -> s3a://bronze/albuns
  artistas: 5 registros | 5 colunas -> s3a://bronze/artistas
  musicas: 5 registros | 5 colunas -> s3a://bronze/musicas
  reproducoes: 5 registros | 5 colunas -> s3a://bronze/reproducoes
  usuarios: 5 registros | 5 colunas -> s3a://bronze/usuarios

Conversao concluida! 5 tabelas Delta criadas no bucket [bronze].
```

## Configuração do Spark

O Spark é configurado com dois pacotes Maven baixados automaticamente:

| Pacote | Versão | Finalidade |
|--------|--------|-----------|
| `io.delta:delta-spark_2.12` | 3.2.0 | Suporte ao formato Delta Lake |
| `org.apache.hadoop:hadoop-aws` | 3.3.4 | Conector S3A para MinIO |

```python
spark = (
    SparkSession.builder
    .config('spark.jars.packages',
            'io.delta:delta-spark_2.12:3.2.0,org.apache.hadoop:hadoop-aws:3.3.4')
    .config('spark.sql.extensions',
            'io.delta.sql.DeltaSparkSessionExtension')
    .config('spark.hadoop.fs.s3a.endpoint', MINIO_ENDPOINT)
    .config('spark.hadoop.fs.s3a.path.style.access', 'true')
    .getOrCreate()
)
```

## Conversão CSV → Delta

```python
df = spark.read \
    .option('header', 'true') \
    .option('inferSchema', 'true') \
    .csv(f's3a://{LANDING_BUCKET}/{csv_file}')

df.write \
    .format('delta') \
    .mode('overwrite') \
    .save(f's3a://{BRONZE_BUCKET}/{tabela}')
```

## Estrutura no MinIO após a conversão

Cada tabela Delta ocupa um diretório com a seguinte estrutura:

```
bronze/
└── artistas/
    ├── _delta_log/
    │   └── 00000000000000000000.json   ← transaction log
    └── part-00000-...snappy.parquet    ← dados
```

O `_delta_log` é o que diferencia uma tabela Delta de um diretório Parquet comum — ele registra todas as operações e permite Time Travel.

!!! warning "Primeira execução"
    O Spark baixa os JARs automaticamente (~280 MB) na primeira execução. As execuções seguintes usam o cache em `~/.ivy2/jars`.
