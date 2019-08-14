CREATE TABLE [dbo].[PSSUMSCOREDTLLOG]
(
[TYPE] [smallint] NOT NULL,
[OPER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PSSUMSCOR__OPERT__17CA7835] DEFAULT (getdate()),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
