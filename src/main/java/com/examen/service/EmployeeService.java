package com.examen.service;

import com.examen.repository.EmployeeRepository;
import com.examen.request.EmployeeRequest;
import com.examen.request.EmployeeWorkedHourRequest;
import com.examen.util.DateUtil;
import org.springframework.stereotype.Service;

import java.sql.Date;

@Service
public class EmployeeService {

    private final EmployeeRepository repository;

    public EmployeeService (EmployeeRepository repository) {
        this.repository = repository;
    }

    public Long createEmployee(EmployeeRequest request) {
        Date birthdate = DateUtil.validateAndConvertDate(request.birthdate());
        return this.repository.insertEmployee(
                request.name(),
                request.lastName(),
                birthdate,
                request.genderId(),
                request.jobId()
        );
    }

    public Long createEmployeeWorkedHour(EmployeeWorkedHourRequest request) {
        Date workedDate = DateUtil.validateAndConvertDate(request.workedDate());
        return this.repository.insertEmployeeWorkedHour(
                request.employeeId(),
                request.workedHours(),
                workedDate
        );
    }
}
