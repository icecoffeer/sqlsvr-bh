CREATE TABLE [dbo].[DMDPRMDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[PRMTYPE] [smallint] NOT NULL CONSTRAINT [DF__DMDPRMDTL__PRMTY__2E5E3569] DEFAULT (0),
[CANGFT] [smallint] NOT NULL CONSTRAINT [DF__DMDPRMDTL__CANGF__2F5259A2] DEFAULT (0),
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__DMDPRMDTL__QPC__3D97EE06] DEFAULT (1),
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__DMDPRMDTL__QPCST__3E8C123F] DEFAULT ('1*1')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DMDPRMDTL] ADD CONSTRAINT [PK__DMDPRMDTL__4924D839] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DMDprmdtl_gdgid] ON [dbo].[DMDPRMDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
