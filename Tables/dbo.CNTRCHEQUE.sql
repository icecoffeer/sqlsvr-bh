CREATE TABLE [dbo].[CNTRCHEQUE]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[CKQNUM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PAYER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[BANK] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[RECEIVER] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRCHEQU__TOTAL__1E8000B7] DEFAULT (0),
[PURPOSE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CNTRCHEQU__PURPO__1F7424F0] DEFAULT ('货款'),
[BILLCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[REMITBANK] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PAYACNT] [varchar] (25) COLLATE Chinese_PRC_CI_AS NULL,
[VDRACNT] [varchar] (25) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTRCHEQUE] ADD CONSTRAINT [PK__CNTRCHEQUE__20684929] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [LINE]) ON [PRIMARY]
GO