-- =============================================================================
-- SISTEMA DE GESTIÓN GANADERA (VACUNOS)
-- DDL Migrado a T-SQL · SQL Server 2022
-- Origen: PostgreSQL 15+ · Norma 3FN estricta · Tríada CID · Ley 29733
-- =============================================================================


-- =============================================================================
-- BLOQUE 1: INFRAESTRUCTURA Y CATÁLOGOS BASE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- usuario
-- CID: Confidencialidad — datos personales protegidos por Ley 29733.
--   Requiere rol: rol_admin, rol_encargado (solo lectura de su propio perfil)
-- -----------------------------------------------------------------------------
CREATE TABLE [usuario] (
    [id]              BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]          VARCHAR(15)     NOT NULL,
    [nombre_usuario]  VARCHAR(50)     NOT NULL,
    [nombre_completo] VARCHAR(100)    NOT NULL,
    [correo]          VARCHAR(120),
    [activo]          BIT             NOT NULL DEFAULT 1,
    [created_at]      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [uq_usuario_codigo]         UNIQUE ([codigo]),
    CONSTRAINT [uq_usuario_nombre_usuario] UNIQUE ([nombre_usuario]),
    CONSTRAINT [uq_usuario_correo]         UNIQUE ([correo])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_usuario_activo] ON [usuario] ([activo]);
GO


-- -----------------------------------------------------------------------------
-- cat_modulo
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_modulo] (
    [code]        VARCHAR(40)     PRIMARY KEY,
    [nombre]      VARCHAR(80)     NOT NULL,
    [descripcion] VARCHAR(250),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_modulo_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_registro
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_registro] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_registro_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_formato_reporte
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_formato_reporte] (
    [code]   VARCHAR(10)     PRIMARY KEY,
    [nombre] VARCHAR(20)     NOT NULL,
    CONSTRAINT [uq_cat_formato_reporte_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_tipo_reporte
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_reporte] (
    [code]        VARCHAR(60)     PRIMARY KEY,
    [modulo_code] VARCHAR(40)     NOT NULL,
    [nombre]      VARCHAR(120)    NOT NULL,
    [descripcion] VARCHAR(300),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [fk_cat_tipo_reporte_modulo] FOREIGN KEY ([modulo_code])
        REFERENCES [cat_modulo] ([code]),
    CONSTRAINT [uq_cat_tipo_reporte_modulo_nombre] UNIQUE ([modulo_code], [nombre])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_cat_tipo_reporte_modulo] ON [cat_tipo_reporte] ([modulo_code]);
GO


-- -----------------------------------------------------------------------------
-- cat_tipo_archivo  [NUEVA — 3FN-04]
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_archivo] (
    [extension] VARCHAR(10)     PRIMARY KEY,
    [mime_type] VARCHAR(80)     NOT NULL
);
GO


-- -----------------------------------------------------------------------------
-- archivo
-- CID: Confidencialidad — archivos pueden contener datos médicos/reproductivos.
--   Requiere rol: rol_admin, rol_encargado (solo sus propios archivos)
-- -----------------------------------------------------------------------------
CREATE TABLE [archivo] (
    [id]                  BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [modulo_code]         VARCHAR(40)     NOT NULL,
    [nombre_original]     VARCHAR(150)    NOT NULL,
    [nombre_almacenado]   VARCHAR(150)    NOT NULL,
    [ruta_archivo]        NVARCHAR(MAX)   NOT NULL,
    [extension]           VARCHAR(10)     NOT NULL,
    [tamano_bytes]        BIGINT,
    [hash_sha256]         VARCHAR(64),
    [creado_por]          BIGINT,
    [created_at]          DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_archivo_modulo]     FOREIGN KEY ([modulo_code]) REFERENCES [cat_modulo] ([code]),
    CONSTRAINT [fk_archivo_extension]  FOREIGN KEY ([extension])   REFERENCES [cat_tipo_archivo] ([extension]),
    CONSTRAINT [fk_archivo_creado_por] FOREIGN KEY ([creado_por])  REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_archivo_hash]      ON [archivo] ([hash_sha256]);
CREATE INDEX [idx_archivo_modulo]    ON [archivo] ([modulo_code]);
CREATE INDEX [idx_archivo_extension] ON [archivo] ([extension]);
GO


-- -----------------------------------------------------------------------------
-- parametro_sistema
-- -----------------------------------------------------------------------------
CREATE TABLE [parametro_sistema] (
    [id]          BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [modulo_code] VARCHAR(40)     NOT NULL,
    [clave]       VARCHAR(80)     NOT NULL,
    [valor]       VARCHAR(150)    NOT NULL,
    [descripcion] VARCHAR(250),
    [created_at]  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_parametro_modulo]       FOREIGN KEY ([modulo_code]) REFERENCES [cat_modulo] ([code]),
    CONSTRAINT [uq_parametro_modulo_clave] UNIQUE ([modulo_code], [clave])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_parametro_modulo_clave] ON [parametro_sistema] ([modulo_code], [clave]);
GO


-- -----------------------------------------------------------------------------
-- bitacora_auditoria
-- 3FN-10: entidad_id cambiado a VARCHAR para soportar PKs texto.
-- 1FN-02: datos_anteriores/datos_nuevos como NVARCHAR(MAX) — EXCEPCIÓN JUSTIFICADA.
-- CID: Confidencialidad — contiene datos personales de todas las entidades.
--   Requiere rol: rol_admin (solo lectura), prohibido UPDATE/DELETE.
-- -----------------------------------------------------------------------------
CREATE TABLE [bitacora_auditoria] (
    [id]               BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [modulo_code]      VARCHAR(40)     NOT NULL,
    [entidad]          VARCHAR(80)     NOT NULL,
    [entidad_id]       VARCHAR(80)     NOT NULL,
    [accion]           VARCHAR(40)     NOT NULL,
    [datos_anteriores] NVARCHAR(MAX),
    [datos_nuevos]     NVARCHAR(MAX),
    [motivo]           VARCHAR(250),
    [usuario_id]       BIGINT,
    [ip_origen]        NVARCHAR(45),
    [user_agent]       VARCHAR(250),
    [created_at]       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_bitacora_modulo]  FOREIGN KEY ([modulo_code]) REFERENCES [cat_modulo] ([code]),
    CONSTRAINT [fk_bitacora_usuario] FOREIGN KEY ([usuario_id])  REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_bitacora_modulo]     ON [bitacora_auditoria] ([modulo_code]);
CREATE INDEX [idx_bitacora_entidad]    ON [bitacora_auditoria] ([entidad]);
CREATE INDEX [idx_bitacora_entidad_id] ON [bitacora_auditoria] ([entidad_id]);
CREATE INDEX [idx_bitacora_usuario]    ON [bitacora_auditoria] ([usuario_id]);
CREATE INDEX [idx_bitacora_created_at] ON [bitacora_auditoria] ([created_at]);
GO


-- =============================================================================
-- BLOQUE 2: RESPONSABLES Y REPOSITORIO DE REPORTES
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cat_tipo_responsable
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_responsable] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_tipo_responsable_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- responsable
-- 3FN-03: nombre_completo ahora NULLABLE.
-- CID: Confidencialidad — datos personales. Requiere rol: rol_admin, rol_veterinario.
-- -----------------------------------------------------------------------------
CREATE TABLE [responsable] (
    [id]                    BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [usuario_id]            BIGINT,
    [tipo_responsable_code] VARCHAR(30)     NOT NULL,
    [nombre_completo]       VARCHAR(100),
    [documento]             VARCHAR(30),
    [telefono]              VARCHAR(20),
    [activo]                BIT             NOT NULL DEFAULT 1,
    [created_at]            DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_responsable_usuario] FOREIGN KEY ([usuario_id])
        REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_responsable_tipo] FOREIGN KEY ([tipo_responsable_code])
        REFERENCES [cat_tipo_responsable] ([code]),
    -- 3FN-03: nombre_completo solo si es externo (usuario_id IS NULL)
    CONSTRAINT [ck_responsable_nombre_externo] CHECK (
        ([usuario_id] IS NULL     AND [nombre_completo] IS NOT NULL)
        OR
        ([usuario_id] IS NOT NULL AND [nombre_completo] IS NULL)
    )
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_responsable_usuario] ON [responsable] ([usuario_id]);
CREATE INDEX [idx_responsable_tipo]    ON [responsable] ([tipo_responsable_code]);
GO


-- -----------------------------------------------------------------------------
-- reporte_descarga
-- 1FN-01: filtros jsonb eliminado → columnas atómicas discretas.
-- 3FN-09: estado ahora FK a cat_estado_registro.
-- -----------------------------------------------------------------------------
CREATE TABLE [reporte_descarga] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [tipo_reporte_code]    VARCHAR(60)     NOT NULL,
    [formato_code]         VARCHAR(10)     NOT NULL,
    [filtro_fecha_inicio]  DATE,
    [filtro_fecha_fin]     DATE,
    [filtro_vacuno_id]     BIGINT,
    [filtro_granja_id]     BIGINT,
    [filtro_raza_code]     VARCHAR(30),
    [filtro_palabra_clave] VARCHAR(100),
    [archivo_id]           BIGINT,
    [estado_code]          VARCHAR(30)     NOT NULL DEFAULT 'ACTIVO',
    [mensaje]              VARCHAR(150),
    [solicitado_por]       BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_reporte_tipo_reporte]   FOREIGN KEY ([tipo_reporte_code]) REFERENCES [cat_tipo_reporte] ([code]),
    CONSTRAINT [fk_reporte_formato]        FOREIGN KEY ([formato_code])      REFERENCES [cat_formato_reporte] ([code]),
    CONSTRAINT [fk_reporte_archivo]        FOREIGN KEY ([archivo_id])        REFERENCES [archivo] ([id]),
    CONSTRAINT [fk_reporte_estado]         FOREIGN KEY ([estado_code])       REFERENCES [cat_estado_registro] ([code]),
    CONSTRAINT [fk_reporte_solicitado_por] FOREIGN KEY ([solicitado_por])    REFERENCES [usuario] ([id]),
    -- CID: Integridad — rango de fechas coherente
    CONSTRAINT [ck_reporte_fechas] CHECK (
        [filtro_fecha_inicio] IS NULL
        OR [filtro_fecha_fin] IS NULL
        OR [filtro_fecha_inicio] <= [filtro_fecha_fin]
    )
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_reporte_tipo]       ON [reporte_descarga] ([tipo_reporte_code]);
CREATE INDEX [idx_reporte_formato]    ON [reporte_descarga] ([formato_code]);
CREATE INDEX [idx_reporte_vacuno]     ON [reporte_descarga] ([filtro_vacuno_id]);
CREATE INDEX [idx_reporte_granja]     ON [reporte_descarga] ([filtro_granja_id]);
CREATE INDEX [idx_reporte_solicitado] ON [reporte_descarga] ([solicitado_por]);
CREATE INDEX [idx_reporte_fechas]     ON [reporte_descarga] ([filtro_fecha_inicio], [filtro_fecha_fin]);
CREATE INDEX [idx_reporte_estado]     ON [reporte_descarga] ([estado_code]);
GO


-- =============================================================================
-- BLOQUE 3: CATÁLOGOS DE VACUNO Y GEOGRAFÍA
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cat_sexo
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_sexo] (
    [code]        VARCHAR(10)     PRIMARY KEY,
    [nombre]      VARCHAR(15)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_sexo_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_raza
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_raza] (
    [code]   VARCHAR(30)     PRIMARY KEY,
    [nombre] VARCHAR(50)     NOT NULL,
    [activo] BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_raza_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_color
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_color] (
    [code]   VARCHAR(30)     PRIMARY KEY,
    [nombre] VARCHAR(30)     NOT NULL,
    [activo] BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_color_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_tipo_adquisicion
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_adquisicion] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_tipo_adquisicion_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_tipo_utilizacion
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_utilizacion] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_tipo_utilizacion_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_vacuno
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_vacuno] (
    [code]        VARCHAR(15)     PRIMARY KEY,
    [nombre]      VARCHAR(30)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_vacuno_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- Geografía
-- -----------------------------------------------------------------------------
CREATE TABLE [geo_departamento] (
    [codigo] VARCHAR(2)      PRIMARY KEY,
    [nombre] VARCHAR(60)     NOT NULL,
    CONSTRAINT [uq_geo_departamento_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [geo_provincia] (
    [codigo]              VARCHAR(4)      PRIMARY KEY,
    [departamento_codigo] VARCHAR(2)      NOT NULL,
    [nombre]              VARCHAR(60)     NOT NULL,
    CONSTRAINT [fk_provincia_departamento] FOREIGN KEY ([departamento_codigo])
        REFERENCES [geo_departamento] ([codigo]),
    CONSTRAINT [uq_geo_provincia_dep_nombre] UNIQUE ([departamento_codigo], [nombre])
);
GO

CREATE TABLE [geo_distrito] (
    [codigo]           VARCHAR(6)      PRIMARY KEY,
    [provincia_codigo] VARCHAR(4)      NOT NULL,
    [nombre]           VARCHAR(60)     NOT NULL,
    CONSTRAINT [fk_distrito_provincia] FOREIGN KEY ([provincia_codigo])
        REFERENCES [geo_provincia] ([codigo]),
    CONSTRAINT [uq_geo_distrito_prov_nombre] UNIQUE ([provincia_codigo], [nombre])
);
GO


-- -----------------------------------------------------------------------------
-- granja
-- -----------------------------------------------------------------------------
CREATE TABLE [granja] (
    [id]              BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [nombre]          VARCHAR(100)    NOT NULL,
    [distrito_codigo] VARCHAR(6)      NOT NULL,
    [activo]          BIT             NOT NULL DEFAULT 1,
    [created_at]      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]      DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_granja_distrito]       FOREIGN KEY ([distrito_codigo]) REFERENCES [geo_distrito] ([codigo]),
    CONSTRAINT [uq_granja_nombre_distrito] UNIQUE ([nombre], [distrito_codigo])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_granja_distrito] ON [granja] ([distrito_codigo]);
GO


-- =============================================================================
-- BLOQUE 4: VACUNO — ENTIDAD PRINCIPAL Y SUBENTIDADES (3FN)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- vacuno
-- 3FN-01: precio_compra y fecha_adquisicion movidos a vacuno_adquisicion.
-- 3FN-02: tipo_utilizacion_code movido a vacuno_utilizacion_historial.
-- CID: Confidencialidad — Requiere rol: rol_encargado, rol_veterinario, rol_admin.
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno] (
    [id]                    BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]                VARCHAR(15)     NOT NULL,
    [nombre]                VARCHAR(100)    NOT NULL,
    [fecha_nacimiento]      DATE            NOT NULL,
    [tipo_adquisicion_code] VARCHAR(30)     NOT NULL,
    [raza_code]             VARCHAR(30)     NOT NULL,
    [color_code]            VARCHAR(30)     NOT NULL,
    [sexo_code]             VARCHAR(10)     NOT NULL,
    [padre_id]              BIGINT,
    [madre_id]              BIGINT,
    [granja_id]             BIGINT          NOT NULL,
    [observaciones]         VARCHAR(150),
    [fecha_registro]        DATE            NOT NULL,
    [created_by]            BIGINT,
    [updated_by]            BIGINT,
    [deleted_by]            BIGINT,
    [created_at]            DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]            DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [deleted_at]            DATETIME2,
    [motivo_eliminacion]    VARCHAR(250),
    CONSTRAINT [uq_vacuno_codigo]        UNIQUE ([codigo]),
    CONSTRAINT [fk_vacuno_adquisicion]   FOREIGN KEY ([tipo_adquisicion_code]) REFERENCES [cat_tipo_adquisicion] ([code]),
    CONSTRAINT [fk_vacuno_raza]          FOREIGN KEY ([raza_code])             REFERENCES [cat_raza] ([code]),
    CONSTRAINT [fk_vacuno_color]         FOREIGN KEY ([color_code])            REFERENCES [cat_color] ([code]),
    CONSTRAINT [fk_vacuno_sexo]          FOREIGN KEY ([sexo_code])             REFERENCES [cat_sexo] ([code]),
    CONSTRAINT [fk_vacuno_padre]         FOREIGN KEY ([padre_id])              REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vacuno_madre]         FOREIGN KEY ([madre_id])              REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vacuno_granja]        FOREIGN KEY ([granja_id])             REFERENCES [granja] ([id]),
    CONSTRAINT [fk_vacuno_created_by]    FOREIGN KEY ([created_by])            REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_vacuno_updated_by]    FOREIGN KEY ([updated_by])            REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_vacuno_deleted_by]    FOREIGN KEY ([deleted_by])            REFERENCES [usuario] ([id]),
    -- CID: Integridad — fecha de nacimiento no puede ser futura
    CONSTRAINT [ck_vacuno_fecha_nacimiento] CHECK ([fecha_nacimiento] <= CAST(GETDATE() AS DATE)),
    -- CID: Integridad — auto-referencias genealógicas
    CONSTRAINT [ck_vacuno_padre_no_self]   CHECK ([padre_id] <> [id]),
    CONSTRAINT [ck_vacuno_madre_no_self]   CHECK ([madre_id] <> [id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_vacuno_nombre]           ON [vacuno] ([nombre]);
CREATE INDEX [idx_vacuno_fecha_nacimiento] ON [vacuno] ([fecha_nacimiento]);
CREATE INDEX [idx_vacuno_raza]             ON [vacuno] ([raza_code]);
CREATE INDEX [idx_vacuno_sexo]             ON [vacuno] ([sexo_code]);
CREATE INDEX [idx_vacuno_granja]           ON [vacuno] ([granja_id]);
CREATE INDEX [idx_vacuno_padre]            ON [vacuno] ([padre_id]);
CREATE INDEX [idx_vacuno_madre]            ON [vacuno] ([madre_id]);
CREATE INDEX [idx_vacuno_fecha_registro]   ON [vacuno] ([fecha_registro]);
CREATE INDEX [idx_vacuno_deleted_at]       ON [vacuno] ([deleted_at]);
GO


-- -----------------------------------------------------------------------------
-- vacuno_adquisicion  [NUEVA — 3FN-01]
-- CID: Confidencialidad — precio es dato económico sensible. Requiere rol: rol_admin.
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno_adquisicion] (
    [vacuno_id]             BIGINT          PRIMARY KEY,
    [tipo_adquisicion_code] VARCHAR(30)     NOT NULL,
    [precio_compra]         NUMERIC(12, 2),
    [fecha_adquisicion]     DATE            NOT NULL,
    [proveedor]             VARCHAR(150),
    [observaciones]         VARCHAR(250),
    [created_at]            DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_vacuno_adquisicion_vacuno] FOREIGN KEY ([vacuno_id])
        REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vacuno_adquisicion_tipo] FOREIGN KEY ([tipo_adquisicion_code])
        REFERENCES [cat_tipo_adquisicion] ([code]),
    -- CID: Integridad — precio debe ser positivo si se registra
    CONSTRAINT [ck_vacuno_adquisicion_precio] CHECK (
        [precio_compra] IS NULL OR [precio_compra] > 0
    ),
    -- CID: Integridad — fecha de adquisición no futura
    CONSTRAINT [ck_vacuno_adquisicion_fecha] CHECK ([fecha_adquisicion] <= CAST(GETDATE() AS DATE))
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_vacuno_adquisicion_tipo]  ON [vacuno_adquisicion] ([tipo_adquisicion_code]);
CREATE INDEX [idx_vacuno_adquisicion_fecha] ON [vacuno_adquisicion] ([fecha_adquisicion]);
GO


-- -----------------------------------------------------------------------------
-- vacuno_utilizacion_historial  [NUEVA — 3FN-02]
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno_utilizacion_historial] (
    [id]                    BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]             BIGINT          NOT NULL,
    [tipo_utilizacion_code] VARCHAR(30)     NOT NULL,
    [motivo]                VARCHAR(150),
    [created_by]            BIGINT,
    [created_at]            DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_vuh_vacuno]      FOREIGN KEY ([vacuno_id])             REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vuh_utilizacion] FOREIGN KEY ([tipo_utilizacion_code]) REFERENCES [cat_tipo_utilizacion] ([code]),
    CONSTRAINT [fk_vuh_created_by]  FOREIGN KEY ([created_by])            REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_vuh_vacuno]     ON [vacuno_utilizacion_historial] ([vacuno_id]);
CREATE INDEX [idx_vuh_tipo]       ON [vacuno_utilizacion_historial] ([tipo_utilizacion_code]);
CREATE INDEX [idx_vuh_created_at] ON [vacuno_utilizacion_historial] ([created_at]);
GO


-- -----------------------------------------------------------------------------
-- vacuno_foto
-- Es_principal garantizado con UNIQUE filtrado (solo 1 = TRUE por vacuno).
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno_foto] (
    [id]           BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]    BIGINT          NOT NULL,
    [archivo_id]   BIGINT          NOT NULL,
    [es_principal] BIT             NOT NULL DEFAULT 0,
    [uploaded_by]  BIGINT,
    [created_at]   DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_vacuno_foto_vacuno]   FOREIGN KEY ([vacuno_id])   REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vacuno_foto_archivo]  FOREIGN KEY ([archivo_id])  REFERENCES [archivo] ([id]),
    CONSTRAINT [fk_vacuno_foto_uploaded] FOREIGN KEY ([uploaded_by]) REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_vacuno_foto_vacuno]  ON [vacuno_foto] ([vacuno_id]);
CREATE INDEX [idx_vacuno_foto_archivo] ON [vacuno_foto] ([archivo_id]);
GO

-- Garantiza una sola foto principal por vacuno (Índice Filtrado — SQL Server)
CREATE UNIQUE NONCLUSTERED INDEX [uq_vacuno_foto_principal]
    ON [vacuno_foto] ([vacuno_id])
    WHERE [es_principal] = 1;
GO


