# 03 — DML e Time Travel

**Notebook:** `notebooks/03_dml_delta.ipynb`

Demonstra operações de manipulação de dados (DML) e Time Travel nas tabelas Delta Lake da camada bronze.

## Operações demonstradas

| Operação | Tabela | Descrição |
|----------|--------|-----------|
| INSERT | `artistas`, `usuarios` | Insere novos registros |
| UPDATE | `usuarios` | Atualiza o plano de todos os usuários `gratuito` para `basico` |
| DELETE | `artistas` | Remove o artista inserido (id=6) |
| MERGE | `musicas` | Atualiza existente e insere novo em uma única operação |
| Time Travel | `musicas` | Consulta versões anteriores e exibe o histórico |

## Helpers de path

O notebook não usa o Hive catalog (`CREATE TABLE`) para evitar inconsistências no `_delta_log`. Em vez disso, define três funções utilitárias na célula de setup:

```python
def dp(tabela):
    return f's3a://{BRONZE_BUCKET}/{tabela}'        # path S3

def dt(tabela):
    return DeltaTable.forPath(spark, dp(tabela))    # DeltaTable API

def dr(tabela):
    return spark.read.format('delta').load(dp(tabela))  # DataFrame
```

!!! warning "Por que não usar CREATE TABLE?"
    `CREATE TABLE IF NOT EXISTS ... USING delta LOCATION '...'` escreve uma entrada de metadados no `_delta_log` da tabela. Se o notebook for re-executado após uma limpeza parcial do bucket, essa entrada extra gera versões inconsistentes e o erro `DELTA_VERSIONS_NOT_CONTIGUOUS`.

## INSERT

```python
novo_artista = spark.createDataFrame([
    Row(id=6, nome='Novo Artista', pais='Brasil', genero='MPB', criado_em='2024-01-01')
])
novo_artista.write.format('delta').mode('append').save(dp('artistas'))
```

## UPDATE

```python
dt('usuarios').update(
    condition="plano = 'gratuito'",
    set={"plano": "'basico'"}
)
```

## DELETE

```python
dt('artistas').delete("id = 6")
```

## MERGE (UPSERT)

O MERGE atualiza registros existentes e insere os novos em uma única operação atômica:

```python
(
    dt('musicas')
    .alias('alvo')
    .merge(atualizacoes.alias('src'), 'alvo.id = src.id')
    .whenMatchedUpdateAll()     # id=1 existe → atualiza
    .whenNotMatchedInsertAll()  # id=99 não existe → insere
    .execute()
)
```

## Time Travel

```python
# Histórico de operações
dt('musicas').history().select('version', 'timestamp', 'operation').show()

# Ler versão específica
spark.read.format('delta').option('versionAsOf', 0).load(dp('musicas')).show()
```

### Histórico esperado após as operações

| version | operation | descrição |
|---------|-----------|-----------|
| 2 | MERGE | MERGE INTO musicas |
| 1 | WRITE | INSERT (append) |
| 0 | WRITE | WRITE inicial (criação pelo notebook 02) |

!!! info "ACID no Delta Lake"
    Cada operação DML é gravada atomicamente no `_delta_log`. Se uma operação falhar no meio, o Delta garante que nenhuma alteração parcial seja visível — o estado anterior permanece intacto.

## Resetar o ambiente

Se o `_delta_log` ficar corrompido por execuções parciais, a forma mais segura de resetar é deletar o bucket `bronze` pelo MinIO Console e re-executar o notebook 02:

1. Acesse **http://localhost:9021**
2. **Buckets → bronze → Delete Bucket**
3. Re-execute o notebook 02 (recria o bucket e as tabelas Delta do zero)
