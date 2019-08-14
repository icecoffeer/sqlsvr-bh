CREATE TABLE [dbo].[VOUCHERTYPE]
(
[CODE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (60) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPE] [int] NOT NULL CONSTRAINT [DF__VOUCHERTYP__TYPE__6043A273] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VOUCHERTY__AMOUN__6137C6AC] DEFAULT (0),
[NOTE] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VOUCHERTY__CREAT__622BEAE5] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__VOUCHERTY__CREAT__63200F1E] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VOUCHERTY__LSTUP__64143357] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__VOUCHERTY__LSTUP__65085790] DEFAULT (getdate()),
[SNDTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERTYPE] ADD CONSTRAINT [PK__VOUCHERTYPE__65FC7BC9] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO
