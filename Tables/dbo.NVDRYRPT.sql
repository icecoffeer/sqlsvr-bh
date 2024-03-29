CREATE TABLE [dbo].[NVDRYRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BVDRGID] [int] NULL,
[BWRH] [int] NULL,
[BGDGID] [int] NULL,
[CQ1] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ1__438CC5CB] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ2__4480EA04] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ3__45750E3D] DEFAULT (0),
[CQ4] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ4__46693276] DEFAULT (0),
[CQ5] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ5__475D56AF] DEFAULT (0),
[CQ6] [money] NULL CONSTRAINT [DF__NVDRYRPT__CQ6__48517AE8] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT1__49459F21] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT2__4A39C35A] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT3__4B2DE793] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT4__4C220BCC] DEFAULT (0),
[CT5] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT5__4D163005] DEFAULT (0),
[CT6] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT6__4E0A543E] DEFAULT (0),
[CT7] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT7__4EFE7877] DEFAULT (0),
[CT8] [money] NULL CONSTRAINT [DF__NVDRYRPT__CT8__4FF29CB0] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ1__50E6C0E9] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ2__51DAE522] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ3__52CF095B] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ4__53C32D94] DEFAULT (0),
[DQ5] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ5__54B751CD] DEFAULT (0),
[DQ6] [money] NULL CONSTRAINT [DF__NVDRYRPT__DQ6__55AB7606] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT1__569F9A3F] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT2__5793BE78] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT3__5887E2B1] DEFAULT (0),
[DT4] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT4__597C06EA] DEFAULT (0),
[DT5] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT5__5A702B23] DEFAULT (0),
[DT6] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT6__5B644F5C] DEFAULT (0),
[DT7] [money] NULL CONSTRAINT [DF__NVDRYRPT__DT7__5C587395] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL,
[ci2] [money] NULL CONSTRAINT [DF__nvdryrpt__ci2__27BA8E24] DEFAULT (0),
[di2] [money] NULL CONSTRAINT [DF__nvdryrpt__di2__28AEB25D] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NVDRYRPT] ADD CONSTRAINT [PK__NVDRYRPT__5649C92D] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
