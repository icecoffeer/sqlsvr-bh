CREATE TABLE [dbo].[PROCTASKPROD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[PSCPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PSCPQTY] [decimal] (24, 4) NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL,
[TOTAL] [decimal] (24, 4) NULL,
[CSTPRC] [decimal] (24, 4) NULL,
[INPRC] [decimal] (24, 4) NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[GENQTY] [decimal] (24, 4) NULL,
[WRH] [int] NOT NULL,
[PSCPGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROCTASKPROD] ADD CONSTRAINT [PK__PROCTASKPROD__240D262D] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
