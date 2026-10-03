/* =====================================================================
   ZooTech Platform - Esquema base de la base de datos de TENANT
   Motor destino : SQL Server 2025 (compatibilidad 170)
   Origen        : Database Backup - Tenant - ZooTech.bacpac
                   (exportado el 2026-07-05 desde SQL Server 2025 RTM 17.0.1000.7)
   Contenido     : tablas, PK, UNIQUE, DEFAULT, CHECK, FOREIGN KEY, indices y vistas
   NO incluye    : datos / INSERT, logins, usuarios ni permisos
   Uso           : ejecutar dentro de la base de datos destino ya creada
                   (sqlcmd -d <BD> -I -i este_script.sql  /  SSMS / Azure Data Studio)
   Nota          : el script no usa variables de scripting de sqlcmd; el nombre
                   de la BD lo define la conexion o el USE de abajo.
   ===================================================================== */

/* -- Opcional: crear la base de datos (la coleccion es la del origen) --
IF DB_ID(N'ZooTechTenant') IS NULL
    CREATE DATABASE [ZooTechTenant] COLLATE SQL_Latin1_General_CP1_CI_AS;
GO
USE [ZooTechTenant];
GO
*/

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET NOCOUNT ON;
GO

/* ============================ 1. TABLAS ============================ */

CREATE TABLE [dbo].[cat_caracteristica_celo] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_cara__357D4CF858E76519] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_caracteristica_celo_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_carac__activ__336AA144] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_color] (
    [code]   varchar(30) NOT NULL,
    [nombre] varchar(30) NOT NULL,
    [activo] bit         NOT NULL,
    CONSTRAINT [PK__cat_colo__357D4CF894DF5306] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_color_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_color__activ__1F98B2C1] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_estado_celo] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF840685346] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_celo_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_fecundacion_vacuno] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(60)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF838EB0524] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_fec_vacuno_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_ordenio] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF8FBA8C253] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_ordenio_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_registro] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF8DC626498] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_registro_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_sequia] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF8784A38BD] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_sequia_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_trazabilidad] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(60)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF833C0D6A2] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_trazabilidad_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_estado_vacuno] (
    [code]        varchar(15)  NOT NULL,
    [nombre]      varchar(30)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_esta__357D4CF8811A8632] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_estado_vacuno_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_formato_reporte] (
    [code]   varchar(10) NOT NULL,
    [nombre] varchar(20) NOT NULL,
    CONSTRAINT [PK__cat_form__357D4CF85032BFA3] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_formato_reporte_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_modulo] (
    [code]        varchar(40)  NOT NULL,
    [nombre]      varchar(80)  NOT NULL,
    [descripcion] varchar(250) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_modu__357D4CF859FEE271] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_modulo_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_modul__activ__656C112C] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_raza] (
    [code]   varchar(30) NOT NULL,
    [nombre] varchar(50) NOT NULL,
    [activo] bit         NOT NULL,
    CONSTRAINT [PK__cat_raza__357D4CF8AEF2926E] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_raza_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_raza__activo__1BC821DD] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_resultado_fecundacion] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(60)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_resu__357D4CF84DD5891D] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_resultado_fecundacion_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_sexo] (
    [code]        varchar(10)  NOT NULL,
    [nombre]      varchar(15)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_sexo__357D4CF81E3A02DA] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_sexo_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_tipo_adquisicion] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF84A5809D0] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_adquisicion_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_tipo___activ__236943A5] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_tipo_archivo] (
    [extension] varchar(10) NOT NULL,
    [mime_type] varchar(80) NOT NULL,
    CONSTRAINT [PK__cat_tipo__51EBE911EE7FD96A] PRIMARY KEY CLUSTERED ([extension])
);
GO

CREATE TABLE [dbo].[cat_tipo_fecundacion] (
    [code]        varchar(40)  NOT NULL,
    [nombre]      varchar(80)  NOT NULL,
    [descripcion] varchar(200) NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF89E9CC9C8] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_fecundacion_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_tipo_peso] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF8E03DBB3A] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_peso_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_tipo___activ__14E61A24] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[cat_tipo_responsable] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF80C263D30] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_responsable_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[cat_tipo_utilizacion] (
    [code]        varchar(30)  NOT NULL,
    [nombre]      varchar(50)  NOT NULL,
    [descripcion] varchar(150) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF841B174F0] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_utilizacion_nombre] UNIQUE ([nombre]),
    CONSTRAINT [DF__cat_tipo___activ__2739D489] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[geo_departamento] (
    [codigo] varchar(2)  NOT NULL,
    [nombre] varchar(60) NOT NULL,
    CONSTRAINT [PK__geo_depa__40F9A20746960A5A] PRIMARY KEY CLUSTERED ([codigo]),
    CONSTRAINT [uq_geo_departamento_nombre] UNIQUE ([nombre])
);
GO

CREATE TABLE [dbo].[usuario] (
    [id]              bigint       IDENTITY(1,1) NOT NULL,
    [codigo]          varchar(15)  NOT NULL,
    [nombre_usuario]  varchar(50)  NOT NULL,
    [nombre_completo] varchar(100) NOT NULL,
    [correo]          varchar(120) NULL,
    [activo]          bit          NOT NULL,
    [created_at]      datetime2(7) NOT NULL,
    [updated_at]      datetime2(7) NOT NULL,
    CONSTRAINT [PK__usuario__3213E83F94B0B488] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_usuario_codigo] UNIQUE ([codigo]),
    CONSTRAINT [uq_usuario_correo] UNIQUE ([correo]),
    CONSTRAINT [uq_usuario_nombre_usuario] UNIQUE ([nombre_usuario]),
    CONSTRAINT [DF__usuario__activo__5FB337D6] DEFAULT ((1)) FOR [activo],
    CONSTRAINT [DF__usuario__created__60A75C0F] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__usuario__updated__619B8048] DEFAULT (sysdatetime()) FOR [updated_at]
);
GO

