CREATE TABLE [dbo].[VOUCHERUSERULEGOODSINDTLOCR]
(
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[GDGID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERUSERULEGOODSINDTLOCR] ADD CONSTRAINT [PK__VOUCHERUSERULEGO__4692B61B] PRIMARY KEY CLUSTERED  ([BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
