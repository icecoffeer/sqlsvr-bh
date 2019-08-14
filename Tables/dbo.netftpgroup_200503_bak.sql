CREATE TABLE [dbo].[netftpgroup_200503_bak]
(
[GRPID] [int] NOT NULL,
[GrpName] [varchar] (60) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLSID] [int] NOT NULL,
[RCVSelect] [text] COLLATE Chinese_PRC_CI_AS NULL,
[AutoRCVSPName] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[AutoRcvSelect] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[AutoRcvErrUpd] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
