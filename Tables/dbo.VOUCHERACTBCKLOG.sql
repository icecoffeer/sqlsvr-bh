CREATE TABLE [dbo].[VOUCHERACTBCKLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL,
[ACTION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VOUCHERACTBCKLOG_PRIMARY] ON [dbo].[VOUCHERACTBCKLOG] ([NUM]) ON [PRIMARY]
GO
