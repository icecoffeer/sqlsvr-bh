CREATE TABLE [dbo].[CstBill]
(
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLIENT] [int] NOT NULL CONSTRAINT [DF__CstBill__CLIENT__6597C50C] DEFAULT (1),
[OUTNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TOTAL] [money] NOT NULL,
[RCPTOTAL] [money] NOT NULL CONSTRAINT [DF__CstBill__RCPTOTA__668BE945] DEFAULT (0),
[OTOTAL] [money] NOT NULL CONSTRAINT [DF__CstBill__OTOTAL__67800D7E] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CstBill] ADD CONSTRAINT [PK__CstBill__64A3A0D3] PRIMARY KEY CLUSTERED  ([CLS], [OUTNUM]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
