-- Crear la secuencia SEQ_EMPLOYEES
CREATE SEQUENCE SEQ_EMPLOYEES
    START WITH 1 -- Comienza desde 1
    INCREMENT BY 1 -- Incrementa de 1 en 1
    NOCACHE; -- No usa caché
-- Crear la secuencia SEQ_EMPLOYEE_WORKED_HOURS
CREATE SEQUENCE SEQ_EMPLOYEE_WORKED_HOURS
    START WITH 1 -- Comienza desde 1
    INCREMENT BY 1 -- Incrementa de 1 en 1
    NOCACHE; -- No usa caché

-- Crear la tabla GENDERS
CREATE TABLE genders (
    id NUMBER(10, 0) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL
);

-- Crear la tabla JOBS
CREATE TABLE jobs (
    id NUMBER(10, 0) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    salary NUMBER(9, 2) NOT NULL
);

-- Crear la tabla EMPLOYEES
CREATE TABLE employees (
    id NUMBER(10, 0) PRIMARY KEY,
    name VARCHAR2(255) NOT NULL,
    last_name VARCHAR2(255) NOT NULL,
    birthdate DATE NOT NULL,
    gender_id NUMBER(10, 0) NOT NULL,
    job_id NUMBER(10, 0) NOT NULL,
    FOREIGN KEY (gender_id) REFERENCES genders(id),
    FOREIGN KEY (job_id) REFERENCES jobs(id)
);

-- Crear el trigger para usar la secuencia en la tabla EMPLOYEES
CREATE OR REPLACE TRIGGER trg_employees_id
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
    :NEW.id := SEQ_EMPLOYEES.NEXTVAL; -- Asigna el siguiente valor de la secuencia
END;
/

-- Crear el trigger para usar la secuencia en la tabla EMPLOYEE_WORKED_HOURS
CREATE OR REPLACE TRIGGER trg_employee_worked_hours_id
BEFORE INSERT ON employee_worked_hours
FOR EACH ROW
BEGIN
    :NEW.id := SEQ_EMPLOYEE_WORKED_HOURS.NEXTVAL; -- Asigna el siguiente valor de la secuencia
END;
/

-- Crear la tabla EMPLOYEE_WORKED_HOURS
CREATE TABLE employee_worked_hours (
    id NUMBER(10, 0) PRIMARY KEY,
    employee_id NUMBER(10, 0) NOT NULL,
    worked_hours NUMBER(10, 0) NOT NULL,
    worked_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);


-- Inserts para la tabla GENDERS
INSERT INTO genders (id, name) VALUES (1, 'Masculino');
INSERT INTO genders (id, name) VALUES (2, 'Femenino');

-- Inserts para la tabla JOBS
INSERT INTO jobs (id, name, salary) VALUES (1, 'Developer', 70000);
INSERT INTO jobs (id, name, salary) VALUES (2, 'Project Manager', 90000);
INSERT INTO jobs (id, name, salary) VALUES (3, 'Business Analyst', 80000);

-- Crear el paquete EMPLOYEE_PKG
CREATE OR REPLACE PACKAGE EMPLOYEE_PKG AS
	-- ################################################ Función 1 ######################################################
    FUNCTION FN_01_EMPLOYEE(
        p_name      IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_birthdate IN DATE,
        p_gender_id IN NUMBER,
        p_job_id    IN NUMBER
    ) RETURN NUMBER; -- Devuelve el ID del empleado insertado
	
	-- ################################################ Función 2 ######################################################
	FUNCTION FN_02_EMPLOYEE(
        p_employee_id  IN NUMBER,
        p_worked_hours IN NUMBER,
        p_worked_date  IN DATE
    ) RETURN NUMBER;
END EMPLOYEE_PKG;
/


create or replace NONEDITIONABLE PACKAGE BODY EMPLOYEE_PKG AS

	-- ################################################ Función 1 ######################################################
    FUNCTION FN_01_EMPLOYEE(
        p_name      IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_birthdate IN DATE,
        p_gender_id IN NUMBER,
        p_job_id    IN NUMBER
    ) RETURN NUMBER IS
        v_employee_id NUMBER;
        v_count NUMBER;
        v_age NUMBER;
    BEGIN
        -- Validar que el nombre y apellido no existan
        SELECT COUNT(*) INTO v_count
        FROM employees emp
        WHERE emp.name = p_name AND emp.last_name = p_last_name;

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El empleado ya existe.');
        END IF;

        -- Validar que el género exista
        SELECT COUNT(*) INTO v_count
        FROM genders gen
        WHERE gen.id = p_gender_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El género no existe.');
        END IF;

        -- Validar que el puesto exista
        SELECT COUNT(*) INTO v_count
        FROM jobs job
        WHERE job.id = p_job_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20003, 'El puesto no existe.');
        END IF;

        -- Calcular la edad
        v_age := FLOOR(MONTHS_BETWEEN(SYSDATE, p_birthdate) / 12);

        IF v_age < 18 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El empleado debe ser mayor de edad.');
        END IF;

        -- Si todas las validaciones pasan, insertar el empleado
        INSERT INTO employees (name, last_name, birthdate, gender_id, job_id)
        VALUES (p_name, p_last_name, p_birthdate, p_gender_id, p_job_id)
        RETURNING id INTO v_employee_id;

        RETURN v_employee_id; -- Devuelve el ID del nuevo empleado
    END FN_01_EMPLOYEE;

	-- ################################################ Función 2 ######################################################
	FUNCTION FN_02_EMPLOYEE(
        p_employee_id  IN NUMBER,
        p_worked_hours IN NUMBER,
        p_worked_date  IN DATE
    ) RETURN NUMBER IS
        v_worked_hours_id NUMBER;
        v_employee_exists NUMBER;
        v_total_hours NUMBER;
    BEGIN
        -- Validar si el empleado existe
        SELECT COUNT(1)
        INTO v_employee_exists
        FROM employees emp
        WHERE emp.id = p_employee_id;

        IF v_employee_exists = 0 THEN
            RAISE_APPLICATION_ERROR(-20004, 'El empleado no existe');
        END IF;

        -- Validar que las horas trabajadas no excedan 20 horas por día
        IF p_worked_hours > 20 THEN
            RAISE_APPLICATION_ERROR(-20005, 'Las horas trabajadas no pueden exceder 20 horas por día');
        END IF;

        -- Validar que la fecha de trabajo no sea mayor a la fecha actual
        IF p_worked_date > SYSDATE THEN
            RAISE_APPLICATION_ERROR(-20006, 'La fecha de trabajo no puede ser mayor a la fecha actual');
        END IF;

        -- Validar que no haya un registro duplicado para el mismo empleado en la misma fecha
        SELECT COUNT(1)
        INTO v_total_hours
        FROM employee_worked_hours ewh
        WHERE ewh.employee_id = p_employee_id
        AND ewh.worked_date = p_worked_date;

        IF v_total_hours > 0 THEN
            RAISE_APPLICATION_ERROR(-20007, 'Ya existe un registro de horas trabajadas para este empleado en esta fecha');
        END IF;

        -- Insertar las horas trabajadas en la tabla employee_worked_hours
        INSERT INTO employee_worked_hours (employee_id, worked_hours, worked_date)
        VALUES (p_employee_id, p_worked_hours, p_worked_date)
        RETURNING id INTO v_worked_hours_id;

        -- Retornar el ID del registro insertado
        RETURN v_worked_hours_id;
    END FN_02_EMPLOYEE;

END EMPLOYEE_PKG;
