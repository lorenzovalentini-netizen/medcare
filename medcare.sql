CREATE TABLE paciente (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(120) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    cpf CHAR(11) NOT NULL UNIQUE,
    data_nascimento DATE NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE especialidade (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(80) NOT NULL UNIQUE
);

CREATE TABLE medico (
    id SERIAL PRIMARY KEY,
    especialidade_id INT NOT NULL,
    nome VARCHAR(120) NOT NULL,
    crm VARCHAR(30) NOT NULL UNIQUE,
    valor_consulta NUMERIC(10,2) NOT NULL
        CHECK (valor_consulta > 0),

    FOREIGN KEY (especialidade_id)
        REFERENCES especialidade(id)
);

CREATE TABLE consulta (
    id SERIAL PRIMARY KEY,
    medico_id INT NOT NULL,
    paciente_id INT NOT NULL,
    data_hora TIMESTAMP NOT NULL,
    status VARCHAR(15) NOT NULL DEFAULT 'Agendada'
        CHECK (status IN ('Agendada', 'Realizada', 'Cancelada')),

    FOREIGN KEY (medico_id)
        REFERENCES medico(id),

    FOREIGN KEY (paciente_id)
        REFERENCES paciente(id)
);

CREATE TABLE exame_consulta (
    id SERIAL PRIMARY KEY,
    consulta_id INT NOT NULL,
    nome_exame VARCHAR(120) NOT NULL,
    valor_exame NUMERIC(10,2) NOT NULL
        CHECK (valor_exame >= 0),

    FOREIGN KEY (consulta_id)
        REFERENCES consulta(id)
);




INSERT INTO especialidade (nome)
VALUES
    ('Cardiologia'),
    ('Pediatria'),
    ('Dermatologia');



INSERT INTO medico
    (nome, crm, especialidade_id, valor_consulta)
VALUES
    ('Marcos Oliveira', 'SC-45821', 1, 420.00),
    ('Juliana Martins', 'SC-52736', 2, 280.00),
    ('Rafael Mendes', 'SC-61492', 3, 360.00);



INSERT INTO paciente
    (nome, email, cpf, data_nascimento)
VALUES
    ('Carlos Silva', 'carlos.silva@email.com', '11122233344', '1998-03-12'),
    ('Beatriz Lima', 'beatriz.lima@email.com', '22233344455', '2002-07-25'),
    ('Pedro Santos', 'pedro.santos@email.com', '33344455566', '1989-12-04');



INSERT INTO consulta
    (medico_id, paciente_id, data_hora, status)
VALUES
    (1, 1, '2026-09-05 08:30:00', 'Realizada'),
    (2, 2, '2026-09-06 10:00:00', 'Realizada'),
    (3, 1, '2026-09-08 14:30:00', 'Agendada'),
    (1, 3, '2026-09-09 16:00:00', 'Realizada');




INSERT INTO exames_consulta
    (consulta_id, nome_exame, valor_exame)
VALUES
    (1, 'Eletrocardiograma', 110.00),
    (1, 'Exame de Sangue', 75.00),
    (2, 'Hemograma Completo', 85.00),
    (4, 'Eletrocardiograma', 110.00);



SELECT
    med.nome AS nome_medico,
    med.crm,
    esp.nome AS especialidade,
    med.valor_consulta
FROM medico AS med
INNER JOIN especialidade AS esp
    ON esp.id = med.especialidade_id
ORDER BY med.valor_consulta DESC;




SELECT
    con.id,
    con.data_hora,
    med.nome AS medico,
    esp.nome AS especialidade,
    con.status
FROM consulta AS con
INNER JOIN paciente AS pac
    ON pac.id = con.paciente_id
INNER JOIN medico AS med
    ON med.id = con.medico_id
INNER JOIN especialidade AS esp
    ON esp.id = med.especialidade_id
WHERE pac.nome = 'Carlos Silva'
ORDER BY con.data_hora ASC;




SELECT
    con.id AS consulta,
    pac.nome AS paciente,
    med.nome AS medico,
    med.valor_consulta +
        COALESCE(SUM(ec.valor_exame), 0) AS valor_total
FROM consulta AS con
JOIN paciente AS pac
    ON pac.id = con.paciente_id
JOIN medico AS med
    ON med.id = con.medico_id
LEFT JOIN exames_consulta AS ec
    ON ec.consulta_id = con.id
GROUP BY
    con.id,
    pac.nome,
    med.nome,
    med.valor_consulta
ORDER BY con.id;




SELECT
    nome,
    crm,
    valor_consulta
FROM medico
WHERE valor_consulta > 300
ORDER BY valor_consulta DESC;




SELECT
    esp.nome AS especialidade,
    SUM(
        med.valor_consulta +
        COALESCE(
            (
                SELECT SUM(ex.valor_exame)
                FROM exames_consulta AS ex
                WHERE ex.consulta_id = con.id
            ),
            0
        )
    ) AS faturamento
FROM consulta AS con
JOIN medico AS med
    ON med.id = con.medico_id
JOIN especialidade AS esp
    ON esp.id = med.especialidade_id
WHERE con.status = 'Realizada'
GROUP BY esp.id, esp.nome
ORDER BY faturamento DESC;