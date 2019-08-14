CREATE TABLE [dbo].[rbill]
(
[bill] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[num] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[stat] [int] NOT NULL,
[line] [int] NOT NULL,
[fildate] [datetime] NOT NULL,
[gdgid] [int] NOT NULL,
[wrh] [int] NOT NULL,
[qty] [money] NOT NULL CONSTRAINT [DF__rbill__qty__140AFD37] DEFAULT (0),
[price] [money] NULL CONSTRAINT [DF__rbill__price__14FF2170] DEFAULT (0),
[cost] [money] NOT NULL CONSTRAINT [DF__rbill__cost__15F345A9] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[rbill] ADD CONSTRAINT [PK__rbill__1316D8FE] PRIMARY KEY CLUSTERED  ([bill], [cls], [num], [line]) ON [PRIMARY]
GO
