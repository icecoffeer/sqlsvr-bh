CREATE TABLE [dbo].[CRMMODIFYDEPOSITDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[ADJMONEY] [decimal] (24, 2) NOT NULL,
[HSTNUM] [char] (26) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CRMMODIFYDEPOSITDTL] ADD CONSTRAINT [PK__CRMMODIFYDEPOSIT__5B31A737] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
