CREATE TABLE [dbo].[BCKNOTIFYLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL,
[ACT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BCKNOTIFYLOG] ADD CONSTRAINT [PK__BCKNOTIFYLOG__11CC185C] PRIMARY KEY CLUSTERED  ([TIME], [NUM], [STAT]) ON [PRIMARY]
GO
