CREATE TABLE [dbo].[VDRBCKDMDDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[CASES] [decimal] (24, 4) NULL,
[QTY] [decimal] (24, 4) NULL,
[DMDCASES] [decimal] (24, 4) NULL,
[DMDQTY] [decimal] (24, 4) NULL,
[DMDPRICE] [money] NULL,
[PRICE] [money] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[INV] [money] NOT NULL CONSTRAINT [DF__VDRBCKDMDDT__INV__444D7688] DEFAULT (0),
[CHECKED] [smallint] NULL,
[bckedqty] [decimal] (24, 4) NULL CONSTRAINT [DF__vdrbckdmd__bcked__0FE49B41] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRBCKDMDDTL] ADD CONSTRAINT [PK__VDRBCKDMDDTL__4359524F] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
