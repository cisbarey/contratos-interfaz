package com.examen.repository;

import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.sql.*;

@Slf4j
@Repository
public class EmployeeRepository {

    private final JdbcTemplate jdbcTemplate;

    public EmployeeRepository (JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Long insertEmployee(String name, String lastName, Date birthdate, Long genderId, Long jobId) {
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
    }

    public Long insertEmployeeWorkedHour(Long employeeId, Long workedHours, Date workedDate) {
        return this.jdbcTemplate.execute((Connection conn) -> {
            CallableStatement callableStatement = conn.prepareCall("{? = call EMPLOYEE_PKG.FN_02_EMPLOYEE(?, ?, ?)}");
            callableStatement.registerOutParameter(1, Types.NUMERIC);
            callableStatement.setLong(2, employeeId);
            callableStatement.setLong(3, workedHours);
            callableStatement.setDate(4, workedDate);

            callableStatement.execute();
            return callableStatement.getLong(1);
        });
    }
}
