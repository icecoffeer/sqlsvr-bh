CREATE TABLE [dbo].[INPRCPRMLACDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[INPRCPRMLACDTL] ADD CONSTRAINT [PK__INPRCPRMLACDTL__1B9ED002] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