CREATE TABLE [dbo].[archivo] (
    [id]                bigint        IDENTITY(1,1) NOT NULL,
    [modulo_code]       varchar(40)   NOT NULL,
    [nombre_original]   varchar(150)  NOT NULL,
    [nombre_almacenado] varchar(150)  NOT NULL,
    [ruta_archivo]      nvarchar(MAX) NOT NULL,
    [extension]         varchar(10)   NOT NULL,
    [tamano_bytes]      bigint        NULL,
    [hash_sha256]       varchar(64)   NULL,
    [creado_por]        bigint        NULL,
    [created_at]        datetime2(7)  NOT NULL,
    CONSTRAINT [PK__archivo__3213E83FC88C9300] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__archivo__created__74AE54BC] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[bitacora_auditoria] (
    [id]               bigint        IDENTITY(1,1) NOT NULL,
    [modulo_code]      varchar(40)   NOT NULL,
    [entidad]          varchar(80)   NOT NULL,
    [entidad_id]       varchar(80)   NOT NULL,
    [accion]           varchar(40)   NOT NULL,
    [datos_anteriores] nvarchar(MAX) NULL,
    [datos_nuevos]     nvarchar(MAX) NULL,
    [motivo]           varchar(250)  NULL,
    [usuario_id]       bigint        NULL,
    [ip_origen]        nvarchar(45)  NULL,
    [user_agent]       varchar(250)  NULL,
    [created_at]       datetime2(7)  NOT NULL,
    CONSTRAINT [PK__bitacora__3213E83FFF8F8901] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__bitacora___creat__00200768] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[cat_tipo_reporte] (
    [code]        varchar(60)  NOT NULL,
    [modulo_code] varchar(40)  NOT NULL,
    [nombre]      varchar(120) NOT NULL,
    [descripcion] varchar(300) NULL,
    [activo]      bit          NOT NULL,
    CONSTRAINT [PK__cat_tipo__357D4CF89CA3AAA9] PRIMARY KEY CLUSTERED ([code]),
    CONSTRAINT [uq_cat_tipo_reporte_modulo_nombre] UNIQUE ([modulo_code], [nombre]),
    CONSTRAINT [DF__cat_tipo___activ__6EF57B66] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[celo_configuracion] (
    [id]                        bigint       IDENTITY(1,1) NOT NULL,
    [nombre]                    varchar(80)  NOT NULL,
    [dias_ciclo_estandar]       int          NOT NULL,
    [dias_alerta_previa]        int          NOT NULL,
    [dias_tolerancia_posterior] int          NOT NULL,
    [activo]                    bit          NOT NULL,
    [created_by]                bigint       NULL,
    [created_at]                datetime2(7) NOT NULL,
    [updated_at]                datetime2(7) NOT NULL,
    CONSTRAINT [PK__celo_con__3213E83F01A0C7E2] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__celo_conf__creat__27F8EE98] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__celo_conf__updat__28ED12D1] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [DF__celo_conf__activ__2704CA5F] DEFAULT ((1)) FOR [activo],
    CONSTRAINT [ck_celo_config_dias_alerta] CHECK ([dias_alerta_previa]>=(0)),
    CONSTRAINT [ck_celo_config_dias_ciclo] CHECK ([dias_ciclo_estandar]>(0)),
    CONSTRAINT [ck_celo_config_dias_tol] CHECK ([dias_tolerancia_posterior]>=(0))
);
GO

CREATE TABLE [dbo].[geo_provincia] (
    [codigo]              varchar(4)  NOT NULL,
    [departamento_codigo] varchar(2)  NOT NULL,
    [nombre]              varchar(60) NOT NULL,
    CONSTRAINT [PK__geo_prov__40F9A207128DD835] PRIMARY KEY CLUSTERED ([codigo]),
    CONSTRAINT [uq_geo_provincia_dep_nombre] UNIQUE ([departamento_codigo], [nombre])
);
GO

CREATE TABLE [dbo].[parametro_sistema] (
    [id]          bigint       IDENTITY(1,1) NOT NULL,
    [modulo_code] varchar(40)  NOT NULL,
    [clave]       varchar(80)  NOT NULL,
    [valor]       varchar(150) NOT NULL,
    [descripcion] varchar(250) NULL,
    [created_at]  datetime2(7) NOT NULL,
    [updated_at]  datetime2(7) NOT NULL,
    CONSTRAINT [PK__parametr__3213E83F4E6A83B1] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_parametro_modulo_clave] UNIQUE ([modulo_code], [clave]),
    CONSTRAINT [DF__parametro__creat__7B5B524B] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__parametro__updat__7C4F7684] DEFAULT (sysdatetime()) FOR [updated_at]
);
GO

CREATE TABLE [dbo].[reproductor_externo] (
    [id]             bigint       IDENTITY(1,1) NOT NULL,
    [nombre]         varchar(100) NOT NULL,
    [codigo_externo] varchar(50)  NULL,
    [sexo_code]      varchar(10)  NULL,
    [descripcion]    varchar(150) NULL,
    [activo]         bit          NOT NULL,
    [created_by]     bigint       NULL,
    [created_at]     datetime2(7) NOT NULL,
    CONSTRAINT [PK__reproduc__3213E83F73DA3FD4] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__reproduct__activ__56B3DD81] DEFAULT ((1)) FOR [activo],
    CONSTRAINT [DF__reproduct__creat__57A801BA] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[responsable] (
    [id]                    bigint       IDENTITY(1,1) NOT NULL,
    [usuario_id]            bigint       NULL,
    [tipo_responsable_code] varchar(30)  NOT NULL,
    [nombre_completo]       varchar(100) NULL,
    [documento]             varchar(30)  NULL,
    [telefono]              varchar(20)  NULL,
    [activo]                bit          NOT NULL,
    [created_at]            datetime2(7) NOT NULL,
    CONSTRAINT [PK__responsa__3213E83FAAA888EC] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__responsab__activ__07C12930] DEFAULT ((1)) FOR [activo],
    CONSTRAINT [DF__responsab__creat__08B54D69] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [ck_responsable_nombre_externo] CHECK ([usuario_id] IS NULL AND [nombre_completo] IS NOT NULL OR [usuario_id] IS NOT NULL AND [nombre_completo] IS NULL)
);
GO

CREATE TABLE [dbo].[geo_distrito] (
    [codigo]           varchar(6)  NOT NULL,
    [provincia_codigo] varchar(4)  NOT NULL,
    [nombre]           varchar(60) NOT NULL,
    CONSTRAINT [PK__geo_dist__40F9A207408F138A] PRIMARY KEY CLUSTERED ([codigo]),
    CONSTRAINT [uq_geo_distrito_prov_nombre] UNIQUE ([provincia_codigo], [nombre])
);
GO

CREATE TABLE [dbo].[reporte_descarga] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [tipo_reporte_code]    varchar(60)  NOT NULL,
    [formato_code]         varchar(10)  NOT NULL,
    [filtro_fecha_inicio]  date         NULL,
    [filtro_fecha_fin]     date         NULL,
    [filtro_vacuno_id]     bigint       NULL,
    [filtro_granja_id]     bigint       NULL,
    [filtro_raza_code]     varchar(30)  NULL,
    [filtro_palabra_clave] varchar(100) NULL,
    [archivo_id]           bigint       NULL,
    [estado_code]          varchar(30)  NOT NULL,
    [mensaje]              varchar(150) NULL,
    [solicitado_por]       bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    CONSTRAINT [PK__reporte___3213E83F3EB28E0B] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__reporte_d__estad__0E6E26BF] DEFAULT ('ACTIVO') FOR [estado_code],
    CONSTRAINT [DF__reporte_d__creat__0F624AF8] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [ck_reporte_fechas] CHECK ([filtro_fecha_inicio] IS NULL OR [filtro_fecha_fin] IS NULL OR [filtro_fecha_inicio]<=[filtro_fecha_fin])
);
GO

CREATE TABLE [dbo].[granja] (
    [id]              bigint       IDENTITY(1,1) NOT NULL,
    [nombre]          varchar(100) NOT NULL,
    [distrito_codigo] varchar(6)   NOT NULL,
    [activo]          bit          NOT NULL,
    [created_at]      datetime2(7) NOT NULL,
    [updated_at]      datetime2(7) NOT NULL,
    CONSTRAINT [PK__granja__3213E83F4767B2FF] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_granja_nombre_distrito] UNIQUE ([nombre], [distrito_codigo]),
    CONSTRAINT [DF__granja__updated___3A4CA8FD] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [DF__granja__created___395884C4] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__granja__activo__3864608B] DEFAULT ((1)) FOR [activo]
);
GO

