
/*a) Usando los ficheros hospital tables.sql y hospital data.sql disponibles en Moodle,
crear la base de datos hospital management system y cargar todos los datos disponibles
que van a ser objeto de procesos en puntos posteriores.*/

# HECHO

/*b) Resolver en SQL la consulta: Obtener el nombres de los doctores, los medicamentos y 
la fecha de prescripcion de los mismos de aquellos doctores que estan afiliados al departamento
de “General Medicine” y que han recetado algun medicamento en el ano 2023 o 2024.*/

SELECT physician.name, medication.name, prescribes.date
FROM physician 
    INNER JOIN affiliated_with  ON physician.employeeid = affiliated_with.physicianid
    INNER JOIN department ON affiliated_with.departmentid = department.departmentid
    INNER JOIN prescribes ON physician.employeeid = prescribes.physicianid
    INNER JOIN medication ON prescribes.medicationid = medication.code
WHERE department.name = 'General Medicine'
    AND (prescribes.date LIKE '%2023' OR prescribes.date LIKE '%2024');

/*c) Resolver en SQL la consulta: Obtener el nombre del paciente con el ingreso mas largo y el
paciente con el ingreso mas corto en el hospital, mostrando para cada uno su nombre, el 
numero de habitacion donde estuvo ingresado, ası como el piso y bloque de la misma, la
duracion de la estancia en dıas y el tipo de estancia (mas largo o mas corto).*/

(SELECT p.name AS Paciente, r.roomnumber AS NumeroHabitacion, r.blockfloorid AS PlantaBloque, 
    r.blockcodeid AS CodigoBloque, DATEDIFF(STR_TO_DATE(s.end_time, '%d/%m/%Y'), 
                                            STR_TO_DATE(s.start_time, '%d/%m/%Y')
                                            ) AS EstanciaEnDias, 'Larga estancia' AS TipoEstancia
FROM patient p
    JOIN stay s ON s.patientid = p.ssn
    JOIN room r ON r.roomnumber = s.roomid
GROUP BY p.name, r.roomnumber, r.blockfloorid, r.blockcodeid, EstanciaEnDias, TipoEstancia
ORDER BY EstanciaEnDias DESC LIMIT 1)
UNION
(SELECT p.name AS Paciente, r.roomnumber AS NumeroHabitacion, r.blockfloorid AS PlantaBloque, 
    r.blockcodeid AS CodigoBloque, DATEDIFF(STR_TO_DATE(s.end_time, '%d/%m/%Y'), 
                                            STR_TO_DATE(s.start_time, '%d/%m/%Y')
                                            ) AS EstanciaEnDias, 'Corta estancia' AS TipoEstancia
FROM patient p
    JOIN stay s ON s.patientid = p.ssn
    JOIN room r ON r.roomnumber = s.roomid
GROUP BY p.name, r.roomnumber, r.blockfloorid, r.blockcodeid, EstanciaEnDias, TipoEstancia
ORDER BY EstanciaEnDias ASC LIMIT 1);

/*d) Resolver en SQL la consulta: Actualizar la descripcion de los medicamentos agregando la
nota de “Possible discontinuation” (posible descatalogacion) a aquellos que no han sido rece-
tados durante los ultimos dos anos por doctores pertenecientes al departamento de “General 
Medicine”, evitando ademas incluir aquellos que ya contengan dicha advertencia en su des-
cripcion actual.*/

SET SQL_SAFE_UPDATES = 0;

UPDATE medication
SET description = CONCAT(description, ' - Possible discontinuation')
WHERE code NOT IN (
    SELECT DISTINCT p.medicationid
    FROM prescribes p
        JOIN affiliated_with a ON p.physicianid = a.physicianid
        JOIN department d ON a.departmentid = d.departmentid
    WHERE d.name = 'General Medicine'
    AND a.primary_affiliation = 't'
    AND STR_TO_DATE(p.date, '%d/%m/%Y') >= DATE_SUB(CURDATE(), INTERVAL 2 YEAR)
)
AND description NOT LIKE '%Possible discontinuation%';

SET SQL_SAFE_UPDATES = 1;

# PRUEBAS CONSULTA D :
# Mirar cambios en medicamentos no recetados recientemente 
SELECT * FROM medication;

/*e) Resolver en SQL la consulta: Obtener un listado detallado de los doctores del hospital, 
mostrando para cada uno su nombre, el numero total de procedimientos realizados, el coste total
de dichos procedimientos y el coste promedio por procedimiento. Los resultados deben estar
ordenados de mayor a menor segun el numero de procedimientos realizados.*/

SELECT physician.name, COUNT(undergoes.procedureid) AS Total_Procedimientos,
 SUM(medical_procedure.cost) AS Coste_Total, AVG(medical_procedure.cost) AS Coste_Promedio
FROM physician 
    INNER JOIN undergoes ON physician.employeeid = undergoes.physicianid
    INNER JOIN medical_procedure ON undergoes.procedureid = medical_procedure.code
GROUP BY physician.employeeid, physician.name
ORDER BY Total_Procedimientos DESC;

/*f) Resolver en SQL la consulta: Obtener los doctores (nombre y posicion) que han realizado ´
todos los procedimientos medicos con coste superior a 5000 y que haya realizado mas de 3 ´
procedimientos medicos de cualquiera de los tipos en total.*/

SELECT ph.name AS Nombre, ph.position AS Posicion
FROM physician ph
WHERE
    (SELECT COUNT(DISTINCT u.procedureid)
    FROM undergoes u
    WHERE u.physicianid = ph.employeeid) > 3
    
    AND NOT EXISTS(
                    SELECT * FROM medical_procedure mp
                    WHERE mp.cost > 5000
                    AND NOT EXISTS (
                                    SELECT *
                                    FROM undergoes u
                                    WHERE u.procedureid = mp.code
                                    AND u.physicianid = ph.employeeid
                    )
);

/*g) Resolver en SQL la consulta: Obtener el personal de enfermerıa que siempre han estado
asignadas a turnos en el mismo sitio (bloque y piso) y que ademas, si han participado en
procedimientos medicos, siempre haya sido con el mismo doctores.*/

SELECT nurse.employeeid, nurse.name
FROM nurse
JOIN on_call ON nurse.employeeid = on_call.nurseid
GROUP BY nurse.employeeid, nurse.name
HAVING COUNT(DISTINCT on_call.blockfloorid, on_call.blockcodeid) = 1
   AND nurse.employeeid NOT IN (
       SELECT undergoes.assistingnurseid
       FROM undergoes
       WHERE undergoes.assistingnurseid IS NOT NULL
       GROUP BY undergoes.assistingnurseid
       HAVING COUNT(DISTINCT undergoes.physicianid) > 1
   );

/*h) Resolver en SQL la consulta: Obtener para cada medicamento (codigo y nombre) el numero
total de veces que ha sido prescrito, el nombre del doctor que mas lo ha recetado (si existen
empates mostrar todos los doctores empatados), y la dosis promedio recetada. Ordenar los
resultados de mayor a menor segun el numero total de prescripciones. Tener en cuenta que
si existen empates entre los doctores se tienen que mostrar todos los doctores, cada uno en
una fila distinta.*/

SELECT medication.code, medication.name, 
   (SELECT COUNT(*) FROM prescribes WHERE prescribes.medicationid = medication.code) AS total_prescrito,
    physician.name AS Nombre_Doctor, (SELECT AVG(dose) FROM prescribes WHERE prescribes.medicationid = medication.code) AS dosis_promedio
FROM medication 
    INNER JOIN prescribes ON medication.code = prescribes.medicationid
    INNER JOIN physician ON prescribes.physicianid = physician.employeeid
GROUP BY medication.code, medication.name, physician.name
HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                        FROM prescribes
                        WHERE prescribes.medicationid = medication.code
                        GROUP BY prescribes.physicianid)
ORDER BY total_prescrito DESC;

/*i) Resolver en SQL la consulta: Obtener el nombre de los medicamentos que han sido prescritos por todos
 los doctores pertenecientes a mas de un departamento diferente.*/

SELECT med.name AS NombreMedicamento
FROM medication med
WHERE NOT EXISTS (
                    SELECT aw.physicianid
                    FROM affiliated_with aw
                    GROUP BY aw.physicianid
                    HAVING COUNT(DISTINCT aw.departmentid) > 1
                    AND NOT EXISTS (
                                    SELECT *
                                    FROM prescribes p
                                    WHERE p.medicationid = med.code
                                    AND p.physicianid = aw.physicianid
                                    )
);

/*j) Codifica un trigger que garantice que unicamente los doctores con la formaci ´ on adecuada y ´
actualizada puedan programar nuevas intervenciones medicas para las que se han certifica- ´
do. Es decir, que el certificado sea valido para la fecha del procedimiento que va a realizar.
Diferenciar mediante mensajes de error espec´ıficos entre ambos casos: los que el doctor no
posee la certificacion requerida y aquellos en los que la certificaci ´ on existe pero se encuentra ´
caducada. Incluir las sentencias SQL para probar el trigger con todos los casos (i.e. que se
se pueda dar de alta correctamente y ambos errores).*/

DROP TRIGGER IF EXISTS trg_check_doctor_certification;

DELIMITER //

CREATE TRIGGER trg_check_doctor_certification
BEFORE INSERT ON undergoes
FOR EACH ROW
BEGIN
    DECLARE var_proc_date DATE;
    DECLARE var_latest_expiry DATE;

    -- Convertir la fecha del nuevo registro
    SET var_proc_date = STR_TO_DATE(NEW.date, '%d/%m/%Y');

    -- Obtener la fecha de expiración de la certificación
    SELECT MAX(STR_TO_DATE(certificationexpires, '%d/%m/%Y')) INTO var_latest_expiry
    FROM trained_in
    WHERE physicianid = NEW.physicianid
      AND treatmentid = NEW.procedureid;

    -- Lógica de validación
    IF var_latest_expiry IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: El doctor no posee la certificación requerida para este procedimiento.';
    
    ELSEIF var_proc_date > var_latest_expiry THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: La certificación existe pero se encuentra caducada para la fecha del procedimiento.';
    END IF;
END //

DELIMITER ;

# PRUEBAS J :
# Actualizar certificación para probar caso de éxito (los datos originales están caducados)
UPDATE trained_in SET certificationexpires = '31/12/2025' WHERE physicianid = 3 AND treatmentid = 1;
# Caso Éxito
INSERT INTO undergoes (patientid, procedureid, stayid, date, physicianid, assistingnurseid)
VALUES (100000001, 1, 3215, '01/01/2025', 3, 101);
# Caso Error (Caducado)
INSERT INTO undergoes (patientid, procedureid, stayid, date, physicianid, assistingnurseid)
VALUES (100000001, 2, 3215, '01/01/2025', 3, 101);
# Caso Error (Sin Certificado)
INSERT INTO undergoes (patientid, procedureid, stayid, date, physicianid, assistingnurseid)
VALUES (100000001, 10, 3215, '01/01/2025', 1, 101);


/*k) Con el diseno actual de la base de datos, la polıtica de gestion de borrados de pacientes no
permite llevar a cabo el borrado de aquellos pacientes que tengan asociado cualquier tipo de
informacion medica sobre ellos. Sin embargo, se desea cambiar esta polıtica de manera que
se permita eliminar pacientes bajo condiciones controladas: no tener citas o procedimientos
medicos futuros programados y no tener registrado en la base de datos ningun tipo de infor- 
macion de actividad medica (consultas, procedimientos, prescriciones o estancias) durante los ultimos
 tres annos.Para poder realizar esta gestion, primeramente generar las sentencias SQL necesarias para
permitir el borrado de pacientes de la bases de datos aunque tengan asociados datos (se
borraran los datos del resto de tablas que tengan asociados)*/

ALTER TABLE appointments DROP FOREIGN KEY appointments_ibfk_1; 
# Añadimos la nueva con borrado en cascada
ALTER TABLE appointments 
ADD CONSTRAINT fk_appointments_patient_cascade 
FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE;

ALTER TABLE prescribes DROP FOREIGN KEY prescribes_ibfk_2;
# Añadimos la nueva con borrado en cascada
ALTER TABLE prescribes 
ADD CONSTRAINT fk_prescribes_patient_cascade 
FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE;

