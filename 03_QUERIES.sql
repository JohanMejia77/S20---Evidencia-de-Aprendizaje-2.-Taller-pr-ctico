-- Q0: Crear la base de datos si no existe y usarla
CREATE DATABASE IF NOT EXISTS proyectos_informaticos;

USE proyectos_informaticos;

-- Q1: Selecciona los proyectos y su docente jefe mediante un JOIN y les asigna un alias
SELECT p.proyecto_id, p.nombre AS proyecto, d.nombres AS docente_jefe
FROM proyecto p
    JOIN docente d ON d.docente_id = p.docente_id_jefe;

-- Q2: Selecciona el docente, su nombre, y el promedio de presupuesto por docente mediante una función
SELECT
    d.docente_id,
    d.nombres,
    fn_promedio_presupuesto_por_docente (d.docente_id) AS promedio_presupuesto
FROM docente d;

-- Q3: Verifica el trigger UPDATE de la tabla copia_actualizados_docente y los ordena por el ID de la auditoría de forma descendente y limita el resultado a 10
SELECT *
FROM copia_actualizados_docente
ORDER BY auditoria_id DESC
LIMIT 10;

-- Q4: Verifica el trigger DELETE de la tabla copia_eliminados_docente y los ordena por el ID de la auditoría de forma descendente y limita el resultado a 10
SELECT *
FROM copia_eliminados_docente
ORDER BY auditoria_id DESC
LIMIT 10;

-- Q5: Valida los CHECKs de la tabla proyecto y selecciona el proyecto, su nombre, su fecha inicial, su fecha final, su presupuesto y sus horas, y filtra por las fechas y el presupuesto
SELECT
    proyecto_id,
    nombre,
    fecha_inicial,
    fecha_final,
    presupuesto,
    horas
FROM proyecto
WHERE (
        fecha_final IS NULL
        OR fecha_final >= fecha_inicial
    )
    AND presupuesto >= 0
    AND horas >= 0;

-- Q6: Selecciona el docente, su ID, y los proyectos que tiene asignados mediante un LEFT JOIN y los ordena por el ID del docente de forma ascendente
SELECT d.docente_id, d.nombres, p.proyecto_id, p.nombre
FROM docente d
    LEFT JOIN proyecto p ON d.docente_id = p.docente_id_jefe
ORDER BY d.docente_id;

-- Q7: Selecciona el docente, su ID, y el total de horas que tiene asignadas mediante un LEFT JOIN y los agrupa por el ID del docente y el nombre del docente y los ordena por el ID del docente de forma ascendente y suma las horas
SELECT d.docente_id, d.nombres, SUM(p.horas) AS total_horas
FROM docente d
    LEFT JOIN proyecto p ON d.docente_id = p.docente_id_jefe
GROUP BY
    d.docente_id,
    d.nombres;

-- Q8: Llama al procedimiento de crear un docente con los valores proporcionados
CALL sp_docente_crear (
    'CC1001',
    'Ana Gómez',
    'MSc. Ing. Sistemas',
    6,
    'Cra 10 # 5-55',
    'Tiempo completo'
);

CALL sp_docente_crear (
    'CC1002',
    'Carlos Ruiz',
    'Ing. Informático',
    3,
    'Cll 20 # 4-10',
    'Cátedra'
);

-- Hace un set para obtener el ID de un docente mediante un select y guardarlo en una variable
SET
    @id_ana := (
        SELECT docente_id
        FROM docente
        WHERE
            numero_documento = 'CC1001'
    );

SET
    @id_carlos := (
        SELECT docente_id
        FROM docente
        WHERE
            numero_documento = 'CC1002'
    );

-- Llama al procedimiento de crear un proyecto con los valores proporcionados
CALL sp_proyecto_crear (
    'Plataforma Académica',
    'Módulos de matrícula',
    '2025-01-01',
    NULL,
    25000000,
    800,
    @id_ana
);

CALL sp_proyecto_crear (
    'Chat Soporte TI',
    'Chat universitario',
    '2025-02-01',
    '2025-06-30',
    12000000,
    450,
    @id_carlos
);

-- Q9: Inserta un docente y un proyecto directamente
INSERT INTO
    docente (
        numero_documento,
        nombres,
        titulo,
        anios_experiencia,
        direccion,
        tipo_docente
    )
VALUES (
        'CC2001',
        'María López',
        'Esp. Gestión de Proyectos',
        7,
        'Av. Siempre Viva 742',
        'Cátedra'
    );

INSERT INTO
    proyecto (
        nombre,
        descripcion,
        fecha_inicial,
        fecha_final,
        presupuesto,
        horas,
        docente_id_jefe
    )
VALUES (
        'App Biblioteca',
        'App móvil de préstamos',
        '2025-03-01',
        NULL,
        9000000,
        320,
        (
            SELECT docente_id
            FROM docente
            WHERE
                numero_documento = 'CC2001'
        )
    );