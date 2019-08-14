CREATE TABLE [dbo].[PCKONLINE]
(
[FLOWNO] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PLATFORM] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ITEMNO] [smallint] NOT NULL,
[INPUTER] [int] NOT NULL CONSTRAINT [DF__PCKONLINE__INPUT__2744F34B] DEFAULT ((1)),
[OPERATOR] [int] NOT NULL CONSTRAINT [DF__PCKONLINE__OPERA__28391784] DEFAULT ((1)),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PCKONLINE__FILDA__292D3BBD] DEFAULT (getdate()),
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PCKONLINE__QTY__2A215FF6] DEFAULT ((0)),
[IMPSTAT] [smallint] NOT NULL CONSTRAINT [DF__PCKONLINE__IMPST__2B15842F] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PCKONLINE] ADD CONSTRAINT [PK__PCKONLIN__6C35879B255CAAD9] PRIMARY KEY CLUSTERED  ([PLATFORM], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO
