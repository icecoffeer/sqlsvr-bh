CREATE TABLE [dbo].[VOUCHERUSERULEGOODSOUTDTLOCR]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[GDGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERUSERULEGOODSOUTDTLOCR] ADD CONSTRAINT [PK__VOUCHERUSERULEGO__487AFE8D] PRIMARY KEY CLUSTERED  ([BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
