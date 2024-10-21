package com.examen.request;

import com.fasterxml.jackson.annotation.JsonProperty;

public record EmployeeRequest(
        @JsonProperty("gender_id") Long genderId,
        @JsonProperty("job_id") Long jobId,
        @JsonProperty("name") String name,
        @JsonProperty("last_name") String lastName,
        @JsonProperty("birthdate") String birthdate
) {}
