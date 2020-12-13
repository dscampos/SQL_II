/*
Author: Dirson S. Campos
  Trigger stored procedure in PL / pgSQL
The trigger guarantees that when a row is inserted or updated in the table, 
the user who performed the insertion or update is always registered in this row, and when this occurred.
In addition, the trigger checks that the employee's name is provided, and that the salary value is a positive number.
*/

DROP TABLE IF EXISTS emp;
DROP FUNCTION IF EXISTS emp_gatilho;

CREATE TABLE emp (
    nome_emp       text,
    salario        integer,
    ultima_data    timestamp,
    ultimo_usuario text
);

CREATE FUNCTION emp_gatilho() RETURNS trigger AS $emp_gatilho$
    BEGIN
        -- Verificar se foi fornecido o nome e o salário do empregado
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

        -- Registrar quem alterou a folha de pagamento e quando
        NEW.ultima_data := 'now';
        NEW.ultimo_usuario := current_user;
        RETURN NEW;
    END;
$emp_gatilho$ LANGUAGE plpgsql;

CREATE TRIGGER emp_gatilho BEFORE INSERT OR UPDATE ON emp
    FOR EACH ROW EXECUTE PROCEDURE emp_gatilho();

INSERT INTO emp (nome_emp, salario) VALUES ('João',1000);
INSERT INTO emp (nome_emp, salario) VALUES ('José',1500);
INSERT INTO emp (nome_emp, salario) VALUES ('Maria',2500);

SELECT * FROM emp;
