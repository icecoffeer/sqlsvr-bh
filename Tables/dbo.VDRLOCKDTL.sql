CREATE TABLE [dbo].[VDRLOCKDTL]
(
[ID] [int] NOT NULL,
[LINE] [int] NOT NULL,
[BEGINDATE] [datetime] NULL,
[ENDDATE] [datetime] NULL,
[IVCNUM] [char] (16) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRLOCKDTL] ADD CONSTRAINT [PK__VDRLOCKDTL__65452156] PRIMARY KEY CLUSTERED  ([ID], [LINE]) ON [PRIMARY]
GO
