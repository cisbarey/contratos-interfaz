package com.examen.util;

import com.examen.exception.DateException;

import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

public class DateUtil {

    public static Date validateAndConvertDate(String dateStr) throws DateException {
        SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
        dateFormat.setLenient(false);

        try {
            java.util.Date parsedDate = dateFormat.parse(dateStr);
            return new Date(parsedDate.getTime());
        } catch (ParseException e) {
            throw new DateException("Fecha inválida");
        }
    }
}
