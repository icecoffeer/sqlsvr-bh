CREATE TABLE [dbo].[POSGRP]
(
[NO] [int] NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PRIVATEPATH] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SQLWHERE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POSGRP] ADD CONSTRAINT [PK__POSGRP__395A1B72] PRIMARY KEY CLUSTERED  ([NO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
