CREATE TABLE [dbo].[NBILLTOADJDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[OBILLTO] [int] NOT NULL,
[NBILLTO] [int] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBILLTOADJDTL] ADD CONSTRAINT [PK__NBILLTOADJDTL__7B6EFC00] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
