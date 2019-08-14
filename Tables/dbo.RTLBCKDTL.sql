CREATE TABLE [dbo].[RTLBCKDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[CASES] [money] NULL,
[QTY] [money] NOT NULL,
[PRICE] [money] NOT NULL,
[DISCOUNT] [money] NOT NULL CONSTRAINT [DF__RTLBCKDTL__DISCO__2E534871] DEFAULT (100),
[AMOUNT] [money] NOT NULL,
[RTLPRC] [money] NOT NULL,
[INPRC] [money] NOT NULL,
[SUBWRH] [int] NULL,
[ALCPRC] [money] NULL,
[DSPSUBWRH] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TAX] [money] NOT NULL,
[LXGDNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[LXGDSPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[LXGDMUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[LXGDTM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[COST] [money] NOT NULL CONSTRAINT [DF__RTLBCKDTL__COST__64997F32] DEFAULT (0),
[COSTPRC] [money] NOT NULL CONSTRAINT [DF__RTLBCKDTL__COSTP__6775EBDD] DEFAULT (0),
[CURINPRC] [decimal] (14, 4) NOT NULL CONSTRAINT [DF__RtlBckDtl__CURIN__2867C6F6] DEFAULT (0),
[REDCARDCOST] [decimal] (24, 4) NULL,
[BLUECARDCOST] [decimal] (24, 4) NULL,
[VOUAMT] [decimal] (24, 4) NULL,
[GFTFLAG] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RTLBCKDTL] ADD CONSTRAINT [PK__RTLBCKDTL__125EB334] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO