CREATE TABLE [dbo].[SELLCARD]
(
[TIME] [datetime] NOT NULL CONSTRAINT [DF__SELLCARD__TIME__4461B9CA] DEFAULT (getdate()),
[SELLER] [int] NOT NULL CONSTRAINT [DF__SELLCARD__SELLER__4555DE03] DEFAULT (1),
[GID] [int] NOT NULL,
[CODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [char] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEETYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FEE] [money] NOT NULL CONSTRAINT [DF__SELLCARD__FEE__464A023C] DEFAULT (0),
[OLDBALANCE] [money] NULL CONSTRAINT [DF__SELLCARD__OLDBAL__473E2675] DEFAULT (0),
[NEWBALANCE] [money] NULL CONSTRAINT [DF__SELLCARD__NEWBAL__48324AAE] DEFAULT (0),
[OLDVALIDDATE] [datetime] NULL CONSTRAINT [DF__SELLCARD__OLDVAL__49266EE7] DEFAULT (0),
[NEWVALIDDATE] [datetime] NULL CONSTRAINT [DF__SELLCARD__NEWVAL__4A1A9320] DEFAULT (0)
) ON [PRIMARY]
GO
CREATE CLUSTERED INDEX [CODETIME] ON [dbo].[SELLCARD] ([CODE], [TIME]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
