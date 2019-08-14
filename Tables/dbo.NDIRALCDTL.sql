CREATE TABLE [dbo].[NDIRALCDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NULL,
[CASES] [money] NULL,
[QTY] [money] NULL,
[PRICE] [money] NULL,
[TOTAL] [money] NULL,
[TAX] [money] NULL,
[ALCPRC] [money] NULL,
[ALCAMT] [money] NULL,
[VALIDDATE] [datetime] NULL,
[WRH] [int] NULL,
[BNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OUTTAX] [money] NOT NULL CONSTRAINT [DF__ndiralcdt__OUTTA__01168DA6] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__NDIRALCDTL__COST__62B136C0] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NDIRALCDTL] ADD CONSTRAINT [PK__NDIRALCDTL__1EF99443] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
