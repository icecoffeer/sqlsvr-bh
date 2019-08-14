CREATE TABLE [dbo].[mr_tt]
(
[NO] [int] NOT NULL,
[MODULE] [smallint] NOT NULL,
[FUNCTION] [smallint] NOT NULL,
[NAME] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TABLENAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[FIELDNAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[SPEC] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
