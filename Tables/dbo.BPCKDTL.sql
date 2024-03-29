CREATE TABLE [dbo].[BPCKDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NULL,
[STAT] [smallint] NULL CONSTRAINT [DF__BPCKDTL__STAT__5ACF527F] DEFAULT (0),
[GDGID] [int] NULL,
[QTY] [money] NULL CONSTRAINT [DF__BPCKDTL__QTY__5BC376B8] DEFAULT (0),
[TOTAL] [money] NULL CONSTRAINT [DF__BPCKDTL__TOTAL__5CB79AF1] DEFAULT (0),
[CKNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CKLINE] [smallint] NULL,
[subwrh] [int] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BPCKDTL] ADD CONSTRAINT [PK__BPCKDTL__1A69E950] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [bpckdtl_gdgid] ON [dbo].[BPCKDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