ALTER TABLE stay DROP FOREIGN KEY stay_ibfk_1;
# Añadimos la nueva con borrado en cascada
ALTER TABLE stay 
ADD CONSTRAINT fk_stay_patient_cascade 
FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE;

ALTER TABLE undergoes DROP FOREIGN KEY undergoes_ibfk_1;
# Añadimos la nueva con borrado en cascada
ALTER TABLE undergoes 
ADD CONSTRAINT fk_undergoes_patient_cascade 
FOREIGN KEY (patientid) REFERENCES patient(ssn) ON DELETE CASCADE;
 
 /*Posteriormente, codificar un trigger que impida la eliminacion de pacientes que no cumplan
con las condiciones controladas indicadas anteriormente. Dicho trigger debera proporcio-
nar mensajes de error diferenciados para cada una de las situaciones de error que puedan
ocurrir. Incluir tambien todas las sentencias SQL necesarias para probar el trigger en todos
los casos (i.e. que se se pueda realizar el borrado correctamente ası como los diferentes
errores).*/

DROP TRIGGER IF EXISTS trg_validar_borrado_paciente;

DELIMITER $$
CREATE TRIGGER trg_validar_borrado_paciente
BEFORE DELETE ON patient
FOR EACH ROW
BEGIN
    DECLARE v_futuro INT DEFAULT 0;
    DECLARE v_reciente INT DEFAULT 0;
    
    # 1. VERIFICAR CITAS O PROCEDIMIENTOS FUTUROS
    
    SELECT COUNT(*) INTO v_futuro
    FROM appointments
    WHERE patientid = OLD.ssn
      AND STR_TO_DATE(start_dt_time, '%d/%m/%Y') > CURDATE();
      
    IF v_futuro = 0 THEN
        SELECT COUNT(*) INTO v_futuro
        FROM undergoes
        WHERE patientid = OLD.ssn
          AND STR_TO_DATE(date, '%d/%m/%Y') > CURDATE();
    END IF;

    # Error tipo 1
    IF v_futuro > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'ERROR: No se puede eliminar al paciente. Tiene citas o procedimientos médicos futuros programados.';
    END IF;

    #2. VERIFICAR ACTIVIDAD RECIENTE (Últimos 3 años)
        
    SELECT (
        
        (SELECT COUNT(*) FROM appointments 
         WHERE patientid = OLD.ssn 
         AND STR_TO_DATE(start_dt_time, '%d/%m/%Y') BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 YEAR) AND CURDATE()) +
         
        (SELECT COUNT(*) FROM prescribes 
         WHERE patientid = OLD.ssn 
         AND STR_TO_DATE(date, '%d/%m/%Y') BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 YEAR) AND CURDATE()) +
         
        (SELECT COUNT(*) FROM undergoes 
         WHERE patientid = OLD.ssn 
         AND STR_TO_DATE(date, '%d/%m/%Y') BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 YEAR) AND CURDATE()) +
         
        (SELECT COUNT(*) FROM stay 
         WHERE patientid = OLD.ssn 
         AND STR_TO_DATE(start_time, '%d/%m/%Y') BETWEEN DATE_SUB(CURDATE(), INTERVAL 3 YEAR) AND CURDATE())
    ) INTO v_reciente;

    # Error tipo 2
    IF v_reciente > 0 THEN
        SIGNAL SQLSTATE '45001'
        SET MESSAGE_TEXT = 'ERROR: No se puede eliminar al paciente. Existe historial de actividad médica en los últimos 3 años.';
    END IF;

END$$
DELIMITER ;

# PRUEBAS K :
# Intentar borrar paciente con actividad reciente (debe fallar)
DELETE FROM patient WHERE ssn = 100000001;
# Crear paciente antiguo dummy para borrado exitoso
INSERT INTO patient(ssn, name, address, phonenum, insuranceid, pcpid) 
VALUES (999999, 'Old Patient', 'N/A', '000', 999999, 1);
INSERT INTO appointments(appointmentid, patientid, prepnurseid, physicianid, start_dt_time, end_dt_time, examinationroom) 
VALUES (999999, 999999, 101, 1, '01/01/2008', '01/01/2008', 'A');
# Borrar paciente antiguo (debe funcionar)
DELETE FROM patient WHERE ssn = 999999;

