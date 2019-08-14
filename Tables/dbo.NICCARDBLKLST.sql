CREATE TABLE [dbo].[NICCARDBLKLST]
(
[CARDNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[RCVTIME] [datetime] NOT NULL CONSTRAINT [DF__NICCARDBL__RCVTI__76E24C9F] DEFAULT (getdate()),
[NNote] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
