CREATE TABLE [dbo].[NCTCNTRDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[CHGCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GENUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[GENCYCLE] [smallint] NULL,
[GENDAYOFFSET] [smallint] NULL,
[FSTGENDATE] [datetime] NULL,
[NEXTGENDATE] [datetime] NULL,
[GATHERINGMODE] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NCTCNTRDT__GATHE__1FA92F1A] DEFAULT ('冲扣货款'),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PAYUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRDTL] ADD CONSTRAINT [PK__NCTCNTRDTL__209D5353] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
