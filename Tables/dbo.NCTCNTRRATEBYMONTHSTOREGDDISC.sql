CREATE TABLE [dbo].[NCTCNTRRATEBYMONTHSTOREGDDISC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[ROWNO] [smallint] NOT NULL,
[RATE] [decimal] (24, 2) NOT NULL,
[LOWDATE] [datetime] NOT NULL,
[HIGHDATE] [datetime] NOT NULL,
[GAMT] [decimal] (24, 2) NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRRATEBYMONTHSTOREGDDISC] ADD CONSTRAINT [PK__NCTCNTRRATEBYMON__45CED802] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [ITEMNO], [ROWNO]) ON [PRIMARY]
GO