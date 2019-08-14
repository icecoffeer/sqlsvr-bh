CREATE TABLE [dbo].[VDRBEPADJDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[STOREGID] [int] NOT NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VDRBEPADJ__TOTAL__1FB5B2C0] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRBEPADJDTL] ADD CONSTRAINT [PK__VDRBEPADJDTL__20A9D6F9] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO