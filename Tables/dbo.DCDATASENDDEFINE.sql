CREATE TABLE [dbo].[DCDATASENDDEFINE]
(
[ANAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Note] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DCDATASENDDEFINE] ADD CONSTRAINT [PK__DCDATASENDDEFINE__0175B502] PRIMARY KEY CLUSTERED  ([ANAME]) ON [PRIMARY]
GO