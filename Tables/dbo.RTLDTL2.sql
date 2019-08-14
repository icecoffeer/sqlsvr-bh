CREATE TABLE [dbo].[RTLDTL2]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__RTLDTL2__QTY__3025B6F3] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__RTLDTL2__COST__3119DB2C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RTLDTL2] ADD CONSTRAINT [PK__RTLDTL2__2F3192BA] PRIMARY KEY CLUSTERED  ([SUBWRH], [NUM], [LINE]) ON [PRIMARY]
GO
