CREATE TABLE [dbo].[SCHEMELAC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SCHEMELAC] ADD CONSTRAINT [PK__SCHEMELAC__1A26F69C] PRIMARY KEY CLUSTERED  ([NUM], [STOREGID]) ON [PRIMARY]
GO
