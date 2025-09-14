-- Llama al procedimiento de crear un docente con los valores proporcionados
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

-- Llama al procedimiento de actualizar un docente con los valores proporcionados
CALL sp_docente_actualizar (
    @id_carlos,
    'CC1002',
    'Carlos A. Ruiz',
    'Esp. Base de Datos',
    4,
    'Cll 20 # 4-10',
    'Cátedra'
);

-- Elimina los proyectos de la docente Ana mediante el ID de la docente guardado en la variable
DELETE FROM proyecto WHERE docente_id_jefe = @id_ana;

-- Llama al procedimiento de eliminar un docente con el ID de la docente guardado en la variable
CALL sp_docente_eliminar (@id_ana);