CREATE TABLE [dbo].[PROMGFT]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMNO] [int] NOT NULL,
[LINE] [int] NOT NULL,
[GFTGID] [int] NULL,
[GFTCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRC] [decimal] (24, 4) NOT NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[CNTRINPRC] [decimal] (24, 4) NOT NULL,
[COST] [decimal] (24, 4) NOT NULL,
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMGFT__QPC__5797B72B] DEFAULT (1),
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRMDIV1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMGFT__PRMDIV1__588BDB64] DEFAULT (100),
[PRMDIV2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMGFT__PRMDIV2__597FFF9D] DEFAULT (0),
[PRMDIV3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMGFT__PRMDIV3__5A7423D6] DEFAULT (0),
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PROMGFT__QTY__5B68480F] DEFAULT (1),
[FLAG] [int] NOT NULL,
[ISDLT] [smallint] NOT NULL CONSTRAINT [DF__PROMGFT__ISDLT__62AB0DD2] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROMGFT] ADD CONSTRAINT [PK__PROMGFT__5C5C6C48] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [PRMNO], [FLAG], [LINE]) ON [PRIMARY]
GO
