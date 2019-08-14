CREATE TABLE [dbo].[NINMRPT]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[ASTORE] [int] NULL,
[ASETTLENO] [int] NULL,
[BGDGID] [int] NULL,
[BVDRGID] [int] NULL,
[BWRH] [int] NULL,
[CQ1] [money] NULL CONSTRAINT [DF__NINMRPT__CQ1__59E61B3E] DEFAULT (0),
[CQ2] [money] NULL CONSTRAINT [DF__NINMRPT__CQ2__5ADA3F77] DEFAULT (0),
[CQ3] [money] NULL CONSTRAINT [DF__NINMRPT__CQ3__5BCE63B0] DEFAULT (0),
[CQ4] [money] NULL CONSTRAINT [DF__NINMRPT__CQ4__5CC287E9] DEFAULT (0),
[CT1] [money] NULL CONSTRAINT [DF__NINMRPT__CT1__5DB6AC22] DEFAULT (0),
[CT2] [money] NULL CONSTRAINT [DF__NINMRPT__CT2__5EAAD05B] DEFAULT (0),
[CT3] [money] NULL CONSTRAINT [DF__NINMRPT__CT3__5F9EF494] DEFAULT (0),
[CT4] [money] NULL CONSTRAINT [DF__NINMRPT__CT4__609318CD] DEFAULT (0),
[CI1] [money] NULL CONSTRAINT [DF__NINMRPT__CI1__61873D06] DEFAULT (0),
[CI2] [money] NULL CONSTRAINT [DF__NINMRPT__CI2__627B613F] DEFAULT (0),
[CI3] [money] NULL CONSTRAINT [DF__NINMRPT__CI3__636F8578] DEFAULT (0),
[CI4] [money] NULL CONSTRAINT [DF__NINMRPT__CI4__6463A9B1] DEFAULT (0),
[CR1] [money] NULL CONSTRAINT [DF__NINMRPT__CR1__6557CDEA] DEFAULT (0),
[CR2] [money] NULL CONSTRAINT [DF__NINMRPT__CR2__664BF223] DEFAULT (0),
[CR3] [money] NULL CONSTRAINT [DF__NINMRPT__CR3__6740165C] DEFAULT (0),
[CR4] [money] NULL CONSTRAINT [DF__NINMRPT__CR4__68343A95] DEFAULT (0),
[DQ1] [money] NULL CONSTRAINT [DF__NINMRPT__DQ1__69285ECE] DEFAULT (0),
[DQ2] [money] NULL CONSTRAINT [DF__NINMRPT__DQ2__6A1C8307] DEFAULT (0),
[DQ3] [money] NULL CONSTRAINT [DF__NINMRPT__DQ3__6B10A740] DEFAULT (0),
[DQ4] [money] NULL CONSTRAINT [DF__NINMRPT__DQ4__6C04CB79] DEFAULT (0),
[DT1] [money] NULL CONSTRAINT [DF__NINMRPT__DT1__6CF8EFB2] DEFAULT (0),
[DT2] [money] NULL CONSTRAINT [DF__NINMRPT__DT2__6DED13EB] DEFAULT (0),
[DT3] [money] NULL CONSTRAINT [DF__NINMRPT__DT3__6EE13824] DEFAULT (0),
[DT4] [money] NULL CONSTRAINT [DF__NINMRPT__DT4__6FD55C5D] DEFAULT (0),
[DI1] [money] NULL CONSTRAINT [DF__NINMRPT__DI1__70C98096] DEFAULT (0),
[DI2] [money] NULL CONSTRAINT [DF__NINMRPT__DI2__71BDA4CF] DEFAULT (0),
[DI3] [money] NULL CONSTRAINT [DF__NINMRPT__DI3__72B1C908] DEFAULT (0),
[DI4] [money] NULL CONSTRAINT [DF__NINMRPT__DI4__73A5ED41] DEFAULT (0),
[DR1] [money] NULL CONSTRAINT [DF__NINMRPT__DR1__749A117A] DEFAULT (0),
[DR2] [money] NULL CONSTRAINT [DF__NINMRPT__DR2__758E35B3] DEFAULT (0),
[DR3] [money] NULL CONSTRAINT [DF__NINMRPT__DR3__768259EC] DEFAULT (0),
[DR4] [money] NULL CONSTRAINT [DF__NINMRPT__DR4__77767E25] DEFAULT (0),
[NSTAT] [smallint] NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NINMRPT] ADD CONSTRAINT [PK__NINMRPT__2E3BD7D3] PRIMARY KEY CLUSTERED  ([ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
