-- Crear la secuencia SEQ_EMPLOYEES
CREATE SEQUENCE SEQ_EMPLOYEES
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

-- Crear la tabla EMPLOYEE_WORKED_HOURS
CREATE TABLE employee_worked_hours (
    id NUMBER(10, 0) PRIMARY KEY,
    employee_id NUMBER(10, 0) NOT NULL,
    worked_hours NUMBER(10, 0) NOT NULL,
    worked_date DATE NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(id)
);

-- Crear el paquete EMPLOYEE_PKG
CREATE OR REPLACE PACKAGE EMPLOYEE_PKG AS
    FUNCTION FN_01_EMPLOYEE(
        p_name      IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_birthdate IN DATE,
        p_gender_id IN NUMBER,
        p_job_id    IN NUMBER
    ) RETURN NUMBER; -- Devuelve el ID del empleado insertado
END EMPLOYEE_PKG;
/


-- Crear el cuerpo del paquete EMPLOYEE_PKG
CREATE OR REPLACE PACKAGE BODY EMPLOYEE_PKG AS

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
        FROM employees e
        WHERE e.name = p_name AND e.last_name = p_last_name;

        IF v_count > 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'El empleado ya existe.');
        END IF;

        -- Validar que el género exista
        SELECT COUNT(*) INTO v_count
        FROM genders g
        WHERE g.id = p_gender_id;

        IF v_count = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'El género no existe.');
        END IF;

        -- Validar que el puesto exista
        SELECT COUNT(*) INTO v_count
        FROM jobs j
        WHERE j.id = p_job_id;

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

END EMPLOYEE_PKG;
/


-- Inserts para la tabla GENDERS
INSERT INTO genders (id, name) VALUES (1, 'Masculino');
INSERT INTO genders (id, name) VALUES (2, 'Femenino');

-- Inserts para la tabla JOBS
INSERT INTO jobs (id, name, salary) VALUES (1, 'Developer', 70000);
INSERT INTO jobs (id, name, salary) VALUES (2, 'Project Manager', 90000);
INSERT INTO jobs (id, name, salary) VALUES (3, 'Business Analyst', 80000);