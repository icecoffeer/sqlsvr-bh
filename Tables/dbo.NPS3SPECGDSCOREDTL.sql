CREATE TABLE [dbo].[NPS3SPECGDSCOREDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[MINAMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NPS3SPECG__MINAM__5AAB9005] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NPS3SPECG__AMOUN__5B9FB43E] DEFAULT (0),
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NPS3SPECG__SCORE__5C93D877] DEFAULT (0),
[MAXDISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NPS3SPECG__MAXDI__5D87FCB0] DEFAULT (100),
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SCORESORT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NPS3SPECG__SCORE__032E82AB] DEFAULT ('-'),
[NSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NPS3SPECG__NSCOR__2D24BC77] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPS3SPECGDSCOREDTL] ADD CONSTRAINT [PK__NPS3SPECGDSCORED__5E7C20E9] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPS3SPECGDSCOREDTL_2] ON [dbo].[NPS3SPECGDSCOREDTL] ([GDGID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_NPS3SPECGDSCOREDTL_1] ON [dbo].[NPS3SPECGDSCOREDTL] ([NUM]) ON [PRIMARY]
GO
