CREATE TABLE [dbo].[ALCADJDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[OLDVALUE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NEWVALUE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ALCADJDTL] ADD CONSTRAINT [PK__ALCADJDTL__633E7401] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
