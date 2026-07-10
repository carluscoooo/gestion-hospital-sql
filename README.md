# gestion-hospital-sql — Sistema de gestión hospitalaria

![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?logo=openjdk&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?logo=apachemaven&logoColor=white)

Diseño e implementación de una **base de datos relacional** para la gestión de un
hospital, cubriendo el flujo completo: del modelo conceptual a su explotación con
SQL y a una aplicación Java que carga datos automáticamente desde ficheros CSV y XML.

## Contenido

- **`modelo-entidad-relacion/`** — modelo entidad-relación y su paso a tablas (diagramas SVG).
- **`consultas-sql/`** — creación de la base de datos, inserción de datos y consultas.
- **`cargador-java-csv-xml/`** — programa Java (Maven + JDBC) que importa datos desde CSV y XML a MySQL.

## Competencias que pone en práctica

- **Modelado de datos** (entidad-relación) y normalización a tablas.
- **SQL**: DDL, DML y consultas con `JOIN`, agregados y vistas.
- Integración **Java–MySQL con JDBC** y lectura de fuentes CSV/XML.
- Buenas prácticas: **credenciales fuera del código**, mediante variables de entorno.

## Configuración

```bash
export DB_USER=tu_usuario
export DB_PASSWORD=tu_contraseña
```

En los scripts SQL, sustituye `TU_CONTRASEÑA` por la contraseña del usuario `consultor`.

## Ejecución

```bash
# 1) Crear la BBDD e insertar datos
mysql -u root -p < consultas-sql/crear-base-de-datos.sql
mysql -u root -p < consultas-sql/insertar-datos.sql

# 2) Ejecutar el cargador Java
cd cargador-java-csv-xml
mvn package
```

## Autor

**Carlos Gómez Moreno** — [@carluscoooo](https://github.com/carluscoooo)
