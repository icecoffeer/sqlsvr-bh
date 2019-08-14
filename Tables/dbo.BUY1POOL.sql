CREATE TABLE [dbo].[BUY1POOL]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__BUY1POOL__FILDAT__4D9A16FC] DEFAULT (getdate()),
[CASHIER] [int] NOT NULL CONSTRAINT [DF__BUY1POOL__CASHIE__4E8E3B35] DEFAULT (1),
[WRH] [int] NOT NULL CONSTRAINT [DF__BUY1POOL__WRH__4F825F6E] DEFAULT (1),
[ASSISTANT] [int] NULL,
[TOTAL] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY1POOL__TOTAL__507683A7] DEFAULT (0),
[REALAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY1POOL__REALAM__516AA7E0] DEFAULT (0),
[PREVAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__BUY1POOL__PREVAM__525ECC19] DEFAULT (0),
[GUEST] [int] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__BUY1POOL__RECCNT__5352F052] DEFAULT (0),
[MEMO] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TAG] [smallint] NOT NULL CONSTRAINT [DF__BUY1POOL__TAG__5447148B] DEFAULT (0),
[INVNO] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[SCORE] [decimal] (24, 4) NULL,
[CARDCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[DEALER] [int] NULL,
[FLAG] [int] NOT NULL CONSTRAINT [DF__BUY1POOL__FLAG__553B38C4] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUY1POOL] ADD CONSTRAINT [PK__BUY1POOL__562F5CFD] PRIMARY KEY CLUSTERED  ([FLOWNO], [POSNO]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[BUY1POOL] ([FILDATE]) ON [PRIMARY]
GO
