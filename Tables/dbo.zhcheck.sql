CREATE TABLE [dbo].[zhcheck]
(
[num] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[settleno] [int] NOT NULL,
[fildate] [datetime] NOT NULL,
[filler] [int] NOT NULL,
[checker] [int] NOT NULL,
[stat] [int] NOT NULL,
[reccnt] [int] NOT NULL,
[note] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[zhcheck] ADD CONSTRAINT [PK_zhcheck] PRIMARY KEY NONCLUSTERED  ([num]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
