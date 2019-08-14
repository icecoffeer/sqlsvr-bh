CREATE TABLE [dbo].[PS3_OUTEROUTMST]
(
[PLATFORM] [varchar] (80) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLNUM] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHOPNO] [varchar] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILLER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PS3_OUTER__FILDA__4E88DD9E] DEFAULT (getdate()),
[CLIENT] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[DEPT] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3_OUTER__AMOUN__4F7D01D7] DEFAULT ((0)),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[DIRECTION] [smallint] NOT NULL,
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERATIONSTAT] [smallint] NOT NULL CONSTRAINT [DF__PS3_OUTER__OPERA__50712610] DEFAULT ((0)),
[OPERATIONNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_OUTEROUTMST] ADD CONSTRAINT [PK__PS3_OUTE__65A475E752596E82] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3_OuterOutMst_PB] ON [dbo].[PS3_OUTEROUTMST] ([PLATFORM], [BILLNUM]) ON [PRIMARY]
GO
