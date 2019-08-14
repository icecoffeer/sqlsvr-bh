CREATE TABLE [dbo].[MOUTMRPT]
(
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[CQ1] [money] NULL CONSTRAINT [DF__MOUTMRPT__CQ1__6A518D31] DEFAULT (0),
[CQ5] [money] NULL CONSTRAINT [DF__MOUTMRPT__CQ5__6B45B16A] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__MOUTMRPT__CT1__6C39D5A3] DEFAULT (0),
[CT5] [money] NULL CONSTRAINT [DF__MOUTMRPT__CT5__6D2DF9DC] DEFAULT (0),
[CT92] [money] NULL CONSTRAINT [DF__MOUTMRPT__CT92__6E221E15] DEFAULT (0),
[CI1] [money] NULL CONSTRAINT [DF__MOUTMRPT__CI1__6F16424E] DEFAULT (0),
[CI5] [money] NULL CONSTRAINT [DF__MOUTMRPT__CI5__700A6687] DEFAULT (0),
[CR1] [money] NULL CONSTRAINT [DF__MOUTMRPT__CR1__70FE8AC0] DEFAULT (0),
[CR5] [money] NULL CONSTRAINT [DF__MOUTMRPT__CR5__71F2AEF9] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__MOUTMRPT__DQ1__72E6D332] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__MOUTMRPT__DQ5__73DAF76B] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__MOUTMRPT__DT1__74CF1BA4] DEFAULT (0),
[DT5] [money] NULL CONSTRAINT [DF__MOUTMRPT__DT5__75C33FDD] DEFAULT (0),
[DT92] [money] NULL CONSTRAINT [DF__MOUTMRPT__DT92__76B76416] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__MOUTMRPT__DI1__77AB884F] DEFAULT (0),
[DI5] [money] NULL CONSTRAINT [DF__MOUTMRPT__DI5__789FAC88] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__MOUTMRPT__DR1__7993D0C1] DEFAULT (0),
[DR5] [money] NULL CONSTRAINT [DF__MOUTMRPT__DR5__7A87F4FA] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[MOUTMRPT] ADD CONSTRAINT [PK__MOUTMRPT__1293BD5E] PRIMARY KEY CLUSTERED  ([ASTORE], [BGDGID], [ASETTLENO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO