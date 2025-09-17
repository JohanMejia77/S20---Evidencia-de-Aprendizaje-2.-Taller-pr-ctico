--Antes de crear los triggers de auditoría, se eliminan los que pudieran existir con el mismo nombre;
--esto previene errores de duplicidad si se ejecuta varias veces el script.

DROP TRIGGER IF EXISTS tr_docente_after_update;

DROP TRIGGER IF EXISTS tr_docente_after_delete;

-- Se eliminan las tablas de respaldo (copia_eliminados_docente, copia_actualizados_docente) y las tablas principales (proyecto, docente) si ya existen.
--Esto ayuda a que el script siempre empiece con una estructura limpia.

DROP TABLE IF EXISTS copia_eliminados_docente;

DROP TABLE IF EXISTS copia_actualizados_docente;

DROP TABLE IF EXISTS proyecto;

DROP TABLE IF EXISTS docente;

-- Se crean las tablas de la entidad Docente, incluye restricciones de clave primaria, 
--valores unicos y una condición logica para que los años de experiencia no sean negativos.

CREATE TABLE docente (
    docente_id INT AUTO_INCREMENT PRIMARY KEY,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(120) NOT NULL,
    titulo VARCHAR(120),
    anios_experiencia INT NOT NULL DEFAULT 0,
    direccion VARCHAR(180),
    tipo_docente VARCHAR(40),
    CONSTRAINT uq_docente_documento UNIQUE (numero_documento),
    CONSTRAINT ck_docente_anios CHECK (anios_experiencia >= 0)
) ENGINE = InnoDB;

-- Se crean las tablas de la entidad Proyecto, incluye restricciones de: clave primaria, horas y presupuesto no negativos,
-- fecha final debe ser mayor o igual a la fecha inicial si no es nula, y clave foránea que referencia a la tabla docente.

CREATE TABLE proyecto (
    proyecto_id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120) NOT NULL,
    descripcion VARCHAR(400),
    fecha_inicial DATE NOT NULL,
    fecha_final DATE,
    presupuesto DECIMAL(12, 2) NOT NULL DEFAULT 0,
    horas INT NOT NULL DEFAULT 0,
    docente_id_jefe INT NOT NULL,
    CONSTRAINT ck_proyecto_horas CHECK (horas >= 0),
    CONSTRAINT ck_proyecto_pres CHECK (presupuesto >= 0),
    CONSTRAINT ck_proyecto_fechas CHECK (
        fecha_final IS NULL
        OR fecha_final >= fecha_inicial
    ),
    CONSTRAINT fk_proyecto_docente FOREIGN KEY (docente_id_jefe) REFERENCES docente (docente_id) ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Se crea la tabla de copia de seguridad para docentes, Guardan un historial de cambios realizados sobre la tabla docente
--almacena una copia de los docentes cuando se actualizan, junto con la fecha y el usuario que realizó el cambio.

CREATE TABLE copia_actualizados_docente (
    auditoria_id INT AUTO_INCREMENT PRIMARY KEY,
    docente_id INT NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(120) NOT NULL,
    titulo VARCHAR(120),
    anios_experiencia INT NOT NULL,
    direccion VARCHAR(180),
    tipo_docente VARCHAR(40),
    accion_fecha DATETIME NOT NULL DEFAULT(UTC_TIMESTAMP()),
    usuario_sql VARCHAR(128) NOT NULL DEFAULT(CURRENT_USER())
) ENGINE = InnoDB;

--Se crea la tabla de copia de seguridad de los docentes eliminados, 
--guarda un historial de los docentes eliminados, junto con la fecha y el usuario que realizó la eliminación.

CREATE TABLE copia_eliminados_docente (
    auditoria_id INT AUTO_INCREMENT PRIMARY KEY,
    docente_id INT NOT NULL,
    numero_documento VARCHAR(20) NOT NULL,
    nombres VARCHAR(120) NOT NULL,
    titulo VARCHAR(120),
    anios_experiencia INT NOT NULL,
    direccion VARCHAR(180),
    tipo_docente VARCHAR(40),
    accion_fecha DATETIME NOT NULL DEFAULT(UTC_TIMESTAMP()),
    usuario_sql VARCHAR(128) NOT NULL DEFAULT(CURRENT_USER())
) ENGINE = InnoDB;

-- Se borran los procedimientos de docentes si existen, para evitar errores de duplicidad si se ejecuta varias veces el script
--esto permite que el script siempre cree los procedimientos desde cero.

DROP PROCEDURE IF EXISTS sp_docente_crear;

DROP PROCEDURE IF EXISTS sp_docente_leer;

DROP PROCEDURE IF EXISTS sp_docente_actualizar;

DROP PROCEDURE IF EXISTS sp_docente_eliminar;

DELIMITER $$

--Se crea el procedimiento de crear un docente,
--recibe los valores necesarios para insertar un nuevo docente en la tabla docente, y retorna el ID del docente creado.
--antes de insertar verifica que los años de experiencia no sean nulos, si lo son los convierte a 0.

CREATE PROCEDURE sp_docente_crear(
  IN p_numero_documento VARCHAR(20),
  IN p_nombres          VARCHAR(120),
  IN p_titulo           VARCHAR(120),
  IN p_anios_experiencia INT,
  IN p_direccion        VARCHAR(180),
  IN p_tipo_docente     VARCHAR(40)
)
BEGIN
  INSERT INTO docente (numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES (p_numero_documento, p_nombres, p_titulo, IFNULL(p_anios_experiencia,0), p_direccion, p_tipo_docente);
  SELECT LAST_INSERT_ID() AS docente_id_creado;
END$$

--Se crea el procedimiento de leer un docente el cual se selecciona mediante su ID, 
--y retorna toda la información del docente, si no existe retorna un conjunto de resultados vacío.

CREATE PROCEDURE sp_docente_leer(IN p_docente_id INT)
BEGIN
  SELECT * FROM docente WHERE docente_id = p_docente_id;
END$$

--Se crea el procedimiento de Actualizar el cual recibe los valores nuevos y el id del docente
--antes de actualizar verifica que los años de experiencia no sean nulos, si lo son los convierte a 0.

CREATE PROCEDURE sp_docente_actualizar(
  IN p_docente_id       INT,
  IN p_numero_documento VARCHAR(20),
  IN p_nombres          VARCHAR(120),
  IN p_titulo           VARCHAR(120),
  IN p_anios_experiencia INT,
  IN p_direccion        VARCHAR(180),
  IN p_tipo_docente     VARCHAR(40)
)
BEGIN
  UPDATE docente
     SET numero_documento = p_numero_documento,
         nombres = p_nombres,
         titulo = p_titulo,
         anios_experiencia = IFNULL(p_anios_experiencia,0),
         direccion = p_direccion,
         tipo_docente = p_tipo_docente
   WHERE docente_id = p_docente_id;
  SELECT * FROM docente WHERE docente_id = p_docente_id;
END$$

--Se crea el procedimiento de eliminar recibiendo el ID, elimina el docente correspondiente de la tabla docente.
--Si el docente tiene proyectos asociados, la eliminación fallará debido a la restricción de clave foránea.

CREATE PROCEDURE sp_docente_eliminar(IN p_docente_id INT)
BEGIN
  DELETE FROM docente WHERE docente_id = p_docente_id;
END$$

-- Se borran los procedimientos de Proyectos si existen, para evitar errores de duplicidad si se ejecuta varias veces el script
--esto permite que el script siempre cree los procedimientos desde cero.

DROP PROCEDURE IF EXISTS sp_proyecto_crear;

DROP PROCEDURE IF EXISTS sp_proyecto_leer;

DROP PROCEDURE IF EXISTS sp_proyecto_actualizar;

DROP PROCEDURE IF EXISTS sp_proyecto_eliminar;

-- Se crea el procedimiento de crear un proyecto, recibe los valores necesarios para insertar un nuevo proyecto en la tabla proyecto,
--y retorna el ID del proyecto creado. Antes de insertar verifica que las horas y el presupuesto.

CREATE PROCEDURE sp_proyecto_crear(
  IN p_nombre           VARCHAR(120),
  IN p_descripcion      VARCHAR(400),
  IN p_fecha_inicial    DATE,
  IN p_fecha_final      DATE,
  IN p_presupuesto      DECIMAL(12,2),
  IN p_horas            INT,
  IN p_docente_id_jefe  INT

--p_docente_id_jefe debe existir en la tabla docente, horas y presupuesto no deben ser nulos (si lo son se convierten a 0
--si fecha_final no es nula debe ser mayor o igual a fecha_inicial.

)
BEGIN
  INSERT INTO proyecto (nombre, descripcion, fecha_inicial, fecha_final, presupuesto, horas, docente_id_jefe)
  VALUES (p_nombre, p_descripcion, p_fecha_inicial, p_fecha_final, IFNULL(p_presupuesto,0), IFNULL(p_horas,0), p_docente_id_jefe);
  SELECT LAST_INSERT_ID() AS proyecto_id_creado;
END$$
-- Se crea el procedimiento de leer un proyecto se selecciona mediante su ID, y retorna toda la información del proyecto junto con el nombre del docente jefe.
-- Si no existe retorna un conjunto de resultados vacío.

CREATE PROCEDURE sp_proyecto_leer(IN p_proyecto_id INT)
BEGIN
  SELECT p.*, d.nombres AS nombre_docente_jefe
  FROM proyecto p
  JOIN docente d ON d.docente_id = p.docente_id_jefe
  WHERE p.proyecto_id = p_proyecto_id;
END$$
-- Se crea el procedimiento de actualizar un proyecto recibiendo los nuevos valores y el ID del proyecto,

CREATE PROCEDURE sp_proyecto_actualizar(
  IN p_proyecto_id      INT,
  IN p_nombre           VARCHAR(120),
  IN p_descripcion      VARCHAR(400),
  IN p_fecha_inicial    DATE,
  IN p_fecha_final      DATE,
  IN p_presupuesto      DECIMAL(12,2),
  IN p_horas            INT,
  IN p_docente_id_jefe  INT

--p_docente_id_jefe debe existir en la tabla docente,
)
BEGIN
  UPDATE proyecto
     SET nombre = p_nombre,
         descripcion = p_descripcion,
         fecha_inicial = p_fecha_inicial,
         fecha_final = p_fecha_final,
         presupuesto = IFNULL(p_presupuesto,0),
         horas = IFNULL(p_horas,0),
         docente_id_jefe = p_docente_id_jefe
   WHERE proyecto_id = p_proyecto_id;
  CALL sp_proyecto_leer(p_proyecto_id);
END$$

-- Se crea el procedimiento de eliminar un proyecto recibiendo su ID, elimina el proyecto correspondiente de la tabla proyecto.
--Si el proyecto tiene restricciones de clave foránea, la eliminación fallará debido a esas restricciones

CREATE PROCEDURE sp_proyecto_eliminar(IN p_proyecto_id INT)
BEGIN
  DELETE FROM proyecto WHERE proyecto_id = p_proyecto_id;
END$$

-- Se borra la función si existe, para evitar errores de duplicidad si se ejecuta varias veces el script

DROP FUNCTION IF EXISTS fn_promedio_presupuesto_por_docente;

CREATE FUNCTION fn_promedio_presupuesto_por_docente(p_docente_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
  DECLARE v_prom DECIMAL(12,2);
  SELECT IFNULL(AVG(presupuesto),0) INTO v_prom
  FROM proyecto
  WHERE docente_id_jefe = p_docente_id;
  RETURN IFNULL(v_prom,0);
END$$

-- Triggers para auditoría de actualizaciones y eliminaciones en la tabla docente, se crean los triggers 
--para registrar los cambios en las tablas de auditoría correspondientes.

CREATE TRIGGER tr_docente_after_update
AFTER UPDATE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO copia_actualizados_docente
    (docente_id, numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES
    (NEW.docente_id, NEW.numero_documento, NEW.nombres, NEW.titulo, NEW.anios_experiencia, NEW.direccion, NEW.tipo_docente);
END$$

-- Trigger para auditoría de eliminaciones en la tabla docente, 
--se crea el trigger para registrar las eliminaciones en la tabla de auditoría correspondiente.

CREATE TRIGGER tr_docente_after_delete
AFTER DELETE ON docente
FOR EACH ROW
BEGIN
  INSERT INTO copia_eliminados_docente
    (docente_id, numero_documento, nombres, titulo, anios_experiencia, direccion, tipo_docente)
  VALUES
    (OLD.docente_id, OLD.numero_documento, OLD.nombres, OLD.titulo, OLD.anios_experiencia, OLD.direccion, OLD.tipo_docente);
END$$

DELIMITER;

-- Se crean los índices para optimizar las consultas, mejorando el rendimiento de las operaciones de búsqueda y unión.

CREATE INDEX ix_proyecto_docente ON proyecto (docente_id_jefe);

CREATE INDEX ix_docente_documento ON docente (numero_documento);