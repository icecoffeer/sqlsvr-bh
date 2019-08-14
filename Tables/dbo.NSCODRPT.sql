CREATE TABLE [dbo].[NSCODRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BCARRIER] [int] NOT NULL,
[BCARD] [int] NOT NULL,
[DT1] [money] NOT NULL CONSTRAINT [DF__NSCODRPT__DT1__7820899B] DEFAULT (0),
[DT2] [money] NOT NULL CONSTRAINT [DF__NSCODRPT__DT2__7914ADD4] DEFAULT (0),
[DS1] [money] NOT NULL CONSTRAINT [DF__NSCODRPT__DS1__7A08D20D] DEFAULT (0),
[DS2] [money] NOT NULL CONSTRAINT [DF__NSCODRPT__DS2__7AFCF646] DEFAULT (0),
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[RCV] [int] NOT NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSCODRPT] ADD CONSTRAINT [PK__NSCODRPT__772C6562] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
