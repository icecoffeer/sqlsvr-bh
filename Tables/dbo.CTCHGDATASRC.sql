CREATE TABLE [dbo].[CTCHGDATASRC]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DSCODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCHGDATASRC] ADD CONSTRAINT [PK__CTCHGDATASRC__2A245B88] PRIMARY KEY CLUSTERED  ([CODE], [DSCODE]) ON [PRIMARY]
GO
