CREATE TABLE [dbo].[NSQLITEM_NETFTPBAK]
(
[OID] [int] NOT NULL,
[ANAME] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SECTION] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[CLSID] [int] NULL,
[GRPID] [int] NULL,
[ACTID] [smallint] NULL,
[ASELECT] [text] COLLATE Chinese_PRC_CI_AS NULL,
[AINSERT] [text] COLLATE Chinese_PRC_CI_AS NULL,
[ADELETE] [text] COLLATE Chinese_PRC_CI_AS NULL,
[INFOSQL1] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[INFOSQL2] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[RCVSelect] [text] COLLATE Chinese_PRC_CI_AS NULL,
[GrpName] [varchar] (60) COLLATE Chinese_PRC_CI_AS NULL,
[AutoRcvSPName] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[AutoRcvSelect] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[AutoRcvErrUpd] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
