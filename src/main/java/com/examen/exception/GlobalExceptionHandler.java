package com.examen.exception;

import com.examen.response.ErrorResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.context.request.WebRequest;

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

    private ResponseEntity<ErrorResponse> buildError(String message, HttpStatusCode status) {
        ErrorResponse error = ErrorResponse.builder()
                .message(message)
                .success(Boolean.FALSE)
                .build();
        return new ResponseEntity<>(error, status);
    }
}
