CREATE TABLE [dbo].[BCKDMDDTLDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[CASENUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[CASES] [decimal] (24, 4) NULL,
[QTY] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BCKDMDDTLDTL] ADD CONSTRAINT [PK__BCKDMDDTLDTL__3CD8D3F7] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO
