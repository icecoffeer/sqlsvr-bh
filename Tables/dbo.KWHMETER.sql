CREATE TABLE [dbo].[KWHMETER]
(
[NO] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[SRC] [int] NOT NULL,
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL,
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[KWHMETERMAX] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[KWHMETER] ADD CONSTRAINT [PK__KWHMETER__3214D548664B5896] PRIMARY KEY CLUSTERED  ([NO]) ON [PRIMARY]
GO