CREATE TABLE [dbo].[POLYPROMEXGDDTLOCR]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[GDGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPROMEXGDDTLOCR] ADD CONSTRAINT [PK__POLYPROMEXGDDTLO__601A5098] PRIMARY KEY CLUSTERED  ([CLS], [BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
