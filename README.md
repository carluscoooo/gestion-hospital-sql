# Base de Datos — Sistema de gestión hospitalaria

Práctica de **Bases de Datos**: diseño y explotación de una base de datos
para la gestión de un hospital. Dividida en tres apartados.

## Contenido

1. **1-modelo-entidad-relacion/** — modelo E-R y su paso a tablas (SVG).
2. **2-consultas-sql/** — script de creación de la BBDD, inserción de datos y consultas SQL.
3. **3-cargador-java/** — programa Java que carga datos desde CSV y XML a la
   base de datos (Maven).

## Configuración (importante)

El cargador Java **no** contiene credenciales. Debes definirlas como
variables de entorno antes de ejecutarlo:

```bash
export DB_USER=tu_usuario
export DB_PASSWORD=tu_contraseña
```

En los scripts SQL, sustituye `TU_CONTRASEÑA` por la contraseña que quieras
para el usuario `consultor`.

## Autor
Carlos Gómez Moreno
