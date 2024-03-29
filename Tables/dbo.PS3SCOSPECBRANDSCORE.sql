CREATE TABLE [dbo].[PS3SCOSPECBRANDSCORE]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BRAND] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__MINAM__1277BA80] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__AMOUN__136BDEB9] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__SCORE__146002F2] DEFAULT (0),
[BGNDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SCOSPECBRANDSCORE] ADD CONSTRAINT [PK__PS3SCOSPECBRANDS__1554272B] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3SCOSPECBRANDSCORE] ON [dbo].[PS3SCOSPECBRANDSCORE] ([BRAND]) ON [PRIMARY]
GO
