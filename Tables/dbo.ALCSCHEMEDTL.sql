CREATE TABLE [dbo].[ALCSCHEMEDTL]
(
[CODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[VDRGID] [int] NOT NULL,
[ALCPRC] [decimal] (24, 4) NULL,
[FALCPRC] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[INPRC] [decimal] (24, 4) NULL,
[ALCQTY] [decimal] (24, 4) NULL,
[SUGGESTEDQTYLOWBOUND] [decimal] (24, 4) NULL,
[SUGGESTEDQTYHIGHBOUND] [decimal] (24, 4) NULL,
[SUGGESTEDQTY] [decimal] (24, 4) NULL,
[ORDQTYMIN] [decimal] (24, 4) NULL,
[ALC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LIMIT] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ALCSCHEMEDTL] ADD CONSTRAINT [PK__AlcSchemeDtl__599FFB2E] PRIMARY KEY CLUSTERED  ([CODE], [GDGID]) ON [PRIMARY]
GO
