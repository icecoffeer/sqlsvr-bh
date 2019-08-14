CREATE TABLE [dbo].[gdCheck]
(
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[sort] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[billto] [int] NOT NULL,
[vCode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[vName] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[counter] [int] NOT NULL,
[pageNo] [int] NOT NULL CONSTRAINT [DF__gdCheck__pageNo__263D255D] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gdCheck] ADD CONSTRAINT [PK__gdCheck__6D03DCAA] PRIMARY KEY CLUSTERED  ([num]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
