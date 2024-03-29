CREATE TABLE [dbo].[CKLOG]
(
[TIME] [datetime] NOT NULL,
[STOREGID] [int] NOT NULL,
[SETTLENO] [int] NULL,
[EMPCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[EMPNAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[WSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CONTENT] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CKLOG] ADD CONSTRAINT [PK__CKLOG__2AA05119] PRIMARY KEY CLUSTERED  ([TIME], [STOREGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
