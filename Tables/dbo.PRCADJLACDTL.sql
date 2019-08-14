CREATE TABLE [dbo].[PRCADJLACDTL]
(
[CLS] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PRCADJLACDT__CLS__5086CE36] DEFAULT ('核算售价'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PRCADJLACDTL] ADD CONSTRAINT [PK__PRCADJLACDTL__75C27486] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [STOREGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
