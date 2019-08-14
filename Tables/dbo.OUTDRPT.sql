CREATE TABLE [dbo].[OUTDRPT]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[ADATE] [datetime] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BCSTGID] [int] NOT NULL,
[DQ1] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ1__31832429] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ2__32774862] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ3__336B6C9B] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ4__345F90D4] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ5__3553B50D] DEFAULT (0),
[DQ6] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ6__3647D946] DEFAULT (0),
[DQ7] [money] NULL CONSTRAINT [DF__OUTDRPT__DQ7__373BFD7F] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__OUTDRPT__DT1__383021B8] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__OUTDRPT__DT2__392445F1] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__OUTDRPT__DT3__3A186A2A] DEFAULT (0),
[DT4] [money] NULL CONSTRAINT [DF__OUTDRPT__DT4__3B0C8E63] DEFAULT (0),
[DT5] [money] NULL CONSTRAINT [DF__OUTDRPT__DT5__3C00B29C] DEFAULT (0),
[DT6] [money] NULL CONSTRAINT [DF__OUTDRPT__DT6__3CF4D6D5] DEFAULT (0),
[DT7] [money] NULL CONSTRAINT [DF__OUTDRPT__DT7__3DE8FB0E] DEFAULT (0),
[DT91] [money] NULL CONSTRAINT [DF__OUTDRPT__DT91__3EDD1F47] DEFAULT (0),
[DT92] [money] NULL CONSTRAINT [DF__OUTDRPT__DT92__3FD14380] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__OUTDRPT__DI1__40C567B9] DEFAULT (0),
[DI2] [money] NULL CONSTRAINT [DF__OUTDRPT__DI2__41B98BF2] DEFAULT (0),
[DI3] [money] NULL CONSTRAINT [DF__OUTDRPT__DI3__42ADB02B] DEFAULT (0),
[DI4] [money] NULL CONSTRAINT [DF__OUTDRPT__DI4__43A1D464] DEFAULT (0),
[DI5] [money] NULL CONSTRAINT [DF__OUTDRPT__DI5__4495F89D] DEFAULT (0),
[DI6] [money] NULL CONSTRAINT [DF__OUTDRPT__DI6__458A1CD6] DEFAULT (0),
[DI7] [money] NULL CONSTRAINT [DF__OUTDRPT__DI7__467E410F] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__OUTDRPT__DR1__47726548] DEFAULT (0),
[DR2] [money] NULL CONSTRAINT [DF__OUTDRPT__DR2__48668981] DEFAULT (0),
[DR3] [money] NULL CONSTRAINT [DF__OUTDRPT__DR3__495AADBA] DEFAULT (0),
[DR4] [money] NULL CONSTRAINT [DF__OUTDRPT__DR4__4A4ED1F3] DEFAULT (0),
[DR5] [money] NULL CONSTRAINT [DF__OUTDRPT__DR5__4B42F62C] DEFAULT (0),
[DR6] [money] NULL CONSTRAINT [DF__OUTDRPT__DR6__4C371A65] DEFAULT (0),
[DR7] [money] NULL CONSTRAINT [DF__OUTDRPT__DR7__4D2B3E9E] DEFAULT (0),
[LSTUPDTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[OUTDRPT] ADD CONSTRAINT [PK__OUTDRPT__5C02A283] PRIMARY KEY CLUSTERED  ([ADATE], [BGDGID], [BCSTGID], [BWRH], [ASETTLENO], [ASTORE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [gddatewrh] ON [dbo].[OUTDRPT] ([BGDGID], [ADATE], [BWRH]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO