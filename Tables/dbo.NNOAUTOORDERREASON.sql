CREATE TABLE [dbo].[NNOAUTOORDERREASON]
(
[REASONCODE] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[REASONNAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[TEAMID] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NNOAUTOORDERREASON] ADD CONSTRAINT [PK__NNOAUTOORDERREAS__5F23CA5A] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
