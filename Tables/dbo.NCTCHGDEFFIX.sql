CREATE TABLE [dbo].[NCTCHGDEFFIX]
(
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FIXMETHOD] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[AMOUNT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__NCTCHGDEF__AMOUN__05E95D17] DEFAULT (0),
[FEETOSTORE] [smallint] NOT NULL CONSTRAINT [DF__NCTCHGDEF__FEETO__06DD8150] DEFAULT (0),
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCHGDEFFIX] ADD CONSTRAINT [PK__NCTCHGDEFFIX__07D1A589] PRIMARY KEY CLUSTERED  ([SRC], [ID], [CODE]) ON [PRIMARY]
GO
