CREATE TABLE [dbo].[pckst]
(
[LINE] [int] NOT NULL IDENTITY(1, 1),
[SETTLENO] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[WRH] [int] NOT NULL,
[SUBWRH] [int] NOT NULL,
[ACNTQTY] [money] NOT NULL,
[QTY] [money] NOT NULL,
[ACNTTL] [money] NOT NULL,
[TOTAL] [money] NOT NULL,
[OVFAMT] [money] NOT NULL,
[LOSAMT] [money] NOT NULL,
[INPRC] [money] NOT NULL,
[RTLPRC] [money] NOT NULL
) ON [PRIMARY]
GO