-- -----------------------------------------------------------------------------
-- vacuno_estado_historial
-- Campo vigente eliminado: el estado vigente = MAX(created_at) por vacuno_id (3FN-08).
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno_estado_historial] (
    [id]          BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]   BIGINT          NOT NULL,
    [estado_code] VARCHAR(15)     NOT NULL,
    [fecha_estado] DATE           NOT NULL,
    [motivo]      VARCHAR(150),
    [created_by]  BIGINT,
    [created_at]  DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_veh_vacuno]  FOREIGN KEY ([vacuno_id])   REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_veh_estado]  FOREIGN KEY ([estado_code]) REFERENCES [cat_estado_vacuno] ([code]),
    CONSTRAINT [fk_veh_created] FOREIGN KEY ([created_by])  REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_veh_vacuno]     ON [vacuno_estado_historial] ([vacuno_id]);
CREATE INDEX [idx_veh_estado]     ON [vacuno_estado_historial] ([estado_code]);
CREATE INDEX [idx_veh_fecha]      ON [vacuno_estado_historial] ([fecha_estado]);
CREATE INDEX [idx_veh_created_at] ON [vacuno_estado_historial] ([created_at]);
GO


-- -----------------------------------------------------------------------------
-- incidente_vacuno
-- -----------------------------------------------------------------------------
CREATE TABLE [incidente_vacuno] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]            BIGINT          NOT NULL,
    [fecha_incidente]      DATE            NOT NULL,
    [descripcion]          VARCHAR(150)    NOT NULL,
    [estado_registro_code] VARCHAR(30)     NOT NULL DEFAULT 'ACTIVO',
    [created_by]           BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_incidente_vacuno]  FOREIGN KEY ([vacuno_id])            REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_incidente_estado]  FOREIGN KEY ([estado_registro_code]) REFERENCES [cat_estado_registro] ([code]),
    CONSTRAINT [fk_incidente_created] FOREIGN KEY ([created_by])           REFERENCES [usuario] ([id]),
    -- CID: Integridad — fecha de incidente no futura
    CONSTRAINT [ck_incidente_fecha] CHECK ([fecha_incidente] <= CAST(GETDATE() AS DATE))
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_incidente_vacuno] ON [incidente_vacuno] ([vacuno_id]);
CREATE INDEX [idx_incidente_fecha]  ON [incidente_vacuno] ([fecha_incidente]);
CREATE INDEX [idx_incidente_estado] ON [incidente_vacuno] ([estado_registro_code]);
GO


-- =============================================================================
-- BLOQUE 5: PRODUCCIÓN DE LECHE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cat_estado_ordenio
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_ordenio] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_ordenio_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- ordenio
-- CID: Confidencialidad — datos de producción. Requiere rol: rol_encargado, rol_admin.
-- -----------------------------------------------------------------------------
CREATE TABLE [ordenio] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]               VARCHAR(15)     NOT NULL,
    [fecha_hora]           DATETIME2       NOT NULL,
    [vacuno_id]            BIGINT          NOT NULL,
    [encargado_usuario_id] BIGINT          NOT NULL,
    [litros]               NUMERIC(8, 3)   NOT NULL,
    [observaciones]        VARCHAR(150),
    [estado_ordenio_code]  VARCHAR(30)     NOT NULL DEFAULT 'ACTIVO',
    [created_by]           BIGINT,
    [updated_by]           BIGINT,
    [deleted_by]           BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [deleted_at]           DATETIME2,
    [motivo_eliminacion]   VARCHAR(250),
    CONSTRAINT [uq_ordenio_codigo]       UNIQUE ([codigo]),
    CONSTRAINT [uq_ordenio_vacuno_fecha] UNIQUE ([vacuno_id], [fecha_hora]),
    CONSTRAINT [fk_ordenio_vacuno]       FOREIGN KEY ([vacuno_id])            REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_ordenio_encargado]    FOREIGN KEY ([encargado_usuario_id]) REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_ordenio_estado]       FOREIGN KEY ([estado_ordenio_code])  REFERENCES [cat_estado_ordenio] ([code]),
    CONSTRAINT [fk_ordenio_created_by]   FOREIGN KEY ([created_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_ordenio_updated_by]   FOREIGN KEY ([updated_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_ordenio_deleted_by]   FOREIGN KEY ([deleted_by])           REFERENCES [usuario] ([id]),
    -- CID: Integridad — litros deben ser positivos
    CONSTRAINT [ck_ordenio_litros] CHECK ([litros] > 0),
    -- CID: Integridad — fecha no futura
    CONSTRAINT [ck_ordenio_fecha]  CHECK ([fecha_hora] <= SYSDATETIME())
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_ordenio_fecha_hora] ON [ordenio] ([fecha_hora]);
CREATE INDEX [idx_ordenio_vacuno]     ON [ordenio] ([vacuno_id]);
CREATE INDEX [idx_ordenio_encargado]  ON [ordenio] ([encargado_usuario_id]);
CREATE INDEX [idx_ordenio_estado]     ON [ordenio] ([estado_ordenio_code]);
CREATE INDEX [idx_ordenio_deleted_at] ON [ordenio] ([deleted_at]);
GO


-- -----------------------------------------------------------------------------
-- produccion_leche_estandar
-- Campo activo eliminado: el estándar vigente = fecha_fin IS NULL o MAX(fecha_inicio) (3FN-08).
-- -----------------------------------------------------------------------------
CREATE TABLE [produccion_leche_estandar] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]            BIGINT,
    [fecha_inicio]         DATE            NOT NULL,
    [fecha_fin]            DATE,
    [litros_esperados_dia] NUMERIC(8, 3)   NOT NULL,
    [descripcion]          VARCHAR(150),
    [created_by]           BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_ple_vacuno]     FOREIGN KEY ([vacuno_id])  REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_ple_created_by] FOREIGN KEY ([created_by]) REFERENCES [usuario] ([id]),
    -- CID: Integridad — litros esperados positivos
    CONSTRAINT [ck_ple_litros] CHECK ([litros_esperados_dia] > 0),
    -- CID: Integridad — rango de fechas coherente
    CONSTRAINT [ck_ple_fechas] CHECK ([fecha_fin] IS NULL OR [fecha_inicio] <= [fecha_fin])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_ple_vacuno]    ON [produccion_leche_estandar] ([vacuno_id]);
CREATE INDEX [idx_ple_fecha_ini] ON [produccion_leche_estandar] ([fecha_inicio]);
CREATE INDEX [idx_ple_fecha_fin] ON [produccion_leche_estandar] ([fecha_fin]);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_sequia
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_sequia] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_sequia_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- periodo_sequia
-- -----------------------------------------------------------------------------
CREATE TABLE [periodo_sequia] (
    [id]                 BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]          BIGINT          NOT NULL,
    [fecha_inicio]       DATE            NOT NULL,
    [fecha_fin_estimada] DATE,
    [fecha_fin_real]     DATE,
    [estado_sequia_code] VARCHAR(30)     NOT NULL,
    [motivo]             VARCHAR(150),
    [observaciones]      VARCHAR(150),
    [created_by]         BIGINT,
    [updated_by]         BIGINT,
    [created_at]         DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]         DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_sequia_vacuno]     FOREIGN KEY ([vacuno_id])          REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_sequia_estado]     FOREIGN KEY ([estado_sequia_code]) REFERENCES [cat_estado_sequia] ([code]),
    CONSTRAINT [fk_sequia_created_by] FOREIGN KEY ([created_by])         REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_sequia_updated_by] FOREIGN KEY ([updated_by])         REFERENCES [usuario] ([id]),
    -- CID: Integridad — coherencia de fechas
    CONSTRAINT [ck_sequia_fechas] CHECK (
        ([fecha_fin_estimada] IS NULL OR [fecha_inicio] <= [fecha_fin_estimada]) AND
        ([fecha_fin_real]     IS NULL OR [fecha_inicio] <= [fecha_fin_real])
    )
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_sequia_vacuno]      ON [periodo_sequia] ([vacuno_id]);
CREATE INDEX [idx_sequia_fecha_ini]   ON [periodo_sequia] ([fecha_inicio]);
CREATE INDEX [idx_sequia_fecha_fin_e] ON [periodo_sequia] ([fecha_fin_estimada]);
CREATE INDEX [idx_sequia_fecha_fin_r] ON [periodo_sequia] ([fecha_fin_real]);
CREATE INDEX [idx_sequia_estado]      ON [periodo_sequia] ([estado_sequia_code]);
GO


