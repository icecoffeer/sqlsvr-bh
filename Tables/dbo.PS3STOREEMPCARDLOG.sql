CREATE TABLE [dbo].[PS3STOREEMPCARDLOG]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TYPE] [int] NOT NULL,
[CARDINFO] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[EMPGID] [int] NOT NULL,
[OLDCONTENT] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3STOREE__OPERT__7B21B5E1] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3STOREEMPCARDLOG] ADD CONSTRAINT [PK__PS3STOREEMPCARDL__7C15DA1A] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
