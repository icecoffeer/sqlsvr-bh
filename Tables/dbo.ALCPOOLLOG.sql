CREATE TABLE [dbo].[ALCPOOLLOG]
(
[ATIME] [datetime] NOT NULL,
[SETTLENO] [smallint] NULL,
[ATYPE] [smallint] NOT NULL CONSTRAINT [DF__ALCPOOLLO__ATYPE__10AD0B9A] DEFAULT (0),
[ACALLER] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CONTENT] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
