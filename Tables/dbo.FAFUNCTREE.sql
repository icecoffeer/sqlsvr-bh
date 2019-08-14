CREATE TABLE [dbo].[FAFUNCTREE]
(
[PRODUCT] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NODENO] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NODETYPE] [smallint] NOT NULL CONSTRAINT [DF__FAFUNCTRE__NODET__0DDEB943] DEFAULT (0),
[FATHERNODENO] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[NODENAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ORDERNUM] [int] NOT NULL,
[ISSHOW] [smallint] NOT NULL CONSTRAINT [DF__FAFUNCTRE__ISSHO__0ED2DD7C] DEFAULT (1),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__FAFUNCTREE__TAG__0FC701B5] DEFAULT (0),
[FUNCGRP] [varchar] (120) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__FAFUNCTRE__FUNCG__10BB25EE] DEFAULT ('-')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[FAFUNCTREE] ADD CONSTRAINT [PK__FAFUNCTREE__11AF4A27] PRIMARY KEY CLUSTERED  ([PRODUCT], [NODENO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_FAFUNCTREEBRANCH] ON [dbo].[FAFUNCTREE] ([PRODUCT], [FATHERNODENO]) ON [PRIMARY]
GO
