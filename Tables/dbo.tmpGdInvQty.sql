CREATE TABLE [dbo].[tmpGdInvQty]
(
[Code] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[Name] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[TAXRATE] [decimal] (24, 4) NULL,
[F1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[IsLtd] [smallint] NULL,
[Sale] [smallint] NULL,
[Wrh] [int] NULL,
[Gid] [int] NULL,
[InvQty] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
