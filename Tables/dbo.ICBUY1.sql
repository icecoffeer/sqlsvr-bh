CREATE TABLE [dbo].[ICBUY1]
(
[STORE] [int] NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SETTLENO] [int] NOT NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__ICBUY1__FILDATE__2D3E5D50] DEFAULT (getdate()),
[CASHIER] [int] NOT NULL CONSTRAINT [DF__ICBUY1__CASHIER__2E328189] DEFAULT (1),
[WRH] [int] NOT NULL CONSTRAINT [DF__ICBUY1__WRH__2F26A5C2] DEFAULT (1),
[ASSISTANT] [int] NULL,
[TOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICBUY1__TOTAL__301AC9FB] DEFAULT (0),
[REALAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICBUY1__REALAMT__310EEE34] DEFAULT (0),
[PREVAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__ICBUY1__PREVAMT__3203126D] DEFAULT (0),
[GUEST] [int] NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__ICBUY1__RECCNT__32F736A6] DEFAULT (0),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TAG] [smallint] NOT NULL CONSTRAINT [DF__ICBUY1__TAG__33EB5ADF] DEFAULT (0),
[INVNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SCORE] [decimal] (24, 2) NULL,
[SENDTIME] [datetime] NULL,
[SENDER] [int] NULL,
[RCVTIME] [datetime] NULL,
[CARDCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ICBUY1] ADD CONSTRAINT [PK__ICBUY1__2C4A3917] PRIMARY KEY CLUSTERED  ([STORE], [POSNO], [FLOWNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO