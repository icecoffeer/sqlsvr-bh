CREATE TABLE [dbo].[SETTLEDEPTVDR]
(
[VDRGID] [int] NOT NULL,
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SETTLEDEPTVDR] ADD CONSTRAINT [PK__SETTLEDEPTVDR__124CD1F7] PRIMARY KEY CLUSTERED  ([CODE], [VDRGID]) ON [PRIMARY]
GO
