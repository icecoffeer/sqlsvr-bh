CREATE TABLE [dbo].[NPROMFPRCGOODS]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RTLPRC] [decimal] (24, 4) NOT NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NOT NULL,
[COST] [decimal] (24, 4) NOT NULL,
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPROMFPRCGO__QPC__549CE59D] DEFAULT (1),
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMDIV1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPROMFPRC__PRMDI__559109D6] DEFAULT (100),
[PRMDIV2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPROMFPRC__PRMDI__56852E0F] DEFAULT (0),
[PRMDIV3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPROMFPRC__PRMDI__57795248] DEFAULT (0),
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPROMFPRCGO__QTY__586D7681] DEFAULT (1),
[FLAG] [int] NOT NULL CONSTRAINT [DF__NPROMFPRCG__FLAG__59619ABA] DEFAULT (0),
[ISDLT] [smallint] NOT NULL CONSTRAINT [DF__NPROMFPRC__ISDLT__5A55BEF3] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPROMFPRCGOODS] ADD CONSTRAINT [PK__NPROMFPRCGOODS__5B49E32C] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [FLAG]) ON [PRIMARY]
GO