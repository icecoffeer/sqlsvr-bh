CREATE TABLE [dbo].[CHARGECHKDTL2]
(
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[PAYCLS] [smallint] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CHARGECHK__TOTAL__5E0588EF] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHARGECHKDTL2] ADD CONSTRAINT [PK__CHARGECHKDTL2__5EF9AD28] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
