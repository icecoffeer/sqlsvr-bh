CREATE TABLE [dbo].[NINVCHGYRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BGDGID] [int] NULL,
[BWRH] [int] NULL,
[CQ1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CQ1__0B13627E] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CQ2__0C0786B7] DEFAULT (0),
[CQ4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CQ4__0CFBAAF0] DEFAULT (0),
[CQ5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CQ5__0DEFCF29] DEFAULT (0),
[CI1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CI1__0EE3F362] DEFAULT (0),
[CI2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CI2__0FD8179B] DEFAULT (0),
[CI3] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CI3__10CC3BD4] DEFAULT (0),
[CI4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CI4__11C0600D] DEFAULT (0),
[CI5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CI5__12B48446] DEFAULT (0),
[CR1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CR1__13A8A87F] DEFAULT (0),
[CR2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CR2__149CCCB8] DEFAULT (0),
[CR3] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CR3__1590F0F1] DEFAULT (0),
[CR4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CR4__1685152A] DEFAULT (0),
[CR5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__CR5__17793963] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DQ1__186D5D9C] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DQ2__196181D5] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DQ4__1A55A60E] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DQ5__1B49CA47] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DI1__1C3DEE80] DEFAULT (0),
[DI2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DI2__1D3212B9] DEFAULT (0),
[DI3] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DI3__1E2636F2] DEFAULT (0),
[DI4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DI4__1F1A5B2B] DEFAULT (0),
[DI5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DI5__200E7F64] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DR1__2102A39D] DEFAULT (0),
[DR2] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DR2__21F6C7D6] DEFAULT (0),
[DR3] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DR3__22EAEC0F] DEFAULT (0),
[DR4] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DR4__23DF1048] DEFAULT (0),
[DR5] [money] NULL CONSTRAINT [DF__NINVCHGYRPT__DR5__24D33481] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL,
[CQ6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CQ6__452AF57A] DEFAULT (0),
[CQ7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CQ7__461F19B3] DEFAULT (0),
[CT6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CT6__47133DEC] DEFAULT (0),
[CT7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CT7__48076225] DEFAULT (0),
[CI6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CI6__48FB865E] DEFAULT (0),
[CI7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CI7__49EFAA97] DEFAULT (0),
[CR6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CR6__4AE3CED0] DEFAULT (0),
[CR7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__CR7__4BD7F309] DEFAULT (0),
[DQ6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DQ6__4CCC1742] DEFAULT (0),
[DQ7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DQ7__4DC03B7B] DEFAULT (0),
[DT6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DT6__4EB45FB4] DEFAULT (0),
[DT7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DT7__4FA883ED] DEFAULT (0),
[DI6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DI6__509CA826] DEFAULT (0),
[DI7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DI7__5190CC5F] DEFAULT (0),
[DR6] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DR6__5284F098] DEFAULT (0),
[DR7] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DR7__537914D1] DEFAULT (0),
[DI8] [money] NOT NULL CONSTRAINT [DF__NINVCHGYRPT__DI8__6E22E96C] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINVCHGYRPT] ADD CONSTRAINT [PK__NINVCHGYRPT__34E8D562] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO