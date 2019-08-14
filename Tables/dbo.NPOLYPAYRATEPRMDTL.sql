CREATE TABLE [dbo].[NPOLYPAYRATEPRMDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NULL,
[BRAND] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[POLYPAYRATE] [decimal] (24, 4) NOT NULL,
[ASTART] [datetime] NOT NULL CONSTRAINT [DF__NPOLYPAYR__ASTAR__4802048E] DEFAULT ('1899.12.30 00:00:00'),
[AFINISH] [datetime] NOT NULL CONSTRAINT [DF__NPOLYPAYR__AFINI__48F628C7] DEFAULT ('9999.12.31 23:59:59'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[STARTDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPOLYPAYR__START__25CDB372] DEFAULT (0),
[FINISHDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPOLYPAYR__FINIS__26C1D7AB] DEFAULT (100)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPOLYPAYRATEPRMDTL] ADD CONSTRAINT [PK__NPOLYPAYRATEPRMD__49EA4D00] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
