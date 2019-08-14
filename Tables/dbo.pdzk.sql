CREATE TABLE [dbo].[pdzk]
(
[未销未付数] [money] NULL,
[未销未付额] [money] NULL,
[未销已付数] [money] NULL,
[未销已付额] [money] NULL,
[已销未付数] [money] NOT NULL,
[已销未付额] [money] NOT NULL,
[总应付差价] [money] NOT NULL,
[企业应付差价] [money] NOT NULL,
[name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[code] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[sale] [money] NULL,
[SaleNow] [smallint] NOT NULL,
[gid] [int] NOT NULL CONSTRAINT [DF__pdzk__gid__1394653D] DEFAULT (0),
[inprc] [money] NOT NULL CONSTRAINT [DF__pdzk__inprc__14888976] DEFAULT (0),
[rtlprc] [money] NOT NULL CONSTRAINT [DF__pdzk__rtlprc__157CADAF] DEFAULT (0)
) ON [PRIMARY]
GO
