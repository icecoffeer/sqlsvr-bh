CREATE TABLE [dbo].[NTJ]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[Type] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Code] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Name] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[Remark] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[QtyName] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[AmtName] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[QtyUnit] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NTJ__QtyUnit__5882851A] DEFAULT (1),
[AmtUnit] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NTJ__AmtUnit__5976A953] DEFAULT (1),
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NTJ] ADD CONSTRAINT [PK__NTJ__5A6ACD8C] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO
