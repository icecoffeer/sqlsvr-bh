CREATE TABLE [dbo].[PROMOTEGFT]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMNO] [int] NOT NULL,
[BILLLINE] [int] NOT NULL,
[GFTGID] [int] NOT NULL,
[GFTCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMOTEGFT__QTY__6AAA8B9F] DEFAULT (1),
[FLAG] [int] NOT NULL,
[GFTQPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMOTEGF__GFTQP__6B9EAFD8] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROMOTEGFT] ADD CONSTRAINT [PK__PROMOTEGFT__700508F0] PRIMARY KEY CLUSTERED  ([BILLNUM], [CLS], [PRMNO], [FLAG], [BILLLINE], [GFTGID], [GFTCODE]) ON [PRIMARY]
GO
