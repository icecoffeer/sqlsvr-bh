CREATE TABLE [dbo].[POLYLTDADJLACDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYLTDADJLACDTL] ADD CONSTRAINT [PK__POLYLTDADJLACDTL__7065C6FA] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
