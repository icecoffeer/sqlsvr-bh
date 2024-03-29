CREATE TABLE [dbo].[PS3SCOSPECSORTSCORE]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SORT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__MINAM__1924B80F] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__AMOUN__1A18DC48] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SCOSPE__SCORE__1B0D0081] DEFAULT (0),
[BGNDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SCOSPECSORTSCORE] ADD CONSTRAINT [PK__PS3SCOSPECSORTSC__1C0124BA] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3SCOSPECSORTSCORE] ON [dbo].[PS3SCOSPECSORTSCORE] ([SORT]) ON [PRIMARY]
GO
