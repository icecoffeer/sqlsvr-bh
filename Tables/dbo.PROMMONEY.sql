CREATE TABLE [dbo].[PROMMONEY]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMNO] [int] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[PRMTOTAL] [decimal] (24, 2) NOT NULL,
[IFGFT] [int] NOT NULL CONSTRAINT [DF__PROMMONEY__IFGFT__4FF69563] DEFAULT (0),
[GFTQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMMONEY__GFTQT__50EAB99C] DEFAULT (0),
[PTOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMMONEY__PTOTA__51DEDDD5] DEFAULT (0),
[ISFULL] [int] NOT NULL CONSTRAINT [DF__PROMMONEY__ISFUL__52D3020E] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROMMONEY] ADD CONSTRAINT [PK__PROMMONEY__53C72647] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [PRMNO]) ON [PRIMARY]
GO
