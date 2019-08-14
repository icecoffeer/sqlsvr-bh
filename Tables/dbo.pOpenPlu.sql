CREATE TABLE [dbo].[pOpenPlu]
(
[PluCode] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ScanCode] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[PluName] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[JinPrice] [money] NULL,
[PluPrice] [money] NULL,
[WhlPrice] [money] NULL,
[VipPrice] [money] NULL,
[VipPrice1] [money] NULL,
[DSPrice] [money] NULL,
[DSCode] [char] (8) COLLATE Chinese_PRC_CI_AS NULL,
[CunCode] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[ClassCode] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[PluZsFlag] [char] (1) COLLATE Chinese_PRC_CI_AS NULL,
[PluYhFlag] [char] (1) COLLATE Chinese_PRC_CI_AS NULL,
[PluThFlag] [char] (1) COLLATE Chinese_PRC_CI_AS NULL,
[Tag] [char] (1) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
