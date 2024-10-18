package com.examen.request;

import java.time.LocalDate;

public record EmployeeRequest(
        Long genderId,
        Long jobId,
        String name,
        String lastName,
        String birthdate
) {
}