-- =============================================================================
-- BLOQUE 6: TRIAJE
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cat_tipo_peso
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_peso] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_tipo_peso_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- triaje
-- CID: Confidencialidad — datos médicos. Requiere rol: rol_veterinario, rol_encargado.
-- -----------------------------------------------------------------------------
CREATE TABLE [triaje] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]               VARCHAR(15)     NOT NULL,
    [fecha_hora]           DATETIME2       NOT NULL,
    [vacuno_id]            BIGINT          NOT NULL,
    [tipo_peso_code]       VARCHAR(30)     NOT NULL,
    [peso_kg]              NUMERIC(8, 2)   NOT NULL,
    [observaciones]        VARCHAR(150),
    [estado_registro_code] VARCHAR(30)     NOT NULL DEFAULT 'ACTIVO',
    [encargado_usuario_id] BIGINT,
    [created_by]           BIGINT,
    [updated_by]           BIGINT,
    [deleted_by]           BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [deleted_at]           DATETIME2,
    [motivo_eliminacion]   VARCHAR(250),
    CONSTRAINT [uq_triaje_codigo]            UNIQUE ([codigo]),
    CONSTRAINT [uq_triaje_vacuno_fecha_tipo] UNIQUE ([vacuno_id], [fecha_hora], [tipo_peso_code]),
    CONSTRAINT [fk_triaje_vacuno]            FOREIGN KEY ([vacuno_id])            REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_triaje_tipo_peso]         FOREIGN KEY ([tipo_peso_code])       REFERENCES [cat_tipo_peso] ([code]),
    CONSTRAINT [fk_triaje_estado]            FOREIGN KEY ([estado_registro_code]) REFERENCES [cat_estado_registro] ([code]),
    CONSTRAINT [fk_triaje_encargado]         FOREIGN KEY ([encargado_usuario_id]) REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_triaje_created_by]        FOREIGN KEY ([created_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_triaje_updated_by]        FOREIGN KEY ([updated_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_triaje_deleted_by]        FOREIGN KEY ([deleted_by])           REFERENCES [usuario] ([id]),
    -- CID: Integridad — peso debe ser positivo
    CONSTRAINT [ck_triaje_peso]  CHECK ([peso_kg] > 0),
    -- CID: Integridad — fecha no futura
    CONSTRAINT [ck_triaje_fecha] CHECK ([fecha_hora] <= SYSDATETIME())
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_triaje_fecha_hora] ON [triaje] ([fecha_hora]);
CREATE INDEX [idx_triaje_vacuno]     ON [triaje] ([vacuno_id]);
CREATE INDEX [idx_triaje_tipo_peso]  ON [triaje] ([tipo_peso_code]);
CREATE INDEX [idx_triaje_estado]     ON [triaje] ([estado_registro_code]);
CREATE INDEX [idx_triaje_deleted_at] ON [triaje] ([deleted_at]);
GO


-- =============================================================================
-- BLOQUE 7: CELO
-- =============================================================================

-- -----------------------------------------------------------------------------
-- celo_configuracion
-- -----------------------------------------------------------------------------
CREATE TABLE [celo_configuracion] (
    [id]                        BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [nombre]                    VARCHAR(80)     NOT NULL,
    [dias_ciclo_estandar]       INTEGER         NOT NULL,
    [dias_alerta_previa]        INTEGER         NOT NULL,
    [dias_tolerancia_posterior] INTEGER         NOT NULL,
    [activo]                    BIT             NOT NULL DEFAULT 1,
    [created_by]                BIGINT,
    [created_at]                DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]                DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_celo_config_created_by]   FOREIGN KEY ([created_by]) REFERENCES [usuario] ([id]),
    -- CID: Integridad — días deben ser positivos/no negativos
    CONSTRAINT [ck_celo_config_dias_ciclo] CHECK ([dias_ciclo_estandar] > 0),
    CONSTRAINT [ck_celo_config_dias_alerta] CHECK ([dias_alerta_previa] >= 0),
    CONSTRAINT [ck_celo_config_dias_tol]   CHECK ([dias_tolerancia_posterior] >= 0)
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_celo_config_activo] ON [celo_configuracion] ([activo]);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_celo
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_celo] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_celo_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_caracteristica_celo
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_caracteristica_celo] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(50)     NOT NULL,
    [descripcion] VARCHAR(150),
    [activo]      BIT             NOT NULL DEFAULT 1,
    CONSTRAINT [uq_cat_caracteristica_celo_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- celo_registro
-- CID: Confidencialidad — datos reproductivos sensibles.
--   Requiere rol: rol_veterinario, rol_encargado.
-- -----------------------------------------------------------------------------
CREATE TABLE [celo_registro] (
    [id]                   BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]               VARCHAR(15)     NOT NULL,
    [fecha_hora]           DATETIME2       NOT NULL,
    [vacuno_id]            BIGINT          NOT NULL,
    [encargado_usuario_id] BIGINT          NOT NULL,
    [observaciones]        VARCHAR(150),
    [estado_registro_code] VARCHAR(30)     NOT NULL DEFAULT 'ACTIVO',
    [created_by]           BIGINT,
    [updated_by]           BIGINT,
    [deleted_by]           BIGINT,
    [created_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]           DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [deleted_at]           DATETIME2,
    [motivo_eliminacion]   VARCHAR(250),
    CONSTRAINT [uq_celo_registro_codigo]       UNIQUE ([codigo]),
    CONSTRAINT [uq_celo_registro_vacuno_fecha] UNIQUE ([vacuno_id], [fecha_hora]),
    CONSTRAINT [fk_celo_registro_vacuno]       FOREIGN KEY ([vacuno_id])            REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_celo_registro_encargado]    FOREIGN KEY ([encargado_usuario_id]) REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_celo_registro_estado]       FOREIGN KEY ([estado_registro_code]) REFERENCES [cat_estado_registro] ([code]),
    CONSTRAINT [fk_celo_registro_created_by]   FOREIGN KEY ([created_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_celo_registro_updated_by]   FOREIGN KEY ([updated_by])           REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_celo_registro_deleted_by]   FOREIGN KEY ([deleted_by])           REFERENCES [usuario] ([id]),
    -- CID: Integridad — fecha de celo no futura
    CONSTRAINT [ck_celo_registro_fecha] CHECK ([fecha_hora] <= SYSDATETIME())
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_celo_registro_fecha_hora] ON [celo_registro] ([fecha_hora]);
CREATE INDEX [idx_celo_registro_vacuno]     ON [celo_registro] ([vacuno_id]);
CREATE INDEX [idx_celo_registro_encargado]  ON [celo_registro] ([encargado_usuario_id]);
CREATE INDEX [idx_celo_registro_estado]     ON [celo_registro] ([estado_registro_code]);
CREATE INDEX [idx_celo_registro_deleted_at] ON [celo_registro] ([deleted_at]);
GO


