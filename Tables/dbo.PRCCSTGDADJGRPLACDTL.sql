CREATE TABLE [dbo].[PRCCSTGDADJGRPLACDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STYLECODE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCCSTGDADJGRPLACDTL] ADD CONSTRAINT [PK__PRCCSTGDADJGRPLA__7A4BF68B] PRIMARY KEY CLUSTERED  ([NUM], [STYLECODE]) ON [PRIMARY]
GO