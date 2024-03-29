CREATE TABLE [dbo].[CQNGOODSAPP]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODSAP__STAT__419D8914] DEFAULT (0),
[RATIFIER] [int] NOT NULL,
[SRC] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__CQNGOODSAPP__PSR__4291AD4D] DEFAULT (1),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODSA__FILDA__4385D186] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[RATOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[RATDATE] [datetime] NULL,
[DEADDATE] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODSA__LSTUP__4479F5BF] DEFAULT (getdate()),
[PRNTIME] [datetime] NULL,
[SNDTIME] [datetime] NULL,
[SETTLENO] [int] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[GOODSCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[APPMODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__CQNGOODSA__RECCN__456E19F8] DEFAULT (0),
[MODNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNGOODSA__NSTAT__46623E31] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODSA__EXTIM__4756626A] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNGOODSAPP] ADD CONSTRAINT [PK__CQNGOODSAPP__40A964DB] PRIMARY KEY CLUSTERED  ([GROUPID], [RHQUUID]) ON [PRIMARY]
GO
