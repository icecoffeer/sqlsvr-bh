CREATE TABLE [dbo].[NPURCHASEORDERTRANSDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[REALAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__REALA__19258366] DEFAULT (0),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NPURCHASE__RECCN__1A19A79F] DEFAULT (0),
[QTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASEOR__QTY__1B0DCBD8] DEFAULT (0),
[GUEST] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPURCHASEORDERTRANSDTL] ADD CONSTRAINT [PK__NPURCHASEORDERTR__1C01F011] PRIMARY KEY CLUSTERED  ([SRC], [ID], [FLOWNO], [POSNO]) ON [PRIMARY]
GO
