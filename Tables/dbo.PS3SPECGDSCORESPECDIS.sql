CREATE TABLE [dbo].[PS3SPECGDSCORESPECDIS]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CARDTYPECODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CARDTYPENAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3SPECGD__DISCO__170C297D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SPECGDSCORESPECDIS] ADD CONSTRAINT [PK__PS3SPECGDSCORESP__18004DB6] PRIMARY KEY CLUSTERED  ([NUM], [CLS], [LINE]) ON [PRIMARY]
GO
