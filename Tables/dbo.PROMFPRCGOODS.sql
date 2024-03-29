CREATE TABLE [dbo].[PROMFPRCGOODS]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RTLPRC] [decimal] (24, 4) NOT NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NOT NULL,
[COST] [decimal] (24, 4) NOT NULL,
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCGOO__QPC__3DB98045] DEFAULT (1),
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMDIV1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCG__PRMDI__3EADA47E] DEFAULT (100),
[PRMDIV2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCG__PRMDI__3FA1C8B7] DEFAULT (0),
[PRMDIV3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCG__PRMDI__4095ECF0] DEFAULT (0),
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMFPRCGOO__QTY__418A1129] DEFAULT (1),
[FLAG] [int] NOT NULL CONSTRAINT [DF__PROMFPRCGO__FLAG__427E3562] DEFAULT (0),
[ISDLT] [smallint] NOT NULL CONSTRAINT [DF__PROMFPRCG__ISDLT__4372599B] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROMFPRCGOODS] ADD CONSTRAINT [PK__PROMFPRCGOODS__44667DD4] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [LINE], [FLAG]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PROMQGOODS_GDGID] ON [dbo].[PROMFPRCGOODS] ([GDGID]) ON [PRIMARY]
GO
