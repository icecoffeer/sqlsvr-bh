CREATE TABLE [dbo].[CQNOUTMRPT]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNOUTMRP__NSTAT__2851ED06] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNOUTMRP__EXTIM__2946113F] DEFAULT (getdate()),
[ASTORE] [int] NOT NULL,
[ASETTLENO] [int] NOT NULL,
[BGDGID] [int] NOT NULL,
[BWRH] [int] NOT NULL,
[BCSTGID] [int] NOT NULL,
[DQ1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ1__2A3A3578] DEFAULT (0),
[DQ2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ2__2B2E59B1] DEFAULT (0),
[DQ3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ3__2C227DEA] DEFAULT (0),
[DQ4] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ4__2D16A223] DEFAULT (0),
[DQ5] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ5__2E0AC65C] DEFAULT (0),
[DQ6] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ6__2EFEEA95] DEFAULT (0),
[DQ7] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DQ7__2FF30ECE] DEFAULT (0),
[DT1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT1__30E73307] DEFAULT (0),
[DT2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT2__31DB5740] DEFAULT (0),
[DT3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT3__32CF7B79] DEFAULT (0),
[DT4] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT4__33C39FB2] DEFAULT (0),
[DT5] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT5__34B7C3EB] DEFAULT (0),
[DT6] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT6__35ABE824] DEFAULT (0),
[DT7] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT7__36A00C5D] DEFAULT (0),
[DT91] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT91__37943096] DEFAULT (0),
[DT92] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DT92__388854CF] DEFAULT (0),
[DI1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI1__397C7908] DEFAULT (0),
[DI2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI2__3A709D41] DEFAULT (0),
[DI3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI3__3B64C17A] DEFAULT (0),
[DI4] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI4__3C58E5B3] DEFAULT (0),
[DI5] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI5__3D4D09EC] DEFAULT (0),
[DI6] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI6__3E412E25] DEFAULT (0),
[DI7] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DI7__3F35525E] DEFAULT (0),
[DR1] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR1__40297697] DEFAULT (0),
[DR2] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR2__411D9AD0] DEFAULT (0),
[DR3] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR3__4211BF09] DEFAULT (0),
[DR4] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR4__4305E342] DEFAULT (0),
[DR5] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR5__43FA077B] DEFAULT (0),
[DR6] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR6__44EE2BB4] DEFAULT (0),
[DR7] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNOUTMRPT__DR7__45E24FED] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNOUTMRPT] ADD CONSTRAINT [PK__CQNOUTMRPT__46D67426] PRIMARY KEY CLUSTERED  ([GROUPID], [ASTORE], [ASETTLENO], [BGDGID], [BWRH], [BCSTGID]) ON [PRIMARY]
GO