-- -----------------------------------------------------------------------------
-- celo_registro_caracteristica
-- 2FN-02: PK compuesta (celo_registro_id, caracteristica_code) — sin surrogate id.
-- -----------------------------------------------------------------------------
CREATE TABLE [celo_registro_caracteristica] (
    [celo_registro_id]    BIGINT          NOT NULL,
    [caracteristica_code] VARCHAR(30)     NOT NULL,
    CONSTRAINT [pk_celo_reg_caract]    PRIMARY KEY ([celo_registro_id], [caracteristica_code]),
    CONSTRAINT [fk_crc_celo_registro]  FOREIGN KEY ([celo_registro_id])   REFERENCES [celo_registro] ([id]),
    CONSTRAINT [fk_crc_caracteristica] FOREIGN KEY ([caracteristica_code]) REFERENCES [cat_caracteristica_celo] ([code])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_crc_celo_registro]  ON [celo_registro_caracteristica] ([celo_registro_id]);
CREATE INDEX [idx_crc_caracteristica] ON [celo_registro_caracteristica] ([caracteristica_code]);
GO


-- -----------------------------------------------------------------------------
-- celo_registro_caracteristica_libre
-- -----------------------------------------------------------------------------
CREATE TABLE [celo_registro_caracteristica_libre] (
    [id]               BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [celo_registro_id] BIGINT          NOT NULL,
    [descripcion]      VARCHAR(80)     NOT NULL,
    [created_at]       DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_crcl_celo_registro] FOREIGN KEY ([celo_registro_id])
        REFERENCES [celo_registro] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_crcl_celo_registro] ON [celo_registro_caracteristica_libre] ([celo_registro_id]);
GO


-- =============================================================================
-- BLOQUE 8: REPRODUCCIÓN / FECUNDACIÓN
-- =============================================================================

-- -----------------------------------------------------------------------------
-- cat_tipo_fecundacion
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_tipo_fecundacion] (
    [code]        VARCHAR(40)     PRIMARY KEY,
    [nombre]      VARCHAR(80)     NOT NULL,
    [descripcion] VARCHAR(200),
    CONSTRAINT [uq_cat_tipo_fecundacion_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_resultado_fecundacion
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_resultado_fecundacion] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(60)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_resultado_fecundacion_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_fecundacion_vacuno
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_fecundacion_vacuno] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(60)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_fec_vacuno_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- cat_estado_trazabilidad
-- -----------------------------------------------------------------------------
CREATE TABLE [cat_estado_trazabilidad] (
    [code]        VARCHAR(30)     PRIMARY KEY,
    [nombre]      VARCHAR(60)     NOT NULL,
    [descripcion] VARCHAR(150),
    CONSTRAINT [uq_cat_estado_trazabilidad_nombre] UNIQUE ([nombre])
);
GO


-- -----------------------------------------------------------------------------
-- reproductor_externo
-- CID: Confidencialidad — puede contener datos de terceros.
--   Requiere rol: rol_veterinario, rol_admin.
-- -----------------------------------------------------------------------------
CREATE TABLE [reproductor_externo] (
    [id]             BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [nombre]         VARCHAR(100)    NOT NULL,
    [codigo_externo] VARCHAR(50),
    [sexo_code]      VARCHAR(10),
    [descripcion]    VARCHAR(150),
    [activo]         BIT             NOT NULL DEFAULT 1,
    [created_by]     BIGINT,
    [created_at]     DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [fk_reproductor_sexo]       FOREIGN KEY ([sexo_code])   REFERENCES [cat_sexo] ([code]),
    CONSTRAINT [fk_reproductor_created_by] FOREIGN KEY ([created_by])  REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_reproductor_nombre] ON [reproductor_externo] ([nombre]);
CREATE INDEX [idx_reproductor_codigo] ON [reproductor_externo] ([codigo_externo]);
GO


-- -----------------------------------------------------------------------------
-- fecundacion
-- 3FN-06: codigo_semen y codigo_embrion movidos a subentidades.
-- 3FN-07: donante movido a fecundacion_donante.
-- CID: Confidencialidad — datos reproductivos médicos sensibles.
--   Requiere rol: rol_veterinario.
-- -----------------------------------------------------------------------------
CREATE TABLE [fecundacion] (
    [id]                         BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [codigo]                     VARCHAR(15)     NOT NULL,
    [tipo_fecundacion_code]      VARCHAR(40)     NOT NULL,
    [vacuno_receptor_id]         BIGINT          NOT NULL,
    [celo_registro_id]           BIGINT,
    [fecha_procedimiento]        DATE            NOT NULL,
    [responsable_id]             BIGINT          NOT NULL,
    [resultado_code]             VARCHAR(30)     NOT NULL,
    [observaciones_veterinarias] VARCHAR(250),
    [created_by]                 BIGINT,
    [updated_by]                 BIGINT,
    [created_at]                 DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]                 DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [uq_fecundacion_codigo]      UNIQUE ([codigo]),
    CONSTRAINT [fk_fecundacion_tipo]        FOREIGN KEY ([tipo_fecundacion_code]) REFERENCES [cat_tipo_fecundacion] ([code]),
    CONSTRAINT [fk_fecundacion_receptor]    FOREIGN KEY ([vacuno_receptor_id])    REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_fecundacion_celo]        FOREIGN KEY ([celo_registro_id])      REFERENCES [celo_registro] ([id]),
    CONSTRAINT [fk_fecundacion_responsable] FOREIGN KEY ([responsable_id])        REFERENCES [responsable] ([id]),
    CONSTRAINT [fk_fecundacion_resultado]   FOREIGN KEY ([resultado_code])        REFERENCES [cat_resultado_fecundacion] ([code]),
    CONSTRAINT [fk_fecundacion_created_by]  FOREIGN KEY ([created_by])            REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_fecundacion_updated_by]  FOREIGN KEY ([updated_by])            REFERENCES [usuario] ([id]),
    -- CID: Integridad — fecha de procedimiento no futura
    CONSTRAINT [ck_fecundacion_fecha] CHECK ([fecha_procedimiento] <= CAST(GETDATE() AS DATE))
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_fecundacion_tipo]        ON [fecundacion] ([tipo_fecundacion_code]);
CREATE INDEX [idx_fecundacion_receptor]    ON [fecundacion] ([vacuno_receptor_id]);
CREATE INDEX [idx_fecundacion_celo]        ON [fecundacion] ([celo_registro_id]);
CREATE INDEX [idx_fecundacion_fecha]       ON [fecundacion] ([fecha_procedimiento]);
CREATE INDEX [idx_fecundacion_responsable] ON [fecundacion] ([responsable_id]);
CREATE INDEX [idx_fecundacion_resultado]   ON [fecundacion] ([resultado_code]);
GO


