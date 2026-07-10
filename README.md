# gestion-hospital-sql — Sistema de gestión hospitalaria

![MySQL](https://img.shields.io/badge/MySQL-4479A1?logo=mysql&logoColor=white)
![Java](https://img.shields.io/badge/Java-ED8B00?logo=openjdk&logoColor=white)
![Maven](https://img.shields.io/badge/Maven-C71A36?logo=apachemaven&logoColor=white)

Diseño e implementación de una **base de datos relacional** para la gestión de
un hospital, desde el modelo conceptual hasta la explotación con SQL y una
aplicación Java que carga datos desde ficheros CSV y XML.

## Contenido

- **`modelo-entidad-relacion/`** — modelo entidad-relación y su paso a tablas (diagramas SVG).
- **`consultas-sql/`** — script de creación de la base de datos, inserción de datos y consultas SQL.
- **`cargador-java-csv-xml/`** — programa Java (Maven + JDBC) que importa datos desde CSV y XML a MySQL.

## Qué demuestra

- **Modelado de datos** (E-R) y normalización a tablas.
- **SQL**: DDL, DML y consultas con `JOIN`, agregados y vistas.
- Conexión **Java–MySQL con JDBC** y lectura de fuentes CSV/XML.

## Configuración

El cargador Java **no contiene credenciales**; se leen de variables de entorno:

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

## Autoría

Desarrollado por **Carlos Gómez Moreno** ([@carluscoooo](https://github.com/carluscoooo)).
