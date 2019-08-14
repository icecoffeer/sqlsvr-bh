CREATE TABLE [dbo].[NMKTPRCDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDQPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NMKTPRCDT__GDQPC__40E95BFD] DEFAULT ('1*1'),
[GDQPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NMKTPRCDT__GDQPC__41DD8036] DEFAULT (1),
[RTLPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NULL,
[WHSPRC] [decimal] (24, 4) NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[PROMOTEPRICE] [decimal] (24, 4) NULL,
[PROMOTEINPRC] [decimal] (24, 4) NULL,
[PROMOTEMBRPRC] [decimal] (24, 4) NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LRTLPRC] [decimal] (24, 4) NULL,
[LCNTINPRC] [decimal] (24, 4) NULL,
[LWHSPRC] [decimal] (24, 4) NULL,
[LMBRPRC] [decimal] (24, 4) NULL,
[LPROMOTEPRICE] [decimal] (24, 4) NULL,
[LPROMOTEINPRC] [decimal] (24, 4) NULL,
[LPROMOTEMBRPRC] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NMKTPRCDTL] ADD CONSTRAINT [PK__NMktPrcDtl__42D1A46F] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
