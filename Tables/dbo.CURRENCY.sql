CREATE TABLE [dbo].[CURRENCY]
(
[CODE] [smallint] NOT NULL,
[NAME] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FAVRATE] [money] NULL,
[CASHIER] [smallint] NULL CONSTRAINT [DF__CURRENCY__CASHIE__0BDC9E2E] DEFAULT (1),
[CHANGE] [smallint] NULL CONSTRAINT [DF__CURRENCY__CHANGE__0CD0C267] DEFAULT (1),
[ByDevice] [smallint] NOT NULL CONSTRAINT [DF__CURRENCY__ByDevi__73809419] DEFAULT (0),
[SndtoFg] [smallint] NOT NULL CONSTRAINT [DF__CURRENCY__SndtoF__13E3420A] DEFAULT (1),
[FAVRPTRATE] [decimal] (9, 4) NOT NULL CONSTRAINT [DF__CURRENCY__FAVRPT__3CE5579D] DEFAULT (0),
[FAVRPTRATEDENO] [decimal] (9, 4) NOT NULL CONSTRAINT [DF__CURRENCY__FAVRPT__3DD97BD6] DEFAULT (100),
[HighLmtDis] [decimal] (5, 2) NOT NULL CONSTRAINT [DF__CURRENCY__HighLm__70EFD6DF] DEFAULT (0),
[PayByCash] [smallint] NOT NULL CONSTRAINT [DF__CURRENCY__PayByC__71E3FB18] DEFAULT (1),
[BEGINDATE] [datetime] NOT NULL CONSTRAINT [DF__CURRENCY__BEGIND__7E421261] DEFAULT (getdate()),
[ENDDATE] [datetime] NOT NULL CONSTRAINT [DF__CURRENCY__ENDDAT__7F36369A] DEFAULT ('2099.12.31 23:59:59'),
[DisUseAcnt] [smallint] NOT NULL CONSTRAINT [DF__CURRENCY__DisUse__32D5D631] DEFAULT (0),
[IsInSumTotal] [smallint] NOT NULL CONSTRAINT [DF__CURRENCY__IsInSu__3B361208] DEFAULT (1),
[ALWBCK] [smallint] NOT NULL CONSTRAINT [DF__Currency__ALWBCK__228A5FCF] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CURRENCY] ADD CONSTRAINT [PK__CURRENCY__3DB3258D] PRIMARY KEY CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
