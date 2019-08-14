CREATE TABLE [dbo].[GDQPC]
(
[GID] [int] NOT NULL,
[QPCSTR] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__GDQPC__QPCSTR__1589FCAC] DEFAULT ('1*1'),
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__GDQPC__QPC__167E20E5] DEFAULT (1),
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__GDQPC__MUNIT__1772451E] DEFAULT ('个'),
[VOL] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WEIGHT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ISDU] [smallint] NOT NULL CONSTRAINT [DF__GDQPC__ISDU__18666957] DEFAULT (1),
[ISPU] [smallint] NOT NULL CONSTRAINT [DF__GDQPC__ISPU__195A8D90] DEFAULT (1),
[ISWU] [smallint] NOT NULL CONSTRAINT [DF__GDQPC__ISWU__1A4EB1C9] DEFAULT (1),
[ISRU] [smallint] NOT NULL CONSTRAINT [DF__GDQPC__ISRU__1B42D602] DEFAULT (1),
[RTLPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GDQPC__RTLPRC__1C36FA3B] DEFAULT (0),
[WHSPRC] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__GDQPC__WHSPRC__1D2B1E74] DEFAULT (0),
[MBRPRC] [decimal] (24, 2) NULL,
[LWTRTLPRC] [decimal] (24, 4) NULL,
[TOPRTLPRC] [decimal] (24, 4) NULL,
[BQTYPRC] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[PROMOTE] [smallint] NOT NULL CONSTRAINT [DF__GDQPC__PROMOTE__1E1F42AD] DEFAULT ((-1))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDQPC] ADD CONSTRAINT [PK__GDQPC__1F1366E6] PRIMARY KEY CLUSTERED  ([GID], [QPCSTR]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_GDQPC_GIDX] ON [dbo].[GDQPC] ([GID], [QPC]) ON [PRIMARY]
GO
