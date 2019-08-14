CREATE TABLE [dbo].[CTCNTRFIXDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[FEEUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[FEECYCLE] [smallint] NULL,
[FSTFEEDATE] [datetime] NULL,
[NEXTBEGINDATE] [datetime] NULL,
[NEXTENDDATE] [datetime] NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CTCNTRFIX__AMOUN__33ADC5C2] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRFIXDTL] ADD CONSTRAINT [PK__CTCNTRFIXDTL__34A1E9FB] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE]) ON [PRIMARY]
GO
