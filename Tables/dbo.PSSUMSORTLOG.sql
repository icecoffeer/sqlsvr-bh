CREATE TABLE [dbo].[PSSUMSORTLOG]
(
[TYPE] [smallint] NOT NULL,
[OPER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PSSUMSORT__OPERT__05ABC7FA] DEFAULT (getdate()),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
