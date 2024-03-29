CREATE TABLE [dbo].[PSTASKCYCLE]
(
[ID] [int] NOT NULL,
[NAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [int] NOT NULL CONSTRAINT [DF__PSTASKCYCLE__CLS__4C65304A] DEFAULT (0),
[ALLDAYS] [int] NOT NULL,
[BGNDAY] [int] NOT NULL CONSTRAINT [DF__PSTASKCYC__BGNDA__4D595483] DEFAULT (1),
[DELAYDAY] [int] NOT NULL CONSTRAINT [DF__PSTASKCYC__DELAY__4E4D78BC] DEFAULT (1),
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSTASKCYCLE] ADD CONSTRAINT [PK__PSTASKCYCLE__4F419CF5] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
