CREATE TABLE [dbo].[CQDETYPEDEF]
(
[NO] [int] NOT NULL,
[NAME] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MTABLEBUF] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DTABLEBUF] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MID] [int] NOT NULL,
[DID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQDETYPEDEF] ADD CONSTRAINT [PK__CQDETYPEDEF__6E8F5FC5] PRIMARY KEY CLUSTERED  ([NO]) ON [PRIMARY]
GO