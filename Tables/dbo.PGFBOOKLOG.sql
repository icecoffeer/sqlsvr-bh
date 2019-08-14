CREATE TABLE [dbo].[PGFBOOKLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PGFBOOKLOG] ADD CONSTRAINT [PK__PGFBOOKLOG__7AA292F4] PRIMARY KEY CLUSTERED  ([NUM], [TIME], [STAT]) ON [PRIMARY]
GO