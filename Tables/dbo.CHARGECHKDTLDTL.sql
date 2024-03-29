CREATE TABLE [dbo].[CHARGECHKDTLDTL]
(
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[DTLDTLLINE] [int] NOT NULL,
[DTLCLS] [smallint] NOT NULL,
[CODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKNO] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CHARGECHK__TOTAL__60E1F59A] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHARGECHKDTLDTL] ADD CONSTRAINT [PK__CHARGECHKDTLDTL__61D619D3] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [DTLDTLLINE]) ON [PRIMARY]
GO
