CREATE TABLE [dbo].[GOODST]
(
[GID] [int] NOT NULL,
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RTLPRC] [money] NOT NULL,
[INPRC] [money] NOT NULL,
[TAXRATE] [money] NOT NULL,
[PROMOTE] [smallint] NOT NULL,
[PRCTYPE] [smallint] NOT NULL,
[SALE] [smallint] NOT NULL,
[LSTINPRC] [money] NOT NULL,
[INVPRC] [money] NOT NULL,
[OLDINVPRC] [money] NOT NULL,
[LWTRTLPRC] [money] NULL,
[WHSPRC] [money] NOT NULL,
[WRH] [int] NOT NULL,
[ACNT] [smallint] NOT NULL,
[PAYTODTL] [smallint] NOT NULL,
[PAYRATE] [money] NULL,
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ISPKG] [smallint] NOT NULL,
[GFT] [smallint] NOT NULL,
[QPC] [money] NOT NULL,
[TM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MANUFACTOR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[MCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GPR] [money] NULL,
[LOWINV] [money] NULL,
[HIGHINV] [money] NULL,
[VALIDPERIOD] [smallint] NULL,
[CREATEDATE] [datetime] NOT NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CHKVD] [smallint] NOT NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[DXPRC] [money] NOT NULL,
[BILLTO] [int] NOT NULL,
[AUTOORD] [smallint] NOT NULL,
[ORIGIN] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MBRPRC] [money] NULL,
[SALETAX] [money] NOT NULL,
[PSR] [int] NOT NULL,
[F1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[F2] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F3] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [int] NOT NULL,
[MODIFIER] [int] NOT NULL,
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CODE2] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[MKTINPRC] [money] NULL,
[MKTRTLPRC] [money] NULL,
[CNTINPRC] [money] NULL,
[ALCQTY] [money] NULL,
[ISBIND] [smallint] NULL,
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ISLTD] [smallint] NULL
) ON [PRIMARY]
GO
