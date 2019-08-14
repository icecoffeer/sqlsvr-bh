CREATE TABLE [dbo].[PS3_ONLINEORD]
(
[PLATFORM] [varchar] (80) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDNO] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHOPNO] [varchar] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [varchar] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[APPROVESTAT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATOR] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__PS3_ONLIN__CREAT__003547CB] DEFAULT (getdate()),
[LSTMODIFIER] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LSTMODTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3_ONLIN__LSTMO__01296C04] DEFAULT (getdate()),
[CSTNAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CSTPHONE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CSTADDRESS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[REALAMOUNT] [decimal] (24, 2) NOT NULL,
[CANCELTYPE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CANCELREASON] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PAYSTAT] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[PAYAMOUNT] [decimal] (24, 2) NULL,
[PAYTIME] [datetime] NULL,
[PAYER] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OPERATIONSTAT] [smallint] NOT NULL CONSTRAINT [DF__PS3_ONLIN__OPERA__021D903D] DEFAULT (0),
[OPERATIONNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[UUID] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLEAMOUNT] [decimal] (24, 2) NULL,
[BILLFROM] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SRCORDNO] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL,
[MBRGID] [int] NULL,
[DLVTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[DLVMAN] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[DLVPHONE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MbrCardNo] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[RCVCTNAME] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[RCVCTPHONE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[RCVCTADDRESS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SHOPAMOUNT] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_ONLINEORD] ADD CONSTRAINT [PK__PS3_OnLineOrd__0311B476] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PS3_ONLINEORD_PO] ON [dbo].[PS3_ONLINEORD] ([PLATFORM], [ORDNO]) ON [PRIMARY]
GO