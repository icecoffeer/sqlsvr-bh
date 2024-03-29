CREATE TABLE [dbo].[PREORDPOOLDTL]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDGID] [int] NOT NULL,
[RTLQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__RTLQT__50AAC27A] DEFAULT (0),
[PRICE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__PRICE__519EE6B3] DEFAULT (0),
[REALAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__REALA__52930AEC] DEFAULT (0),
[RTLBACKQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__RTLBA__53872F25] DEFAULT (0),
[PREORDQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__PREORDPOO__PREOR__547B535E] DEFAULT (0),
[REMARK] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PREORDPOOLDTL] ADD CONSTRAINT [PK__PREORDPOOLDTL__556F7797] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO], [GDGID]) ON [PRIMARY]
GO
