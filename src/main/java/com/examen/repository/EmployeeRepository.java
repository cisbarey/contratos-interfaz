package com.examen.repository;

import com.examen.exception.EmployeeException;
import com.examen.exception.GenderException;
import com.examen.exception.JobException;
import com.examen.exception.RepositoryException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.UncategorizedSQLException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.util.Objects;

@Slf4j
@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository (JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Long insertEmployee(String name, String lastName, Date birthdate, Long genderId, Long jobId) {
        try {
            return this.jdbcTemplate.execute((Connection conn) -> {
                CallableStatement callableStatement = conn.prepareCall("{? = call EMPLOYEE_PKG.FN_01_EMPLOYEE(?, ?, ?, ?, ?)}");
                callableStatement.registerOutParameter(1, Types.NUMERIC);
                callableStatement.setString(2, name);
                callableStatement.setString(3, lastName);
                callableStatement.setDate(4, birthdate);
                callableStatement.setLong(5, genderId);
                callableStatement.setLong(6, jobId);

                callableStatement.execute();
                return callableStatement.getLong(1);
            });
        } catch (UncategorizedSQLException e) {
            int errorCode = Objects.requireNonNull(e.getSQLException()).getErrorCode();
            switch (errorCode) {
                case 20001:
                    throw new EmployeeException("El empleado ya existe");
                case 20002:
                    throw new GenderException("El género no existe");
                case 20003:
                    throw new JobException("El puesto no existe");
                default:
                    throw new RepositoryException("Ocurrió un error al ejecutar el paquete");
            }
        }
    }
}
