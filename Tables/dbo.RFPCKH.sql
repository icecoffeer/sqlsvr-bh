CREATE TABLE [dbo].[RFPCKH]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILLER] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__RFPCKH__QTY__1F781DA3] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__RFPCKH__FILDATE__206C41DC] DEFAULT (getdate()),
[LSTUPDTIME] [datetime] NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[GENNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[GENCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SUBWRH] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__RFPCKH__SUBWRH__21606615] DEFAULT (''),
[PDANUM] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RFPCKH] ADD CONSTRAINT [PK__RFPCKH__22548A4E] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
