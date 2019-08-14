CREATE TABLE [dbo].[BCKEXPFEE]
(
[VDRGID] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL,
[CYCLEID] [int] NOT NULL,
[EXPAMT] [decimal] (24, 2) NOT NULL,
[EXPRATE] [decimal] (24, 4) NOT NULL,
[PROCAMT] [decimal] (24, 2) NOT NULL,
[PAYSTAT] [int] NULL,
[EXPDAYS] [int] NULL,
[EXPPAYAMT] [decimal] (24, 2) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BCKEXPFEE] ADD CONSTRAINT [PK__BCKEXPFEE__0DE8DAE4] PRIMARY KEY CLUSTERED  ([VDRGID], [CYCLEID]) ON [PRIMARY]
GO
