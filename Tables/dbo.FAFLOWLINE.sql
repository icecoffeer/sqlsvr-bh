CREATE TABLE [dbo].[FAFLOWLINE]
(
[UUID] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[FOBJSRC] [int] NOT NULL CONSTRAINT [DF__FAFLOWLIN__FOBJS__2986D3B8] DEFAULT (0),
[FOBJDST] [int] NOT NULL CONSTRAINT [DF__FAFLOWLIN__FOBJD__2A7AF7F1] DEFAULT (0),
[FPTCOUNT] [int] NOT NULL,
[FCOLOR] [int] NOT NULL,
[FPTSRC] [int] NOT NULL,
[FPTDST] [int] NOT NULL,
[FSTYLE] [int] NOT NULL,
[FPARFONT] [int] NOT NULL CONSTRAINT [DF__FAFLOWLIN__FPARF__2B6F1C2A] DEFAULT (0),
[FTEXT] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FLINEWIDTH] [int] NOT NULL CONSTRAINT [DF__FAFLOWLIN__FLINE__2C634063] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFLOWLINE] ADD CONSTRAINT [PK__FAFLOWLINE__2D57649C] PRIMARY KEY CLUSTERED  ([UUID], [ITEMNO]) ON [PRIMARY]
GO
