CREATE TABLE [dbo].[SVIDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL,
[TOTAL] [money] NOT NULL,
[STOTAL] [money] NOT NULL,
[BPayDate] [datetime] NOT NULL,
[EPayDate] [datetime] NOT NULL,
[INPRC] [money] NOT NULL,
[RTLPRC] [money] NOT NULL,
[TAX] [money] NOT NULL,
[CLS] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__SVIDTL__CLS__0293F66D] DEFAULT ('代销'),
[FROMTOTAL] [money] NOT NULL CONSTRAINT [DF__SVIDTL__FROMTOTA__55B72E55] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SVIDTL] ADD CONSTRAINT [PK__SVIDTL__03881AA6] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [SVIDTL_GDGID] ON [dbo].[SVIDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
