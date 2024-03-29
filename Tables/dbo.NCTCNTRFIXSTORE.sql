CREATE TABLE [dbo].[NCTCNTRFIXSTORE]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[STORESCOPE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCNTRFI__TOTAL__274A50E2] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRFIXSTORE] ADD CONSTRAINT [PK__NCTCNTRFIXSTORE__283E751B] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [ITEMNO]) ON [PRIMARY]
GO
