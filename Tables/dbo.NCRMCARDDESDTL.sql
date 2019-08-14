CREATE TABLE [dbo].[NCRMCARDDESDTL]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BALANCE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDD__BALAN__2D9FE6B1] DEFAULT (0),
[CONSUME] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDD__CONSU__2E940AEA] DEFAULT (0),
[BANTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDD__BANTO__2F882F23] DEFAULT (0),
[ADJMONEY] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCRMCARDD__ADJMO__307C535C] DEFAULT (0),
[ADJMONEYTIME] [datetime] NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCRMCARDDESDTL] ADD CONSTRAINT [PK__NCRMCARDDESDTL__31707795] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
