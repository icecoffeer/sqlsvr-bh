CREATE TABLE [dbo].[PS3MBRPROMSUBJ]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORE] [int] NOT NULL CONSTRAINT [DF__PS3MBRPRO__STORE__77C7BCF7] DEFAULT (0),
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3MBRPRO__NSCOR__78BBE130] DEFAULT (1),
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PS3MBRPROM__STAT__79B00569] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PS3MBRPRO__FILDA__7AA429A2] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRNTIME] [datetime] NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[ABORTDATE] [datetime] NULL,
[ABORTER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3MBRPRO__LSTUP__7B984DDB] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3MBRPRO__LSTUP__7C8C7214] DEFAULT ('未知[-]'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__PS3MBRPRO__SETTL__7D80964D] DEFAULT (0),
[RECCNT] [int] NOT NULL,
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ISALLCARDTYPEIN] [smallint] NOT NULL CONSTRAINT [DF__PS3MBRPRO__ISALL__736DE785] DEFAULT (0),
[TPCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3MBRPRO__TPCLS__322A340D] DEFAULT ('会员类型'),
[DISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3MBRPRO__DISCO__331E5846] DEFAULT (0),
[MAXDISCOUNT] [decimal] (24, 2) NULL CONSTRAINT [DF__PS3MBRPRO__MAXDI__34127C7F] DEFAULT (100),
[PREC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PS3MBRPROM__PREC__3506A0B8] DEFAULT (0.01)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3MBRPROMSUBJ] ADD CONSTRAINT [PK__PS3MBRPROMSUBJ__06232B4B] PRIMARY KEY CLUSTERED  ([NUM], [CLS]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ID_MBRPRMSUBJ] ON [dbo].[PS3MBRPROMSUBJ] ([CLS], [CODE]) ON [PRIMARY]
GO
