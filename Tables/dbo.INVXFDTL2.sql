CREATE TABLE [dbo].[INVXFDTL2]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__INVXFDTL2__QTY__503FE2CF] DEFAULT (0),
[FROMRTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__FROMR__51340708] DEFAULT (0),
[TORTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__TORTO__52282B41] DEFAULT (0),
[BNUM] [char] (12) COLLATE Chinese_PRC_CI_AS NULL,
[CAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__CAMT__531C4F7A] DEFAULT (0),
[CTAX] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__CTAX__541073B3] DEFAULT (0),
[VDRGID] [int] NULL,
[BILLTO] [int] NULL,
[SALE] [smallint] NULL,
[VBNUM] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[VALIDDATE] [datetime] NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__TOTAL__550497EC] DEFAULT (0),
[TAX] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__INVXFDTL2__TAX__55F8BC25] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INVXFDTL2] ADD CONSTRAINT [PK__INVXFDTL2__4F4BBE96] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [LINE], [ITEMNO]) ON [PRIMARY]
GO
