package com.examen.request;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EmployeeWorkedHourRequest(
        @JsonProperty("employee_id") Long employeeId,
        @JsonProperty("worked_hours") Long workedHours,
        @JsonProperty("worked_date") String workedDate
) {
}
