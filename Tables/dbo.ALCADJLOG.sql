CREATE TABLE [dbo].[ALCADJLOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACT] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ALCADJLOG] ADD CONSTRAINT [PK__ALCADJLOG__6526BC73] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [STAT], [ACT], [TIME]) ON [PRIMARY]
GO
