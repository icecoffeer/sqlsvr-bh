CREATE TABLE [dbo].[PSONLINEORDGENERRORLOG]
(
[ORDNO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDFILDATE] [datetime] NULL,
[NOTE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BILLFROM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GENBILLNAME] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__PSONLINEO__CREAT__25F0DC5F] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSONLINEORDGENERRORLOG] ADD CONSTRAINT [PK__PSONLINE__60AD15F627D924D1] PRIMARY KEY CLUSTERED  ([ORDNO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3_ONLINEORDGENERRORLOG] ON [dbo].[PSONLINEORDGENERRORLOG] ([CREATETIME]) ON [PRIMARY]
GO
