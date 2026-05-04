CREATE TABLE IF NOT EXISTS artistas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    pais VARCHAR(50),
    genero VARCHAR(50),
    criado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS  albuns (
    id SERIAL PRIMARY KEY,
    artista_id INT NOT NULL REFERENCES artistas(id),
    titulo VARCHAR(150) NOT NULL,
    ano_lancamento INT,
    total_faixas INT
);

CREATE TABLE IF NOT EXISTS musicas (
    id SERIAL PRIMARY KEY,
    album_id INT NOT NULL REFERENCES albuns(id),
    titulo VARCHAR(150) NOT NULL,
    duracao_segundos INT,
    numero_faixa INT
);

CREATE TABLE IF NOT EXISTS usuarios (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    plano VARCHAR(20) DEFAULT 'free',
    criado_em TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reproducoes (
    id SERIAL PRIMARY KEY,
    usuario_id INT NOT NULL REFERENCES usuarios(id),
    musica_id INT NOT NULL REFERENCES musicas(id),
    reproduzida_em TIMESTAMP DEFAULT NOW(),
    duracao_ouvida_segundos INT
);


INSERT INTO artistas (nome, pais, genero) VALUES
    ('The Weeknd',      'Canadá',         'R&B'),
    ('Dua Lipa',        'Reino Unido',    'Pop'),
    ('Kendrick Lamar',  'Estados Unidos', 'Hip-Hop'),
    ('Billie Eilish',   'Estados Unidos', 'Indie Pop'),
    ('Tame Impala',     'Austrália',      'Psicodélico');

INSERT INTO albuns (artista_id, titulo, ano_lancamento, total_faixas) VALUES
    (1, 'After Hours',          2020, 14),
    (2, 'Future Nostalgia',     2020, 11),
    (3, 'To Pimp a Butterfly',  2015, 16),
    (4, 'Happier Than Ever',    2021, 16),
    (5, 'Currents',             2015, 13);

INSERT INTO musicas (album_id, titulo, duracao_segundos, numero_faixa) VALUES
    (1, 'Blinding Lights',  200, 6),
    (2, 'Levitating',       203, 5),
    (3, 'Alright',          219, 9),
    (4, 'Happier Than Ever',298, 11),
    (5, 'The Less I Know the Better', 216, 11);

INSERT INTO usuarios (nome, email, plano) VALUES
    ('Ana Lima',      'ana.lima@email.com',      'premium'),
    ('Bruno Costa',   'bruno.costa@email.com',   'free'),
    ('Carla Souza',   'carla.souza@email.com',   'premium'),
    ('Diego Martins', 'diego.martins@email.com', 'free'),
    ('Elena Ferraz',  'elena.ferraz@email.com',  'premium');

INSERT INTO reproducoes (usuario_id, musica_id, reproduzida_em, duracao_ouvida_segundos) VALUES
    (1, 1, '2025-04-01 08:15:00', 200),
    (2, 3, '2025-04-01 09:30:00', 100),
    (3, 5, '2025-04-02 14:00:00', 216),
    (4, 2, '2025-04-03 18:45:00', 90),
    (5, 4, '2025-04-04 21:00:00', 298);
