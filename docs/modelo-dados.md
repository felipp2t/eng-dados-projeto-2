# Modelo de Dados

Domínio de streaming musical com 5 tabelas relacionadas.

## Diagrama ER

```
artistas
├── id (PK)
├── nome
├── pais
├── genero
└── criado_em
      │
      │ 1:N
      ▼
albuns
├── id (PK)
├── artista_id (FK → artistas)
├── titulo
├── ano_lancamento
└── total_faixas
      │
      │ 1:N
      ▼
musicas ◀──────────────────────────────┐
├── id (PK)                             │
├── album_id (FK → albuns)              │ N:1
├── titulo                              │
├── duracao_segundos               reproducoes
└── numero_faixa                   ├── id (PK)
                                   ├── usuario_id (FK → usuarios)
usuarios                           ├── musica_id (FK → musicas)
├── id (PK)          1:N ──────────├── reproduzida_em
├── nome                           └── duracao_ouvida_segundos
├── email
├── plano
└── criado_em
```

## Tabelas

### artistas

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL PK | Identificador |
| `nome` | VARCHAR(100) | Nome do artista |
| `pais` | VARCHAR(50) | País de origem |
| `genero` | VARCHAR(50) | Gênero musical |
| `criado_em` | TIMESTAMP | Data de cadastro |

### albuns

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL PK | Identificador |
| `artista_id` | INT FK | Referência ao artista |
| `titulo` | VARCHAR(150) | Título do álbum |
| `ano_lancamento` | INT | Ano de lançamento |
| `total_faixas` | INT | Número de faixas |

### musicas

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL PK | Identificador |
| `album_id` | INT FK | Referência ao álbum |
| `titulo` | VARCHAR(150) | Título da música |
| `duracao_segundos` | INT | Duração em segundos |
| `numero_faixa` | INT | Posição no álbum |

### usuarios

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL PK | Identificador |
| `nome` | VARCHAR(100) | Nome do usuário |
| `email` | VARCHAR(150) UNIQUE | E-mail |
| `plano` | VARCHAR(20) | Plano contratado (`basico`, `premium`) |
| `criado_em` | TIMESTAMP | Data de cadastro |

### reproducoes

| Coluna | Tipo | Descrição |
|--------|------|-----------|
| `id` | SERIAL PK | Identificador |
| `usuario_id` | INT FK | Referência ao usuário |
| `musica_id` | INT FK | Referência à música |
| `reproduzida_em` | TIMESTAMP | Momento da reprodução |
| `duracao_ouvida_segundos` | INT | Segundos efetivamente ouvidos |

## Dados de Exemplo

O arquivo `init.sql` popula o banco com 5 registros por tabela:

| Artista | Gênero | Álbum |
|---------|--------|-------|
| The Weeknd | R&B | After Hours (2020) |
| Dua Lipa | Pop | Future Nostalgia (2020) |
| Kendrick Lamar | Hip-Hop | To Pimp a Butterfly (2015) |
| Billie Eilish | Indie Pop | Happier Than Ever (2021) |
| Tame Impala | Psicodélico | Currents (2015) |
