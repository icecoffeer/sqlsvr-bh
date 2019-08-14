CREATE TABLE [dbo].[NCHARGECHKDTL2DTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[DTLDTLLINE] [int] NOT NULL,
[DTLCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CODE] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKNO] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCHARGECH__TOTAL__2B0FF4CE] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCHARGECHKDTL2DTL] ADD CONSTRAINT [PK__NCHARGECHKDTL2DT__2C041907] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [DTLDTLLINE]) ON [PRIMARY]
GO
