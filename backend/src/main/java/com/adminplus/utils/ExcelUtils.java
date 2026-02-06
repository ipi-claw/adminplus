package com.adminplus.utils;

import jakarta.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.OutputStream;
import java.lang.reflect.Field;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.List;

/**
 * Excel 工具类
 *
 * @author AdminPlus
 * @since 2026-02-06
 */
public class ExcelUtils {

    /**
     * 导出 Excel
     */
    public static <T> void exportExcel(HttpServletResponse response, List<T> data, String fileName, Class<T> clazz) throws IOException {
        try (Workbook workbook = new XSSFWorkbook()) {
            Sheet sheet = workbook.createSheet("Sheet1");

            // 获取字段列表
            Field[] fields = clazz.getDeclaredFields();
            List<String> headers = new ArrayList<>();
            for (Field field : fields) {
                headers.add(field.getName());
            }

            // 创建表头
            Row headerRow = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);

            for (int i = 0; i < headers.size(); i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers.get(i));
                cell.setCellStyle(headerStyle);
            }

            // 填充数据
            for (int i = 0; i < data.size(); i++) {
                Row row = sheet.createRow(i + 1);
                T item = data.get(i);

                for (int j = 0; j < fields.length; j++) {
                    try {
                        fields[j].setAccessible(true);
                        Object value = fields[j].get(item);
                        Cell cell = row.createCell(j);
                        if (value != null) {
                            cell.setCellValue(value.toString());
                        }
                    } catch (IllegalAccessException e) {
                        // 忽略无法访问的字段
                    }
                }
            }

            // 设置响应头
            response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
            response.setCharacterEncoding("utf-8");
            String encodedFileName = URLEncoder.encode(fileName + ".xlsx", StandardCharsets.UTF_8)
                    .replaceAll("\\+", "%20");
            response.setHeader("Content-disposition", "attachment;filename*=utf-8''" + encodedFileName);

            // 写入输出流
            try (OutputStream out = response.getOutputStream()) {
                workbook.write(out);
            }
        }
    }

    /**
     * 导入 Excel
     */
    public static <T> List<T> importExcel(MultipartFile file, Class<T> clazz) throws IOException {
        List<T> result = new ArrayList<>();

        try (Workbook workbook = new XSSFWorkbook(file.getInputStream())) {
            Sheet sheet = workbook.getSheetAt(0);
            Field[] fields = clazz.getDeclaredFields();

            // 从第二行开始读取（第一行是表头）
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                Row row = sheet.getRow(i);
                if (row == null) continue;

                try {
                    T instance = clazz.getDeclaredConstructor().newInstance();

                    for (int j = 0; j < fields.length && j < row.getLastCellNum(); j++) {
                        Cell cell = row.getCell(j);
                        if (cell != null) {
                            fields[j].setAccessible(true);
                            String value = getCellValueAsString(cell);
                            setFieldValue(instance, fields[j], value);
                        }
                    }

                    result.add(instance);
                } catch (Exception e) {
                    // 忽略行解析错误
                }
            }
        }

        return result;
    }

    /**
     * 获取单元格值
     */
    private static String getCellValueAsString(Cell cell) {
        return switch (cell.getCellType()) {
            case STRING -> cell.getStringCellValue();
            case NUMERIC -> String.valueOf(cell.getNumericCellValue());
            case BOOLEAN -> String.valueOf(cell.getBooleanCellValue());
            case FORMULA -> cell.getCellFormula();
            default -> "";
        };
    }

    /**
     * 设置字段值
     */
    private static void setFieldValue(Object instance, Field field, String value) throws IllegalAccessException {
        try {
            Class<?> type = field.getType();
            if (type == String.class) {
                field.set(instance, value);
            } else if (type == Integer.class || type == int.class) {
                field.set(instance, Integer.parseInt(value));
            } else if (type == Long.class || type == long.class) {
                field.set(instance, Long.parseLong(value));
            } else if (type == Double.class || type == double.class) {
                field.set(instance, Double.parseDouble(value));
            } else if (type == Boolean.class || type == boolean.class) {
                field.set(instance, Boolean.parseBoolean(value));
            }
        } catch (NumberFormatException e) {
            // 忽略数字转换错误
        }
    }
}