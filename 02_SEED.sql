-- Cada bloque de call esta creando o insertando la informacion de un docente nuevo en la tabla Docente de la base de datos, con los datos que se le proporcionan 
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

-- El set es como pedirle a la base de datos que busque y que me de el ID interno del docente mediante un select y guardarlo en una cajita o variable
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

--Cada bloque de call esta creando un proyecto nuevo en la base de datos, Se pasan como parámetros el nombre, la descripción, las fechas de inicio y fin, el presupuesto, el número de horas, y el ID del docente responsable
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

-- Llama al procedimiento sp_docente_actualizar para modificar los datos de un docente existente en la base de datos, usando el ID guardado en @id_carlos y reemplazando la información anterior con los nuevos valores
CALL sp_docente_actualizar (
    @id_carlos,
    'CC1002',
    'Carlos A. Ruiz',
    'Esp. Base de Datos',
    4,
    'Cll 20 # 4-10',
    'Cátedra'
);

-- Elimina todos los registros de la tabla proyecto que estén asociados a la docente Ana, utilizando el valor de su ID que está almacenado en la variable @id_ana.
DELETE FROM proyecto WHERE docente_id_jefe = @id_ana;

-- Ejecuta el procedimiento sp_docente_eliminar para borrar definitivamente a la docente Ana de la base de datos, identificándola mediante el ID guardado en la variable @id_ana.
CALL sp_docente_eliminar (@id_ana);