CREATE TABLE [dbo].[CTCHGDEFFIX]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FIXMETHOD] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__CTCHGDEFF__AMOUN__1AE217F8] DEFAULT (0),
[FEETOSTORE] [smallint] NOT NULL CONSTRAINT [DF__CTCHGDEFF__FEETO__741D5092] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCHGDEFFIX] ADD CONSTRAINT [PK__CTCHGDEFFIX__1BD63C31] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO