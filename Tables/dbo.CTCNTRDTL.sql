CREATE TABLE [dbo].[CTCNTRDTL]
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
[GATHERINGMODE] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CTCNTRDTL__GATHE__30D15917] DEFAULT ('冲扣货款'),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PAYUNIT] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[ISADDED] [int] NOT NULL CONSTRAINT [DF__CTCNTRDTL__ISADD__0A9078A8] DEFAULT (0),
[MODALCLS] [int] NOT NULL CONSTRAINT [DF__CTCNTRDTL__MODAL__0B849CE1] DEFAULT (0),
[VDRGDGID] [int] NULL,
[SINGLEFEE] [int] NOT NULL CONSTRAINT [DF__CTCNTRDTL__SINGL__0C78C11A] DEFAULT (0),
[CASE] [int] NOT NULL CONSTRAINT [DF__CTCNTRDTL__CASE__0D6CE553] DEFAULT (0),
[CHGBOOKNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CTCNTRDTL__COUNT__0AD13B21] DEFAULT ('月')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRDTL] ADD CONSTRAINT [PK__CTCNTRDTL__31C57D50] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE]) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [IDX_CTCNTRDTL_CHGCODE] ON [dbo].[CTCNTRDTL] ([NUM], [VERSION], [CHGCODE]) ON [PRIMARY]
GO
