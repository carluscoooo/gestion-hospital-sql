package upm.etsisi;

import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class LoadDriverCSV {
    private static String USERNAME = System.getenv("DB_USER"); // definir en variable de entorno
    private static String PASSWORD = System.getenv("DB_PASSWORD"); // definir en variable de entorno
    private static String DESTINO  = "hospital_management_system"; //bbdd a usar en la consulta
    private static String sql = "SELECT NombrePaciente, Medicamento, code, brand, date, NombreDoctor " +
            "FROM getDatosPaciente WHERE NombrePaciente = ? "; //Consulta SQL

    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
            System.out.println("Driver cargado correctamente");
        } catch (Exception ex) {
            System.out.println("Error, no se ha podido encontrar el driver necesario");
        }

        Connection conn = null;
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3307/" + DESTINO,
                    USERNAME,
                    PASSWORD
            );
            System.out.println("Conectado a la bbdd " + DESTINO + ", usuario: " +USERNAME);
        } catch (SQLException ex) {
            System.out.println("Error, no se ha podido conectar a la base de datos ");
        }

        try{
            List<String> datosCSV = conversorCSV(conn);
            String nombreArchivo = "preinscripciones.csv";
            FileWriter archivo = new FileWriter(nombreArchivo, true);
            PrintWriter escribir = new PrintWriter(archivo);
            for(String nombre : datosCSV) {
                if(nombre != null){
                    escribir.println(nombre);}
                else{
                    escribir.println("-");
                }
            }
            escribir.close();
            System.out.println("Fichero .csv creado con exito -> " + nombreArchivo);
        }catch (IOException exe) {
            System.out.println("No se pudo crear el archivo .csv");
        } catch (SQLException e) {
            throw new RuntimeException(e);
        }

    }

    static List<String> conversorCSV(Connection connection) throws SQLException {
        List<String> csvDatos = new ArrayList<>();
        PreparedStatement preparedStatement = connection.prepareStatement(sql);
        System.out.println("Introduce nombre del paciente a buscar");
        Scanner scanner = new Scanner(System.in);
        String paciente = scanner.nextLine();
        preparedStatement.setString(1, paciente);
        ResultSet resultSet = preparedStatement.executeQuery();
        while(resultSet.next()) {
            String dato = formatoCSV(resultSet.getString("NombrePaciente"))+
                    ","+formatoCSV(resultSet.getString("Medicamento"))+
                    "," +formatoCSV(resultSet.getString("code"))+
                    ","+formatoCSV(resultSet.getString("brand"))+
                    ","+formatoCSV(resultSet.getString("date"))+
                    ","+formatoCSV(resultSet.getString("NombreDoctor"))
                    ;

            csvDatos.add(dato);
        }
        return csvDatos;
    }


    private static String formatoCSV(String value) {
        if(value == null){
            return "\"-\"";
        }
        return "\"" + value
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\"", "\"\"")
                + "\"";
    }

}