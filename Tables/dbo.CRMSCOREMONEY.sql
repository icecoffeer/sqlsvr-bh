CREATE TABLE [dbo].[CRMSCOREMONEY]
(
[SCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMSCOREM__SCORE__070607D4] DEFAULT (0),
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CRMSCOREM__AMOUN__07FA2C0D] DEFAULT (0),
[SRC] [int] NOT NULL,
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL,
[LSTMODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
