CREATE TABLE [dbo].[Spcvdroutflag]
(
[Settleno] [int] NOT NULL,
[Store] [int] NOT NULL,
[Vdrgid] [int] NOT NULL,
[Vdrcode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Dept] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Brand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Qty] [money] NULL CONSTRAINT [DF__Spcvdroutfl__Qty__76E710A9] DEFAULT (0),
[Dt] [money] NULL CONSTRAINT [DF__Spcvdroutfla__Dt__77DB34E2] DEFAULT (0),
[Di] [money] NULL CONSTRAINT [DF__Spcvdroutfla__Di__78CF591B] DEFAULT (0)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Spcvdroutflag_Idx] ON [dbo].[Spcvdroutflag] ([Settleno], [Store], [Vdrgid]) ON [PRIMARY]
GO
