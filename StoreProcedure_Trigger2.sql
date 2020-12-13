/*
Author: Dirson S Campos
Stored procedure of trigger type in PL / pgSQL to record insertion and update
However, unlike the previous trigger made available in file (StoreProcedure_Trigger1.sql).
The creation and update of the row are recorded in different columns.
In addition, the trigger checks that the employee's name is provided, 
and that the salary value is a positive number.

*/

DROP TABLE IF EXISTS emp;
DROP FUNCTION IF EXISTS emp_gatilho;

CREATE TABLE emp (
    nome_emp       text,
    salario        integer,
    usu_cria       text,        -- Usuário que criou a linha
    data_cria      timestamp,   -- Data da criação da linha
    usu_atu        text,        -- Usuário que fez a atualização
    data_atu       timestamp    -- Data da atualização
);

CREATE FUNCTION emp_gatilho() RETURNS trigger AS $emp_gatilho$
    BEGIN
        -- Verificar se foi fornecido o nome do empregado
        IF NEW.nome_emp IS NULL THEN
            RAISE EXCEPTION 'O nome do empregado não pode ser nulo';
        END IF;
        IF NEW.salario IS NULL THEN
            RAISE EXCEPTION '% não pode ter um salário nulo', NEW.nome_emp;
        END IF;

        -- Quem paga para trabalhar?
        IF NEW.salario < 0 THEN
            RAISE EXCEPTION '% não pode ter um salário negativo', NEW.nome_emp;
        END IF;

        -- Registrar quem criou a linha e quando
        IF (TG_OP = 'INSERT') THEN
            NEW.data_cria := current_timestamp;
            NEW.usu_cria  := current_user;
        -- Registrar quem alterou a linha e quando
        ELSIF (TG_OP = 'UPDATE') THEN
            NEW.data_atu := current_timestamp;
            NEW.usu_atu  := current_user;
        END IF;
        RETURN NEW;
    END;
$emp_gatilho$ LANGUAGE plpgsql;

CREATE TRIGGER emp_gatilho BEFORE INSERT OR UPDATE ON emp
    FOR EACH ROW EXECUTE PROCEDURE emp_gatilho();

INSERT INTO emp (nome_emp, salario) VALUES ('João',1000);
INSERT INTO emp (nome_emp, salario) VALUES ('José',1500);
INSERT INTO emp (nome_emp, salario) VALUES ('Maria',250);
UPDATE emp SET salario = 2500 WHERE nome_emp = 'Maria';

SELECT * FROM emp;
