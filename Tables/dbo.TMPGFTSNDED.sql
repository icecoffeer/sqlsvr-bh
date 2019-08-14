CREATE TABLE [dbo].[TMPGFTSNDED]
(
[spid] [int] NOT NULL,
[FlowNo] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PosNo] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SndNum] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[RCODE] [char] (18) COLLATE Chinese_PRC_CI_AS NULL,
[GROUPID] [int] NULL,
[GDGID] [int] NULL,
[QTY] [decimal] (24, 2) NULL,
[BCKEDQTY] [decimal] (24, 2) NULL,
[TOBCKQTY] [decimal] (24, 2) NULL,
[PAYAMT] [decimal] (24, 2) NULL,
[PAYPRC] [decimal] (24, 2) NULL,
[GFTINPRC] [decimal] (24, 2) NULL,
[CTRTYPE] [int] NULL CONSTRAINT [DF__TMPGFTSND__CTRTY__277C2DB0] DEFAULT (0),
[RULEDTLQTY] [decimal] (24, 2) NULL,
[RULEDTLALLQTY] [decimal] (24, 2) NULL,
[RULEDTLALLAMT] [decimal] (24, 2) NULL,
[Done] [int] NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPGFTSNDED_spid] ON [dbo].[TMPGFTSNDED] ([spid]) ON [PRIMARY]
GO
