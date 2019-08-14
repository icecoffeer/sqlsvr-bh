CREATE TABLE [dbo].[cwjkb]
(
[FilDate] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSLayer] [smallint] NOT NULL,
[POSDEPT] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPTCode] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPTName] [char] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DEPLayer] [smallint] NOT NULL,
[RealAmt] [money] NOT NULL CONSTRAINT [DF__cwjkb__RealAmt__6F6B4809] DEFAULT (0),
[IsUpdate] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
CREATE UNIQUE NONCLUSTERED INDEX [cwjkb_idx] ON [dbo].[cwjkb] ([FilDate], [POSDEPT], [DEPTCode]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
