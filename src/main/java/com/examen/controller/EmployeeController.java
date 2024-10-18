package com.examen.controller;

import com.examen.request.EmployeeRequest;
import com.examen.service.EmployeeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@Slf4j
@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    private final EmployeeService service;

    public EmployeeController (EmployeeService service) {
        this.service = service;
    }

    @PostMapping
    public ResponseEntity<Long> createEmployee(@RequestBody EmployeeRequest request) {
        log.info("Entró al método createEmployee {}", request);
        Long employeeId = this.service.createEmployee(request);
        return ResponseEntity.ok(employeeId);
    }
}
