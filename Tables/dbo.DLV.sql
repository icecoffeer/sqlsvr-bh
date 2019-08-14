CREATE TABLE [dbo].[DLV]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__DLV__FILDATE__4ECB04FB] DEFAULT (getdate()),
[FILLER] [int] NOT NULL,
[CARD] [int] NULL,
[CLIENT] [int] NOT NULL,
[CTRNAME] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PROVINCE] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTY] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ADDR] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NEARBY] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[CTRTEL] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[BKDATE] [datetime] NULL,
[DELIVERYMAN] [int] NOT NULL,
[CARARR] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__DLV__STAT__4FBF2934] DEFAULT (0),
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[DLVDATE] [datetime] NULL,
[DLVER] [int] NULL,
[LSTUPDTIME] [datetime] NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__dlv__CLS__6A090B1C] DEFAULT ('零售'),
[AddrCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ROAD] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SUBROAD] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[BUILDING] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ROOM] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[Mansion] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[InCaseQty] [money] NULL CONSTRAINT [DF__DLV__InCaseQty__47BE14B9] DEFAULT (0),
[InCaseAmount] [money] NULL CONSTRAINT [DF__DLV__InCaseAmoun__48B238F2] DEFAULT (0),
[ADDRUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[FROMCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FROMNUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DLV] WITH NOCHECK ADD CONSTRAINT [DLV_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[DLV] ADD CONSTRAINT [PK__DLV__46486B8E] PRIMARY KEY CLUSTERED  ([NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO