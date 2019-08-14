CREATE TABLE [dbo].[PROMFPRCQTY]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__PROMFPRCQT__FLAG__464EC646] DEFAULT (0),
[LINE] [int] NOT NULL CONSTRAINT [DF__PROMFPRCQT__LINE__4742EA7F] DEFAULT (0),
[PRMNO] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCQTY__QTY__48370EB8] DEFAULT (1),
[PRMTOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCQ__PRMTO__492B32F1] DEFAULT (0),
[PPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCQT__PPRC__4A1F572A] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROMFPRCQTY] ADD CONSTRAINT [PK__PROMFPRCQTY__4B137B63] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [LINE], [FLAG], [PRMNO]) ON [PRIMARY]
GO