CREATE TABLE [dbo].[PRCCSTGDADJLACDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCCSTGDADJLACDTL] ADD CONSTRAINT [PK__PRCCSTGDADJLACDT__572CD780] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
