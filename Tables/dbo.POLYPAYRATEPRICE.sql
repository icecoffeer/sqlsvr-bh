CREATE TABLE [dbo].[POLYPAYRATEPRICE]
(
[STORE] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BILLLINE] [int] NOT NULL,
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NULL,
[BRAND] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[POLYPAYRATE] [decimal] (24, 4) NOT NULL,
[ASTART] [datetime] NOT NULL,
[AFINISH] [datetime] NOT NULL,
[OCRTIME] [datetime] NOT NULL CONSTRAINT [DF__POLYPAYRA__OCRTI__3E789A54] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPAYRATEPRICE] ADD CONSTRAINT [PK__POLYPAYRATEPRICE__3F6CBE8D] PRIMARY KEY CLUSTERED  ([STORE], [CLS], [BILLNUM], [BILLLINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_POLYPAYRATEPRICE_DEPT] ON [dbo].[POLYPAYRATEPRICE] ([DEPT]) ON [PRIMARY]
GO