CREATE TABLE [dbo].[TERMPOOL2]
(
[ID] [int] NOT NULL,
[TERMNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[WRHCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[INPUTER] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[GCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__TERMPOOL2__FILDA__1D9CF264] DEFAULT (getdate()),
[QTY] [money] NOT NULL CONSTRAINT [DF__TERMPOOL2__QTY__1E91169D] DEFAULT (0),
[PRICE] [money] NOT NULL CONSTRAINT [DF__TERMPOOL2__PRICE__1F853AD6] DEFAULT (0),
[AMOUNT] [money] NOT NULL CONSTRAINT [DF__TERMPOOL2__AMOUN__20795F0F] DEFAULT (0),
[SUBWRHCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__TERMPOOL2__SUBWR__18DB6AA3] DEFAULT (1)
) ON [PRIMARY]
GO