CREATE TABLE [dbo].[TMPPAY]
(
[spid] [int] NOT NULL,
[VDRGID] [int] NULL,
[IVCNUM] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[IVCCODE] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[OCRDATE] [datetime] NULL,
[PAYDATE] [datetime] NULL,
[TOTAL] [decimal] (24, 2) NULL,
[FEE] [decimal] (24, 2) NULL,
[ACTTOTAL] [decimal] (24, 2) NULL,
[CURTOTAL] [decimal] (24, 2) NULL,
[CHGTYPE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[VDRCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[VDRNAME] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTOCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTONAME] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTO] [int] NULL,
[ISORNOT] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PSR] [int] NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[TAXRATE] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPPAY_spid] ON [dbo].[TMPPAY] ([spid]) ON [PRIMARY]
GO
