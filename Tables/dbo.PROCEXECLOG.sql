CREATE TABLE [dbo].[PROCEXECLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[STAT] [smallint] NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ACT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[TIME] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PROCEXECLOG] ADD CONSTRAINT [PK__PROCEXECLOG__38141EDA] PRIMARY KEY CLUSTERED  ([TIME], [STAT], [NUM]) ON [PRIMARY]
GO
