CREATE TABLE [dbo].[OLD_CARD_STRU]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PCODE] [char] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[IDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[TYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DISCOUNT] [money] NOT NULL,
[CREATEDATE] [datetime] NOT NULL,
[LASTTIME] [datetime] NULL,
[TOTAL] [money] NOT NULL,
[FAVAMT] [money] NOT NULL,
[TLCNT] [int] NOT NULL,
[TLGD] [money] NOT NULL,
[VALIDDATE] [datetime] NOT NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ADDR1] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ADDR2] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[BALANCE] [money] NULL,
[PARVALUE] [money] NULL,
[CSTGID] [int] NULL,
[SEX] [smallint] NULL,
[BIRTHDAY] [datetime] NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[COMPANY] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FAMILIES] [int] NULL,
[INCOME] [money] NULL,
[HOBBY] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[TRAFFIC] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TRANSACTOR] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[WEDDINGDAY] [datetime] NULL,
[FAVCOLOR] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[OTHER] [varchar] (60) COLLATE Chinese_PRC_CI_AS NULL,
[MOBILEPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[BP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO