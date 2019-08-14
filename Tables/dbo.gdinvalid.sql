CREATE TABLE [dbo].[gdinvalid]
(
[gdgid] [int] NOT NULL,
[invqty] [money] NULL,
[invalidqty] [money] NULL,
[outqty] [money] NULL,
[outtotal] [money] NULL,
[inv] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[total] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[gdinvalid] ADD CONSTRAINT [PK_gdinvalid] PRIMARY KEY NONCLUSTERED  ([gdgid]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
