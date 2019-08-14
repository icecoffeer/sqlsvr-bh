CREATE TABLE [dbo].[CusRtlInvDtl]
(
[NUM] [varchar] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QTY] [decimal] (24, 4) NULL,
[AMT] [decimal] (24, 2) NOT NULL,
[PRICE] [decimal] (24, 2) NULL,
[FavAmt] [decimal] (24, 2) NULL,
[MUNIT] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[SPEC] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CusRtlInvDtl] ADD CONSTRAINT [PK__CusRtlInvDtl__57555E04] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
