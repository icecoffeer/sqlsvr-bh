CREATE TABLE [dbo].[LTDADJLACDTL2]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ALCGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[LTDADJLACDTL2] ADD CONSTRAINT [PK__LTDADJLACDTL2__473404D4] PRIMARY KEY CLUSTERED  ([NUM], [ALCGID]) ON [PRIMARY]
GO
