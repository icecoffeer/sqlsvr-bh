CREATE TABLE [dbo].[CNTRPAYCASHVATDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[VENDOR] [char] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STORE] [char] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ADATE] [datetime] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL,
[INNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[AMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRPAYCASH__AMT__4285F4FE] DEFAULT (0),
[TAX] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRPAYCASH__TAX__437A1937] DEFAULT (0),
[TAXRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CNTRPAYCA__TAXRA__1360F1C1] DEFAULT (17),
[IVCNUM] [varchar] (30) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CNTRPAYCASHVATDTL] ADD CONSTRAINT [PK__CNTRPAYCASHVATDT__309C4EED] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO