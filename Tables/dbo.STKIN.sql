CREATE TABLE [dbo].[STKIN]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__STKIN__CLS__2A61254E] DEFAULT ('自营'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NULL,
[VENDOR] [int] NULL CONSTRAINT [DF__STKIN__VENDOR__2B554987] DEFAULT (1),
[VENDORNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTO] [int] NULL CONSTRAINT [DF__STKIN__BILLTO__2C496DC0] DEFAULT (1),
[OCRDATE] [datetime] NULL CONSTRAINT [DF__STKIN__OCRDATE__2D3D91F9] DEFAULT (getdate()),
[TOTAL] [money] NULL CONSTRAINT [DF__STKIN__TOTAL__2E31B632] DEFAULT (0),
[TAX] [money] NULL CONSTRAINT [DF__STKIN__TAX__2F25DA6B] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NULL CONSTRAINT [DF__STKIN__FILDATE__3019FEA4] DEFAULT (getdate()),
[PAYDATE] [datetime] NULL,
[FINISHED] [smallint] NULL CONSTRAINT [DF__STKIN__FINISHED__310E22DD] DEFAULT (0),
[FILLER] [int] NULL CONSTRAINT [DF__STKIN__FILLER__32024716] DEFAULT (1),
[CHECKER] [int] NULL CONSTRAINT [DF__STKIN__CHECKER__32F66B4F] DEFAULT (1),
[STAT] [smallint] NULL CONSTRAINT [DF__STKIN__STAT__33EA8F88] DEFAULT (0),
[MODNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PSR] [int] NULL CONSTRAINT [DF__STKIN__PSR__34DEB3C1] DEFAULT (1),
[RECCNT] [int] NULL CONSTRAINT [DF__STKIN__RECCNT__35D2D7FA] DEFAULT (0),
[SRC] [int] NULL,
[SRCNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[WRH] [int] NULL,
[CHKDATE] [datetime] NULL,
[VERIFIER] [int] NULL,
[GEN] [int] NULL,
[GENBILL] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[GENCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[GENNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PRECHECKER] [int] NULL CONSTRAINT [DF__stkin__PRECHECKE__6EC207EA] DEFAULT (0),
[PRECHKDATE] [datetime] NULL,
[TAXRATELMT] [money] NULL,
[DEPT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[ClrOrdQty] [int] NOT NULL CONSTRAINT [DF__STKIN__ClrOrdQty__763C39DC] DEFAULT ('0')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STKIN] WITH NOCHECK ADD CONSTRAINT [STKIN_单号长度限制10位] CHECK ((len([NUM])=(10)))
GO
ALTER TABLE [dbo].[STKIN] WITH NOCHECK ADD CONSTRAINT [单号长度为10] CHECK NOT FOR REPLICATION ((len([num])=(10) AND left([num],(1))='0'))
GO
ALTER TABLE [dbo].[STKIN] ADD CONSTRAINT [PK__STKIN__1EC48A19] PRIMARY KEY CLUSTERED  ([CLS], [NUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[STKIN] ([FILDATE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
