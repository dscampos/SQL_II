/*
Author: Dirson Santos de Campos
Stored procedure of trigger type in PL / pgSQL that was used to simulate an audit.
This trigger ensures that all inserts, updates and
row exclusions in the emp table are recorded in the emp_audit table
to allow auditing the operations performed in the emp.
The user name and the current time are recorded on the line, 
along with the type of operation that was performed.
*/

DROP TABLE IF EXISTS emp;
DROP TABLE IF EXISTS emp_audit;
DROP FUNCTION IF EXISTS emp_audit;
DROP FUNCTION IF EXISTS  processa_emp_audit;

CREATE TABLE emp (
    nome_emp    text NOT NULL,
    salario     integer
);

CREATE TABLE emp_audit(
    operacao    char(1)   NOT NULL,
    usuario     text      NOT NULL,
    data        timestamp NOT NULL,
    nome_emp    text      NOT NULL,
    salario     integer
);

CREATE OR REPLACE FUNCTION processa_emp_audit() RETURNS TRIGGER AS $emp_audit$
    BEGIN
        --
        -- Cria uma linha na tabela emp_audit para refletir a operação
        -- realizada na tabela emp. Utiliza a variável especial TG_OP
        -- para descobrir a operação sendo realizada.
        --
        IF (TG_OP = 'DELETE') THEN
            INSERT INTO emp_audit SELECT 'E', user, now(), OLD.*;
            RETURN OLD;
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO emp_audit SELECT 'A', user, now(), NEW.*;
            RETURN NEW;
        ELSIF (TG_OP = 'INSERT') THEN
            INSERT INTO emp_audit SELECT 'I', user, now(), NEW.*;
            RETURN NEW;
        END IF;
        RETURN NULL; -- o resultado é ignorado uma vez que este é um gatilho AFTER
    END;
$emp_audit$ language plpgsql;

CREATE TRIGGER emp_audit
AFTER INSERT OR UPDATE OR DELETE ON emp
    FOR EACH ROW EXECUTE PROCEDURE processa_emp_audit();

INSERT INTO emp (nome_emp, salario) VALUES ('João',1000);
INSERT INTO emp (nome_emp, salario) VALUES ('José',1500);
INSERT INTO emp (nome_emp, salario) VALUES ('Maria',250);
UPDATE emp SET salario = 2500 WHERE nome_emp = 'Maria';
DELETE FROM emp WHERE nome_emp = 'João';

SELECT * FROM emp;

SELECT * FROM emp_audit;
