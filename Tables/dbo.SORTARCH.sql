CREATE TABLE [dbo].[SORTARCH]
(
[ACODE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ANAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[APPLYTO] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SORTARCH] ADD CONSTRAINT [PK__SORTARCH__51B25E9E] PRIMARY KEY CLUSTERED  ([ACODE]) ON [PRIMARY]
GO
