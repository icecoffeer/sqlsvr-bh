CREATE TABLE [dbo].[SVIPAYSTOREDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[CLS] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__SVIPAYSTORE__CLS__084CCFC3] DEFAULT ('代销')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SVIPAYSTOREDTL] ADD CONSTRAINT [PK__SVIPAYSTOREDTL__0940F3FC] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [STOREGID]) ON [PRIMARY]
GO
