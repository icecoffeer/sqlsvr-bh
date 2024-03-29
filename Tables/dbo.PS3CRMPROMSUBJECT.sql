CREATE TABLE [dbo].[PS3CRMPROMSUBJECT]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORE] [int] NOT NULL CONSTRAINT [DF__PS3CRMPRO__STORE__0DB6FE16] DEFAULT (0),
[CODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NSCORE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3CRMPRO__NSCOR__0EAB224F] DEFAULT (1),
[BEGINDATE] [datetime] NOT NULL,
[ENDDATE] [datetime] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[OPER] [varchar] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[OPERTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3CRMPRO__OPERT__0F9F4688] DEFAULT (getdate()),
[ISALLCARDTYPEIN] [smallint] NOT NULL CONSTRAINT [DF__PS3CRMPRO__ISALL__7FD3BE6A] DEFAULT (0),
[TPCLS] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3CRMPRO__TPCLS__35FAC4F1] DEFAULT ('会员类型'),
[DISCOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PS3CRMPRO__DISCO__36EEE92A] DEFAULT (0),
[MAXDISCOUNT] [decimal] (24, 2) NULL CONSTRAINT [DF__PS3CRMPRO__MAXDI__37E30D63] DEFAULT (100),
[PREC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PS3CRMPROM__PREC__38D7319C] DEFAULT (0.01)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3CRMPROMSUBJECT] ADD CONSTRAINT [PK__PS3CRMPR__65A475E76B100DB3] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_CRMPROMSUBJECT_STCODE] ON [dbo].[PS3CRMPROMSUBJECT] ([STORE], [CLS], [CODE]) ON [PRIMARY]
GO