/*l) Codifica una funcion almacenada denominada ´ total cost patient que calcule y devuelva el
coste total acumulado de todos los procedimientos medicos registrados en la tabla undergoes
que un paciente, pasado como parametro, haya recibido. Infiere los tipos de datos tanto del 
coste total como del identificador del paciente a partir de los datos con los que las tablas
fueron creadas.*/

DROP FUNCTION IF EXISTS total_cost_patient;

DELIMITER %%
CREATE FUNCTION total_cost_patient(nombrePaciente VARCHAR(200))
RETURNS DECIMAL
DETERMINISTIC
BEGIN
    DECLARE GastoTotal DECIMAL(10,2);
    
    SELECT SUM(mp.cost) INTO GastoTotal FROM medical_procedure mp
    JOIN undergoes u ON u.procedureid = mp.code
    JOIN patient p ON p.ssn = u.patientid
    WHERE p.name = nombrePaciente;
    
    IF GastoTotal IS NULL THEN
    SET GastoTotal = 0;
    END IF;
    
    RETURN GastoTotal;
END %%
DELIMITER ;

/*Tras crear la funcion almacenada total cost patient, realiza una consulta en SQL que,
haciendo uso de la funcion, liste los datos del paciente que mayor coste total acumulado en 
procedimientos medicos.*/

# PRUEBAS L Y LO ANTERIOR :
SELECT *, total_cost_patient(name) AS CosteTotal_JohnSmith
FROM patient
WHERE name = 'John Smith';

/*m) Codifica una funcion almacenada denominada ´ calc stay cost ´ que calcule y devuelva el
coste total de una estancia pasada como parametro. Para determinar dicho coste, considera ´
que las habitaciones de tipo ICU tienen un coste de 500e/d´ıa, las Single de 300e/d´ıa, las
Double de 150e/d´ıa y otros tipos de habitaciones tienen un coste de 100e/d´ıa. 
Para determinar la duracion de una estancia busca informaci ´ on a cerca de las funciones : DATEDIFF y
STR TO DATE. Incluye tambien todas las sentencias SQL necesarias para probar la funci ´ on´
almacenada.*/

DROP FUNCTION IF EXISTS calc_stay_cost;

DELIMITER //

CREATE FUNCTION calc_stay_cost(p_stayid INT)
RETURNS DECIMAL(10, 2)
READS SQL DATA
BEGIN
    DECLARE v_start_time VARCHAR(10);
    DECLARE v_end_time VARCHAR(10);
    DECLARE v_room_type VARCHAR(8);
    DECLARE v_daily_cost DECIMAL(5, 2);
    DECLARE v_duration_days INT;
    DECLARE v_total_cost DECIMAL(10, 2);

    -- Obtener datos de la estancia y la habitación
    SELECT s.start_time, s.end_time, r.roomtype
    INTO v_start_time, v_end_time, v_room_type
    FROM stay s
    JOIN room r ON s.roomid = r.roomnumber
    WHERE s.stayid = p_stayid;

    -- Si no existe la fecha de inicio (estancia no encontrada), devolver 0
    IF v_start_time IS NULL THEN
        RETURN 0.00;
    END IF;

    -- Calcular duración en días (+1 para incluir el día de ingreso)
    SET v_duration_days = DATEDIFF(
        STR_TO_DATE(v_end_time, '%d/%m/%Y'),
        STR_TO_DATE(v_start_time, '%d/%m/%Y')
    ) + 1;

    -- Determinar coste diario según tipo de habitación
    SET v_daily_cost = CASE v_room_type
        WHEN 'ICU' THEN 500.00
        WHEN 'Single' THEN 300.00
        WHEN 'Double' THEN 150.00
        ELSE 100.00 -- Otros tipos
    END;

    -- Calcular coste total
    SET v_total_cost = v_duration_days * v_daily_cost;

    RETURN v_total_cost;
END //

DELIMITER ;

# PRUEBAS M :
SELECT calc_stay_cost(3215) AS Coste_Estancia_3215;

/*n) Codifica un procedimiento almacenado denominado physician report que permita generar
un reporte de texto con los pacientes atendidos por un doctor y las medicinas que les han
prescrito. El procedimiento recibira como entrada el identificador del doctor y el rango de
fechas sobre las que se desea generar el informe. Se dispondra de un parametro de salida
de tipo TEXT que contendra el un informe como el que se muestra a continuacion
 
INFORME DE John Dorian
John Smith (24/4/2008)
# Procrastin-X
John Smith (25/4/2008)
# No medications prescribed

La primera linea indicara el nombre del doctor. En las lineas sucesivas se indicar el nombre
del paciente atendido y la fecha en la que atendio ası como los nombres de los medicamentos
prescritos en la consulta. Si no se receto ningun medicamento se indicar “ No medications
prescribed”. Las consultas deberan ordenarse cronologicamente. Incluye tambien todas las
sentencias SQL necesarias para probar el procedimiento almacenado.*/

DROP PROCEDURE IF EXISTS physician_report;

DELIMITER $$
CREATE PROCEDURE physician_report( IN p_physician_id INT , IN p_start_date VARCHAR(10),
    IN p_end_date VARCHAR(10) , OUT p_report TEXT  )
BEGIN
    
    DECLARE v_doc_name VARCHAR(50);
    DECLARE v_pat_name VARCHAR(50);
    DECLARE v_appt_date VARCHAR(10);
    DECLARE v_appt_id INT;
    DECLARE v_med_name VARCHAR(50);
    
    #Variables de control de bucles
    DECLARE done_citas INT DEFAULT FALSE;
    DECLARE done_meds INT DEFAULT FALSE;
    DECLARE hay_medicamentos BOOLEAN DEFAULT FALSE;

    #Obtenemos paciente, fecha e ID de cita para el doctor en el rango de fechas
    DECLARE cur_citas CURSOR FOR 
        SELECT patient.name, appointments.start_dt_time, appointments.appointmentid
        FROM appointments
            JOIN patient ON appointments.patientid = patient.ssn
        WHERE appointments.physicianid = p_physician_id
            AND STR_TO_DATE(appointments.start_dt_time, '%d/%m/%Y') >= STR_TO_DATE(p_start_date, '%d/%m/%Y')
            AND STR_TO_DATE(appointments.start_dt_time, '%d/%m/%Y') <= STR_TO_DATE(p_end_date, '%d/%m/%Y')
        ORDER BY STR_TO_DATE(appointments.start_dt_time, '%d/%m/%Y');
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_citas = TRUE;

    #Cabezera del Reporte
    SELECT name INTO v_doc_name FROM physician WHERE employeeid = p_physician_id;
    SET p_report = CONCAT('INFORME DE ', v_doc_name, '\n');
    
    OPEN cur_citas;
    read_loop_citas: LOOP
        FETCH cur_citas INTO v_pat_name, v_appt_date, v_appt_id;
        
        IF done_citas THEN
            LEAVE read_loop_citas;
        END IF;

        SET p_report = CONCAT(p_report, v_pat_name, ' (', v_appt_date, ')\n');

        #Hacemos un bloque interno para MEDICAMENTOS
        BLOCK2: BEGIN
            DECLARE cur_meds CURSOR FOR 
                SELECT medication.name 
                FROM prescribes 
                JOIN medication ON prescribes.medicationid = medication.code
                WHERE prescribes.appointmentid = v_appt_id;
            DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_meds = TRUE;

            SET hay_medicamentos = FALSE;
            SET done_meds = FALSE;   #Reiniciamos la variable para el bucle interno

            OPEN cur_meds;
            read_loop_meds: LOOP
                FETCH cur_meds INTO v_med_name;
                
                IF done_meds THEN
                    LEAVE read_loop_meds;
                END IF;

                SET hay_medicamentos = TRUE;
                SET p_report = CONCAT(p_report, '# ', v_med_name, '\n');
            END LOOP;

            CLOSE cur_meds;
        END BLOCK2;

        #Si no hubo medicamentos
        IF hay_medicamentos = FALSE THEN
            SET p_report = CONCAT(p_report, '# No medications prescribed\n');
        END IF;

    END LOOP;
    CLOSE cur_citas;
END$$

DELIMITER ;

# PRUEBAS N :
SET @resultado = '';
CALL physician_report(1, '01/01/2023', '31/12/2023', @resultado);
SELECT @resultado;
