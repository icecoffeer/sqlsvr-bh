CREATE TABLE [dbo].[NVDRPAYDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CHGNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SHOULDPAY] [decimal] (24, 2) NOT NULL,
[REALPAY] [decimal] (24, 2) NOT NULL,
[PAYTOTAL] [decimal] (24, 2) NOT NULL,
[NOPAYTOTAL] [decimal] (24, 2) NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NVDRPAYDTL] ADD CONSTRAINT [PK__NVDRPAYDTL__626B16B0] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