CREATE TABLE [dbo].[vacuno] (
    [id]                    bigint       IDENTITY(1,1) NOT NULL,
    [codigo]                varchar(15)  NOT NULL,
    [nombre]                varchar(100) NOT NULL,
    [fecha_nacimiento]      date         NOT NULL,
    [tipo_adquisicion_code] varchar(30)  NOT NULL,
    [raza_code]             varchar(30)  NOT NULL,
    [color_code]            varchar(30)  NOT NULL,
    [sexo_code]             varchar(10)  NOT NULL,
    [padre_id]              bigint       NULL,
    [madre_id]              bigint       NULL,
    [granja_id]             bigint       NOT NULL,
    [observaciones]         varchar(150) NULL,
    [fecha_registro]        date         NOT NULL,
    [created_by]            bigint       NULL,
    [updated_by]            bigint       NULL,
    [deleted_by]            bigint       NULL,
    [created_at]            datetime2(7) NOT NULL,
    [updated_at]            datetime2(7) NOT NULL,
    [deleted_at]            datetime2(7) NULL,
    [motivo_eliminacion]    varchar(250) NULL,
    CONSTRAINT [PK__vacuno__3213E83F977B081D] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_vacuno_codigo] UNIQUE ([codigo]),
    CONSTRAINT [DF__vacuno__created___3F115E1A] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__vacuno__updated___40058253] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_vacuno_fecha_nacimiento] CHECK ([fecha_nacimiento]<=CONVERT([date],getdate())),
    CONSTRAINT [ck_vacuno_madre_no_self] CHECK ([madre_id]<>[id]),
    CONSTRAINT [ck_vacuno_padre_no_self] CHECK ([padre_id]<>[id])
);
GO

CREATE TABLE [dbo].[celo_registro] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [codigo]               varchar(15)  NOT NULL,
    [fecha_hora]           datetime2(7) NOT NULL,
    [vacuno_id]            bigint       NOT NULL,
    [encargado_usuario_id] bigint       NOT NULL,
    [observaciones]        varchar(150) NULL,
    [estado_registro_code] varchar(30)  NOT NULL,
    [created_by]           bigint       NULL,
    [updated_by]           bigint       NULL,
    [deleted_by]           bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    [updated_at]           datetime2(7) NOT NULL,
    [deleted_at]           datetime2(7) NULL,
    [motivo_eliminacion]   varchar(250) NULL,
    CONSTRAINT [PK__celo_reg__3213E83FEC3B1926] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_celo_registro_codigo] UNIQUE ([codigo]),
    CONSTRAINT [uq_celo_registro_vacuno_fecha] UNIQUE ([vacuno_id], [fecha_hora]),
    CONSTRAINT [DF__celo_regi__estad__382F5661] DEFAULT ('ACTIVO') FOR [estado_registro_code],
    CONSTRAINT [DF__celo_regi__creat__39237A9A] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__celo_regi__updat__3A179ED3] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_celo_registro_fecha] CHECK ([fecha_hora]<=sysdatetime())
);
GO

CREATE TABLE [dbo].[incidente_vacuno] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]            bigint       NOT NULL,
    [fecha_incidente]      date         NOT NULL,
    [descripcion]          varchar(150) NOT NULL,
    [estado_registro_code] varchar(30)  NOT NULL,
    [created_by]           bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    CONSTRAINT [PK__incident__3213E83FF80BE653] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__incidente__estad__681373AD] DEFAULT ('ACTIVO') FOR [estado_registro_code],
    CONSTRAINT [DF__incidente__creat__690797E6] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [ck_incidente_fecha] CHECK ([fecha_incidente]<=CONVERT([date],getdate()))
);
GO

CREATE TABLE [dbo].[ordenio] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [codigo]               varchar(15)  NOT NULL,
    [fecha_hora]           datetime2(7) NOT NULL,
    [vacuno_id]            bigint       NOT NULL,
    [encargado_usuario_id] bigint       NOT NULL,
    [litros]               numeric(8,3) NOT NULL,
    [observaciones]        varchar(150) NULL,
    [estado_ordenio_code]  varchar(30)  NOT NULL,
    [created_by]           bigint       NULL,
    [updated_by]           bigint       NULL,
    [deleted_by]           bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    [updated_at]           datetime2(7) NOT NULL,
    [deleted_at]           datetime2(7) NULL,
    [motivo_eliminacion]   varchar(250) NULL,
    CONSTRAINT [PK__ordenio__3213E83FBA23CB4D] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_ordenio_codigo] UNIQUE ([codigo]),
    CONSTRAINT [uq_ordenio_vacuno_fecha] UNIQUE ([vacuno_id], [fecha_hora]),
    CONSTRAINT [DF__ordenio__estado___74794A92] DEFAULT ('ACTIVO') FOR [estado_ordenio_code],
    CONSTRAINT [DF__ordenio__updated__76619304] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [DF__ordenio__created__756D6ECB] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [ck_ordenio_fecha] CHECK ([fecha_hora]<=sysdatetime()),
    CONSTRAINT [ck_ordenio_litros] CHECK ([litros]>(0))
);
GO

CREATE TABLE [dbo].[periodo_sequia] (
    [id]                 bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]          bigint       NOT NULL,
    [fecha_inicio]       date         NOT NULL,
    [fecha_fin_estimada] date         NULL,
    [fecha_fin_real]     date         NULL,
    [estado_sequia_code] varchar(30)  NOT NULL,
    [motivo]             varchar(150) NULL,
    [observaciones]      varchar(150) NULL,
    [created_by]         bigint       NULL,
    [updated_by]         bigint       NULL,
    [created_at]         datetime2(7) NOT NULL,
    [updated_at]         datetime2(7) NOT NULL,
    CONSTRAINT [PK__periodo___3213E83FB780762A] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__periodo_s__creat__0B5CAFEA] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__periodo_s__updat__0C50D423] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_sequia_fechas] CHECK (([fecha_fin_estimada] IS NULL OR [fecha_inicio]<=[fecha_fin_estimada]) AND ([fecha_fin_real] IS NULL OR [fecha_inicio]<=[fecha_fin_real]))
);
GO

CREATE TABLE [dbo].[produccion_leche_estandar] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]            bigint       NULL,
    [fecha_inicio]         date         NOT NULL,
    [fecha_fin]            date         NULL,
    [litros_esperados_dia] numeric(8,3) NOT NULL,
    [descripcion]          varchar(150) NULL,
    [created_by]           bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    [updated_at]           datetime2(7) NOT NULL,
    CONSTRAINT [PK__producci__3213E83F3A3B7013] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__produccio__creat__00DF2177] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__produccio__updat__01D345B0] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_ple_fechas] CHECK ([fecha_fin] IS NULL OR [fecha_inicio]<=[fecha_fin]),
    CONSTRAINT [ck_ple_litros] CHECK ([litros_esperados_dia]>(0))
);
GO

CREATE TABLE [dbo].[triaje] (
    [id]                   bigint       IDENTITY(1,1) NOT NULL,
    [codigo]               varchar(15)  NOT NULL,
    [fecha_hora]           datetime2(7) NOT NULL,
    [vacuno_id]            bigint       NOT NULL,
    [tipo_peso_code]       varchar(30)  NOT NULL,
    [peso_kg]              numeric(8,2) NOT NULL,
    [observaciones]        varchar(150) NULL,
    [estado_registro_code] varchar(30)  NOT NULL,
    [encargado_usuario_id] bigint       NULL,
    [created_by]           bigint       NULL,
    [updated_by]           bigint       NULL,
    [deleted_by]           bigint       NULL,
    [created_at]           datetime2(7) NOT NULL,
    [updated_at]           datetime2(7) NOT NULL,
    [deleted_at]           datetime2(7) NULL,
    [motivo_eliminacion]   varchar(250) NULL,
    CONSTRAINT [PK__triaje__3213E83F8AC578E0] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_triaje_codigo] UNIQUE ([codigo]),
    CONSTRAINT [uq_triaje_vacuno_fecha_tipo] UNIQUE ([vacuno_id], [fecha_hora], [tipo_peso_code]),
    CONSTRAINT [DF__triaje__estado_r__19AACF41] DEFAULT ('ACTIVO') FOR [estado_registro_code],
    CONSTRAINT [DF__triaje__created___1A9EF37A] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__triaje__updated___1B9317B3] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_triaje_fecha] CHECK ([fecha_hora]<=sysdatetime()),
    CONSTRAINT [ck_triaje_peso] CHECK ([peso_kg]>(0))
);
GO

CREATE TABLE [dbo].[vacuno_adquisicion] (
    [vacuno_id]             bigint        NOT NULL,
    [tipo_adquisicion_code] varchar(30)   NOT NULL,
    [precio_compra]         numeric(12,2) NULL,
    [fecha_adquisicion]     date          NOT NULL,
    [proveedor]             varchar(150)  NULL,
    [observaciones]         varchar(250)  NULL,
    [created_at]            datetime2(7)  NOT NULL,
    CONSTRAINT [PK__vacuno_a__2ACE7902C49F7DA4] PRIMARY KEY CLUSTERED ([vacuno_id]),
    CONSTRAINT [DF__vacuno_ad__creat__4F47C5E3] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [ck_vacuno_adquisicion_fecha] CHECK ([fecha_adquisicion]<=CONVERT([date],getdate())),
    CONSTRAINT [ck_vacuno_adquisicion_precio] CHECK ([precio_compra] IS NULL OR [precio_compra]>(0))
);
GO

CREATE TABLE [dbo].[vacuno_estado_historial] (
    [id]           bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]    bigint       NOT NULL,
    [estado_code]  varchar(15)  NOT NULL,
    [fecha_estado] date         NOT NULL,
    [motivo]       varchar(150) NULL,
    [created_by]   bigint       NULL,
    [created_at]   datetime2(7) NOT NULL,
    CONSTRAINT [PK__vacuno_e__3213E83FE8860E56] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__vacuno_es__creat__625A9A57] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[vacuno_foto] (
    [id]           bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]    bigint       NOT NULL,
    [archivo_id]   bigint       NOT NULL,
    [es_principal] bit          NOT NULL,
    [uploaded_by]  bigint       NULL,
    [created_at]   datetime2(7) NOT NULL,
    CONSTRAINT [PK__vacuno_f__3213E83FEA9E2F9C] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__vacuno_fo__es_pr__5BAD9CC8] DEFAULT ((0)) FOR [es_principal],
    CONSTRAINT [DF__vacuno_fo__creat__5CA1C101] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[vacuno_utilizacion_historial] (
    [id]                    bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]             bigint       NOT NULL,
    [tipo_utilizacion_code] varchar(30)  NOT NULL,
    [motivo]                varchar(150) NULL,
    [created_by]            bigint       NULL,
    [created_at]            datetime2(7) NOT NULL,
    CONSTRAINT [PK__vacuno_u__3213E83FCB7F78F0] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__vacuno_ut__creat__55F4C372] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[celo_registro_caracteristica] (
    [celo_registro_id]    bigint      NOT NULL,
    [caracteristica_code] varchar(30) NOT NULL,
    CONSTRAINT [pk_celo_reg_caract] PRIMARY KEY CLUSTERED ([celo_registro_id], [caracteristica_code])
);
GO

CREATE TABLE [dbo].[celo_registro_caracteristica_libre] (
    [id]               bigint       IDENTITY(1,1) NOT NULL,
    [celo_registro_id] bigint       NOT NULL,
    [descripcion]      varchar(80)  NOT NULL,
    [created_at]       datetime2(7) NOT NULL,
    CONSTRAINT [PK__celo_reg__3213E83F9964464C] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__celo_regi__creat__477199F1] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

CREATE TABLE [dbo].[fecundacion] (
    [id]                         bigint       IDENTITY(1,1) NOT NULL,
    [codigo]                     varchar(15)  NOT NULL,
    [tipo_fecundacion_code]      varchar(40)  NOT NULL,
    [vacuno_receptor_id]         bigint       NOT NULL,
    [celo_registro_id]           bigint       NULL,
    [fecha_procedimiento]        date         NOT NULL,
    [responsable_id]             bigint       NOT NULL,
    [resultado_code]             varchar(30)  NOT NULL,
    [observaciones_veterinarias] varchar(250) NULL,
    [created_by]                 bigint       NULL,
    [updated_by]                 bigint       NULL,
    [created_at]                 datetime2(7) NOT NULL,
    [updated_at]                 datetime2(7) NOT NULL,
    CONSTRAINT [PK__fecundac__3213E83F293328D0] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_fecundacion_codigo] UNIQUE ([codigo]),
    CONSTRAINT [DF__fecundaci__creat__5D60DB10] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__fecundaci__updat__5E54FF49] DEFAULT (sysdatetime()) FOR [updated_at],
    CONSTRAINT [ck_fecundacion_fecha] CHECK ([fecha_procedimiento]<=CONVERT([date],getdate()))
);
GO

CREATE TABLE [dbo].[fecundacion_cria] (
    [id]                       bigint       IDENTITY(1,1) NOT NULL,
    [fecundacion_id]           bigint       NOT NULL,
    [vacuno_hijo_id]           bigint       NOT NULL,
    [estado_trazabilidad_code] varchar(30)  NOT NULL,
    [fecha_vinculacion]        date         NOT NULL,
    [observaciones]            varchar(150) NULL,
    [created_by]               bigint       NULL,
    [updated_by]               bigint       NULL,
    [created_at]               datetime2(7) NOT NULL,
    [updated_at]               datetime2(7) NOT NULL,
    CONSTRAINT [PK__fecundac__3213E83F49BCDB39] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [uq_fecundacion_cria_fec_vacuno] UNIQUE ([fecundacion_id], [vacuno_hijo_id]),
    CONSTRAINT [DF__fecundaci__estad__762C88DA] DEFAULT ('VALIDA') FOR [estado_trazabilidad_code],
    CONSTRAINT [DF__fecundaci__creat__7720AD13] DEFAULT (sysdatetime()) FOR [created_at],
    CONSTRAINT [DF__fecundaci__updat__7814D14C] DEFAULT (sysdatetime()) FOR [updated_at]
);
GO

CREATE TABLE [dbo].[fecundacion_donante] (
    [fecundacion_id]     bigint      NOT NULL,
    [tipo_donante]       varchar(10) NOT NULL,
    [vacuno_donante_id]  bigint      NULL,
    [externo_donante_id] bigint      NULL,
    CONSTRAINT [pk_fecundacion_donante] PRIMARY KEY CLUSTERED ([fecundacion_id]),
    CONSTRAINT [ck_fd_donante_exclusivo] CHECK ([tipo_donante]='INTERNO' AND [vacuno_donante_id] IS NOT NULL AND [externo_donante_id] IS NULL OR [tipo_donante]='EXTERNO' AND [externo_donante_id] IS NOT NULL AND [vacuno_donante_id] IS NULL),
    CONSTRAINT [ck_fd_tipo_donante] CHECK ([tipo_donante]='EXTERNO' OR [tipo_donante]='INTERNO')
);
GO

CREATE TABLE [dbo].[fecundacion_embrion] (
    [fecundacion_id] bigint      NOT NULL,
    [codigo_embrion] varchar(30) NOT NULL,
    CONSTRAINT [PK__fecundac__A6B542F27EAB98D1] PRIMARY KEY CLUSTERED ([fecundacion_id])
);
GO

CREATE TABLE [dbo].[fecundacion_inseminacion] (
    [fecundacion_id] bigint      NOT NULL,
    [codigo_semen]   varchar(30) NOT NULL,
    CONSTRAINT [PK__fecundac__A6B542F22BFDDD0A] PRIMARY KEY CLUSTERED ([fecundacion_id])
);
GO

CREATE TABLE [dbo].[vacuno_estado_fecundacion_historial] (
    [id]                      bigint       IDENTITY(1,1) NOT NULL,
    [vacuno_id]               bigint       NOT NULL,
    [estado_fecundacion_code] varchar(30)  NOT NULL,
    [fecundacion_id]          bigint       NULL,
    [fecha_actualizacion]     date         NOT NULL,
    [observaciones]           varchar(150) NULL,
    [created_by]              bigint       NULL,
    [deleted_by]              bigint       NULL,
    [created_at]              datetime2(7) NOT NULL,
    [deleted_at]              datetime2(7) NULL,
    [motivo_eliminacion]      varchar(250) NULL,
    CONSTRAINT [PK__vacuno_e__3213E83F9B76A954] PRIMARY KEY CLUSTERED ([id]),
    CONSTRAINT [DF__vacuno_es__creat__7FB5F314] DEFAULT (sysdatetime()) FOR [created_at]
);
GO

/* ===================== 2. CLAVES FORANEAS (FK) ===================== */

ALTER TABLE [dbo].[archivo] ADD CONSTRAINT [fk_archivo_creado_por] FOREIGN KEY ([creado_por])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[archivo] ADD CONSTRAINT [fk_archivo_extension] FOREIGN KEY ([extension])
    REFERENCES [dbo].[cat_tipo_archivo] ([extension]);
ALTER TABLE [dbo].[archivo] ADD CONSTRAINT [fk_archivo_modulo] FOREIGN KEY ([modulo_code])
    REFERENCES [dbo].[cat_modulo] ([code]);
ALTER TABLE [dbo].[bitacora_auditoria] ADD CONSTRAINT [fk_bitacora_modulo] FOREIGN KEY ([modulo_code])
    REFERENCES [dbo].[cat_modulo] ([code]);
ALTER TABLE [dbo].[bitacora_auditoria] ADD CONSTRAINT [fk_bitacora_usuario] FOREIGN KEY ([usuario_id])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[cat_tipo_reporte] ADD CONSTRAINT [fk_cat_tipo_reporte_modulo] FOREIGN KEY ([modulo_code])
    REFERENCES [dbo].[cat_modulo] ([code]);
ALTER TABLE [dbo].[celo_configuracion] ADD CONSTRAINT [fk_celo_config_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_deleted_by] FOREIGN KEY ([deleted_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_encargado] FOREIGN KEY ([encargado_usuario_id])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_estado] FOREIGN KEY ([estado_registro_code])
    REFERENCES [dbo].[cat_estado_registro] ([code]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[celo_registro] ADD CONSTRAINT [fk_celo_registro_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[celo_registro_caracteristica] ADD CONSTRAINT [fk_crc_caracteristica] FOREIGN KEY ([caracteristica_code])
    REFERENCES [dbo].[cat_caracteristica_celo] ([code]);
ALTER TABLE [dbo].[celo_registro_caracteristica] ADD CONSTRAINT [fk_crc_celo_registro] FOREIGN KEY ([celo_registro_id])
    REFERENCES [dbo].[celo_registro] ([id]);
ALTER TABLE [dbo].[celo_registro_caracteristica_libre] ADD CONSTRAINT [fk_crcl_celo_registro] FOREIGN KEY ([celo_registro_id])
    REFERENCES [dbo].[celo_registro] ([id]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_celo] FOREIGN KEY ([celo_registro_id])
    REFERENCES [dbo].[celo_registro] ([id]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_receptor] FOREIGN KEY ([vacuno_receptor_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_responsable] FOREIGN KEY ([responsable_id])
    REFERENCES [dbo].[responsable] ([id]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_resultado] FOREIGN KEY ([resultado_code])
    REFERENCES [dbo].[cat_resultado_fecundacion] ([code]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_tipo] FOREIGN KEY ([tipo_fecundacion_code])
    REFERENCES [dbo].[cat_tipo_fecundacion] ([code]);
ALTER TABLE [dbo].[fecundacion] ADD CONSTRAINT [fk_fecundacion_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[fecundacion_cria] ADD CONSTRAINT [fk_fc_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[fecundacion_cria] ADD CONSTRAINT [fk_fc_fecundacion] FOREIGN KEY ([fecundacion_id])
    REFERENCES [dbo].[fecundacion] ([id]);
ALTER TABLE [dbo].[fecundacion_cria] ADD CONSTRAINT [fk_fc_trazabilidad] FOREIGN KEY ([estado_trazabilidad_code])
    REFERENCES [dbo].[cat_estado_trazabilidad] ([code]);
ALTER TABLE [dbo].[fecundacion_cria] ADD CONSTRAINT [fk_fc_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[fecundacion_cria] ADD CONSTRAINT [fk_fc_vacuno_hijo] FOREIGN KEY ([vacuno_hijo_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[fecundacion_donante] ADD CONSTRAINT [fk_fd_externo_donante] FOREIGN KEY ([externo_donante_id])
    REFERENCES [dbo].[reproductor_externo] ([id]);
ALTER TABLE [dbo].[fecundacion_donante] ADD CONSTRAINT [fk_fd_fecundacion] FOREIGN KEY ([fecundacion_id])
    REFERENCES [dbo].[fecundacion] ([id]);
ALTER TABLE [dbo].[fecundacion_donante] ADD CONSTRAINT [fk_fd_vacuno_donante] FOREIGN KEY ([vacuno_donante_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[fecundacion_embrion] ADD CONSTRAINT [fk_femb_fecundacion] FOREIGN KEY ([fecundacion_id])
    REFERENCES [dbo].[fecundacion] ([id]);
ALTER TABLE [dbo].[fecundacion_inseminacion] ADD CONSTRAINT [fk_fins_fecundacion] FOREIGN KEY ([fecundacion_id])
    REFERENCES [dbo].[fecundacion] ([id]);
ALTER TABLE [dbo].[geo_distrito] ADD CONSTRAINT [fk_distrito_provincia] FOREIGN KEY ([provincia_codigo])
    REFERENCES [dbo].[geo_provincia] ([codigo]);
ALTER TABLE [dbo].[geo_provincia] ADD CONSTRAINT [fk_provincia_departamento] FOREIGN KEY ([departamento_codigo])
    REFERENCES [dbo].[geo_departamento] ([codigo]);
ALTER TABLE [dbo].[granja] ADD CONSTRAINT [fk_granja_distrito] FOREIGN KEY ([distrito_codigo])
    REFERENCES [dbo].[geo_distrito] ([codigo]);
ALTER TABLE [dbo].[incidente_vacuno] ADD CONSTRAINT [fk_incidente_created] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[incidente_vacuno] ADD CONSTRAINT [fk_incidente_estado] FOREIGN KEY ([estado_registro_code])
    REFERENCES [dbo].[cat_estado_registro] ([code]);
ALTER TABLE [dbo].[incidente_vacuno] ADD CONSTRAINT [fk_incidente_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_deleted_by] FOREIGN KEY ([deleted_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_encargado] FOREIGN KEY ([encargado_usuario_id])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_estado] FOREIGN KEY ([estado_ordenio_code])
    REFERENCES [dbo].[cat_estado_ordenio] ([code]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[ordenio] ADD CONSTRAINT [fk_ordenio_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[parametro_sistema] ADD CONSTRAINT [fk_parametro_modulo] FOREIGN KEY ([modulo_code])
    REFERENCES [dbo].[cat_modulo] ([code]);
ALTER TABLE [dbo].[periodo_sequia] ADD CONSTRAINT [fk_sequia_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[periodo_sequia] ADD CONSTRAINT [fk_sequia_estado] FOREIGN KEY ([estado_sequia_code])
    REFERENCES [dbo].[cat_estado_sequia] ([code]);
ALTER TABLE [dbo].[periodo_sequia] ADD CONSTRAINT [fk_sequia_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[periodo_sequia] ADD CONSTRAINT [fk_sequia_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[produccion_leche_estandar] ADD CONSTRAINT [fk_ple_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[produccion_leche_estandar] ADD CONSTRAINT [fk_ple_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[reporte_descarga] ADD CONSTRAINT [fk_reporte_archivo] FOREIGN KEY ([archivo_id])
    REFERENCES [dbo].[archivo] ([id]);
ALTER TABLE [dbo].[reporte_descarga] ADD CONSTRAINT [fk_reporte_estado] FOREIGN KEY ([estado_code])
    REFERENCES [dbo].[cat_estado_registro] ([code]);
ALTER TABLE [dbo].[reporte_descarga] ADD CONSTRAINT [fk_reporte_formato] FOREIGN KEY ([formato_code])
    REFERENCES [dbo].[cat_formato_reporte] ([code]);
ALTER TABLE [dbo].[reporte_descarga] ADD CONSTRAINT [fk_reporte_solicitado_por] FOREIGN KEY ([solicitado_por])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[reporte_descarga] ADD CONSTRAINT [fk_reporte_tipo_reporte] FOREIGN KEY ([tipo_reporte_code])
    REFERENCES [dbo].[cat_tipo_reporte] ([code]);
ALTER TABLE [dbo].[reproductor_externo] ADD CONSTRAINT [fk_reproductor_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[reproductor_externo] ADD CONSTRAINT [fk_reproductor_sexo] FOREIGN KEY ([sexo_code])
    REFERENCES [dbo].[cat_sexo] ([code]);
ALTER TABLE [dbo].[responsable] ADD CONSTRAINT [fk_responsable_tipo] FOREIGN KEY ([tipo_responsable_code])
    REFERENCES [dbo].[cat_tipo_responsable] ([code]);
ALTER TABLE [dbo].[responsable] ADD CONSTRAINT [fk_responsable_usuario] FOREIGN KEY ([usuario_id])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_deleted_by] FOREIGN KEY ([deleted_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_encargado] FOREIGN KEY ([encargado_usuario_id])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_estado] FOREIGN KEY ([estado_registro_code])
    REFERENCES [dbo].[cat_estado_registro] ([code]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_tipo_peso] FOREIGN KEY ([tipo_peso_code])
    REFERENCES [dbo].[cat_tipo_peso] ([code]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[triaje] ADD CONSTRAINT [fk_triaje_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_adquisicion] FOREIGN KEY ([tipo_adquisicion_code])
    REFERENCES [dbo].[cat_tipo_adquisicion] ([code]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_color] FOREIGN KEY ([color_code])
    REFERENCES [dbo].[cat_color] ([code]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_deleted_by] FOREIGN KEY ([deleted_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_granja] FOREIGN KEY ([granja_id])
    REFERENCES [dbo].[granja] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_madre] FOREIGN KEY ([madre_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_padre] FOREIGN KEY ([padre_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_raza] FOREIGN KEY ([raza_code])
    REFERENCES [dbo].[cat_raza] ([code]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_sexo] FOREIGN KEY ([sexo_code])
    REFERENCES [dbo].[cat_sexo] ([code]);
ALTER TABLE [dbo].[vacuno] ADD CONSTRAINT [fk_vacuno_updated_by] FOREIGN KEY ([updated_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_adquisicion] ADD CONSTRAINT [fk_vacuno_adquisicion_tipo] FOREIGN KEY ([tipo_adquisicion_code])
    REFERENCES [dbo].[cat_tipo_adquisicion] ([code]);
ALTER TABLE [dbo].[vacuno_adquisicion] ADD CONSTRAINT [fk_vacuno_adquisicion_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno_estado_fecundacion_historial] ADD CONSTRAINT [fk_vefh_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_estado_fecundacion_historial] ADD CONSTRAINT [fk_vefh_deleted_by] FOREIGN KEY ([deleted_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_estado_fecundacion_historial] ADD CONSTRAINT [fk_vefh_estado] FOREIGN KEY ([estado_fecundacion_code])
    REFERENCES [dbo].[cat_estado_fecundacion_vacuno] ([code]);
ALTER TABLE [dbo].[vacuno_estado_fecundacion_historial] ADD CONSTRAINT [fk_vefh_fecundacion] FOREIGN KEY ([fecundacion_id])
    REFERENCES [dbo].[fecundacion] ([id]);
ALTER TABLE [dbo].[vacuno_estado_fecundacion_historial] ADD CONSTRAINT [fk_vefh_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno_estado_historial] ADD CONSTRAINT [fk_veh_created] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_estado_historial] ADD CONSTRAINT [fk_veh_estado] FOREIGN KEY ([estado_code])
    REFERENCES [dbo].[cat_estado_vacuno] ([code]);
ALTER TABLE [dbo].[vacuno_estado_historial] ADD CONSTRAINT [fk_veh_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno_foto] ADD CONSTRAINT [fk_vacuno_foto_archivo] FOREIGN KEY ([archivo_id])
    REFERENCES [dbo].[archivo] ([id]);
ALTER TABLE [dbo].[vacuno_foto] ADD CONSTRAINT [fk_vacuno_foto_uploaded] FOREIGN KEY ([uploaded_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_foto] ADD CONSTRAINT [fk_vacuno_foto_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
ALTER TABLE [dbo].[vacuno_utilizacion_historial] ADD CONSTRAINT [fk_vuh_created_by] FOREIGN KEY ([created_by])
    REFERENCES [dbo].[usuario] ([id]);
ALTER TABLE [dbo].[vacuno_utilizacion_historial] ADD CONSTRAINT [fk_vuh_utilizacion] FOREIGN KEY ([tipo_utilizacion_code])
    REFERENCES [dbo].[cat_tipo_utilizacion] ([code]);
ALTER TABLE [dbo].[vacuno_utilizacion_historial] ADD CONSTRAINT [fk_vuh_vacuno] FOREIGN KEY ([vacuno_id])
    REFERENCES [dbo].[vacuno] ([id]);
GO

/* ========================== 3. INDICES ============================ */

CREATE NONCLUSTERED INDEX [idx_archivo_extension]
    ON [dbo].[archivo] ([extension]);
CREATE NONCLUSTERED INDEX [idx_archivo_hash]
    ON [dbo].[archivo] ([hash_sha256]);
CREATE NONCLUSTERED INDEX [idx_archivo_modulo]
    ON [dbo].[archivo] ([modulo_code]);
CREATE NONCLUSTERED INDEX [idx_bitacora_created_at]
    ON [dbo].[bitacora_auditoria] ([created_at]);
CREATE NONCLUSTERED INDEX [idx_bitacora_entidad]
    ON [dbo].[bitacora_auditoria] ([entidad]);
CREATE NONCLUSTERED INDEX [idx_bitacora_entidad_id]
    ON [dbo].[bitacora_auditoria] ([entidad_id]);
CREATE NONCLUSTERED INDEX [idx_bitacora_modulo]
    ON [dbo].[bitacora_auditoria] ([modulo_code]);
CREATE NONCLUSTERED INDEX [idx_bitacora_usuario]
    ON [dbo].[bitacora_auditoria] ([usuario_id]);
CREATE NONCLUSTERED INDEX [idx_cat_tipo_reporte_modulo]
    ON [dbo].[cat_tipo_reporte] ([modulo_code]);
CREATE NONCLUSTERED INDEX [idx_celo_config_activo]
    ON [dbo].[celo_configuracion] ([activo]);
CREATE NONCLUSTERED INDEX [idx_celo_registro_deleted_at]
    ON [dbo].[celo_registro] ([deleted_at]);
CREATE NONCLUSTERED INDEX [idx_celo_registro_encargado]
    ON [dbo].[celo_registro] ([encargado_usuario_id]);
CREATE NONCLUSTERED INDEX [idx_celo_registro_estado]
    ON [dbo].[celo_registro] ([estado_registro_code]);
CREATE NONCLUSTERED INDEX [idx_celo_registro_fecha_hora]
    ON [dbo].[celo_registro] ([fecha_hora]);
CREATE NONCLUSTERED INDEX [idx_celo_registro_vacuno]
    ON [dbo].[celo_registro] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_crc_caracteristica]
    ON [dbo].[celo_registro_caracteristica] ([caracteristica_code]);
CREATE NONCLUSTERED INDEX [idx_crc_celo_registro]
    ON [dbo].[celo_registro_caracteristica] ([celo_registro_id]);
CREATE NONCLUSTERED INDEX [idx_crcl_celo_registro]
    ON [dbo].[celo_registro_caracteristica_libre] ([celo_registro_id]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_celo]
    ON [dbo].[fecundacion] ([celo_registro_id]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_fecha]
    ON [dbo].[fecundacion] ([fecha_procedimiento]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_receptor]
    ON [dbo].[fecundacion] ([vacuno_receptor_id]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_responsable]
    ON [dbo].[fecundacion] ([responsable_id]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_resultado]
    ON [dbo].[fecundacion] ([resultado_code]);
CREATE NONCLUSTERED INDEX [idx_fecundacion_tipo]
    ON [dbo].[fecundacion] ([tipo_fecundacion_code]);
CREATE NONCLUSTERED INDEX [idx_fc_fecundacion]
    ON [dbo].[fecundacion_cria] ([fecundacion_id]);
CREATE NONCLUSTERED INDEX [idx_fc_trazabilidad]
    ON [dbo].[fecundacion_cria] ([estado_trazabilidad_code]);
CREATE NONCLUSTERED INDEX [idx_fc_vacuno_hijo]
    ON [dbo].[fecundacion_cria] ([vacuno_hijo_id]);
CREATE NONCLUSTERED INDEX [idx_fd_externo_donante]
    ON [dbo].[fecundacion_donante] ([externo_donante_id]);
CREATE NONCLUSTERED INDEX [idx_fd_vacuno_donante]
    ON [dbo].[fecundacion_donante] ([vacuno_donante_id]);
CREATE NONCLUSTERED INDEX [idx_granja_distrito]
    ON [dbo].[granja] ([distrito_codigo]);
CREATE NONCLUSTERED INDEX [idx_incidente_estado]
    ON [dbo].[incidente_vacuno] ([estado_registro_code]);
CREATE NONCLUSTERED INDEX [idx_incidente_fecha]
    ON [dbo].[incidente_vacuno] ([fecha_incidente]);
CREATE NONCLUSTERED INDEX [idx_incidente_vacuno]
    ON [dbo].[incidente_vacuno] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_ordenio_deleted_at]
    ON [dbo].[ordenio] ([deleted_at]);
CREATE NONCLUSTERED INDEX [idx_ordenio_encargado]
    ON [dbo].[ordenio] ([encargado_usuario_id]);
CREATE NONCLUSTERED INDEX [idx_ordenio_estado]
    ON [dbo].[ordenio] ([estado_ordenio_code]);
CREATE NONCLUSTERED INDEX [idx_ordenio_fecha_hora]
    ON [dbo].[ordenio] ([fecha_hora]);
CREATE NONCLUSTERED INDEX [idx_ordenio_vacuno]
    ON [dbo].[ordenio] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_parametro_modulo_clave]
    ON [dbo].[parametro_sistema] ([modulo_code], [clave]);
CREATE NONCLUSTERED INDEX [idx_sequia_estado]
    ON [dbo].[periodo_sequia] ([estado_sequia_code]);
CREATE NONCLUSTERED INDEX [idx_sequia_fecha_fin_e]
    ON [dbo].[periodo_sequia] ([fecha_fin_estimada]);
CREATE NONCLUSTERED INDEX [idx_sequia_fecha_fin_r]
    ON [dbo].[periodo_sequia] ([fecha_fin_real]);
CREATE NONCLUSTERED INDEX [idx_sequia_fecha_ini]
    ON [dbo].[periodo_sequia] ([fecha_inicio]);
CREATE NONCLUSTERED INDEX [idx_sequia_vacuno]
    ON [dbo].[periodo_sequia] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_ple_fecha_fin]
    ON [dbo].[produccion_leche_estandar] ([fecha_fin]);
CREATE NONCLUSTERED INDEX [idx_ple_fecha_ini]
    ON [dbo].[produccion_leche_estandar] ([fecha_inicio]);
CREATE NONCLUSTERED INDEX [idx_ple_vacuno]
    ON [dbo].[produccion_leche_estandar] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_reporte_estado]
    ON [dbo].[reporte_descarga] ([estado_code]);
CREATE NONCLUSTERED INDEX [idx_reporte_fechas]
    ON [dbo].[reporte_descarga] ([filtro_fecha_inicio], [filtro_fecha_fin]);
CREATE NONCLUSTERED INDEX [idx_reporte_formato]
    ON [dbo].[reporte_descarga] ([formato_code]);
CREATE NONCLUSTERED INDEX [idx_reporte_granja]
    ON [dbo].[reporte_descarga] ([filtro_granja_id]);
CREATE NONCLUSTERED INDEX [idx_reporte_solicitado]
    ON [dbo].[reporte_descarga] ([solicitado_por]);
CREATE NONCLUSTERED INDEX [idx_reporte_tipo]
    ON [dbo].[reporte_descarga] ([tipo_reporte_code]);
CREATE NONCLUSTERED INDEX [idx_reporte_vacuno]
    ON [dbo].[reporte_descarga] ([filtro_vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_reproductor_codigo]
    ON [dbo].[reproductor_externo] ([codigo_externo]);
CREATE NONCLUSTERED INDEX [idx_reproductor_nombre]
    ON [dbo].[reproductor_externo] ([nombre]);
CREATE NONCLUSTERED INDEX [idx_responsable_tipo]
    ON [dbo].[responsable] ([tipo_responsable_code]);
CREATE NONCLUSTERED INDEX [idx_responsable_usuario]
    ON [dbo].[responsable] ([usuario_id]);
CREATE NONCLUSTERED INDEX [idx_triaje_deleted_at]
    ON [dbo].[triaje] ([deleted_at]);
CREATE NONCLUSTERED INDEX [idx_triaje_estado]
    ON [dbo].[triaje] ([estado_registro_code]);
CREATE NONCLUSTERED INDEX [idx_triaje_fecha_hora]
    ON [dbo].[triaje] ([fecha_hora]);
CREATE NONCLUSTERED INDEX [idx_triaje_tipo_peso]
    ON [dbo].[triaje] ([tipo_peso_code]);
CREATE NONCLUSTERED INDEX [idx_triaje_vacuno]
    ON [dbo].[triaje] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_usuario_activo]
    ON [dbo].[usuario] ([activo]);
CREATE NONCLUSTERED INDEX [idx_vacuno_deleted_at]
    ON [dbo].[vacuno] ([deleted_at]);
CREATE NONCLUSTERED INDEX [idx_vacuno_fecha_nacimiento]
    ON [dbo].[vacuno] ([fecha_nacimiento]);
CREATE NONCLUSTERED INDEX [idx_vacuno_fecha_registro]
    ON [dbo].[vacuno] ([fecha_registro]);
CREATE NONCLUSTERED INDEX [idx_vacuno_granja]
    ON [dbo].[vacuno] ([granja_id]);
CREATE NONCLUSTERED INDEX [idx_vacuno_madre]
    ON [dbo].[vacuno] ([madre_id]);
CREATE NONCLUSTERED INDEX [idx_vacuno_nombre]
    ON [dbo].[vacuno] ([nombre]);
CREATE NONCLUSTERED INDEX [idx_vacuno_padre]
    ON [dbo].[vacuno] ([padre_id]);
CREATE NONCLUSTERED INDEX [idx_vacuno_raza]
    ON [dbo].[vacuno] ([raza_code]);
CREATE NONCLUSTERED INDEX [idx_vacuno_sexo]
    ON [dbo].[vacuno] ([sexo_code]);
CREATE NONCLUSTERED INDEX [idx_vacuno_adquisicion_fecha]
    ON [dbo].[vacuno_adquisicion] ([fecha_adquisicion]);
CREATE NONCLUSTERED INDEX [idx_vacuno_adquisicion_tipo]
    ON [dbo].[vacuno_adquisicion] ([tipo_adquisicion_code]);
CREATE NONCLUSTERED INDEX [idx_vefh_created_at]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([created_at]);
CREATE NONCLUSTERED INDEX [idx_vefh_deleted_at]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([deleted_at]);
CREATE NONCLUSTERED INDEX [idx_vefh_estado]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([estado_fecundacion_code]);
CREATE NONCLUSTERED INDEX [idx_vefh_fecha]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([fecha_actualizacion]);
CREATE NONCLUSTERED INDEX [idx_vefh_fecundacion]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([fecundacion_id]);
CREATE NONCLUSTERED INDEX [idx_vefh_vacuno]
    ON [dbo].[vacuno_estado_fecundacion_historial] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_veh_created_at]
    ON [dbo].[vacuno_estado_historial] ([created_at]);
CREATE NONCLUSTERED INDEX [idx_veh_estado]
    ON [dbo].[vacuno_estado_historial] ([estado_code]);
CREATE NONCLUSTERED INDEX [idx_veh_fecha]
    ON [dbo].[vacuno_estado_historial] ([fecha_estado]);
CREATE NONCLUSTERED INDEX [idx_veh_vacuno]
    ON [dbo].[vacuno_estado_historial] ([vacuno_id]);
CREATE NONCLUSTERED INDEX [idx_vacuno_foto_archivo]
    ON [dbo].[vacuno_foto] ([archivo_id]);
CREATE NONCLUSTERED INDEX [idx_vacuno_foto_vacuno]
    ON [dbo].[vacuno_foto] ([vacuno_id]);
CREATE UNIQUE NONCLUSTERED INDEX [uq_vacuno_foto_principal]
    ON [dbo].[vacuno_foto] ([vacuno_id])
    WHERE ([es_principal]=(1));
CREATE NONCLUSTERED INDEX [idx_vuh_created_at]
    ON [dbo].[vacuno_utilizacion_historial] ([created_at]);
CREATE NONCLUSTERED INDEX [idx_vuh_tipo]
    ON [dbo].[vacuno_utilizacion_historial] ([tipo_utilizacion_code]);
CREATE NONCLUSTERED INDEX [idx_vuh_vacuno]
    ON [dbo].[vacuno_utilizacion_historial] ([vacuno_id]);
GO

/* =========================== 4. VISTAS =========================== */

CREATE OR ALTER VIEW [dbo].[v_celo_estado_vacuno]
AS
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

CREATE OR ALTER VIEW [dbo].[v_produccion_leche_estandar_vigente]
AS
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

CREATE OR ALTER VIEW [dbo].[v_vacuno_estado_vigente]
AS
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

CREATE OR ALTER VIEW [dbo].[v_vacuno_utilizacion_vigente]
AS
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