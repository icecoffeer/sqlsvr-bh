CREATE TABLE [dbo].[Vdrsettlebind]
(
[Zvdrcode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Zdept] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Zbrand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Storecode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Store] [int] NOT NULL,
[Mvdrcode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Mdept] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Mbrand] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Lwtdt] [money] NULL CONSTRAINT [DF__Vdrsettle__Lwtdt__74FEC837] DEFAULT (0),
[Payrate] [money] NOT NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [Vdrsettlebind_Idx] ON [dbo].[Vdrsettlebind] ([Zvdrcode], [Store], [Mvdrcode]) ON [PRIMARY]
GO
