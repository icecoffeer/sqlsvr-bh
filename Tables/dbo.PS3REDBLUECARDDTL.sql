CREATE TABLE [dbo].[PS3REDBLUECARDDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[LOWLIMIT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3REDBLU__LOWLI__06137A49] DEFAULT (0),
[TOPLIMIT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3REDBLU__TOPLI__07079E82] DEFAULT (0),
[LIMITPERCENT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3REDBLU__LIMIT__07FBC2BB] DEFAULT (0),
[LIMITTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3REDBLU__LIMIT__08EFE6F4] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3REDBLUECARDDTL] ADD CONSTRAINT [PK__PS3REDBLUECARDDT__09E40B2D] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
