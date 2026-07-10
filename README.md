# Sistema de gestión hospitalaria (SQL + Java)

Diseño y explotación de una base de datos para la gestión de un hospital.

## Contenido
- **modelo-entidad-relacion** — modelo E-R y su paso a tablas (SVG).
- **consultas-sql** — creación de la BBDD, inserción de datos y consultas.
- **cargador-java-csv-xml** — programa Java (Maven) que carga datos desde CSV y XML.

## Configuración
El cargador Java no contiene credenciales; se definen por variable de entorno:

```bash
export DB_USER=tu_usuario
export DB_PASSWORD=tu_contraseña
```

En los scripts SQL, sustituye `TU_CONTRASEÑA` por la que quieras.

## Autor
Carlos Gómez Moreno
