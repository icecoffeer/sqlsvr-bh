CREATE TABLE [dbo].[TangoDomain]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[code] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[remark] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL,
[profile] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[profile2] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[settleOrganization] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[taxCode] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[invoiceCode] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[bankAccount] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[isHeadQuarter] [tinyint] NULL,
[isCompany] [tinyint] NULL,
[isDc] [tinyint] NULL,
[isStore] [tinyint] NULL,
[isVendor] [tinyint] NULL,
[isCustomer] [tinyint] NULL,
[levelId] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[upperDomain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[storeInstallTime] [datetime] NULL,
[deliveryOrder] [int] NULL,
[orderDays] [int] NULL,
[customizedOrderDays] [int] NULL,
[dealRange] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[productStyle] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[transporter] [varchar] (1) COLLATE Chinese_PRC_CI_AS NULL,
[alevel] [varchar] (1) COLLATE Chinese_PRC_CI_AS NULL,
[profile3] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[profile4] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoDomain] ADD CONSTRAINT [PK__TangoDomain__7454BCC1] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoDomain] ADD CONSTRAINT [UQ__TangoDomain__7548E0FA] UNIQUE NONCLUSTERED  ([code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_Domain_1] ON [dbo].[TangoDomain] ([domain]) ON [PRIMARY]
GO
