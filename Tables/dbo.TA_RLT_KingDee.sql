CREATE TABLE [dbo].[TA_RLT_KingDee]
(
[RELATIONID] [int] NOT NULL,
[OPERATIONID] [int] NOT NULL,
[DIRECTION] [smallint] NOT NULL,
[ACCOUNT] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BRIEF] [varchar] (80) COLLATE Chinese_PRC_CI_AS NULL,
[FClsName1] [int] NULL,
[FObjID1] [int] NULL,
[FObjName1] [int] NULL,
[FClsName2] [int] NULL,
[FObjID2] [int] NULL,
[FObjName2] [int] NULL,
[FClsName3] [int] NULL,
[FObjID3] [int] NULL,
[FObjName3] [int] NULL,
[FTransID] [int] NULL,
[FCyID] [int] NULL,
[FExchRate] [int] NULL,
[FFcAmt] [int] NULL,
[Fqty] [int] NULL,
[Fprice] [int] NULL,
[Fdebit] [int] NULL,
[Fcredit] [int] NULL,
[FSettleCode] [int] NULL,
[FSettleNO] [int] NULL,
[ISSUM] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TA_RLT_KingDee] ADD CONSTRAINT [PK__TA_RLT_KingDee__2EFAF1E2] PRIMARY KEY CLUSTERED  ([RELATIONID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
