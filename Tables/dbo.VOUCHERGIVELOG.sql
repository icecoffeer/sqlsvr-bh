CREATE TABLE [dbo].[VOUCHERGIVELOG]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [int] NOT NULL,
[ACTION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MODIFIER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TIME] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERGIVELOG] ADD CONSTRAINT [PK__VOUCHERGIVELOG__57F24C47] PRIMARY KEY CLUSTERED  ([NUM], [STAT], [ACTION], [TIME]) ON [PRIMARY]
GO
