CREATE TABLE [dbo].[CKDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[WRH] [int] NULL,
[ACNTQTY] [money] NULL CONSTRAINT [DF__CKDTL__ACNTQTY__48B0A244] DEFAULT (0),
[QTY] [money] NULL CONSTRAINT [DF__CKDTL__QTY__49A4C67D] DEFAULT (0),
[ACNTTL] [money] NULL CONSTRAINT [DF__CKDTL__ACNTTL__4A98EAB6] DEFAULT (0),
[TOTAL] [money] NULL CONSTRAINT [DF__CKDTL__TOTAL__4B8D0EEF] DEFAULT (0),
[OVFAMT] [money] NULL CONSTRAINT [DF__CKDTL__OVFAMT__4C813328] DEFAULT (0),
[LOSAMT] [money] NULL CONSTRAINT [DF__CKDTL__LOSAMT__4D755761] DEFAULT (0),
[INPRC] [money] NULL CONSTRAINT [DF__CKDTL__INPRC__4E697B9A] DEFAULT (0),
[RTLPRC] [money] NULL CONSTRAINT [DF__CKDTL__RTLPRC__4F5D9FD3] DEFAULT (0),
[ACNTQTY2] [money] NULL CONSTRAINT [DF__CKDTL__ACNTQTY2__5051C40C] DEFAULT (0),
[ACNTTL2] [money] NULL CONSTRAINT [DF__CKDTL__ACNTTL2__5145E845] DEFAULT (0),
[INPRC2] [money] NULL CONSTRAINT [DF__CKDTL__INPRC2__523A0C7E] DEFAULT (0),
[RTLPRC2] [money] NULL CONSTRAINT [DF__CKDTL__RTLPRC2__532E30B7] DEFAULT (0),
[subwrh] [int] NULL,
[COST] [money] NOT NULL CONSTRAINT [DF__CKDTL__COST__383B0EB0] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CKDTL] ADD CONSTRAINT [PK__CKDTL__28B808A7] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [ckdtl_gdgid] ON [dbo].[CKDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO