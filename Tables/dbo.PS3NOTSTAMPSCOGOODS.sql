CREATE TABLE [dbo].[PS3NOTSTAMPSCOGOODS]
(
[GOODS] [int] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3NOTSTA__OPERT__2ADD4CA9] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3NOTSTAMPSCOGOODS] ADD CONSTRAINT [PK__PS3NOTSTAMPSCOGO__2BD170E2] PRIMARY KEY CLUSTERED  ([GOODS]) ON [PRIMARY]
GO