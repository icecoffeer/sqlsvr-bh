CREATE TABLE [dbo].[spcode]
(
[id] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gg] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[sh] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL,
[dw] [varchar] (2) COLLATE Chinese_PRC_CI_AS NULL,
[xx] [int] NULL,
[gid] [int] NOT NULL CONSTRAINT [DF__spcode__gid__51A6A64F] DEFAULT (0),
[inprc] [money] NOT NULL CONSTRAINT [DF__spcode__inprc__529ACA88] DEFAULT (0),
[rtlprc] [money] NOT NULL CONSTRAINT [DF__spcode__rtlprc__538EEEC1] DEFAULT (0),
[sale] [smallint] NOT NULL CONSTRAINT [DF__spcode__sale__548312FA] DEFAULT (0),
[billto] [int] NOT NULL CONSTRAINT [DF_spcode_billto] DEFAULT (0),
[sort] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
