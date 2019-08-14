CREATE TABLE [dbo].[NICBUY1]
(
[STORE] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NICBUY1__FILDATE__42397A36] DEFAULT (getdate()),
[CASHIER] [int] NOT NULL CONSTRAINT [DF__NICBUY1__CASHIER__432D9E6F] DEFAULT (1),
[WRH] [int] NOT NULL CONSTRAINT [DF__NICBUY1__WRH__4421C2A8] DEFAULT (1),
[ASSISTANT] [int] NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY1__TOTAL__4515E6E1] DEFAULT (0),
[REALAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY1__REALAMT__460A0B1A] DEFAULT (0),
[PREVAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NICBUY1__PREVAMT__46FE2F53] DEFAULT (0),
[GUEST] [int] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__NICBUY1__RECCNT__47F2538C] DEFAULT (0),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TAG] [smallint] NOT NULL CONSTRAINT [DF__NICBUY1__TAG__48E677C5] DEFAULT (0),
[INVNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SCORE] [decimal] (24, 2) NULL,
[SENDER] [int] NULL,
[RCVTIME] [datetime] NULL,
[CARDCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[NNOTE] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RCV] [int] NULL,
[SNDTIME] [datetime] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NICBUY1] ADD CONSTRAINT [PK__NICBUY1__414555FD] PRIMARY KEY CLUSTERED  ([SRC], [ID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO