CREATE TABLE [dbo].[CRMCARDTYPERIGHT]
(
[EMPGRPGID] [int] NOT NULL,
[CARDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMCARDTYPERIGHT] ADD CONSTRAINT [PK__CRMCARDTYPERIGHT__54B9B3D2] PRIMARY KEY CLUSTERED  ([EMPGRPGID], [CARDTYPE]) ON [PRIMARY]
GO
