CREATE TABLE [dbo].[FAFLOWLOG]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OCRTIME] [datetime] NOT NULL CONSTRAINT [DF__FAFLOWLOG__OCRTI__1DB5F9B0] DEFAULT (getdate()),
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFLOWLOG] ADD CONSTRAINT [PK__FAFLOWLOG__1EAA1DE9] PRIMARY KEY CLUSTERED  ([UUID], [OCRTIME]) ON [PRIMARY]
GO
