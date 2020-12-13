/*
Autor: Dirson S Campos
 Procedimento do tipo trigger (gatilho) em PL/pgSQL
A trigger garante que quando é inserida ou atualizada uma linha na tabela, 
fica sempre registrado nesta linha o usuário que efetuou a inserção ou a atualização, e quando isto ocorreu. 
Além disso, o gatilho verifica se é fornecido o nome do empregado, e se o valor do salário é um número positivo.
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
