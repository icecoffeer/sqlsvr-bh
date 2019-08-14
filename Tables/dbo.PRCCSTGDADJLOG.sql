CREATE TABLE [dbo].[PRCCSTGDADJLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACT] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCCSTGDADJLOG] ADD CONSTRAINT [PK__PRCCSTGDADJLOG__5AFD6864] PRIMARY KEY CLUSTERED  ([NUM], [STAT], [ACT], [TIME]) ON [PRIMARY]
GO
