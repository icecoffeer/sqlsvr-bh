CREATE TABLE [dbo].[PS3SPECGDSCOREINV]
(
[UUID] [varchar] (36) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__MINAM__3F037590] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__AMOUN__3FF799C9] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__SCORE__40EBBE02] DEFAULT (0),
[MAXDISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__MAXDI__41DFE23B] DEFAULT (100),
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECGD__SRCNU__2F8C27D6] DEFAULT ('-'),
[SRCCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECGD__SRCCL__30804C0F] DEFAULT ('-'),
[SCORESORT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECGD__SCORE__01463A39] DEFAULT ('-'),
[NSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__NSCOR__2B3C7405] DEFAULT (1),
[DISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__DISCO__675D165B] DEFAULT (0),
[DISMAXDIS] [decimal] (24, 2) NULL,
[DISPREC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PS3SPECGD__DISPR__68513A94] DEFAULT (0.01)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SPECGDSCOREINV] ADD CONSTRAINT [PK__PS3SPECGDSCOREIN__42D40674] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3SPECGDSCOREINV] ON [dbo].[PS3SPECGDSCOREINV] ([GDGID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3SPECGDSCOREINV_NUMCLS] ON [dbo].[PS3SPECGDSCOREINV] ([SRCNUM], [SRCCLS]) ON [PRIMARY]
GO
