CREATE TABLE [dbo].[MKTPRCDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDQPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__MKTPRCDTL__GDQPC__2FBECFFB] DEFAULT ('1*1'),
[GDQPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__MKTPRCDTL__GDQPC__30B2F434] DEFAULT (1),
[RTLPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NULL,
[WHSPRC] [decimal] (24, 4) NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[PROMOTEPRICE] [decimal] (24, 4) NULL,
[PROMOTEINPRC] [decimal] (24, 4) NULL,
[PROMOTEMBRPRC] [decimal] (24, 4) NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[LRTLPRC] [decimal] (24, 4) NULL,
[LCNTINPRC] [decimal] (24, 4) NULL,
[LWHSPRC] [decimal] (24, 4) NULL,
[LMBRPRC] [decimal] (24, 4) NULL,
[LPROMOTEPRICE] [decimal] (24, 4) NULL,
[LPROMOTEINPRC] [decimal] (24, 4) NULL,
[LPROMOTEMBRPRC] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MKTPRCDTL] ADD CONSTRAINT [PK__MktPrcDtl__31A7186D] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
