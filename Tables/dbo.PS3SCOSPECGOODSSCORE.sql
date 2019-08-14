CREATE TABLE [dbo].[PS3SCOSPECGOODSSCORE]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__MINAM__1FD1B59E] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__AMOUN__20C5D9D7] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__SCORE__21B9FE10] DEFAULT (0),
[BGNDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SCOSPECGOODSSCORE] ADD CONSTRAINT [PK__PS3SCOSPECGOODSS__22AE2249] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3SCOSPECGOODSSCORE] ON [dbo].[PS3SCOSPECGOODSSCORE] ([GDGID]) ON [PRIMARY]
GO
