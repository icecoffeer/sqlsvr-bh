CREATE TABLE [dbo].[GDSORTLTDGOODS]
(
[CODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDSORTLTDGOODS] ADD CONSTRAINT [PK__GDSORTLTDGOODS__169198D0] PRIMARY KEY CLUSTERED  ([CODE], [GDGID]) ON [PRIMARY]
GO
