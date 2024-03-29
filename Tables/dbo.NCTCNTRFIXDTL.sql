CREATE TABLE [dbo].[NCTCNTRFIXDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[FEEUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NULL,
[FEECYCLE] [smallint] NULL,
[FSTFEEDATE] [datetime] NULL,
[NEXTBEGINDATE] [datetime] NULL,
[NEXTENDDATE] [datetime] NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCNTRFI__AMOUN__246DE437] DEFAULT (0),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRFIXDTL] ADD CONSTRAINT [PK__NCTCNTRFIXDTL__25620870] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
