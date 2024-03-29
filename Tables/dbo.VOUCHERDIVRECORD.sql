CREATE TABLE [dbo].[VOUCHERDIVRECORD]
(
[POSNO] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GIVENUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VoucherActivityCode] [char] (16) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VoucherCode] [char] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VoucherAmt] [decimal] (24, 4) NOT NULL,
[GDGID] [int] NOT NULL,
[ApportAmt] [decimal] (24, 4) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERDIVRECORD] ADD CONSTRAINT [PK__VOUCHERDIVRECORD__5CB70164] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [GDGID], [VoucherCode], [ApportAmt]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VCDR] ON [dbo].[VOUCHERDIVRECORD] ([GIVENUM]) ON [PRIMARY]
GO
