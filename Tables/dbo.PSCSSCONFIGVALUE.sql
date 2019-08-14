CREATE TABLE [dbo].[PSCSSCONFIGVALUE]
(
[CODE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[CFGVALUE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VALUECAPTION] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSCONFIGVALUE] ADD CONSTRAINT [PK__PSCSSCONFIGVALUE__2827CFD4] PRIMARY KEY CLUSTERED  ([CODE], [ITEMNO]) ON [PRIMARY]
GO