CREATE TABLE [dbo].[NOUTMRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BGDGID] [int] NULL,
[BWRH] [int] NULL,
[BCSTGID] [int] NULL,
[DQ1] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ1__4E3F5E68] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ2__4F3382A1] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ3__5027A6DA] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ4__511BCB13] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ5__520FEF4C] DEFAULT (0),
[DQ6] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ6__53041385] DEFAULT (0),
[DQ7] [money] NULL CONSTRAINT [DF__NOUTMRPT__DQ7__53F837BE] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT1__54EC5BF7] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT2__55E08030] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT3__56D4A469] DEFAULT (0),
[DT4] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT4__57C8C8A2] DEFAULT (0),
[DT5] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT5__58BCECDB] DEFAULT (0),
[DT6] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT6__59B11114] DEFAULT (0),
[DT7] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT7__5AA5354D] DEFAULT (0),
[DT91] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT91__5B995986] DEFAULT (0),
[DT92] [money] NULL CONSTRAINT [DF__NOUTMRPT__DT92__5C8D7DBF] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI1__5D81A1F8] DEFAULT (0),
[DI2] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI2__5E75C631] DEFAULT (0),
[DI3] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI3__5F69EA6A] DEFAULT (0),
[DI4] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI4__605E0EA3] DEFAULT (0),
[DI5] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI5__615232DC] DEFAULT (0),
[DI6] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI6__62465715] DEFAULT (0),
[DI7] [money] NULL CONSTRAINT [DF__NOUTMRPT__DI7__633A7B4E] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR1__642E9F87] DEFAULT (0),
[DR2] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR2__6522C3C0] DEFAULT (0),
[DR3] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR3__6616E7F9] DEFAULT (0),
[DR4] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR4__670B0C32] DEFAULT (0),
[DR5] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR5__67FF306B] DEFAULT (0),
[DR6] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR6__68F354A4] DEFAULT (0),
[DR7] [money] NULL CONSTRAINT [DF__NOUTMRPT__DR7__69E778DD] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NOUTMRPT] ADD CONSTRAINT [PK__NOUTMRPT__3C89F72A] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
