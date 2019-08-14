CREATE TABLE [dbo].[gdCheckDtl]
(
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[line] [int] NOT NULL,
[gid] [int] NOT NULL,
[price] [money] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gdCheckDtl] ADD CONSTRAINT [PK_gdCheckDtl] PRIMARY KEY NONCLUSTERED  ([num], [line]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gdCheckDtl] ADD CONSTRAINT [UQ__gdCheckDtl__2360B8B2] UNIQUE NONCLUSTERED  ([num], [line]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
