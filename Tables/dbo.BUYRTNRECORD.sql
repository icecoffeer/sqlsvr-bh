CREATE TABLE [dbo].[BUYRTNRECORD]
(
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [varchar] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [int] NOT NULL,
[BCKQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUYRTNREC__BCKQT__4783ACF8] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUYRTNRECORD] ADD CONSTRAINT [PK__BuyRtnRecord__4877D131] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO