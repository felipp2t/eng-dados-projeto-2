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

## Registrar tabelas no Spark

Antes de usar Spark SQL, as tabelas Delta são registradas apontando para o caminho S3:

```python
spark.sql(f"""
    CREATE TABLE IF NOT EXISTS {tabela}
    USING delta
    LOCATION 's3a://{BRONZE_BUCKET}/{tabela}'
""")
```

## INSERT

```python
spark.sql("""
    INSERT INTO artistas VALUES (6, 'Novo Artista', 'Brasil', 'MPB', '2024-01-01')
""")
```

## UPDATE

O Delta Lake suporta UPDATE via API Python sem necessidade de reescrever a tabela inteira:

```python
DeltaTable.forName(spark, 'usuarios').update(
    condition="plano = 'gratuito'",
    set={"plano": "'basico'"}
)
```

## DELETE

```python
DeltaTable.forName(spark, 'artistas').delete("id = 6")
```

## MERGE (UPSERT)

O MERGE atualiza registros existentes e insere os novos em uma única operação atômica:

```python
(
    DeltaTable.forName(spark, 'musicas')
    .alias('alvo')
    .merge(atualizacoes.alias('src'), 'alvo.id = src.id')
    .whenMatchedUpdateAll()    # id=1 existe → atualiza
    .whenNotMatchedInsertAll() # id=99 não existe → insere
    .execute()
)
```

## Time Travel

O Delta Lake registra cada operação DML como uma nova versão. É possível consultar versões anteriores:

```python
# Histórico de operações
DeltaTable.forName(spark, 'musicas').history().show()

# Ler versão específica
spark.read.format('delta').option('versionAsOf', 0).table('musicas').show()
```

### Histórico esperado após as operações

| version | operation | description |
|---------|-----------|-------------|
| 2 | MERGE | MERGE INTO musicas |
| 1 | WRITE | WRITE (overwrite da conversão) |
| 0 | WRITE | WRITE inicial (criação) |

!!! info "ACID no Delta Lake"
    Cada operação DML é gravada atomicamente no `_delta_log`. Se uma operação falhar no meio, o Delta garante que nenhuma alteração parcial seja visível — o estado anterior permanece intacto.
