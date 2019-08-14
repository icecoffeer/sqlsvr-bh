CREATE TABLE [dbo].[TA_OPERATION]
(
[OPERATIONID] [int] NOT NULL,
[OPERATIONNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SIMPLENAME] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SQLCONTENT] [varchar] (250) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SQLADDTION] [varchar] (250) COLLATE Chinese_PRC_CI_AS NULL,
[VOUCHERTYPENAME] [varchar] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GENTYPE] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TA_OPERATION] ADD CONSTRAINT [PK__TA_OPERATION__2D12A970] PRIMARY KEY CLUSTERED  ([OPERATIONID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TA_OPERATION] ADD CONSTRAINT [UQ__TA_OPERATION__7C854C05] UNIQUE NONCLUSTERED  ([OPERATIONNAME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO