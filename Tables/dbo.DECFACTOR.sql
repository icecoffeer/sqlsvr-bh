CREATE TABLE [dbo].[DECFACTOR]
(
[DECFACTORCODE] [char] (1) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DECFACTORNAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DECFACTOR] ADD CONSTRAINT [PK__DECFACTOR__307DEA0A] PRIMARY KEY CLUSTERED  ([DECFACTORCODE]) ON [PRIMARY]
GO