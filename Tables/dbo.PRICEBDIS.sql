CREATE TABLE [dbo].[PRICEBDIS]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PRICEBDIS__QTY__6B29AE8C] DEFAULT (1),
[RTLPRC] [decimal] (24, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRICEBDIS] ADD CONSTRAINT [PK__PRICEBDIS__6C1DD2C5] PRIMARY KEY CLUSTERED  ([BILLNUM], [QTY]) ON [PRIMARY]
GO