-- -----------------------------------------------------------------------------
-- fecundacion_donante  [NUEVA — 3FN-07]
-- Regla: exactamente uno de (vacuno_donante_id, externo_donante_id) debe ser NOT NULL.
-- CID: Confidencialidad — datos de reproductores (internos/externos).
-- -----------------------------------------------------------------------------
CREATE TABLE [fecundacion_donante] (
    [fecundacion_id]     BIGINT          NOT NULL,
    [tipo_donante]       VARCHAR(10)     NOT NULL,  -- 'INTERNO' | 'EXTERNO'
    [vacuno_donante_id]  BIGINT,
    [externo_donante_id] BIGINT,
    CONSTRAINT [pk_fecundacion_donante]   PRIMARY KEY ([fecundacion_id]),
    CONSTRAINT [fk_fd_fecundacion]        FOREIGN KEY ([fecundacion_id])     REFERENCES [fecundacion] ([id]),
    CONSTRAINT [fk_fd_vacuno_donante]     FOREIGN KEY ([vacuno_donante_id])  REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_fd_externo_donante]    FOREIGN KEY ([externo_donante_id]) REFERENCES [reproductor_externo] ([id]),
    -- CID: Integridad — exactamente un donante según tipo
    CONSTRAINT [ck_fd_tipo_donante] CHECK ([tipo_donante] IN ('INTERNO', 'EXTERNO')),
    CONSTRAINT [ck_fd_donante_exclusivo] CHECK (
        ([tipo_donante] = 'INTERNO' AND [vacuno_donante_id]  IS NOT NULL AND [externo_donante_id] IS NULL) OR
        ([tipo_donante] = 'EXTERNO' AND [externo_donante_id] IS NOT NULL AND [vacuno_donante_id]  IS NULL)
    )
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_fd_vacuno_donante]  ON [fecundacion_donante] ([vacuno_donante_id]);
CREATE INDEX [idx_fd_externo_donante] ON [fecundacion_donante] ([externo_donante_id]);
GO


-- -----------------------------------------------------------------------------
-- fecundacion_inseminacion  [NUEVA — 3FN-06]
-- -----------------------------------------------------------------------------
CREATE TABLE [fecundacion_inseminacion] (
    [fecundacion_id] BIGINT          PRIMARY KEY,
    [codigo_semen]   VARCHAR(30)     NOT NULL,
    CONSTRAINT [fk_fins_fecundacion] FOREIGN KEY ([fecundacion_id]) REFERENCES [fecundacion] ([id])
);
GO


-- -----------------------------------------------------------------------------
-- fecundacion_embrion  [NUEVA — 3FN-06]
-- -----------------------------------------------------------------------------
CREATE TABLE [fecundacion_embrion] (
    [fecundacion_id] BIGINT          PRIMARY KEY,
    [codigo_embrion] VARCHAR(30)     NOT NULL,
    CONSTRAINT [fk_femb_fecundacion] FOREIGN KEY ([fecundacion_id]) REFERENCES [fecundacion] ([id])
);
GO


-- -----------------------------------------------------------------------------
-- fecundacion_cria
-- -----------------------------------------------------------------------------
CREATE TABLE [fecundacion_cria] (
    [id]                      BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [fecundacion_id]          BIGINT          NOT NULL,
    [vacuno_hijo_id]          BIGINT          NOT NULL,
    [estado_trazabilidad_code] VARCHAR(30)    NOT NULL DEFAULT 'VALIDA',
    [fecha_vinculacion]       DATE            NOT NULL,
    [observaciones]           VARCHAR(150),
    [created_by]              BIGINT,
    [updated_by]              BIGINT,
    [created_at]              DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [updated_at]              DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT [uq_fecundacion_cria_fec_vacuno] UNIQUE ([fecundacion_id], [vacuno_hijo_id]),
    CONSTRAINT [fk_fc_fecundacion]  FOREIGN KEY ([fecundacion_id])           REFERENCES [fecundacion] ([id]),
    CONSTRAINT [fk_fc_vacuno_hijo]  FOREIGN KEY ([vacuno_hijo_id])           REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_fc_trazabilidad] FOREIGN KEY ([estado_trazabilidad_code]) REFERENCES [cat_estado_trazabilidad] ([code]),
    CONSTRAINT [fk_fc_created_by]   FOREIGN KEY ([created_by])               REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_fc_updated_by]   FOREIGN KEY ([updated_by])               REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_fc_fecundacion]  ON [fecundacion_cria] ([fecundacion_id]);
CREATE INDEX [idx_fc_vacuno_hijo]  ON [fecundacion_cria] ([vacuno_hijo_id]);
CREATE INDEX [idx_fc_trazabilidad] ON [fecundacion_cria] ([estado_trazabilidad_code]);
GO


-- -----------------------------------------------------------------------------
-- vacuno_estado_fecundacion_historial
-- Campo vigente eliminado: estado vigente = MAX(created_at) por vacuno_id (3FN-08).
-- CID: Confidencialidad — historial reproductivo sensible.
--   Requiere rol: rol_veterinario, rol_admin.
-- -----------------------------------------------------------------------------
CREATE TABLE [vacuno_estado_fecundacion_historial] (
    [id]                      BIGINT          IDENTITY(1,1) PRIMARY KEY,
    [vacuno_id]               BIGINT          NOT NULL,
    [estado_fecundacion_code] VARCHAR(30)     NOT NULL,
    [fecundacion_id]          BIGINT,
    [fecha_actualizacion]     DATE            NOT NULL,
    [observaciones]           VARCHAR(150),
    [created_by]              BIGINT,
    [deleted_by]              BIGINT,
    [created_at]              DATETIME2       NOT NULL DEFAULT SYSDATETIME(),
    [deleted_at]              DATETIME2,
    [motivo_eliminacion]      VARCHAR(250),
    CONSTRAINT [fk_vefh_vacuno]      FOREIGN KEY ([vacuno_id])               REFERENCES [vacuno] ([id]),
    CONSTRAINT [fk_vefh_estado]      FOREIGN KEY ([estado_fecundacion_code]) REFERENCES [cat_estado_fecundacion_vacuno] ([code]),
    CONSTRAINT [fk_vefh_fecundacion] FOREIGN KEY ([fecundacion_id])          REFERENCES [fecundacion] ([id]),
    CONSTRAINT [fk_vefh_created_by]  FOREIGN KEY ([created_by])              REFERENCES [usuario] ([id]),
    CONSTRAINT [fk_vefh_deleted_by]  FOREIGN KEY ([deleted_by])              REFERENCES [usuario] ([id])
);
GO

-- CID: Disponibilidad
CREATE INDEX [idx_vefh_vacuno]      ON [vacuno_estado_fecundacion_historial] ([vacuno_id]);
CREATE INDEX [idx_vefh_estado]      ON [vacuno_estado_fecundacion_historial] ([estado_fecundacion_code]);
CREATE INDEX [idx_vefh_fecundacion] ON [vacuno_estado_fecundacion_historial] ([fecundacion_id]);
CREATE INDEX [idx_vefh_fecha]       ON [vacuno_estado_fecundacion_historial] ([fecha_actualizacion]);
CREATE INDEX [idx_vefh_created_at]  ON [vacuno_estado_fecundacion_historial] ([created_at]);
CREATE INDEX [idx_vefh_deleted_at]  ON [vacuno_estado_fecundacion_historial] ([deleted_at]);
GO


