CREATE TABLE [dbo].[GDSORTLTD]
(
[CODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ZBLTD] [smallint] NOT NULL,
[MDLTD] [smallint] NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATETIME] [datetime] NOT NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDSORTLTD] ADD CONSTRAINT [PK__GDSORTLTD__14A9505E] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO