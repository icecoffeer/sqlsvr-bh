CREATE TABLE [dbo].[POLYPRCPRMDTLDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[ITEM] [int] NOT NULL,
[START] [datetime] NOT NULL CONSTRAINT [DF__POLYPRCPR__START__37824F59] DEFAULT ('1899.12.30 00:00:00'),
[FINISH] [datetime] NOT NULL CONSTRAINT [DF__POLYPRCPR__FINIS__38767392] DEFAULT ('9999.12.31 23:59:59'),
[RTLPRCDISCNT] [decimal] (5, 2) NOT NULL CONSTRAINT [DF__POLYPRCPR__RTLPR__396A97CB] DEFAULT (0),
[MBRPRCDISCNT] [decimal] (5, 2) NOT NULL CONSTRAINT [DF__POLYPRCPR__MBRPR__3A5EBC04] DEFAULT (0),
[PREC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__POLYPRCPRM__PREC__3B52E03D] DEFAULT (0.01),
[ROUNDTYPE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__POLYPRCPR__ROUND__3C470476] DEFAULT ('四舍五入')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[POLYPRCPRMDTLDTL] ADD CONSTRAINT [PK__POLYPRCPRMDTLDTL__3D3B28AF] PRIMARY KEY CLUSTERED  ([NUM], [LINE], [ITEM]) ON [PRIMARY]
GO
