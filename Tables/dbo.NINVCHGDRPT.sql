CREATE TABLE [dbo].[NINVCHGDRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[ADATE] [datetime] NULL,
[BGDGID] [int] NULL,
[BWRH] [int] NULL,
[DQ1] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DQ1__5F34E040] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DQ2__60290479] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DQ4__611D28B2] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DQ5__62114CEB] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DI1__63057124] DEFAULT (0),
[DI2] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DI2__63F9955D] DEFAULT (0),
[DI3] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DI3__64EDB996] DEFAULT (0),
[DI4] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DI4__65E1DDCF] DEFAULT (0),
[DI5] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DI5__66D60208] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DR1__67CA2641] DEFAULT (0),
[DR2] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DR2__68BE4A7A] DEFAULT (0),
[DR3] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DR3__69B26EB3] DEFAULT (0),
[DR4] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DR4__6AA692EC] DEFAULT (0),
[DR5] [money] NULL CONSTRAINT [DF__NINVCHGDRPT__DR5__6B9AB725] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL,
[DQ6] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DQ6__2E479022] DEFAULT (0),
[DQ7] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DQ7__2F3BB45B] DEFAULT (0),
[DT6] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DT6__302FD894] DEFAULT (0),
[DT7] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DT7__3123FCCD] DEFAULT (0),
[DI6] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DI6__32182106] DEFAULT (0),
[DI7] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DI7__330C453F] DEFAULT (0),
[DR6] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DR6__34006978] DEFAULT (0),
[DR7] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DR7__34F48DB1] DEFAULT (0),
[DI8] [money] NOT NULL CONSTRAINT [DF__NINVCHGDRPT__DI8__6C3AA0FA] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINVCHGDRPT] ADD CONSTRAINT [PK__NINVCHGDRPT__33008CF0] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
