package com.examen.exception;

import com.examen.response.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.UncategorizedSQLException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

import java.util.Objects;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(DateException.class)
    public ResponseEntity<?> handleUserNotFoundException(DateException ex, WebRequest request) {
        return this.buildError(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(EmployeeException.class)
    public ResponseEntity<?> handleUserNotFoundException(EmployeeException ex, WebRequest request) {
        return this.buildError(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(GenderException.class)
    public ResponseEntity<?> handleUserNotFoundException(GenderException ex, WebRequest request) {
        return this.buildError(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(JobException.class)
    public ResponseEntity<?> handleUserNotFoundException(JobException ex, WebRequest request) {
        return this.buildError(ex.getMessage(), HttpStatus.BAD_REQUEST);
    }

    @ExceptionHandler(UncategorizedSQLException.class)
    public ResponseEntity<ErrorResponse> handleUncategorizedSQLException(UncategorizedSQLException ex, WebRequest request) {
        int errorCode = Objects.requireNonNull(ex.getSQLException()).getErrorCode();
        return switch (errorCode) {
            case 20001 -> this.buildError("El empleado ya existe", HttpStatus.BAD_REQUEST);
            case 20002 -> this.buildError("El género no existe", HttpStatus.BAD_REQUEST);
            case 20003 -> this.buildError("El puesto no existe", HttpStatus.BAD_REQUEST);
            case 20004 -> this.buildError("El empleado debe ser mayor de edad.", HttpStatus.BAD_REQUEST);
            case 20005 -> this.buildError("El empleado no existe", HttpStatus.BAD_REQUEST);
            case 20006 -> this.buildError("Las horas trabajadas no pueden exceder 20 horas por día", HttpStatus.BAD_REQUEST);
            case 20007 -> this.buildError("La fecha de trabajo no puede ser mayor a la fecha actual", HttpStatus.BAD_REQUEST);
            case 20008 -> this.buildError("Ya existe un registro de horas trabajadas para este empleado en esta fecha", HttpStatus.BAD_REQUEST);
            default -> this.buildError("Ocurrió un error al ejecutar el paquete", HttpStatus.INTERNAL_SERVER_ERROR);
        };
    }

    private ResponseEntity<ErrorResponse> buildError(String message, HttpStatusCode status) {
        ErrorResponse error = ErrorResponse.builder()
                .message(message)
                .success(Boolean.FALSE)
                .build();
        return new ResponseEntity<>(error, status);
    }
}
