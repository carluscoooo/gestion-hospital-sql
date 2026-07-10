package upm.etsisi;

import org.w3c.dom.Document;
import org.w3c.dom.Element;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.*;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.sql.*;

public class LoadDriverXML {
    private static String USERNAME = System.getenv("DB_USER"); // definir en variable de entorno
    private static String PASSWORD = System.getenv("DB_PASSWORD"); // definir en variable de entorno
    private static String DESTINO  = "hospital_management_system"; //bbdd a usar en la consulta
    private static String sql = "SELECT NombrePaciente, Medicamento, code, brand, date, NombreDoctor " +
            "FROM getDatosPaciente WHERE NombrePaciente = ?";


    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
        } catch (Exception ex) {
            System.out.println("Error, no se ha podido encontrar el driver necesario");
        }


        Connection conn = null;
        try {
            conn = DriverManager.getConnection(
                    "jdbc:mysql://127.0.0.1:3307/" + DESTINO,
                    USERNAME,
                    PASSWORD
            );
        } catch (SQLException ex) {
            System.out.println("Error, no se ha podido conectar a la base de datos ");
        }

        try {
            PreparedStatement stmt = conn.prepareStatement(sql);
            stmt.setString(1, "John Smith"); //Aqui cambiar el nombre del paciente para buscar otro paciente
            ResultSet rs = stmt.executeQuery();

            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();
            Document doc = builder.newDocument();

            Element root = doc.createElement("Preinscripciones");
            doc.appendChild(root);

            String[] campos = {"NombrePaciente", "Medicamento", "code", "brand", "date", "NombreDoctor"};

            while (rs.next()) {
                Element prescripcion = doc.createElement("Preiscripcion");

                for (String columnas : campos) {
                    Element e = doc.createElement(columnas);
                    e.appendChild(doc.createTextNode(rs.getString(columnas)));
                    prescripcion.appendChild(e);
                }

                root.appendChild(prescripcion);
            }
            TransformerFactory transformerFactory = TransformerFactory.newInstance();
            Transformer transformer = transformerFactory.newTransformer();
            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
            transformer.setOutputProperty("{http://xml.apache.org/xslt}indent-amount", "2");
            transformer.transform(new DOMSource(doc), new StreamResult("Preinscripciones.xml"));

            rs.close();
            stmt.close();
            conn.close();

            System.out.println("Archivo xml generado con exito. -> " +root.getTagName());
        } catch(Exception e) {
            e.getMessage();
        }
    }
}