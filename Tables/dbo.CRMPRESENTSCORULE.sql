CREATE TABLE [dbo].[CRMPRESENTSCORULE]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORE] [int] NULL,
[GOODS] [int] NOT NULL,
[CARDTYPE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMPRESEN__SCORE__19B2C0A7] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMPRESENTSCORULE] ADD CONSTRAINT [PK__CRMPRESENTSCORUL__1AA6E4E0] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
