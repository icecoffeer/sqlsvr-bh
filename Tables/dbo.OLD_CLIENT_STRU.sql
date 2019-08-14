CREATE TABLE [dbo].[OLD_CLIENT_STRU]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHORTNAME] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TAXNO] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[ACCOUNTNO] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FAX] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CREATEDATE] [datetime] NOT NULL,
[PROPERTY] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEACCOUNT] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTERM] [smallint] NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LAWREP] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CONTACTOR] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[CTRPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBP] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[FILLER] [int] NOT NULL,
[MODIFIER] [int] NOT NULL,
[OUTPRC] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[EMAILADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[WWWADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