-- =============================================================================
-- BLOQUE 9: VISTAS
-- Los campos derivados se calculan en tiempo de consulta sobre las fuentes de verdad.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- v_celo_estado_vacuno
-- Calcula en tiempo de consulta lo que antes era tabla celo_estado_vacuno.
-- Nota T-SQL: DISTINCT ON no existe; se reemplaza por subconsulta con ROW_NUMBER.
-- Nota T-SQL: ::DATE se reemplaza por CAST(... AS DATE).
-- Nota T-SQL: TRUE se reemplaza por 1.
-- -----------------------------------------------------------------------------
CREATE VIEW [v_celo_estado_vacuno] AS
SELECT
    v.[id]                                                              AS vacuno_id,
    v.[nombre]                                                          AS vacuno_nombre,
    v.[sexo_code],
    -- Último celo registrado (no eliminado)
    CAST(MAX(cr.[fecha_hora]) AS DATE)                                  AS fecha_ultimo_celo,
    -- Conteo de celos válidos
    COUNT(cr.[id])                                                      AS veces_celo,
    -- Crías vinculadas
    COUNT(DISTINCT fc.[id])                                             AS crias,
    -- Fecha estimada próximo celo
    DATEADD(
        DAY,
        (SELECT TOP 1 [dias_ciclo_estandar] FROM [celo_configuracion]
         WHERE [activo] = 1 ORDER BY [updated_at] DESC),
        CAST(MAX(cr.[fecha_hora]) AS DATE)
    )                                                                   AS fecha_proximo_celo_estimada,
    -- Días restantes (negativo = ya pasó)
    DATEDIFF(
        DAY,
        CAST(GETDATE() AS DATE),
        DATEADD(
            DAY,
            (SELECT TOP 1 [dias_ciclo_estandar] FROM [celo_configuracion]
             WHERE [activo] = 1 ORDER BY [updated_at] DESC),
            CAST(MAX(cr.[fecha_hora]) AS DATE)
        )
    )                                                                   AS dias_restantes,
    -- Estado calculado según ventana de alerta/tolerancia
    CASE
        WHEN MAX(cr.[fecha_hora]) IS NULL THEN 'SIN_DATOS'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE),
             DATEADD(DAY,
                (SELECT TOP 1 [dias_ciclo_estandar] FROM [celo_configuracion]
                 WHERE [activo] = 1 ORDER BY [updated_at] DESC),
                CAST(MAX(cr.[fecha_hora]) AS DATE))
             ) BETWEEN 0 AND
             (SELECT TOP 1 [dias_alerta_previa] FROM [celo_configuracion]
              WHERE [activo] = 1 ORDER BY [updated_at] DESC)
        THEN 'PROXIMO'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE),
             DATEADD(DAY,
                (SELECT TOP 1 [dias_ciclo_estandar] FROM [celo_configuracion]
                 WHERE [activo] = 1 ORDER BY [updated_at] DESC),
                CAST(MAX(cr.[fecha_hora]) AS DATE))
             ) BETWEEN
             -(SELECT TOP 1 [dias_tolerancia_posterior] FROM [celo_configuracion]
               WHERE [activo] = 1 ORDER BY [updated_at] DESC) AND -1
        THEN 'EN_CELO'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE),
             DATEADD(DAY,
                (SELECT TOP 1 [dias_ciclo_estandar] FROM [celo_configuracion]
                 WHERE [activo] = 1 ORDER BY [updated_at] DESC),
                CAST(MAX(cr.[fecha_hora]) AS DATE))
             ) < -(SELECT TOP 1 [dias_tolerancia_posterior] FROM [celo_configuracion]
                   WHERE [activo] = 1 ORDER BY [updated_at] DESC)
        THEN 'PASO'
        ELSE 'SIN_DATOS'
    END                                                                 AS estado_celo_calculado
FROM
    [vacuno] v
    LEFT JOIN [celo_registro] cr
        ON cr.[vacuno_id] = v.[id]
        AND cr.[deleted_at] IS NULL
        AND cr.[estado_registro_code] = 'ACTIVO'
    LEFT JOIN [fecundacion_cria] fc
        ON fc.[vacuno_hijo_id] = v.[id]
WHERE
    v.[deleted_at] IS NULL
    AND v.[sexo_code] = 'HEMBRA'
GROUP BY
    v.[id], v.[nombre], v.[sexo_code];
GO


-- -----------------------------------------------------------------------------
-- v_vacuno_utilizacion_vigente
-- Estado de utilización vigente por vacuno (tipo con MAX created_at).
-- Nota T-SQL: DISTINCT ON reemplazado por ROW_NUMBER() OVER (PARTITION BY).
-- -----------------------------------------------------------------------------
CREATE VIEW [v_vacuno_utilizacion_vigente] AS
SELECT
    [vacuno_id],
    [tipo_utilizacion_code],
    [created_at] AS fecha_desde
FROM (
    SELECT
        [vacuno_id],
        [tipo_utilizacion_code],
        [created_at],
        ROW_NUMBER() OVER (PARTITION BY [vacuno_id] ORDER BY [created_at] DESC) AS rn
    FROM [vacuno_utilizacion_historial]
) sub
WHERE rn = 1;
GO


-- -----------------------------------------------------------------------------
-- v_vacuno_estado_vigente
-- Estado sanitario vigente por vacuno (registro con MAX created_at).
-- Nota T-SQL: DISTINCT ON reemplazado por ROW_NUMBER() OVER (PARTITION BY).
-- -----------------------------------------------------------------------------
CREATE VIEW [v_vacuno_estado_vigente] AS
SELECT
    [vacuno_id],
    [estado_code],
    [fecha_estado],
    [created_at] AS fecha_registro
FROM (
    SELECT
        [vacuno_id],
        [estado_code],
        [fecha_estado],
        [created_at],
        ROW_NUMBER() OVER (PARTITION BY [vacuno_id] ORDER BY [created_at] DESC) AS rn
    FROM [vacuno_estado_historial]
) sub
WHERE rn = 1;
GO


-- -----------------------------------------------------------------------------
-- v_produccion_leche_estandar_vigente
-- Estándar de litros vigente por vacuno (o general si vacuno_id IS NULL).
-- Nota T-SQL: DISTINCT ON reemplazado por ROW_NUMBER() OVER (PARTITION BY).
-- Nota T-SQL: CURRENT_DATE reemplazado por CAST(GETDATE() AS DATE).
-- -----------------------------------------------------------------------------
CREATE VIEW [v_produccion_leche_estandar_vigente] AS
SELECT
    [vacuno_id],
    [litros_esperados_dia],
    [fecha_inicio],
    [descripcion]
FROM (
    SELECT
        [vacuno_id],
        [litros_esperados_dia],
        [fecha_inicio],
        [descripcion],
        ROW_NUMBER() OVER (PARTITION BY [vacuno_id] ORDER BY [fecha_inicio] DESC) AS rn
    FROM [produccion_leche_estandar]
    WHERE
        [fecha_fin] IS NULL
        OR [fecha_fin] >= CAST(GETDATE() AS DATE)
) sub
WHERE rn = 1;
GO


-- =============================================================================
-- FIN DEL SCRIPT
-- Motor: SQL Server 2022
-- Normalización: 3FN estricta
-- Tríada CID: comentarios distribuidos en el script
-- Ley 29733: tablas sensibles marcadas con rol sugerido
-- Notas de migración clave:
--   · GENERATED ALWAYS AS IDENTITY → BIGINT IDENTITY(1,1)
--   · TIMESTAMPTZ → DATETIME2
--   · BOOLEAN → BIT  (TRUE/FALSE → 1/0)
--   · JSONB → NVARCHAR(MAX)
--   · INET → NVARCHAR(45)
--   · TEXT → NVARCHAR(MAX)
--   · NOW() → SYSDATETIME()
--   · CURRENT_DATE → CAST(GETDATE() AS DATE)
--   · UNIQUE parcial (WHERE es_principal = TRUE) → Filtered Index (WHERE es_principal = 1)
--   · DISTINCT ON → ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...)
--   · Catálogos con PK VARCHAR: sin IDENTITY (correcto)
-- =============================================================================
