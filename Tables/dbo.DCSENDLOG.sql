CREATE TABLE [dbo].[DCSENDLOG]
(
[Atime] [datetime] NOT NULL,
[ANAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ABEGIN] [datetime] NOT NULL,
[Aend] [datetime] NOT NULL,
[Oper] [int] NOT NULL CONSTRAINT [DF__DCSENDLOG__Oper__045221AD] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DCSENDLOG] ADD CONSTRAINT [PK__DCSENDLOG__035DFD74] PRIMARY KEY CLUSTERED  ([Atime]) ON [PRIMARY]
GO