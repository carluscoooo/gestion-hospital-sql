CREATE VIEW getDatosPaciente AS
SELECT p.name AS NombrePaciente, m.name AS Medicamento, m.code, m.brand, pr.date, ph.name AS NombreDoctor from prescribes pr
join medication m on m.code  = pr.medicationid
join patient p on p.ssn = pr.patientid
join physician ph on ph.employeeid = pr.physicianid;

CREATE USER 'consultor' IDENTIFIED BY 'TU_CONTRASEÑA';
GRANT SELECT ON getDatosPaciente TO 'consultor';