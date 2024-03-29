CREATE TABLE [dbo].[VOUCHERACTBCKVOUACTDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CALCTYPE] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERACTIVITY] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERGIVERULE] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERUSERULE] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VOUCHERTYPEAMT] [decimal] (24, 2) NOT NULL,
[BUYTOTAL] [decimal] (24, 2) NOT NULL,
[BCKTOTAL] [decimal] (24, 2) NOT NULL,
[BCKEDTOTAL] [decimal] (24, 2) NOT NULL,
[REMAINTOTAL] [decimal] (24, 2) NOT NULL,
[SHOULDRECYCLEQTY] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VOUCHERACTBCKVOUACTDTL] ADD CONSTRAINT [PK__VOUCHERACTBCKVOU__6458232C] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_VOUCHERACTBCKVOUACTDTL_ACT] ON [dbo].[VOUCHERACTBCKVOUACTDTL] ([CALCTYPE], [VOUCHERACTIVITY]) ON [PRIMARY]
GO
