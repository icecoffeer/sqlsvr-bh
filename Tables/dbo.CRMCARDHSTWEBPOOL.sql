CREATE TABLE [dbo].[CRMCARDHSTWEBPOOL]
(
[ACTION] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__CRMCARDHS__FILDA__1A22FDE9] DEFAULT (getdate()),
[STORE] [int] NOT NULL,
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OLDCARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OLDBYDATE] [datetime] NULL,
[NEWBYDATE] [datetime] NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CARRIER] [int] NOT NULL CONSTRAINT [DF__CRMCARDHS__CARRI__1B172222] DEFAULT (1),
[CARDCOST] [decimal] (24, 2) NULL,
[CARDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LSTSNDTIME] [datetime] NULL,
[SENDER] [int] NULL,
[SRC] [int] NOT NULL,
[CHARGE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMCARDHS__CHARG__1C0B465B] DEFAULT (0),
[SAVETYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDHS__SAVET__1CFF6A94] DEFAULT ('现金'),
[CHECKNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCHECKID] [int] NULL,
[VERSION] [char] (9) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CRMCARDHS__VERSI__1DF38ECD] DEFAULT ('030000000'),
[NUM] [char] (26) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SENDSTAT] [int] NOT NULL CONSTRAINT [DF__CRMCARDHS__SENDS__1EE7B306] DEFAULT (0),
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CRMCARDHSTWEBPOOL_NUM] ON [dbo].[CRMCARDHSTWEBPOOL] ([NUM]) ON [PRIMARY]
GO
