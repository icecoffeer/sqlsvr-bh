CREATE TABLE [dbo].[DISABLECARDS]
(
[NAME] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DISABLECARDS] ADD CONSTRAINT [PK__DISABLECARDS__09C671A1] PRIMARY KEY CLUSTERED  ([NAME], [NOTE]) ON [PRIMARY]
GO
